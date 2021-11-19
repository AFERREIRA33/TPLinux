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