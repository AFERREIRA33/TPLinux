dl="/srv/yt/downloads"
if [[ -d "$dl" ]]; then
	url=$1
	title=$(youtube-dl -j $url | cut -d'"' -f8)
	mkdir "/srv/yt/downloads/$title"
	mkdir "/srv/yt/downloads/$title/description"
	echo "Video $url was downloaded."
        echo "File path : /srv/yt/downloads/$title/$title.mp4"
	youtube-dl -o "/srv/yt/downloads/$title/%(title)s.%(ext)s" "$url" > "/dev/null"
	youtube-dl -o "/srv/yt/downloads/$title/description/$title" --write-description --skip-download --youtube-skip-dash-manifest "https://www.youtube.com/watch?v=G_1IyYRdLBA" > "/dev/null"
	echo "[$(date "+%Y/%m/%d %T")] Video $url was downloaded. File path : /srv/yt/downloads/$title/$title.mp4" >> "/var/log/yt/download.log"
else
	exit
fi
