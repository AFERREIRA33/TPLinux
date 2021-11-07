# TP2 : Manipulation de services

Ferreira Alex B1 A

[Intro](#Intro)\n
    [Changer le nom de la machine](#pr1)\n
    [Config réseau fonctionnelle](#pr2)\n
[Partie 1 : Installation et configuration d'un service SSH](#p1)
    
[Partie 2 : Installation et configuration d'un service FTP](#p2)

[Partie 3 : Création de votre propre service](#p3)


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

### Installer le paquet openssh-server


## Partie 2 : Installation et configuration d'un service FTP <a name="p2"></a>



## Partie 3 : Création de votre propre service <a name="p3"></a>