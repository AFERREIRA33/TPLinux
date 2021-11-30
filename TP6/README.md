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

## Partie 2 : Setup du serveur NFS sur backup.tp6.linux <a name="p2"></a>

## Partie 3 : Setup des clients NFS : web.tp6.linux et db.tp6.linux <a name="p3"></a>

## Partie 4 : Scripts de sauvegarde <a name="p4"></a>