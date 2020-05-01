# download from instagram/twitter, upload to slack
instagram_2_slack(){
  local message=${2:-"New upload from gallery-dl on $(date)"}
  local exstr="slack file upload -fl {} -chs '#meeting' -cm '${message}'"
  gallery-dl --exec "${exstr}" $1
}

instagram_2_slack $1 $2 
