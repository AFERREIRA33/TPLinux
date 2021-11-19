count=2
countbis=1
echo "Machine name : $(hostname)"
echo "OS $(cat /etc/os-release | egrep ^'NAME="' | cut -d '"' -f2) and kernel version is $(uname -r)"
echo "IP : $(hostname -I | cut -d " " -f2)"
echo "RAM : $(free -mh | grep Mem: | cut -d' ' -f46) / $(free -mh | grep Mem: | cut -d' ' -f11)"
echo "Disque : $(df -ht ext4 | grep "/dev" | cut -d " " -f12) space left"
echo "top 5  processes by RAM usage : "
for ((i = 0 ; i < 5 ; i++)); do
        echo " - $(ps -o %mem,command ax | sort -b -r | head -$count | tail -1)"
        let "count += 1"
done
count=2
echo "Listening ports :"
nb=$(ss -lntr | wc -l)
let "nb -= 1"
for ((i = 0  ; i < $nb ;  i++)); do
        m=$(ss -tulp | grep "LISTEN" | head -$countbis | tail -1 | cut -d':' -f2 |cut -d' ' -f1)
        if  [[ -n "$m" ]]; then
                echo " - $(ss -lntr | head -$count | tail -1 | cut -d':' -f2 |cut -d' ' -f1) : $(ss -tulp | grep "LISTEN" | head -$countbis | tail -1 | cut -d':' -f2 |cut -d' ' -f1)"
        let "count += 1"
        fi
        let "countbis += 1"

done
echo "Here's your random cat :  $(curl -s https://api.thecatapi.com/v1/images/search | grep '"url"' | cut -d'"' -f10)"