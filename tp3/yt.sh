dl="/srv/yt/downloads"
log="/var/log/yt"
if [[ (-d "$dl") && (-d "$log")]]; then
	url=$1
	title=$(youtube-dl -j $url | cut -d'"' -f8)
	way="/srv/yt/downloads/$title"
	mkdir "$way"
	mkdir "$way/description"
	echo "Video $url was downloaded."
        echo "File path : $way/$title.mp4"
	youtube-dl -o "$way/%(title)s.%(ext)s" "$url" > "/dev/null"
	youtube-dl -o "$way/description/$title" --write-description --skip-download --youtube-skip-dash-manifest "https://www.youtube.com/watch?v=G_1IyYRdLBA" > "/dev/null"
	echo "[$(date "+%Y/%m/%d %T")] Video $url was downloaded. File path : $way/$title.mp4" >> "$log/download.log"
else
	exit
fi
