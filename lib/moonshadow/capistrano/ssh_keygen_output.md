dwestendorf@HLY24411VM2:~$ cap SSH

Username for SSH: dwestendorf

Hostname or IP address of remote server: mynewserver
  * executing `SSH'
  * executing `SSH:keygen'
Generating public/private rsa key pair.

Enter file in which to save the key (/home/dwestendorf/.ssh/id_rsa): 

Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 

Your identification has been saved in /home/dwestendorf/.ssh/id_rsa.
Your public key has been saved in /home/dwestendorf/.ssh/id_rsa.pub.

The key fingerprint is:
58:55:5c:b5:03:90:65:00:94:11:9a:42:5b:71:0e:c8 dwestendorf@HLY24411VM2
The key's randomart image is:
+--[ RSA 2048]----+
|    ...+o**=*=...|
|    .Eo *o .o . .|
|     o o..     o |
|      .o        .|
|      . S  !     |
|   . .   .       |
|                 |
|                 |
|                 |
+-----------------+

  * executing `SSH:sendFile'
The authenticity of host 'mynewserver (192.168.1.100)' can't be established.
RSA key fingerprint is 11:88:b8:3i:a2:ca:06:c4:u5:3a:bb:e0:6d:6c:bf:l2.
Are you sure you want to continue connecting (yes/no)? yes

Warning: Permanently added 'mynewserver' (RSA) to the list of known hosts.
dwestendorf@mynewserver's password: 
id_rsa.pub                                    100%  405     0.4KB/s   00:00    
  * executing `SSH:checkDirectory'
  * executing "ls -a ~/.ssh"
    servers: ["mynewserver"]
Password: 
    [dwestendorf@mynewserver] executing command
 ** [out :: dwestendorf@mynewserver] .
 ** [out :: dwestendorf@mynewserver] ..
 ** [out :: dwestendorf@mynewserver] authorized_keys
    command finished
  * executing `SSH:checkFile'
  * executing "ls -a ~/.ssh/authorized_keys"
    servers: ["mynewserver"]
    [dwestendorf@mynewserver] executing command
 ** [out :: dwestendorf@mynewserver] /home/dwestendorf/.ssh/authorized_keys
    command finished
  * executing `SSH:appendKeys'
  * executing "cat ~/id_rsa.pub >> ~/.ssh/authorized_keys"
    servers: ["mynewserver"]
    [dwestendorf@mynewserver] executing command
    command finished
  * executing "rm ~/id_rsa.pub"
    servers: ["mynewserver"]
    [dwestendorf@mynewserver] executing command
    command finished
dwestendorf@HLY24411VM2:~$ ssh mynewserver
Last login: Mon Oct  5 10:24:51 2009 from 192.168.1.102
[dwestendorf@mynewserver ~]$ exit
logout

Connection to mynewserver closed.
