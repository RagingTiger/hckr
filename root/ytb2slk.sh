# globals
VID_SZ_LIMIT=500000000

# funcs
get_num_parts(){
  # get overall size
  local file_size=$(ls -la "${1}" | awk '{print $5}')

  # set initial i
  local parts=1

  # find parts number
  while true; do
    # divide file size by parts number
    if [ $(echo "$file_size / $parts + 1" | bc ) -lt $VID_SZ_LIMIT ]; then
      # if size per part is < 500MB return parts and break
      echo $parts
      break
    else
      # need more parts
      (( parts++ ))
    fi
  done
}

tstmp(){
  # take input and echo back hh:mm:ss time stamp
  echo $(date -d@$1 -u +%H:%M:%S)
}

gen_cuts_txt(){
  # get number of parts to split into
  local parts=$(get_num_parts $1)

  # get end hh:mm:ss time stamp
  local end="$(ffprobe -i "${1}" 2>&1 | grep "Duration"| cut -d ' ' -f 4 | \
               sed s/,//)"

  # convert end time stamp to seconds
  local end_secs="$(echo "${end}" | \
                    awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')"

  # divide end seconds time stamp into N parts (rounded up)
  local part_secs=$(echo "${end_secs%.*} / $parts + 1 " | bc)

  # alert
  echo ">>> File too big. Splitting $end long video" \
       "into $parts parts, ~${part_secs}s long each. <<<\n"

  # setup index (i), in timestamp, out timestamp
  local i=0
  local in_tm=""
  local out_tm=""

  # start loop
  while [ $(echo "$i + 1" | bc) -lt $parts ]; do
    # calculate the beginning time of file part (in seconds)
    in_tm=$(echo "$part_secs * $i" | bc)

    # calculate the ending time of file part (in seconds)
    out_tm=$(echo "$part_secs * ($i + 1)" | bc)

    # increment
    (( i++ ))

    # add time stamps and part name to cuts.txt
    printf "Part${i}_${1} $(tstmp $in_tm) $(tstmp $out_tm)\n" >> cuts.txt
  done

  # add final time stamps and part name to cuts.txt
  in_tm=$(echo "$part_secs * $i" | bc)
  (( i++ ))
  printf "Part${i}_${1} $(tstmp $in_tm) $end \n" >> cuts.txt
}

# main program execution block
main(){
  # first setup some variables
  local payload="ytbdl.$(date +%m%d%y%H%M%S)"
  local channel=${2:-'#meeting'}
  local message=${3:-"New upload from youtube-dl on $(date)"}

  # next get the video and exit if command fails
  youtube-dl --restrict-filename -f 'best' -ciw -o "${payload}"'.%(title)s.%(ext)s' $1 && \

  # check if video is > 500MB
  if [ $(ls -la "${payload}".* | awk '{print $5}') -gt $VID_SZ_LIMIT ]; then
    # first get download filename
    local dwnld=$(ls "${payload}".*)

    # next find halfway point in video and store in cuts.txt
    gen_cuts_txt $dwnld

    # finally start splitting video and pushing to slack
    while read -r -u 3 filename start end; do
      # alert
      printf "\n>>>\n + Copying: $filename from $start to $end\n<<<\n"

      # start copying half of video
      ffmpeg -i "${dwnld}" -ss "${start}" -to "${end}" -c copy "${filename}" && \

      # alert
      printf "\n>>>\n + Now uploading to Slack: ${filename}\n<<<\n" && \

      # push to slack
      slack file upload -fl "${filename}" -chs ${channel}  -cm "${message}"
    done 3< cuts.txt

  else
    # file size is good then just push to Slack
    slack file upload -fl "${payload}".* -chs ${channel}  -cm "${message}"
  fi
}

# executable
main $1 $2 $3
