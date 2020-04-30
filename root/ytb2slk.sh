# download from youtube, upload to slack
youtube_2_slack(){
  local payload="ytbdl.$(date +%m%d%y%H%M%S)"
  local channel=${2:-'#general'}
  local message=${3:-"New upload from youtube-dl on $(date)"}
  youtube-dl --restrict-filename -f 'best' -ciw -o "${payload}"'.%(title)s.%(ext)s' $1 && \
  slack file upload -fl "${payload}".* -chs ${channel}  -cm "${message}"
}

youtube_2_slack $1 $2 $3
