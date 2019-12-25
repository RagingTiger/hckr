# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

export PS1='\u@\h:\W \$ '

## convenience functions
get_youtube_video(){
  youtube-dl --restrict-filename -o '%(title)s.%(ext)s' $1
}

get_youtube_audio(){
  youtube-dl -x --audio-format mp3 $1
}

get_youtube_playlist(){
  youtube-dl --restrict-filenames -ciw -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' $1
}

get_youtube_channel(){
  youtube-dl --restrict-filename -ciw -o '%(uploader)s/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' $1
}

# download from youtube, upload to slack
youtube_2_slack(){
  local payload="ytbdl.$(date +%m%d%y%H%M%S)"
  local channel=${2:-'#general'}
  local message=${3:-"New upload from youtube-dl on $(date)"}
  youtube-dl --restrict-filename -ciw -o "${payload}"'.%(title)s.%(ext)s' $1 && \
  slack file upload -fl "${payload}".* -chs ${channel}  -cm "${message}"
}

# alias for youtube_2_slack
alias ytb2slk='youtube_2_slack'


## banner
cat /root/fsociety.dat
