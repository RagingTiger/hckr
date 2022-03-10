main(){
  # set necessary vars
  local program=${1:-'/root/notifyslack.sh'}

  # alert stdout
  echo "Monitoring /home/hckr and executing $program on new file additions."

  # begin monitoring
  inotifyd "$program" /home/hckr:yn
}

main $1
