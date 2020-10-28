# globals
VID_SZ_LIMIT=400000000

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
       "into $parts parts, ~$(tstmp $part_secs)s long each. <<<"

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

split_for_slack() {
  # check if video is > 500MB
  if [ $(ls -la "${1}" | awk '{print $5}') -gt $VID_SZ_LIMIT ]; then

    # find halfway point in video and store in cuts.txt (lib: pyldsplt)
    gen_cuts_txt "${1}"

    # setup local var for input file name
    local in_file="${1}"

    # start splitting vid in parallel (using default ALL cores)
    cat cuts.txt | parallel --eta --colsep ' ' \
                            ffmpeg -i ${in_file} -ss {2} -to {3} -c copy {1}

    # finally start pushing to slack
    while read -r -u 3 filename start end; do

      # alert
      printf "\n>>>\n + Now uploading to Slack: ${filename}\n<<<\n" && \

      # push to slack
      slack file upload -fl "${filename}" -chs ${channel}  -cm "${message}"
    done 3< cuts.txt

  else
    # file size is good then just push to Slack
    slack file upload -fl "${1}" -chs ${channel}  -cm "${message}"
  fi
}
