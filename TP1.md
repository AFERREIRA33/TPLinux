# TP1 : Are you dead yet ?

Ferreira Alex B1 A

## :memo: Objectif : Trouver au moins 5 façons différentes de péter la machine

## Solution 1 : reboot infini
```sudo su -```
Je deviens le root pour obtenir des permissions sur certains fichier et pouvoir modifier les permissions.

```cd ..```

```sudo nano /etc/rc.local``` 
Je crée un fichier rc.local, ce fichier se lance à la fin du boot.

Dans se fichier :
```
#!/bin/bash
shutdown -r 0
```
La première ligne permet d'utiliser le fichier comme éxecutable et la seconde de redémarrer le pc instantanément ( "-r" pour le relancer et "0" instantanément).

```chmod a+x /etc/rc.local``` 
Je change les permissions du fichier rc.local pour qu'il puisse être éxecuté par tous.

## Solution 2 : remplacer toute les valeur de fichier important

```sudo su -```
Je deviens le root pour avoir l'autorisation de modifier certains fichier.

```cd ..```

```cat /dev/urandom >/dev/sda```

Je met le contenue de urandom dans sda. sda sert à modifier les vameurs des fichier et donc een ajoutant urandom on met des valeurs aléatoires dans les fichiers importants du pc.

## Solution 3 : tous supprimer

```sudo su -```
Je deviens le root pour obtenir des permissions.

```cd ..```

```rm -rf ./*```
Permet de supprimer tous les fichiers.

## Soluce 4 : création de processus au lancement

```sudo nano .bashrc```
Je modifie le fichier bashrc

Au début du fichier bashrc :

```:(){ :|: & };:``` 
Permet de créer des processus à l'infini et donc met la ram à 100 %.

## Solution 5 : Plus de permissions pour le boot ?

```sudo su -```
Je deviens le root pour avoir l'autorisation de modifier les permitions de certains fichier.

```cd ..```

```chmod 000 boot```
Je retire toutes les permissions de boot donc il ne peux plus être lu, modifier et éxecuté.


