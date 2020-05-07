---
layout: post
title: Introduction to Code Review
---

> From PentesterLab.com

## Reasons for doing code review
* It can be faster than penetration testing. Some issues are really easy to spot during a code review (for example weak encryption), where others can take a lot more time (XSS for example).
* Compliance can require you to perform security code review (for example as part of PCI DSS 6.3.2).
* After doing penetration testing for a while; you want to do something different.
* You want to find better bugs. Some of the bugs you will find during a code review can be surprisingly hard to discover with black-box testing.
* You want to check if some code is backdoored (it's actually really hard to do).
* You want to write an exploit for a bug.

## Methodologies
There are plenty of ways to perform code review. Here are some of the core methods:

* String matching/Grep for bugs.
* Following user input.
* Reading source code randomly.
* Read all the code.
* Check one functionality at a time (login, password reset...).

### String matching/Grep for bugs
This is probably the fastest way to find low-hanging fruits; you just try to find patterns of known vulnerabilities. For example, you can use grep to find calls to the PHP system function:
```shell
$ grep -R 'system\(\$_' *
```
You can find a list of regular expressions to try on your code base in the GRaudit project (https://github.com/wireghoul/graudit).

This approach suffers from a lot of limitations:

* You don't get a lot of coverage/assurance on the quality (and therefore security) of the source code. You just know that based on your list of patterns, you couldn't find any issues.
* You need to know of all the dangerous functions/patterns.
* You end up using very complex regular expressions.
This approach works pretty well for timeboxed reviews where you don't have enough time. It can also help you get familiar with a code base as part of a longer review. However, it's probably not the best way to perform proper reviews.

### Following user inputs
Another way to go about doing a review is to follow all the user-controlled inputs and find all ways to access the application (the routes/URI available)

To get started you need to find all the ways to provide data to the application (example in PHP):

* `$_POST` / `$_GET` / `$_REQUEST`
* `$_COOKIE` / `$_SERVER`
* Data coming from the database (for stored XSS and second-order injections for example)
* Data read from a file or a cache
* ...

This method provides good coverage. However, you will need a good understanding of the framework/language used. Finally, you may end up reviewing the same function again and again if it's called multiple times.

### By functionality
Another common way to do a review is to pick one functionality, for example:

* "Password reset".
* "Database access".
* "Authentication".
And review all the code associated with this functionality. This work especially well if you do this across multiple applications/framework as they will all have different behaviors.

This approach gives you an excellent coverage for the functionalities your reviewed and will teach you what mistake people usually make for a given functionality. However, you only have coverage of what you reviewed.

### Read everything
Finally, the more time-consuming way: just start reading the code one file at the time. A better ways to do this is to try to find weaknesses, not vulnerabilities. Then trying to see if the weaknesses can become vulnerabilities on their own or by combining them.

This method is obviously the most laborious way of working but it brings excellent coverage. It's crucial to keep good notes when using this approach.

## What to look for?
When doing a review, you need to look for everything:

* Weird behavior
* Missing checks
* Complexity
* Security checks already in place
* Differences between 2 functions/methods/classes
* Comparison and conditions (if/else)
* Regular expressions/string matching
* What is missing?

You will probably end up seeing function/class/method you don't know. To solve this issue, you need to

* Google it
* Test its’ behavior

It’s going to take time (especially early on) but the more code you review, the easier it gets. Make sure you create a snippet with the function/class/method to test its' behavior. It will be convenient for your future reviews. To test it, you need to run it locally and try to find some edge cases that the developers may have missed.

## Hands-on
We are given a simple PHP web application to clone from GitHub: [cr](https://github.com/PentesterLab/cr). The application is a straightforward application with a dozen security issues. As a user, you can only Register/Login/Logout and Upload/Retrieve files.


We are also told to start with the "Read everything" approach since there are only 13 files, and to look for the following weaknesses:
* Hardcoded credentials or secrets
* Information leak
* Missing security flags
* Weak password hashing mechanism
* Cross-Site Scripting
* No CSRF protection
* Directory listing
* Crypto issue
* Signature bypass
* Authentication bypass
* Authorisation bypass
* Remote Code Execution

## Analysis

### header.php:
* If $user is not set, show login.php and register.php, else show logout.php.

### index.php:
* If not authorized, always redirected to login.php.
* If the $_COOKIE['auth'] is set, the $user is set from the cookie!
	* We could spoof an admin or any user account.
* If $_POST["submit"] is set, $error is set to the output of `User::addfile($user)`
	* later on, if $error is set, it is echo'd with: `<?php echo $error; ?>`. Potential for injection!
* Through googling, I learn the `h()` function is from CakePHP and is a convenience wrapper for `htmlspecialchars()`. See: `<?php echo h($user); ?>`
	* Every time `h()` is used though, it's not sanitizing SQL Injection, just HTML special characters.
	* Edit: in phpfix.php, `h()` invokes: `call_user_func_array("htmlentities", func_get_args());`
* Gets every file for a user as $file from the directory `/files/h($user)/h($file)`.
* Has a form to submit pdf, but doesn't use the `accept` attribute to specify allowed mime-types. One could submit anything, including a malicious payload.

### footer.php:
* Nothing of note.

### login.php:
* So far no $_SESSION checks, seems to be relying on database interaction. If you log in and never close the page, you could potentially be logged in forever. No CSRF token!
* Format of "auth" cookie creation
  * `setcookie()` does not use the `secure` and `httpOnly` flags
```
setcookie("auth", User::createcookie($_POST['username'], $_POST['password']));
```

* Has a "Remember Me" checkbox, which doesn't appear to be hooked up to anything.

### logout.php:
* `User::logout();`
* `die()` does not kill session information.

### register.php:
* Relies on `User::register()` to create a new user, so we need to check User class to see if username duplicates are allowed.
* `setcookie()` does not use the `secure` and `httpOnly` flags
* Doesn't even check for HTML special characters; no input validation besides a strict checking if the two  password fields contents match. 

### deploy.sql:
* Hardcoded admin username and hashed passsword

```sql
create database cr;
use cr;
GRANT ALL PRIVILEGES ON cr.* TO pentesterlab@'localhost' IDENTIFIED BY 'pentesterlab';
create table users ( login VARCHAR(50) not null  primary key , password VARCHAR(50));

INSERT INTO `users` (login,password) VALUES ('admin','bcd86545c5903856961fa21b914c5fe4');
```

### .git directory
* One could rebuild the source code for the entire application.

### classes/db.php:
* Database name is `cr`, run on localhost.
```php
<?php
    $lnk = mysql_connect("127.0.0.1", "pentesterlab", "pentesterlab");
    $db = mysql_select_db('cr', $lnk);
?>
```

### classes/phpfix.php:
* According to the benchmark [here](http://paul-m-jones.com/post/2005/09/22/benchmarking-call_user_func_array/), `call_user_func_array()` is nearly twice as slow as `htmlentities()`.
 ```php
<?php
  function h() {
    return call_user_func_array("htmlentities", func_get_args());
  }
?>
```

#### classes/jwt.php:
* Hardcoded secret (seed)
* Crypto issues
	* The actual signing of the JSON Web Token (JWT), is not per its specification in [RFC 7519](https://tools.ietf.org/html/rfc7519#section-11.2), and so will not be valid across other applications. **Signing must occur before encryption**.
> "While syntactically the signing and encryption operations for Nested JWTs may be applied in any order, if both signing and encryption are necessary, normally producers should sign the message and then encrypt the result (thus encrypting the signature). This prevents attacks in which the signature is stripped, leaving just an encrypted message, as well as providing privacy for the signer. Furthermore, signatures over encrypted text are not considered valid in many jurisdictions. 
> Note that potential concerns about security issues related to the order of signing and encryption operations are already addressed by the underlying JWS and JWE specifications; in particular, because JWE only supports the use of authenticated encryption algorithms, cryptographic concerns about the potential need to sign after encryption that apply in many contexts do not apply to this specification."
  * Hash instead of a HMAC, which would provide immunity against [length extension attacks](https://en.wikipedia.org/wiki/Length_extension_attack)
```php
public static function signature($data) {
	return hash("sha256","donth4ckmebr0".$data);
}
```

* Signature bypass
	* signature is only checked if it's provided in the auth token, and so is vulnerable to maliciously created tokens.
```php
public static function verify($auth) {
  list($h64,$d64,$sign) = explode(".",$auth);
  if (!empty($sign) and (JWT::signature($h64.".".$d64) != $sign)) {
    die("Invalid Signature");
  }
  $header = base64_decode($h64);
  $data = base64_decode($d64);
  return JWT::parse_json($data);
}
```

* Authentication bypass
	* For some reason there is a homebrew json parser instead of using `json_decode()` with a `RecursiveArrayIterator`. 
```php
public static function parse_json($str) {
  $data = explode(",",rtrim(ltrim($str, '{'), '}'));
  $ret = array();
  foreach($data as $entry) {
    list($key, $value) =  explode(":",$entry);
    $key = rtrim(ltrim($key, '"'), '"');
    $value = rtrim(ltrim($value, '"'), '"');
    $ret[$key] = $value;
  }
  return $ret;
}
```

* Per user.php, the $data passed into the following function `sign()` is just the username in an dictionary. With how the tokens are assembled here, you could become an admin in the application injecting through the username, e.g. `fakename","username":"admin`. 
```php
public static function sign($data) {
  $header = str_replace("=","",base64_encode('{"alg":"HS256","iat":'.time().'}'));
  $token = "{";
  foreach($data as $key=>$value) {
    $token.= '"'.$key.'":"'.$value.'",';
  }
  $token .= "}";
  $to_sign = $header.".".base64_encode($token);
  return $to_sign.".".JWT::signature($to_sign);
}
```

#### classes/user.php:
* Weak password hashing mechanism
	* md5
	* Not seeded
	* Hashing done on backend, which could be logged in the DB or transmitted in cleartext between DB and app.
	* Recommendation: scrypt, bcrypt or PBKDF2
```php
public static function register($user, $password) {
    $sql = "INSERT INTO  users (login,password) values (\"";
    $sql.= mysql_real_escape_string($user);
    $sql.= "\", md5(\"";
    $sql.= mysql_real_escape_string($password);
    $sql.= "\"))";
    $result = mysql_query($sql);
    if ($result) {
      return TRUE;
    }
    else
      echo mysql_error();
    return FALSE;
    //die("invalid username/password");
}
```
* Directory listing
	* Lists files in `files/[USERNAME]` and removes the parent and current directory from the list with `array_diff`. But since you can register users named `..`, `../..`, `../admin`, etc, you can look at any part of the server hosting the application.
```php
public static function getfiles($user) {
  $base = "files/".$user;
  if (!file_exists($base)) {
    mkdir($base);
  }
  return array_diff(scandir($base), array('..', '.'));
}
```

* Authorization bypass
	* Uploaded files get saved in the `/files/[USER]/[FILENAME]` directory, and unless the filenames are hashed in some way, an attacker can bruteforce guessing usernames and filenames.
* Remote Code Execution
	* PDF validation is done in the same function with a `preg_match("/\.pdf/", $file)`. This only checks if the filename includes `.pdf`, which could be bypassed easily by naming files like `malicious.pdf.php`. As a `.php` file in the web root, it will get executed when accessed by the attacker. Correct usage to match end of filename string: `preg_match("/\.pdf$/", $file)`.
```php
public static function addfile($user) {
  $file = "files/".$user."/".basename($_FILES["file"]["name"]);
  if (!preg_match("/\.pdf/", $file)) {
    return  "Only PDF are allowed";
  } elseif (!move_uploaded_file($_FILES["file"]["tmp_name"], $file)) {
    return "Sorry, there was an error uploading your file.";
  }
  return NULL;
}
```