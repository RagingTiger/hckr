# local shell libs
source /root/pyldsplt.sh
source /root/domchk.sh

# main program execution block
main(){
  set -x
  # first setup some variables
  local payload="ytbdl.$(date +%m%d%y%H%M%S)"
  local channel=${2:-'#meeting'}
  local message=${3:-"New upload on $(date)"}
  local vid_title='%(title)s.%(ext)s'

  # check if custom uploand name is set
  if [ ! -z "$UPLD_NM" ]; then
    # set to custom uplod name with extension
    vid_title="$UPLD_NM.%(ext)s"

    # alert
    echo "Using custom upload name: $UPLD_NM"
  fi

  # get domain-specific args (lib: domchk)
  local dom_args="$(get_dom_args ${1} ${payload} ${vid_title})"

  # next get the video and exit if command fails
  youtube-dl ${dom_args} ${1}

  # get file name
  local dwnld="$(ls "${payload}".*)" && \

  # check if pushing to slack
  if [ ! -z "$SLACKUP" ]; then
    # prepare for slack (lib: pyldsplt)
    split_for_slack "${dwnld}"
  fi
}

# executable
main $1 $2 $3
