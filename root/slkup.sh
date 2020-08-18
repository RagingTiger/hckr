# local shell libs
source /root/pyldsplt.sh

# main program execution block
main(){
  # first setup some variables
  local vid_title="${1}"
  local channel=${2:-'#meeting'}
  local message=${3:-"New upload from youtube-dl on $(date)"}

  # check if custom uploand name is set
  if [ ! -z "$UPLD_NM" ]; then
    # get extension of current file
    local extension=$(echo "${vid_title#*.}")

    # set to custom upload name with extension
    vid_title="$UPLD_NM.${extension}"

    # alert
    echo "Using custom upload name: $UPLD_NM"
  fi

  # prepare for slack (lib: pyldsplt)
  split_for_slack "${vid_title}"
}

# executable
main $1 $2 $3
