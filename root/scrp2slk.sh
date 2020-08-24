main(){
  set -x
  # check for instagram.com
  if $(echo ${1} | grep -iq 'instagram.com');then
    # execute insta2slk
    source /root/insta2slk.sh $1 
  else
    # exec ytb2slk
    source /root/ytb2slk.sh $1 $2 $3
  fi
}

main $1 $2 $3
