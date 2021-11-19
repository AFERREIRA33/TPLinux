# TP3 : A little script

- [I. Script carte d'identité](#pr1)
- [II. Script youtube-dl](#pr2)
- [III. MAKE IT A SERVICE](#pr3)

## I. Script carte d'identité <a name="pr1"></a>

script : [idcard](./idcard.sh)

résultat :
```bash
xouxou@xouxou-vm:/srv/idcard$ bash idcard.sh
Machine name : xouxou-vm
OS Ubuntu and kernel version is 5.11.0-38-generic
IP : 192.168.56.121
RAM : 1,3Gi / 1,9Gi
Disque : 2,6G space left
top 5  processes by RAM usage :
 -  4.1 xfwm4 --replace
 -  3.6 /usr/libexec/fwupd/fwupd
 -  3.4 /usr/lib/xorg/Xorg -core :0 -seat seat0 -auth /var/run/lightdm/root/:0 -nolisten tcp vt7 -novtswitch
 -  2.3 Thunar --daemon
 -  2.2 /usr/bin/python3 /usr/bin/blueman-applet
Listening ports :
 - 53 : domain
 - 22 : ssh
 - 631 : ipp
Here's your random cat :  https://cdn2.thecatapi.com/images/5qj.jpg
```

## II. Script youtube-dl <a name="pr2"></a>

script : [yt.sh](./yt.sh)

log : [download.log](./download.log)

résultat : 
```bash
xouxou@xouxou-vm:/srv/yt$ sudo bash yt.sh https://www.youtube.com/watch?v=ATsLeb7cb7A
Video https://www.youtube.com/watch?v=ATsLeb7cb7A was downloaded.
File path : /srv/yt/downloads/Zzzz/Zzzz.mp4
xouxou@xouxou-vm:/srv/yt$
```

## III. MAKE IT A SERVICE <a name="pr3"></a>

script : [yt-v2.sh](./yt-v2.sh)

service : [yt.service](./yt.service)

service active : 
```bash
xouxou@xouxou-vm:/srv/idcard$ systemctl status yt
● yt.service - download youtube video with a file
     Loaded: loaded (/etc/systemd/system/yt.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2021-11-19 15:07:30 CET; 2s ago
   Main PID: 2317 (bash)
      Tasks: 2 (limit: 2312)
     Memory: 568.0K
     CGroup: /system.slice/yt.service
             ├─2317 /usr/bin/bash /srv/yt/yt-v2.sh
             └─2319 sleep 5

nov. 19 15:07:30 xouxou-vm systemd[1]: Started download youtube video with a file.
```

log du service :
```bash
xouxou@xouxou-vm:/srv/idcard$ journalctl -xe -u yt
nov. 19 14:28:20 xouxou-vm bash[1150]: File path : /srv/yt/downloads/\u3082\u3063\u3068\u3054\u8912\u7f8e\u2661\u>
nov. 19 14:28:22 xouxou-vm bash[1177]: ERROR: unable to download video data: HTTP Error 403: Forbidden
nov. 19 14:28:24 xouxou-vm bash[1150]: https://www.youtube.com/watch?v=oNPKaw_watU
nov. 19 14:28:26 xouxou-vm bash[1150]: Video https://www.youtube.com/watch?v=oNPKaw_watU was downloaded.
nov. 19 14:28:26 xouxou-vm bash[1150]: File path : /srv/yt/downloads/pov: Soap trusted you. Korone thought she co>
nov. 19 14:47:42 xouxou-vm bash[1795]: https://www.youtube.com/watch?v=05HvaQGmVw0
nov. 19 14:47:44 xouxou-vm bash[1800]: mkdir: cannot create directory ‘/srv/yt/downloads/BASED Nyanners’: File ex>
nov. 19 14:47:44 xouxou-vm bash[1801]: mkdir: cannot create directory ‘/srv/yt/downloads/BASED Nyanners/descripti>
nov. 19 14:47:44 xouxou-vm bash[1795]: Video https://www.youtube.com/watch?v=05HvaQGmVw0 was downloaded.
```

commande pour activer le service dès le lancement :```systemctl enable yt```
