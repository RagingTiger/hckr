# local shell libs
source /root/pyldsplt.sh
source /root/domchk.sh

# main program execution block
main(){
  set -x
  # first setup some variables
  local channel=${2:-'#meeting'}
  local message=${3:-"New upload on $(date)"}

  # create temporary cache dir
  local cache_dir=".ytbdl_$(date +%S%M%H%d%m%y)_cache"
  echo "Creating cache directory: $cache_dir"
  mkdir $cache_dir

  # set vidtitle
  local vid_title="${cache_dir}/%(title)s.%(ext)s"

  # check if custom uploand name is set
  if [ ! -z "$UPLD_NM" ]; then
    # set to custom uplod name with extension
    vid_title="${cache_dir}/$UPLD_NM.%(ext)s"

    # alert
    echo "Using custom upload name: $UPLD_NM"
  fi

  # get domain-specific args (lib: domchk)
  local dom_args="$(get_dom_args ${1} ${vid_title})"

  # next get the video and exit if command fails
  youtube-dl ${dom_args} ${1}

  # now cleanse filename of special chars
  mv "${cache_dir}/$(ls ${cache_dir})" "${cache_dir}/$(ls ${cache_dir} | sed 's/[^a-zA-Z0-9.\_-]//g')"

  # check if pushing to slack
  if [ ! -z "$SLACKUP" ]; then
    # get file name
    local dwnld="$(ls $cache_dir)"

    # prepare for slack (lib: pyldsplt)
    split_for_slack "${cache_dir}/${dwnld}"
  fi
}

# executable
main $1 $2 $3
