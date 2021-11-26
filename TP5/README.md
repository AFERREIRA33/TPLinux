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

## Setup web <a name="p2"></a>