# TP4 : Une distribution orientée serveur

## Sommaire 

-  [Checklist](#p2)
    - [Choisissez et définissez une IP à la VM](#p21)
    - [Connexion SSH fonctionnelle](#p22)
    - [Accès internet](#p23)
    - [Définissez node1.tp4.linux comme nom à la machine](#p24)
- [Mettre en place un service](#p3)
    - [Installez NGINX en vous référant à des docs online](#p31)
    - [Analysez le service NGINX](#p32)
    - [Configurez le firewall pour autoriser le trafic vers le service NGINX](#p33)
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


## Mettre en place un service <a name="p3"></a>