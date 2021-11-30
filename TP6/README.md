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
    - [Démarrez le service](#2.4)
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

## Partie 3 : Setup des clients NFS : web.tp6.linux et db.tp6.linux <a name="p3"></a>

## Partie 4 : Scripts de sauvegarde <a name="p4"></a>