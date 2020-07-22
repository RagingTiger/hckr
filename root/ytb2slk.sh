gen_cuts_txt(){
  # damn this is a lot of SHHHHH!!!TTTT
  #
  # get start hh:mm:ss time stamp
  local start="00:00:00"

  # get end hh:mm:ss time stamp
  local end="$(ffprobe -i "${1}" 2>&1 | grep "Duration"| cut -d ' ' -f 4 | \
               sed s/,//)"

  # convert end time stamp to seconds
  local end_secs="$(echo "${end}" | \
                    awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')"

  # divide end seconds time stamp in half (with decimal point removed)
  local half_secs="$(echo $(( ${end_secs%.*} / 2 )))"

  # finally convert halfway point to hh:mm:ss time stamp
  local half="$(date -d@${half_secs%.*} -u +%H:%M:%S)"

  # now write out to cuts.txt
  printf "Part_1_${1} ${start} ${half}\n" >> cuts.txt
  printf "Part_2_${1} ${half} ${end%.*}\n" >> cuts.txt
}


# download from youtube, upload to slack
youtube_2_slack(){
  # first setup some variables
  local payload="ytbdl.$(date +%m%d%y%H%M%S)"
  local channel=${2:-'#meeting'}
  local message=${3:-"New upload from youtube-dl on $(date)"}

  # next get the video
  youtube-dl --restrict-filename -f 'best' -ciw -o "${payload}"'.%(title)s.%(ext)s' $1 && \
  # check if video is too big
  if [ $(ls -la "${payload}".* | awk '{print $5}') -gt 400000000 ]; then
    # alert
    printf "\n>>> File too big will be split in half <<<\n"

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

youtube_2_slack $1 $2 $3
