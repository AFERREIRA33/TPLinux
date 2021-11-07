# TP2 : Manipulation de services

Ferreira Alex B1 A

- [Intro](#Intro)  
    - [Changer le nom de la machine](#pr1)   
    - [Config réseau fonctionnelle](#pr2)  
- [Partie 1 : Installation et configuration d'un service SSH](#p1) 
    - [Installer le paquet openssh-server](#p11)
    - [Lancer le service ssh](#p12)
    - [Analyser le service en cours de fonctionnement](#p13)
    - [Connectez vous au serveur](#p14)
    - [Modifier le comportement du service](#p15)
    - [Connectez vous sur le nouveau port choisi](#p16)
- [Partie 2 : Installation et configuration d'un service FTP](#p2)  
- [Partie 3 : Création de votre propre service](#p3)  


## Intro

### Changer le nom de la machine <a name="pr1"></a>

- Première étape : changer le nom tout de suite, jusqu'à ce qu'on redémarre la machine

```bash
xouxou@xouxou-vm:~$ sudo hostname node1.tp2.linux
```
- Deuxième étape : changer le nom qui est pris par la machine quand elle s'allume
```bash
xouxou@xouxou-vm:~$ sudo nano /etc/hostname
xouxou@xouxou-vm:~$ cat /etc/hostname
node1.tp2.linux
```

###  Config réseau fonctionnelle <a name="pr2"></a>

- Depuis la VM
```bash
xouxou@xouxou-vm:~$ ping 1.1.1.1 -c 4
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=54 time=58.1 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=54 time=23.0 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=54 time=23.7 ms
64 bytes from 1.1.1.1: icmp_seq=4 ttl=54 time=24.8 ms

--- 1.1.1.1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3003ms
rtt min/avg/max/mdev = 22.994/32.402/58.145/14.876 ms


xouxou@xouxou-vm:~$ ping ynov.com -c 4
PING ynov.com (92.243.16.143) 56(84) bytes of data.
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=1 ttl=50 time=22.3 ms
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=2 ttl=50 time=20.8 ms
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=3 ttl=50 time=23.5 ms
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=4 ttl=50 time=22.5 ms

--- ynov.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 20.774/22.270/23.522/0.981 ms
```
- Depuis mon PC
```bash
C:\Users\xouxo>ping 192.168.56.116

Envoi d’une requête 'Ping'  192.168.56.116 avec 32 octets de données :
Réponse de 192.168.56.116 : octets=32 temps<1ms TTL=64
Réponse de 192.168.56.116 : octets=32 temps<1ms TTL=64
Réponse de 192.168.56.116 : octets=32 temps<1ms TTL=64
Réponse de 192.168.56.116 : octets=32 temps<1ms TTL=64

Statistiques Ping pour 192.168.56.116:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 0ms, Maximum = 0ms, Moyenne = 0ms
```


## Partie 1 : Installation et configuration d'un service SSH <a name="p1"></a>

### Installer le paquet openssh-server <a name="p11"></a>

```bash
xouxou@xouxou-vm:~$ sudo apt install openssh-server
[sudo] password for xouxou:
Reading package lists... Done
Building dependency tree
Reading state information... Done
openssh-server is already the newest version (1:8.2p1-4ubuntu0.3).
0 upgraded, 0 newly installed, 0 to remove and 51 not upgraded.
xouxou@xouxou-vm:~$ cd /etc/ssh
xouxou@xouxou-vm:/etc/ssh$ ls
moduli      ssh_config.d  sshd_config.d       ssh_host_ecdsa_key.pub  ssh_host_ed25519_key.pub  ssh_host_rsa_key.pub
ssh_config  sshd_config   ssh_host_ecdsa_key  ssh_host_ed25519_key    ssh_host_rsa_key
```
### Lancer le service ssh <a name="p12"></a>

```bash
xouxou@xouxou-vm:~$ systemctl start sshd
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to start 'ssh.service'.
Authenticating as: xouxou,,, (xouxou)
Password:
==== AUTHENTICATION COMPLETE ===
xouxou@xouxou-vm:~$ systemctl status sshd
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-10-25 11:47:20 CEST; 17s ago
[...]
```
### Analyser le service en cours de fonctionnement <a name="p13"></a>

- Afficher le statut du service
```bash
xouxou@xouxou-vm:~$ systemctl status sshd
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-10-25 11:47:20 CEST; 17s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 23887 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 23888 (sshd)
      Tasks: 1 (limit: 2312)
     Memory: 1.0M
     CGroup: /system.slice/ssh.service
             └─23888 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
[...]
```
- Afficher le/les processus liés au service ssh
```bash
xouxou@xouxou-vm:~$ ps -ef
[...]
root        1254       1  0 11:12 ?        00:00:00 sshd: xouxou [priv]
xouxou      1332    1254  0 11:12 ?        00:00:00 sshd: xouxou@pts/1
[...]
```
- Afficher le port utilisé par le service ssh
```bash
xouxou@xouxou-vm:~$ ss -lntr
State                       Recv-Q                      Send-Q                                            Local Address:Port                                             Peer Address:Port                      Process
[...]
LISTEN                      0                           128                                                     0.0.0.0:22                                                    0.0.0.0:*
[...]
```
- Afficher les logs du service ssh
```bash
xouxou@xouxou-vm:~$ journalctl -xe -u ssh 
[...]
oct. 25 11:12:07 xouxou-vm sshd[1254]: Accepted password for xouxou from 192.168.56.1 port 55447 ssh2
oct. 25 11:12:07 xouxou-vm sshd[1254]: pam_unix(sshd:session): session opened for user xouxou by (uid=0)
oct. 25 11:46:56 node1.tp2.linux systemd[1]: Stopping OpenBSD Secure Shell server...
[...]
```

### Connectez vous au serveur <a name="p14"></a>

```bash
C:\Users\xouxo>ssh xouxou@192.168.56.116
xouxou@192.168.56.116's password:
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-38-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

51 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Your Hardware Enablement Stack (HWE) is supported until April 2025.
Last login: Mon Oct 25 11:12:07 2021 from 192.168.56.1
xouxou@node1:~$
```

### Modifier le comportement du service <a name="p15"></a>

```bash
xouxou@node1:~$ sudo nano /etc/ssh/sshd_config
xouxou@node1:~$ cat /etc/ssh/sshd_config
[...]
Port 1026
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::
[...]
xouxou@node1:~$ sudo systemctl restart sshd
xouxou@node1:~$ sudo systemctl restart ssh
xouxou@node1:~$ ss -lntr
State         Recv-Q        Send-Q               Local Address:Port               Peer Address:Port       Process
LISTEN        0             4096                  localhost%lo:53                      0.0.0.0:*
LISTEN        0             5                        localhost:631                     0.0.0.0:*
LISTEN        0             128                        0.0.0.0:1026                    0.0.0.0:*
LISTEN        0             5                    ip6-localhost:631                        [::]:*
LISTEN        0             128                           [::]:1026                       [::]:*
```

### Connectez vous sur le nouveau port choisi <a name="p16"></a>

```bash

C:\Users\xouxo>ssh -p 1026 xouxou@192.168.56.116
xouxou@192.168.56.116's password:
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-38-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

51 updates can be applied immediately.
To see these additional updates run: apt list --upgradable


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
Your Hardware Enablement Stack (HWE) is supported until April 2025.
Last login: Wed Nov  3 15:14:57 2021 from 192.168.56.1
xouxou@node1:~$
```


## Partie 2 : Installation et configuration d'un service FTP <a name="p2"></a>



## Partie 3 : Création de votre propre service <a name="p3"></a>