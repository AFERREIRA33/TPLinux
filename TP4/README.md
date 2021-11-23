# TP4 : Une distribution orientée serveur

## Sommaire 

-  [Checklist](#p2)
    - [Choisissez et définissez une IP à la VM](#p21)
    - [Connexion SSH fonctionnelle](#p22)
    - [Accès internet](#p23)
    - [Définissez node1.tp4.linux comme nom à la machine](#p24)
- [Mettre en place un service](#p3)
    - [Installez NGINX ](#p31)
    - [Analysez le service NGINX](#p32)
    - [Configurez le firewall](#p33)
    - [Tester le bon fonctionnement du service](#p34)
    - [Changer le port d'écoute](#p35)
    - [Changer l'utilisateur qui lance le service](#p36)
    - [Changer l'emplacement de la racine Web](#p37)

## Checklist <a name="p2"></a>

### Choisissez et définissez une IP à la VM <a name="p21"></a>

contenu du fichier de conf :
```bash
[xouxou@localhost ~]$ cat /etc//sysconfig/network-scripts/ifcfg-enp0s8
TYPE=ethernet
ONBOOT=yes
BOOTPROTO=static
IPADDR=10.200.1.30
NAME=enp0s8
DEVICE=enp0s8
NETMASK=255.255.255.0
```
vérification changement d'ip :
```bash
[xouxou@localhost ~]$ ip a
[...]
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:e8:8e:05 brd ff:ff:ff:ff:ff:ff
    inet 10.200.1.30/24 brd 10.200.1.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fee8:8e05/64 scope link
       valid_lft forever preferred_lft forever
```

### Connexion SSH fonctionnelle <a name="p22"></a>

service ssh actif :
```bash
[xouxou@localhost ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2021-11-23 11:00:57 CET; 30min ago
     Docs: man:sshd(8)
           man:sshd_config(5)
 Main PID: 867 (sshd)
    Tasks: 1 (limit: 4946)
   Memory: 3.9M
[...]
```
sur le pc : 
```bash
C:\Users\xouxo\.ssh>type id_rsa
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAACFwAAAAdzc2gtcn
NhAAAAAwEAAQAAAgEA08OCXbnDkMpSQKYyfmctk/d4ujZ+mxWmPHssoGNzD5h0ttjZo/uo
fpALzc3d9Bux7Y1PLT88DpeykQOMvV/A2bl50o0z6glO8bQfn1D8eh9ZRXbM1O8lE97YVg
WhOex0YcgNpXMRGvcCMiyKOLWBwCYZ+XO5a8D1+zXOmH5+WT6/PKwASW7cKktgfurAxXRD
/ap8xWYUtvf1Ko5gzXAF1UqIaIxeGLMfSB2D0GjdQoKD5wmQ8TmIsaNxtfaRviSPpyG9QX
8J+Ydgf5mPO1BD9AvsVoFsMdtOmLd7gZb2a+UWx7AaQ14xHjA+7o/+YgQ291tesr1rK3G8
+w1911MXoUnDLh1JqKcz7W6jS3YRQsZBYsPF3dLj7GSRpxBbd6YSSKoQvswoLmriZTh9gK
F9eWL1R+GY0uZsbBfMl9qhtoDRwNToiE0Xwz5g/y9ohDWGJm11bRA1TmBDQWGip1ThFaRy
sHTuPn/oD0j+vGQzL+xED7Z8KrtNZ6dOkS3dgsZ+f/V70cRM/qHJA87PzJyP0moZJqcIgM
8jyqH4vTtO0YnB1JA06Lan7C8xpClM4bYcqmqbFvXnvFWUJih1TiqpQZJ6pOcZMMTsDT/W
w8UL8BVDi/RGlsxf9YvQB2Y3vn4o40xjMCJri1p1btQU+dncq8vki3B1iKy9COA8cSKxpb
EAAAdQHwfQ4B8H0OAAAAAHc3NoLXJzYQAAAgEA08OCXbnDkMpSQKYyfmctk/d4ujZ+mxWm
PHssoGNzD5h0ttjZo/uofpALzc3d9Bux7Y1PLT88DpeykQOMvV/A2bl50o0z6glO8bQfn1
D8eh9ZRXbM1O8lE97YVgWhOex0YcgNpXMRGvcCMiyKOLWBwCYZ+XO5a8D1+zXOmH5+WT6/
PKwASW7cKktgfurAxXRD/ap8xWYUtvf1Ko5gzXAF1UqIaIxeGLMfSB2D0GjdQoKD5wmQ8T
mIsaNxtfaRviSPpyG9QX8J+Ydgf5mPO1BD9AvsVoFsMdtOmLd7gZb2a+UWx7AaQ14xHjA+
7o/+YgQ291tesr1rK3G8+w1911MXoUnDLh1JqKcz7W6jS3YRQsZBYsPF3dLj7GSRpxBbd6
YSSKoQvswoLmriZTh9gKF9eWL1R+GY0uZsbBfMl9qhtoDRwNToiE0Xwz5g/y9ohDWGJm11
bRA1TmBDQWGip1ThFaRysHTuPn/oD0j+vGQzL+xED7Z8KrtNZ6dOkS3dgsZ+f/V70cRM/q
HJA87PzJyP0moZJqcIgM8jyqH4vTtO0YnB1JA06Lan7C8xpClM4bYcqmqbFvXnvFWUJih1
TiqpQZJ6pOcZMMTsDT/Ww8UL8BVDi/RGlsxf9YvQB2Y3vn4o40xjMCJri1p1btQU+dncq8
vki3B1iKy9COA8cSKxpbEAAAADAQABAAACAQC7elqfacf3FvftHnaTq/sRBcYPbhF2cZtD
7nTa5lDGnN2vx5ofcLyCmDqrELiQ1jgXLMTNNS+RZ8ICWpcuTWiqGWf9/V7ZszX+DM72OD
feUoSxV/UOC07TIbZ7qe5MHsgGjZtvP8kEC20ZSI9yl1bw64qRa1/cQvBDYCawoURw9HlQ
WKLEYG5wz1z14BWcekt7d4WRKcfrGOknrPeMycGQTLUpgiQIUATAzsiVKVHCAVSPpct5lM
stIZuZUltDcJDxkZBBPRxymuTW8vd4tp4CoM+y4lAMb7FMyRyB5UnyydX6IjGONQTdSi9c
+4Rl+H9FTNIxAjuwMbjytsYTbQ/78FiAP13/P1bbzVNpdGG1NYJraywvKxFh0qZ5VzecgS
YRxJz7TQjL/YH6oHI1SiencVZeE0S5mKB+8CZISDGK5mDfjsXUgFaaYiCOuZBEGBgN+Z2V
HWpHZjh8X5pTuQpgyEGFyq8HS5+2Qg0nFm7fLSQjeCFbM0Ept0OnE0OqdeMfFHJFwKazHG
i/vywpZ9aNlIKWYhr7iYj96h2/7uY0pb4d3WyZX7iZL/sWvimgkKlnmlLflU1Kf023S1mw
bQRFYFfiJZx+bAW7poKupIYFbXEdu3kBDr1Pz9K/M8/DH6jx54raZCRciFrw5pfUb6a/2c
x40i9z85lutt4fmApCxQAAAQEApdFV5YebmHa1PKz5nKm7jtndfesFTJjjm+vxUiJIXhNM
YyTL+2N5L2B6KaOLsVrLTlqlN9XUV4JibORlKmkp7FVrVZJ52pb9QTjhPmUcksCOQOBI/C
OE0faSqtB7cin6FSsl1gsA1tovbDBgRe7JV8OFomRnwQPILyIUb6SrEa10uO5q7FxxGI3n
+Fm2QCrrOrQyOr9COxumIYEJEtX19LdFro7sOsvjwQtasgF01D+pj2qayOIBkj0TFipk/k
6flzykvUDCJNRR8QlwGna7vAzUi7lC2WcLuuIdFPqbN29Jg449rc0fdLDS0wejUJBB5I9g
rOwGwXCSllm4Hr4GCgAAAQEA/WA3JhOip5/13JpsT4MsKCfPY9oi2r80uEswZFF/yaObdP
rKX8HN3rbE2BjB/7QN6+HxyCJb6LyiAxceHGU77Ww+bSdtAOm3L/5XQc9nbo4pF5lHVaGJ
PKo7OJW0Y7C+BOc69JCCKG08gzvOG03ekZctLfpXA1aU3+4p9wM4iiBi2lnyIoWKfnNr3I
YXjEhh1jNewMc+jo2/mxDd6xgK9D18+7XngQfYcoVE40n0zzecR+AcdHfbhh8XXOmZPtZD
4hVjXUOMfhdaVYx+7a2+g/CWUS31DcjXjgs7vRhfjCtXd9zK6yDN8f98Qew9W0U4mZpxsP
LEvT8JdKC3TBB7QwAAAQEA1fT3T3Zyld2gyCCSD8dP2gPGfMPdWjlfFtL07Ig/GNZQpTNk
sRIl8YOnUcf0O/C5s8VBnF+cODJHDtJxspR6ybPsV/qgkTQsJbQ/N6TDGifUqkxPnSIGRQ
nNM/M08UtWPUnJpB50woGhwisJM3LBwTxFDU0/9dbUpc+2ad4d158UOeSA4oIpQzjOxLAz
NVCx17d5r5BraVAQTJAENs2zhytnHg/ZY1Oyrw05uX6eOzCbxdM5VaIgCNZAXIWPv+7ZDC
aA6/1lO6LtJXKGbXssUu3GHFlTU+JWlyAXs8372rT7Ep1NxQRlzh67BN98ItbUNrsqLjzx
GBdtEQWxDG/Z+wAAABV4b3V4b0BMQVBUT1AtVU9SRDBWVk8BAgME
-----END OPENSSH PRIVATE KEY-----
```
sur la vm :
```bash
[xouxou@localhost /]$ cat /home/xouxou/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTw4JducOQylJApjJ+Zy2T93i6Nn6bFaY8eyygY3MPmHS22Nmj+6h+kAvNzd30G7HtjU8tPzwOl7KRA4y9X8DZuXnSjTPqCU7xtB+fUPx6H1lFdszU7yUT3thWBaE57HRhyA2lcxEa9wIyLIo4tYHAJhn5c7lrwPX7Nc6Yfn5ZPr88rABJbtwqS2B+6sDFdEP9qnzFZhS29/UqjmDNcAXVSohojF4Ysx9IHYPQaN1CgoPnCZDxOYixo3G19pG+JI+nIb1Bfwn5h2B/mY87UEP0C+xWgWwx206Yt3uBlvZr5RbHsBpDXjEeMD7uj/5iBDb3W16yvWsrcbz7DX3XUxehScMuHUmopzPtbqNLdhFCxkFiw8Xd0uPsZJGnEFt3phJIqhC+zCguauJlOH2AoX15YvVH4ZjS5mxsF8yX2qG2gNHA1OiITRfDPmD/L2iENYYmbXVtEDVOYENBYaKnVOEVpHKwdO4+f+gPSP68ZDMv7EQPtnwqu01np06RLd2Cxn5/9XvRxEz+ockDzs/MnI/SahkmpwiAzyPKofi9O07RicHUkDTotqfsLzGkKUzhthyqapsW9ee8VZQmKHVOKqlBknqk5xkwxOwNP9bDxQvwFUOL9EaWzF/1i9AHZje+fijjTGMwImuLWnVu1BT52dyry+SLcHWIrL0I4DxxIrGlsQ== xouxo@LAPTOP-UORD0VVO
```
test connexion :
```bash
C:\Users\xouxo>ssh xouxou@10.200.1.30
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Tue Nov 23 11:38:33 2021 from 10.200.1.1
[xouxou@localhost ~]$
```
### Accès internet <a name="p23"></a>

```bash
[xouxou@localhost ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=24.6 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=24.1 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=113 time=34.4 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=113 time=37.0 ms
^C
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 24.091/30.028/37.038/5.769 ms
[xouxou@localhost ~]$ ping nhentai.net
PING nhentai.net (104.27.194.88) 56(84) bytes of data.
64 bytes from 104.27.194.88 (104.27.194.88): icmp_seq=1 ttl=51 time=29.8 ms
64 bytes from 104.27.194.88 (104.27.194.88): icmp_seq=2 ttl=51 time=29.6 ms
64 bytes from 104.27.194.88 (104.27.194.88): icmp_seq=3 ttl=51 time=29.0 ms
64 bytes from 104.27.194.88 (104.27.194.88): icmp_seq=4 ttl=51 time=31.6 ms
^C
--- nhentai.net ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 29.005/29.979/31.591/0.986 ms
```

### Définissez node1.tp4.linux comme nom à la machine <a name="p24"></a>

```bash
[xouxou@localhost ~]$ cat /etc/hostname
node1.tp4.linux
[xouxou@localhost ~]$ hostname
node1.tp4.linux
```

## Mettre en place un service <a name="p3"></a>

### Installez NGINX <a name="p31"></a>

```bash
[xouxou@localhost ~]$ sudo dnf install nginx
[sudo] password for xouxou:
Last metadata expiration check: 0:43:27 ago on Tue 23 Nov 2021 11:17:20 AM CET.
Dependencies resolved.
[...]
Complete!
```

### Analysez le service NGINX <a name="p32"></a>

root fait tourner le service NGINX :
```bash
[xouxou@localhost ~]$ ps -ef | grep "nginx"
root        8290       1  0 12:04 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       8291    8290  0 12:04 ?        00:00:00 nginx: worker process
xouxou      8302    5679  0 12:06 pts/2    00:00:00 grep --color=auto nginx
```

NGINX écoute derriere le port 80 :
```bash
[xouxou@localhost ~]$ ss -lptu | grep "http"
tcp   LISTEN 0      128          0.0.0.0:http      0.0.0.0:*
tcp   LISTEN 0      128             [::]:http         [::]:*
[xouxou@localhost ~]$ ss -lntr
State         Recv-Q        Send-Q               Local Address:Port               Peer Address:Port       Process
LISTEN        0             128                        0.0.0.0:22                      0.0.0.0:*
LISTEN        0             128                        0.0.0.0:80                      0.0.0.0:*
LISTEN        0             128                           [::]:22                         [::]:*
LISTEN        0             128                           [::]:80                         [::]:*
```
racine :
```bash
[xouxou@localhost nginx]$ cat nginx.conf | grep "root"
        root         /usr/share/nginx/html;
```
tous en lecture :
```bash
[xouxou@localhost html]$ ls -al
total 20
drwxr-xr-x. 2 root root   99 Nov 23 12:00 .
drwxr-xr-x. 4 root root   33 Nov 23 12:00 ..
-rw-r--r--. 1 root root 3332 Jun 10 11:09 404.html
-rw-r--r--. 1 root root 3404 Jun 10 11:09 50x.html
-rw-r--r--. 1 root root 3429 Jun 10 11:09 index.html
-rw-r--r--. 1 root root  368 Jun 10 11:09 nginx-logo.png
-rw-r--r--. 1 root root 1800 Jun 10 11:09 poweredby.png
```

### Configurez le firewall <a name="p33"></a>

```bash
[xouxou@localhost html]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
```

### Tester le bon fonctionnement du service <a name="p34"></a>

sur le pc :
```bash

C:\Users\xouxo>curl http://10.200.1.30:80
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <title>Test Page for the Nginx HTTP Server on Rocky Linux</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <style type="text/css">
      /*<![CDATA[*/
      body {
        background-color: #fff;
        color: #000;
        font-size: 0.9em;
[...]
```

### Changer le port <a name="p35"></a>

modification de nginx.conf :
```bash
[xouxou@localhost nginx]$ cat nginx.conf
[...]
        listen       8080 default_server;
        listen       [::]:8080 default_server;
[...]
```
verification des modificcations :
```bash
[xouxou@localhost nginx]$ ss -lntr
State         Recv-Q        Send-Q               Local Address:Port               Peer Address:Port       Process
LISTEN        0             128                        0.0.0.0:22                      0.0.0.0:*
LISTEN        0             128                        0.0.0.0:8080                    0.0.0.0:*
LISTEN        0             128                           [::]:22                         [::]:*
LISTEN        0             128                           [::]:8080                       [::]:*
```
test de connexion :
```bash
C:\Users\xouxo>curl http://10.200.1.30:8080
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <title>Test Page for the Nginx HTTP Server on Rocky Linux</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <style type="text/css">
      /*<![CDATA[*/
      body {
```

### Changer l'utilisateur qui lance le service <a name="p36"></a>

création + vérification de web :
```bash
[xouxou@localhost nginx]$ sudo useradd -d /home/web -p toto web
[sudo] password for xouxou:
[xouxou@localhost nginx]$ cd /home
[xouxou@localhost home]$ ls
web  xouxou

[xouxou@localhost home]$ cat /etc/passwd
[...]
web:x:1001:1001::/home/web:/bin/bash
```
modification de l'utilisateur qui lance nginx :
```bash
[xouxou@localhost home]$ cat /etc/nginx/nginx.conf | grep user
user web;
[...]


[xouxou@localhost home]$ ps -ef | grep web
web         8586    8585  0 12:47 ?        00:00:00 nginx: worker process
xouxou      8592    5679  0 12:47 pts/2 bash   00:00:00 grep --color=auto web
```

### Changer l'emplacement de la racine Web <a name="p37"></a>

dossier appartien à web :
```bash
[xouxou@node1 www]$ sudo chown web super_site_web/
[xouxou@node1 www]$ ls -l
total 0
drwxr-xr-x. 2 web root 24 Nov 23 14:35 super_site_web

[xouxou@node1 super_site_web]$ sudo chown web index.html
[xouxou@node1 super_site_web]$ ls -l
total 4
-rw-r--r--. 1 web root 121 Nov 23 14:39 index.html
```
changer la racine web :
```bash
[xouxou@node1 html]$ cat /etc/nginx/nginx.conf
[...]
        root         /var/www/super_site_web;
[...]
```
test fonctionnement sur le pc :
```bash
C:\Users\xouxo>curl http://10.200.1.30:8080
<html>
    <head>
        <title>toto</title>
    </head>
    <body>
        <p>zzzzzzzzzzzzzzzz</p>
    </body>
</html>
```

