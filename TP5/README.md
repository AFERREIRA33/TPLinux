# TP5 : P'tit cloud perso

## Sommaire

- [Setup DB](#p1)
    - [Installer MariaDB sur la machine db.tp5.linux](#p11)
    - [Le service MariaDB](#p12)
    - [Firewall](#p13)
    - [Configuration élémentaire de la base](#p14)
    - [Préparation de la base en vue de l'utilisation par NextCloud](#p15)
    - [Installez sur la machine web.tp5.linux la commande mysql](#p16)
    - [Tester la connexion](#p17)
- [Setup Web](#p2)
    - [Installer Apache sur la machine web.tp5.linux](#p21)
    - [Analyse du service Apache](#p22)
    - [Un premier test](#p23)
    - [Installer PHP](#p24)
    - [Analyser la conf Apache](#p25)
    - [Créer un VirtualHost qui accueillera NextCloud](#p26)
    - [Configurer PHP](#p27)
    - [Récupérer Nextcloud](#p28)
    - [Ranger la chambre](#p29)
    - [Modifiez le fichier hosts de votre PC](#p210)
    - [Tester l'accès à NextCloud et finaliser son install'](#p211)

## Setup DB <a name="p1"></a>

### Installer MariaDB sur la machine db.tp5.linux <a name="p11"></a>

```bash
[xouxou@localhost ~]$ sudo dnf install mariadb-server
Rocky Linux 8 - AppStream                                                                13 kB/s | 4.8 kB     00:00
Rocky Linux 8 - BaseOS                                                                   12 kB/s | 4.3 kB     00:00
Rocky Linux 8 - Extras                                                                  9.5 kB/s | 3.5 kB     00:00
Dependencies resolved.
[...]
Complete!
[xouxou@localhost ~]$ sudo dnf install mariadb
Last metadata expiration check: 0:03:34 ago on Thu 25 Nov 2021 11:47:25 AM CET.
Package mariadb-3:10.3.28-1.module+el8.4.0+427+adf35707.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```

### Le service MariaDB <a name="p12"></a>

MariaDb s'active :
```bash
[xouxou@localhost ~]$ sudo systemctl status mariadb
[sudo] password for xouxou:
● mariadb.service - MariaDB 10.3 database server
   Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2021-11-25 11:52:12 CET; 7min ago
[...]
```
MariaDB écoute sur sur le port 3306 :
```bash
[xouxou@localhost ~]$ ss -lntr
State         Recv-Q        Send-Q               Local Address:Port               Peer Address:Port       Process
LISTEN        0             128                        0.0.0.0:22                      0.0.0.0:*
LISTEN        0             80                               *:3306                          *:*
LISTEN        0             128                           [::]:22                         [::]:*
[xouxou@localhost ~]$ ss -tulp
Netid      State       Recv-Q      Send-Q           Local Address:Port              Peer Address:Port      Process
[...]
tcp        LISTEN      0           128                    0.0.0.0:ssh                    0.0.0.0:*
tcp        LISTEN      0           80                           *:mysql                        *:*
tcp        LISTEN      0           128                       [::]:ssh                       [::]:*
```
MariaDB est lancé par l'utilisateur mysql :
```bash
[xouxou@localhost ~]$ sudo systemctl status mariadb
Nov 25 11:52:11 db.tp5.linux mysqld[8631]: 2021-11-25 11:52:11 0 [Note] /usr/libexec/mysqld (mysqld 10.3.28-MariaDB) starting as process 8631 ...
[...]
[xouxou@localhost ~]$ ps -ef | grep mysql
mysql       8631       1  0 11:52 ?        00:00:00 /usr/libexec/mysqld --basedir=/usr
```

### Firewall <a name="p13"></a>

```bash
[xouxou@localhost ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[xouxou@localhost ~]$ sudo firewall-cmd --reload
success
[xouxou@localhost ~]$ sudo firewall-cmd --list-all
public (active)
[...]
  ports: 3306/tcp
[...]
```

### Configuration élémentaire de la base <a name="p14"></a>

```bash
[xouxou@localhost ~]$ mysql_secure_installation

[...]
# Pour donner un mot de passe à root donc augmente la sécurité
Set root password? [Y/n] y

New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!

[...]
# de base MariaDb créer un utilisateur qui sert  à faire des tests avec des droits d'admin,
# en répondant oui je supprime cet utilisateur qui pose probleme car il est facile de s'y connecter
Remove anonymous users? [Y/n] y
 ... Success!


[...]
# Pour faire en sorte que root ne puisse se connecter que sur le réseau local
#se qui permet d'éviter les connexions extérieurs indéiré
Disallow root login remotely? [Y/n] y
 ... Success!

[...]
# supprime la base de donnée créée automatiquement par MariaDB
Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.
[...]
# relance la table de priviège pour mettre nos modifictions à jour
Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!

```

### Préparation de la base en vue de l'utilisation par NextCloud <a name="p15"></a>

```bash
[xouxou@localhost ~]$ sudo mysql -u root -p
[sudo] password for xouxou:
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 16
Server version: 10.3.28-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'nextcloud'@'10.5.1.11' IDENTIFIED BY 'meow';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.5.1.11';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)
```

### Installez sur la machine web.tp5.linux la commande mysql <a name="p16"></a>

```bash
[xouxou@web ~]$ sudo dnf install 8.0.26-1.module+el8.4.0+652+6de068a7
[sudo] password for xouxou:
Rocky Linux 8 - AppStream                                                                12 kB/s | 4.8 kB     00:00
Rocky Linux 8 - BaseOS                                                                   12 kB/s | 4.3 kB     00:00
Rocky Linux 8 - Extras                                                                  9.8 kB/s | 3.5 kB     00:00
No match for argument: 8.0.26-1.module+el8.4.0+652+6de068a7
Error: Unable to find a match: 8.0.26-1.module+el8.4.0+652+6de068a7
[xouxou@web ~]$ dnf provides mysql
Last metadata expiration check: 0:05:56 ago on Thu 25 Nov 2021 12:24:02 PM CET.
mysql-8.0.26-1.module+el8.4.0+652+6de068a7.x86_64 : MySQL client programs and shared libraries
Repo        : appstream
Matched from:
Provide    : mysql = 8.0.26-1.module+el8.4.0+652+6de068a7

[xouxou@web ~]$ sudo dnf install mysql-8.0.26-1.module+el8.4.0+652+6de068a7.x86_64
Last metadata expiration check: 0:01:57 ago on Thu 25 Nov 2021 12:29:47 PM CET.
Dependencies resolved.
[...]
Complete!
```

### Tester la connexion <a name="p17"></a>

```bash
[xouxou@web ~]$ mysql -u nextcloud -h 10.5.1.12 -P 3306 -D nextcloud -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
[...]

mysql> SHOW TABLES;
Empty set (0.00 sec)
```

## Setup web <a name="p2"></a>

### Installer Apache sur la machine web.tp5.linux <a name="p21"></a>

```bash
[xouxou@web ~]$ sudo dnf install httpd
[sudo] password for xouxou:
Last metadata expiration check: 20:46:14 ago on Thu 25 Nov 2021 12:29:47 PM CET.
Dependencies resolved.
[...]
Complete!
```

### Analyse du service Apache <a name="p22"></a>

- Lancement du service et l'activer au démarrage
```bash
[xouxou@web ~]$ sudo systemctl start httpd
[xouxou@web ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[xouxou@web ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2021-11-26 09:19:47 CET; 25s ago
```
- Procesus liés au service httpd 
```bash
[xouxou@web ~]$ ps -ef | grep httpd
root        1988       1  0 09:19 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1989    1988  0 09:19 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1990    1988  0 09:19 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1991    1988  0 09:19 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1992    1988  0 09:19 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```
- Port d'écoute : 80
```bash
[xouxou@web ~]$ ss -lntr
State         Recv-Q        Send-Q               Local Address:Port               Peer Address:Port       Process
LISTEN        0             128                        0.0.0.0:22                      0.0.0.0:*
LISTEN        0             128                              *:80                            *:*
LISTEN        0             128                           [::]:22                         [::]:*
[xouxou@web ~]$ ss -tulp
Netid      State       Recv-Q      Send-Q            Local Address:Port             Peer Address:Port      Process
[...]
tcp        LISTEN      0           128                     0.0.0.0:ssh                   0.0.0.0:*
tcp        LISTEN      0           128                           *:http                        *:*
tcp        LISTEN      0           128                        [::]:ssh                      [::]:*
```
- Apache lance le porcessus 
```bash
[xouxou@web ~]$ ps -ef | grep httpd
root        1988       1  0 09:19 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1989    1988  0 09:19 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1990    1988  0 09:19 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1991    1988  0 09:19 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1992    1988  0 09:19 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

### Installer PHP <a name="p23"></a>

```bash
[xouxou@web ~]$ sudo dnf install epel-release
Last metadata expiration check: 21:02:20 ago on Thu 25 Nov 2021 12:29:47 PM CET.
Dependencies resolved.
[...]
Complete!
[xouxou@web ~]$ sudo dnf update
Extra Packages for Enterprise Linux 8 - x86_64                                          7.4 MB/s |  11 MB     00:01
Extra Packages for Enterprise Linux Modular 8 - x86_64                                  766 kB/s | 958 kB     00:01
Last metadata expiration check: 0:00:01 ago on Fri 26 Nov 2021 09:32:25 AM CET.
Dependencies resolved.
Nothing to do.
Complete!
[xouxou@web ~]$ sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
Last metadata expiration check: 0:00:18 ago on Fri 26 Nov 2021 09:32:25 AM CET.
remi-release-8.rpm                                                                      145 kB/s |  26 kB     00:00
Dependencies resolved.
[...]
Complete!
[xouxou@web ~]$ sudo dnf module enable php:remi-7.4
Remi's Modular repository for Enterprise Linux 8 - x86_64                               2.5 kB/s | 858  B     00:00
Remi's Modular repository for Enterprise Linux 8 - x86_64                               3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0x5F11735A:
[...]
Complete!
[xouxou@web ~]$ sudo dnf install zip unzip libxml2 openssl php74-php php74-php-ctype php74-php-curl php74-php-gd php74-php-iconv php74-php-json php74-php-libxml php74-php-mbstring php74-php-openssl php74-php-posix php74-php-session php74-php-xml php74-php-zip php74-php-zlib php74-php-pdo php74-php-mysqlnd php74-php-intl php74-php-bcmath php74-php-gmp
Last metadata expiration check: 0:00:18 ago on Fri 26 Nov 2021 09:33:11 AM CET.
Package zip-3.0-23.el8.x86_64 is already installed.
Package unzip-6.0-45.el8_4.x86_64 is already installed.
Package libxml2-2.9.7-11.el8.x86_64 is already installed.
Package openssl-1:1.1.1k-4.el8.x86_64 is already installed.
Dependencies resolved.
[...]
Complete!
```

### Analyser la conf Apache <a name="p24"></a>

```bash
[xouxou@web ~]$ cat /etc/httpd/conf/httpd.conf | grep "conf.d"
# Load config files in the "/etc/httpd/conf.d" directory, if any.
IncludeOptional conf.d/*.conf
```

### Créer un VirtualHost qui accueillera NextCloud <a name="p25"></a>

```bash
[xouxou@web conf.d]$ sudo nano nextcloud.conf
[xouxou@web conf.d]$ sudo systemctl restart httpd
[xouxou@web conf.d]$ cat nextcloud.conf
<VirtualHost *:80>
  DocumentRoot /var/www/nextcloud/html/
  ServerName  web.tp5.linux

  <Directory /var/www/nextcloud/html/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews

    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

### Configurer la racine web <a name="p26"></a>

```bash
[xouxou@web conf.d]$ sudo mkdir /var/www/nextcloud
[sudo] password for xouxou:
[xouxou@web conf.d]$ sudo mkdir /var/www/nextcloud/html

[xouxou@web conf.d]$ sudo chown apache /var/www/nextcloud
[xouxou@web conf.d]$ ls -l /var/www/
[...]
drwxr-xr-x. 3 apache root 18 Nov 26 10:04 nextcloud
[xouxou@web conf.d]$ sudo chown apache /var/www/nextcloud/html
[xouxou@web conf.d]$ ls -l /var/www/nextcloud
total 0
drwxr-xr-x. 2 apache root 6 Nov 26 10:04 h
```

### Configurer PHP <a name="p27"></a>

```bash
[xouxou@web conf.d]$ timedatectl
               Local time: Fri 2021-11-26 10:13:28 CET
           Universal time: Fri 2021-11-26 09:13:28 UTC
                 RTC time: Fri 2021-11-26 09:13:25
                Time zone: Europe/Madrid (CET, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no

[xouxou@web conf.d]$ sudo nano /etc/opt/remi/php74/php.ini
[xouxou@web conf.d]$ cat /etc/opt/remi/php74/php.ini | grep date.timezone
; http://php.net/date.timezone
date.timezone = "Europe/Madrid"
```

### Récupérer Nextcloud <a name="p28"></a>

```bash
[xouxou@web conf.d]$ cd
[xouxou@web ~]$ curl -SLO https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  148M  100  148M    0     0  5316k      0  0:00:28  0:00:28 --:--:-- 5520k
[xouxou@web ~]$ ls
nextcloud-21.0.1.zip

```

### Ranger la chambre <a name="p29"></a>

```bash

[xouxou@web ~]$ sudo chown -R apache /var/www/nextcloud/html/nextcloud/
[xouxou@web ~]$ unzip nextcloud-21.0.1.zip
[...]
 extracting: nextcloud/config/CAN_INSTALL
  inflating: nextcloud/config/config.sample.php
  inflating: nextcloud/config/.htaccess
[xouxou@web ~]$ ls
nextcloud  nextcloud-21.0.1.zip
[xouxou@web ~]$ sudo mv nextcloud /var/www/nextcloud/html/
[xouxou@web ~]$ ls /var/www/nextcloud/html/
nextcloud
[xouxou@web ~]$ rm nextcloud-21.0.1.zip


[xouxou@web ~]$ ls -al /var//www/nextcloud/html/
total 128
drwxr-xr-x. 13 apache xouxou  4096 Apr  8  2021 .
drwxr-xr-x.  3 apache root      23 Nov 26 10:27 ..
drwxr-xr-x. 43 apache xouxou  4096 Apr  8  2021 3rdparty
drwxr-xr-x. 47 apache xouxou  4096 Apr  8  2021 apps
-rw-r--r--.  1 apache xouxou 17900 Apr  8  2021 AUTHORS
[...]
[xouxou@web ~]$ ls -al /var//www/nextcloud/html/nextcloud/3rdparty/
total 256
drwxr-xr-x. 43 apache xouxou   4096 Apr  8  2021  .
drwxr-xr-x. 13 apache xouxou   4096 Apr  8  2021  ..
-rw-r--r--.  1 apache xouxou    178 Apr  8  2021  autoload.php
drwxr-xr-x.  3 apache xouxou     25 Apr  8  2021  aws
drwxr-xr-x.  3 apache xouxou     29 Apr  8  2021  bantu
drwxr-xr-x.  3 apache xouxou     20 Apr  8  2021  beberlei
drwxr-xr-x.  3 apache xouxou     18 Apr  8  2021  brick
drwxr-xr-x.  3 apache xouxou     23 Apr  8  2021  christophwurst
[...]
```

###  <a name="p210"></a>

```bash
$ cd c:/windows/system32/drivers/etc
$ sudo nano hosts
#       127.0.0.1       localhost
#       ::1             localhost
10.5.1.11 web.tp5.linux
```

### Tester l'accès à NextCloud et finaliser son install' <a name="p211"></a>

![Capture](./Capture.jpg)
