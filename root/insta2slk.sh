# download from instagram/twitter, upload to slack
instagram_2_slack(){
  # check if pushing to slack
  if [ ! -z "$SLACKUP" ]; then
    # create message
    local message=${2:-"New upload from gallery-dl on $(date)"}

    # create string to be executed
    local exstr="slack file upload -fl {} -chs '#meeting' -cm '${message}'"

    # start
    gallery-dl --exec "${exstr}" $1

  else
    # just run normally
    gallery-dl $1

  fi
}

instagram_2_slack $1 $2
