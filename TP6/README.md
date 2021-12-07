# TP6 : Stockage et sauvegarde

## Sommaire

- [Partie 1 : Préparation de la machine backup.tp6.linux](#p1)
    - [Ajouter un disque dur de 5Go à la VM backup.tp6.linux](#p1.1)
    - [Partitionner le disque à l'aide de LVM](#p1.2)
    - [Formater la partition](#p1.3)
    - [Monter la partition](#p1.4)
- [Partie 2 : Setup du serveur NFS sur backup.tp6.linux](#p2)
    - [Préparer les dossiers à partager](#p2.1)
    - [Install du serveur NFS](#p2.2)
    - [Conf du serveur NFS](#p2.3)
    - [Démarrez le service](#p2.4)
    - [Firewall](#p2.5)
- [Partie 3 : Setup des clients NFS : web.tp6.linux et db.tp6.linux](#p3)
    - [Install'](#p3.1)
    - [Conf'](#p3.2)
    - [Montage !](#p3.3)
    - [Répétez les opérations sur db.tp6.linux](#p3.4)
- [Partie 4 : Scripts de sauvegarde](#p4)
    - [Ecrire un script qui sauvegarde les données de NextCloud](#p4.1)
    - [Créer un service](#p4.2)
    - [Vérifier que vous êtes capables de restaurer les données](#p4.3)
    - [Créer un timer](#p4.4)
    - [Ecrire un script qui sauvegarde les données de la base de données MariaDB](#p4.5)
    - [Créer un service](#p4.6)
    - [Créer un timer](#p4.7)

## Partie 1 : Préparation de la machine backup.tp6.linux <a name="p1"></a>

### Ajouter un disque dur de 5Go à la VM backup.tp6.linux <a name="p1.1"></a>

```bash
[xouxou@backup ~]$ lsblk | grep sdb
sdb           8:16   0    5G  0 disk
```

### Partitionner le disque à l'aide de LVM <a name="p1.2"></a>

- Physical volume
```bash
[xouxou@backup ~]$ sudo pvcreate /dev/sdb
[sudo] password for xouxou:
  Physical volume "/dev/sdb" successfully created.
[xouxou@backup ~]$ sudo pvs
  PV         VG Fmt  Attr PSize  PFree
  /dev/sda2  rl lvm2 a--  <7.00g    0
  /dev/sdb      lvm2 ---   5.00g 5.00g
```
- Volume group
```bash
[xouxou@backup ~]$ sudo vgcreate backup /dev/sdb
  Volume group "backup" successfully created
[xouxou@backup ~]$ sudo vgs
  VG     #PV #LV #SN Attr   VSize  VFree
  backup   1   0   0 wz--n- <5.00g <5.00g
  rl       1   2   0 wz--n- <7.00g     0
```
- Logicial volume
```bash
[xouxou@backup ~]$ sudo lvcreate -l 100%FREE backup -n backup
  Logical volume "backup" created.
[xouxou@backup ~]$ sudo lvs
  LV     VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  backup backup -wi-a-----  <5.00g
  root   rl     -wi-ao----  <6.20g
  swap   rl     -wi-ao---- 820.00m
```

### Formater la partition <a name="p1.3"></a>

```bash
[xouxou@backup ~]$ sudo mkfs -t ext4 /dev/backup/backup
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 1309696 4k blocks and 327680 inodes
Filesystem UUID: 0a55a819-405c-4bab-b4f6-f64c3c7f1ae6
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

### Monter la partition <a name="p1.4"></a>

- montage de la partition
```bash
[xouxou@backup ~]$ sudo mount /dev/backup/backup /mnt/backup
[xouxou@backup ~]$ df -h | grep backup
/dev/mapper/backup-backup  4.9G   20M  4.6G   1% /mnt/backup
[xouxou@backup ~]$ ls -al /mnt | grep backup
drwxr-xr-x.  3 root root 4096 Nov 30 12:15 backup
```
- montage auto
```bash
[xouxou@backup ~]$ sudo  nano /etc/fstab
[xouxou@backup ~]$ cat /etc/fstab  | grep backup
/dev/mapper/backup-backup /mnt/backup ext4 defaults 0 0
[xouxou@backup ~]$ sudo umount /mnt/backup
[xouxou@backup ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /mnt/backup does not contain SELinux labels.
       You just mounted an file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/mnt/backup              : successfully mounted
```

## Partie 2 : Setup du serveur NFS sur backup.tp6.linux <a name="p2"></a>

### Préparer les dossiers à partager <a name="p2.1"></a>

```bash
[xouxou@backup ~]$ sudo mkdir /mnt/backup/web.tp6.linux
[sudo] password for xouxou:
[xouxou@backup ~]$ sudo mkdir /mnt/backup/db.tp6.linux
[xouxou@backup ~]$ cd /mnt/backup/
[xouxou@backup backup]$ ls
db.tp6.linux  lost+found  web.tp6.linux
```

### Install du serveur NFS <a name="p2.2"></a>

```bash
[xouxou@backup backup]$ sudo dnf install nfs-utils
Last metadata expiration check: 6:35:30 ago on Tue 30 Nov 2021 12:30:48 PM CET.
Dependencies resolved.
[...]
Installed:
  gssproxy-0.8.0-19.el8.x86_64           keyutils-1.5.10-9.el8.x86_64        libverto-libevent-0.3.0-5.el8.x86_64
  nfs-utils-1:2.3.3-46.el8.x86_64        rpcbind-1.2.5-8.el8.x86_64

Complete!
```

### Conf du serveur NFS <a name="p2.3"></a>

```bash
[xouxou@backup backup]$ sudo nano /etc/idmapd.conf
[xouxou@backup mnt]$ cat /etc/idmapd.conf | grep Domain
Domain = tp6.linux

[xouxou@backup mnt]$ sudo nano /etc/exports
[xouxou@backup mnt]$ cat /etc/exports
/mnt/backup/web.tp6.linux/ 10.5.1.11/24(rw,no_root_squash)
/mnt/backup/db.tp6.linux/ 10.5.1.12/24(rw,no_root_squash)
```
rw = autorise les requêtes de lecture et d'écriture  
no_root_squash = empêche la transformation de root

### Démarrez le service <a name="p2.4"></a>

```bash
[xouxou@backup ~]$ sudo systemctl start nfs-server
[xouxou@backup ~]$ systemctl status nfs-server
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; disabled; vendor preset: disabled)
   Active: active (exited) since Tue 2021-11-30 19:50:26 CET; 24s ago
[xouxou@backup ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
```

### Firewall <a name="p2.5"></a>

```bash
[xouxou@backup ~]$ sudo firewall-cmd --add-port=2049/tcp --permanent
[xouxou@backup ~]$ ss -lntr |grep 2049
LISTEN 0      64           0.0.0.0:2049       0.0.0.0:*
LISTEN 0      64              [::]:2049          [::]:*
[xouxou@backup ~]$ ss -tulp |grep nfs
tcp   LISTEN 0      64           0.0.0.0:nfs         0.0.0.0:*
tcp   LISTEN 0      64              [::]:nfs            [::]:*
```

## Partie 3 : Setup des clients NFS : web.tp6.linux et db.tp6.linux <a name="p3"></a>

### Install' <a name="p3.1"></a>

```bash
[xouxou@web ~]$ sudo dnf install nfs-utils
[sudo] password for xouxou:
Last metadata expiration check: 8:02:32 ago on Tue 30 Nov 2021 12:05:05 PM CET.
Dependencies resolved.
[...]
Installed:
  gssproxy-0.8.0-19.el8.x86_64           keyutils-1.5.10-9.el8.x86_64        libverto-libevent-0.3.0-5.el8.x86_64
  nfs-utils-1:2.3.3-46.el8.x86_64        rpcbind-1.2.5-8.el8.x86_64

Complete!
```

### Conf' <a name="p3.2"></a>

```bash
[xouxou@web ~]$ sudo mkdir /srv/backup
[xouxou@web ~]$ ls /srv/
backup

[xouxou@web ~]$ sudo nano /etc/idmapd.conf
[xouxou@web ~]$ cat /etc/idmapd.conf | grep Domain
Domain = tp6.linux
```

### Montage !  <a name="p3.3"></a>

- Montage de la partition NFS
```bash
[xouxou@web ~]$ sudo mount -t nfs 10.5.1.13:/mnt/backup/web.tp6.linux /srv/backup
[xouxou@web ~]$ df -h | grep backup
10.5.1.13:/mnt/backup/web.tp6.linux  4.9G   20M  4.6G   1% /srv/backup
[xouxou@web ~]$ ls -al /srv | grep backup
drwxr-xr-x.  2 root root 4096 Nov 30 19:02 backup
```
- Montage auto
```bash
[xouxou@web ~]$ sudo nano /etc/fstab
[xouxou@web ~]$ cat /etc/fstab | grep backup
10.5.1.13:/mnt/backup/web.tp6.linux /srv/backup nfs defaults 0 0
[xouxou@web ~]$ sudo umount /srv/backup
[xouxou@web ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount.nfs: timeout set for Tue Nov 30 21:19:19 2021
mount.nfs: trying text-based options 'vers=4.2,addr=10.5.1.13,clientaddr=10.5.1.11'
/srv/backup              : successfully mounted
```

### Répétez les opérations sur db.tp6.linux <a name="p3.4"></a>

- partition montée
```bash
[xouxou@db ~]$ df -h | grep backup
10.5.1.13:/mnt/backup/db.tp6.linux  4.9G   20M  4.6G   1% /srv/backup
```
- Peut écrire et lire
```bash
[xouxou@db ~]$ ls -al /srv | grep backup
drwxr-xr-x.  2 root root 4096 Nov 30 19:03 backup
```
- montage auto fonctionne
```bash
[xouxou@db ~]$ sudo umount /srv/backup
[xouxou@db ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount.nfs: timeout set for Tue Nov 30 21:30:15 2021
mount.nfs: trying text-based options 'vers=4.2,addr=10.5.1.13,clientaddr=10.5.1.12'
/srv/backup              : successfully mounted
```

## Partie 4 : Scripts de sauvegarde <a name="p4"></a>

### Ecrire un script qui sauvegarde les données de NextCloud <a name="p4.1"></a>

```bash
[xouxou@web ~]$ sudo mkdir /srv/save
[xouxou@web ~]$ sudo touch /srv/save/save.sh
[xouxou@web /]$ sudo mkdir /var/log/backup
[xouxou@web /]$ sudo touch /var/log/backup/backup.log
[xouxou@web /]$ sudo nano /srv/save/save.sh
[xouxou@web /]$ cat /srv/save/save.sh
#!/bin/bash
#
# Ferreira Alex 3/12/2021

log_date=$(date +"[%y/%m/%d %H:%M:%S]")
file_date=$(date +"%y%m%d_%H%M%S")
path="/srv/backup/nextcloud_${file_date}"

line="Backup ${path} created successfully."

tar -cvzf "${path}".tar.gz /var/www/nextcloud/*
echo "${log_date} ${line}" >> /var/log/backup/backup.log
echo "${line}"


[xouxou@web backup]$ sudo bash /srv/save/save.sh
[...]
/var/www/nextcloud/html/data/xouxou/files/Photos/Steps.jpg
/var/www/nextcloud/html/data/xouxou/files/Photos/Readme.md
/var/www/nextcloud/html/data/xouxou/files/Photos/Gorilla.jpg
Backup /srv/backup/nextcloud_211205_100821 created successfully.
[xouxou@web /]$ ls /srv/backup
nextcloud_211205_100821.tar.gz
[xouxou@web /]$ cat /var/log/backup/backup.log
[21/12/05 10:08:21] Backup /srv/backup/nextcloud_211205_100821 created successfully.
```

### Créer un service <a name="p4.2"></a>

```bash
[xouxou@web /]$ cat /etc/systemd/system/backup.service
[Unit]
Description=Do a backup of your nextcloud

[Service]
ExecStart=/usr/bin/bash /srv/save/save.sh
Type=oneshot

[Install]
WantedBy=multi-user.target

[xouxou@web /]$ ls /srv/backup/
nextcloud_211205_100821.tar.gz  nextcloud_211205_102109.tar.gz
[xouxou@web /]$ sudo systemctl start backup
[sudo] password for xouxou:
[xouxou@web /]$ ls /srv/backup/
nextcloud_211205_100821.tar.gz  nextcloud_211205_102109.tar.gz  nextcloud_211205_102209.tar.gz
```

### Vérifier que vous êtes capables de restaurer les données <a name="p4.3"></a>

```bash
[xouxou@web www]$ sudo tar -vxf /srv/backup/nextcloud_211205_100821.tar.gz -C /
[...]
var/www/nextcloud/html/data/xouxou/files/Photos/Vineyard.jpg
var/www/nextcloud/html/data/xouxou/files/Photos/Steps.jpg
var/www/nextcloud/html/data/xouxou/files/Photos/Readme.md
var/www/nextcloud/html/data/xouxou/files/Photos/Gorilla.jpg
```

### Créer un timer <a name="p4.4"></a>

```bash
[xouxou@web www]$ sudo nano /etc/systemd/system/backup.timer
[xouxou@web www]$ [xouxou@web www]$ cat /etc/systemd/system/backup.timer
[Unit]
Description=Lance backup.service à intervalles réguliers
Requires=backup.service

[Timer]
Unit=backup.service
OnCalendar=hourly

[Install]
WantedBy=timers.target


[xouxou@web www]$ sudo systemctl daemon-reload
[xouxou@web www]$ sudo systemctl start backup.timer
[xouxou@web www]$ sudo systemctl enable backup.timer
[xouxou@web www]$ sudo systemctl list-timers | grep "backup"
Sun 2021-12-05 11:00:00 CET  18min left    n/a                          n/a         backup.timer                 backup.service



mysqldump -u nextcloud -h 10.5.1.12 -P 3306 -D nextcloud
```

### Ecrire un script qui sauvegarde les données de la base de données MariaDB <a name="p4.5"></a>

```bash
[xouxou@db ~]$ sudo mkdir /srv/save
[xouxou@db ~]$ sudo nano /srv/save/save.sh
[xouxou@db ~]$ cat /srv/save/save.sh
#!/bin/bash
#
# Ferreira Alex 3/12/2021

log_date=$(date +"[%y/%m/%d %H:%M:%S]")
file_date=$(date +"%y%m%d_%H%M%S")
path="/srv/backup/nextcloud_db_${file_date}.tar.gz"
line="Backup ${path} created successfully."
Mdump='/srv/save/Mdump.sql'
mysqldump -h localhost -p -u root nextcloud --password="toto"> '${Mdump}'
tar -cvzf "${path}" "${Mdump}"
echo "${log_date} ${line}" >> /var/log/backup/backup_db.log
echo "${line}"
[xouxou@db ~]$ sudo mkdir /var/log//backup
[xouxou@db ~]$ sudo touch /var/log/backup/backup_db.log
[xouxou@db ~]$ sudo bash /srv/save/save.sh
Backup /srv/backup/nextcloud_db_211207_231204.tar.gz created successfully.
```

### Créer un service <a name="p4.6"></a>

```bash
[xouxou@db ~]$ sudo nano /etc/systemd/system/backup_db.service
[xouxou@db ~]$ cat /etc/systemd/system/backup_db.service
[Unit]
Description=Do a backup of your database

[Service]
ExecStart=/usr/bin/bash /srv/save/save.sh
Type=oneshot

[Install]
WantedBy=multi-user.target


[xouxou@db ~]$ cat /var/log/backup/backup_db.log
[21/12/07 23:04:28] Backup /srv/backup/nextcloud_db_211207_230428.tar.gz created successfully.
[21/12/07 23:05:08] Backup /srv/backup/nextcloud_db_211207_230508.tar.gz created successfully.
[21/12/07 23:06:25] Backup /srv/backup/nextcloud_db_211207_230625.tar.gz created successfully.
[21/12/07 23:06:50] Backup /srv/backup/nextcloud_db_211207_230650.tar.gz created successfully.
[21/12/07 23:12:04] Backup /srv/backup/nextcloud_db_211207_231204.tar.gz created successfully.
[21/12/07 23:18:37] Backup /srv/backup/nextcloud_db_211207_231837.tar.gz created successfully.
[xouxou@db ~]$ sudo systemctl start backup_db
[xouxou@db ~]$ cat /var/log/backup/backup_db.log
[21/12/07 23:04:28] Backup /srv/backup/nextcloud_db_211207_230428.tar.gz created successfully.
[21/12/07 23:05:08] Backup /srv/backup/nextcloud_db_211207_230508.tar.gz created successfully.
[21/12/07 23:06:25] Backup /srv/backup/nextcloud_db_211207_230625.tar.gz created successfully.
[21/12/07 23:06:50] Backup /srv/backup/nextcloud_db_211207_230650.tar.gz created successfully.
[21/12/07 23:12:04] Backup /srv/backup/nextcloud_db_211207_231204.tar.gz created successfully.
[21/12/07 23:18:37] Backup /srv/backup/nextcloud_db_211207_231837.tar.gz created successfully.
[21/12/07 23:19:32] Backup /srv/backup/nextcloud_db_211207_231932.tar.gz created successfully.
```

### Créer un timer <a name="p4.7"></a>

```bash
[xouxou@db ~]$ sudo nano /etc/systemd/system/backup_db.timer
[xouxou@db ~]$ cat /etc/systemd/system/backup_db.timer
[Unit]
Description=Lance backup_db.service à intervalles réguliers
Requires=backup_db.service

[Timer]
Unit=backup_db.service
OnCalendar=hourly

[Install]
WantedBy=timers.target


[xouxou@db ~]$ sudo systemctl daemon-reload
[xouxou@db ~]$ sudo systemctl start backup_db.timer
[xouxou@db ~]$ sudo systemctl enable backup_db.timer
Created symlink /etc/systemd/system/timers.target.wants/backup_db.timer → /etc/systemd/system/backup_db.timer.
[xouxou@db ~]$ sudo systemctl list-timers | grep backup_db
Wed 2021-12-08 00:00:00 CET  33min left    n/a                          n/a       backup_db.timer              backup_db.service
```



