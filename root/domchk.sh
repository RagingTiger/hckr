get_dom_args() {
  # check for crunchyroll.com
  if $(echo ${1} | grep -iq 'crunchyroll.com');then
    # return crunchyroll unique args
    echo '--sub-lang enUS --write-sub --embed-subs'
  else
    # return normal args
    echo "--restrict-filename -f best -ciw -o ${2}.${3}"
  fi
}
