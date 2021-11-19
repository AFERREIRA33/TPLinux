dl="/srv/yt/downloads"
log="/var/log/yt"
void=""
while true; do
        ytdl="$(cat /srv/yt/ytdownload)"
        if [[ (-d "$dl") && (-d "$log") && (-n "$ytdl") ]]; then
		cat /srv/yt/ytdownload  | while read line; do 
			url=$line
			title=$(youtube-dl -j $url | cut -d'"' -f8)
	                way="/srv/yt/downloads/$title"
			mkdir "$way"
	                mkdir "$way/description"
	                echo "Video $url was downloaded."
	                echo "File path : $way/$title.mp4"
	                youtube-dl -o "$way/%(title)s.%(ext)s" "$url" > "/dev/null"
	                youtube-dl -o "$way/description/$title" --write-description --skip-download --youtube-skip-dash-manifest "$url" > "/dev/null"
	                echo "[$(date "+%Y/%m/%d %T")] Video $url was downloaded. File path : $way/$title.mp4" >> "$log/download.log"
	                sed -i '1d' "/srv/yt/ytdownload"
		done
	fi
	sleep 5
done
