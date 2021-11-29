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

