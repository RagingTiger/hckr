# ytb to slk pipeline
ytb2slk() {
  docker run -d \
             --rm \
             --name ytb2slk.$(date  +%m%d%y%H%M%S) \
             -v ~/.hckr:/usr/etc \
             -e UPLD_NM="$2" \
             -e SLACKUP='true' \
             ghcr.io/ragingtiger/hckr:master bash -c "ytb2slk $1 '#meeting' '$1'"
}

# slack upload
slackup() {
  docker run -d \
             --rm \
             --name slackup.$(date +%m%d%y%H%M%S) \
             -v ~/.hckr:/usr/etc \
             -v $PWD:/home/hckr \
             ghcr.io/ragingtiger/hckr:master  bash -c "slkup $1 '#meeting' $2"
}

# hack it
hckr() {
  local mountpnt=${1:-"$PWD"}
  docker run --rm -v $mountpnt:/home/hckr -it ghcr.io/ragingtiger/hckr:master
}

# insta to slk pipeline
insta2slk() {
  docker run -d \
             --rm \
             --name insta2slk.$(date  +%m%d%y%H%M%S) \
             -v ~/.hckr:/usr/etc \
             ghcr.io/ragingtiger/hckr:master bash -c "insta2slk $1 '$1'"
}

# new and improved
scrp2slk() {
  docker run -d \
             --rm \
             --name scrp2slk.$(date  +%m%d%y%H%M%S) \
             -v ~/.hckr:/usr/etc \
             -e UPLD_NM="$2" \
             -e SLACKUP='true' \
             ghcr.io/ragingtiger/hckr:master bash -c "scrp2slk $1 '#meeting' '$1'"
}

monitdir() {
  docker run -d \
             --rm \
             --name monitdir.$(date +%m%d%y%H%M%S) \
             -v ~/.hckr:/usr/etc \
             -v $PWD:/home/hckr \
             -e NOTIFYMSG='New download available' \
             -e NOTIFYCHNL='#meeting' \
             ghcr.io/ragingtiger/hckr:master bash -c "monitdir"
}

compress2mp4() {
  docker run -d \
             --rm \
             --name compress2mp4.$(date +%m%d%y%H%M%S) \
             -v $PWD:/home/hckr \
             ghcr.io/ragingtiger/hckr:master \
               ffmpeg -i $1 -c:v libx264 -c:a copy -movflags faststart "compressed.${1%.*}.mp4"
}

convert2mp4() {
  docker run -d \
             --rm \
             --name convert2mp4.$(date +%m%d%y%H%M%S) \
             -v $PWD:/home/hckr \
             ghcr.io/ragingtiger/hckr:master \
               ffmpeg -i $1 -map 0 -movflags faststart "${1%.*}.mp4"
}
