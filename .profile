# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# cpu temp
cpu_temp() {
  echo "$(cat /sys/class/thermal/thermal_zone*/temp) mC"
}

# ytb to slk pipeline
ytb2slk() {
  docker run -d \
             --rm \
             --name ytb2slk.$(date  +%m%d%y%H%M%S) \
             -v ~/.hckr:/usr/etc \
             -e UPLD_NM="$2" \
             -e SLACKUP='true' \
             tigerj/hckr bash -c "ytb2slk $1 '#meeting' '$1'"
}

# slack upload
slackup() {
  docker run -d \
             --rm \
             --name slackup.$(date +%m%d%y%H%M%S) \
             -v ~/.hckr:/usr/etc \
             -v $PWD:/home/hckr \
             tigerj/hckr  bash -c "slkup $1 '#meeting' $2"
}

# hack it
hckr() {
  local mountpnt=${1:-"$PWD"}
  docker run --rm -v $mountpnt:/home/hckr -it tigerj/hckr
}

# insta to slk pipeline
insta2slk() {
  docker run -d \
             --rm \
             --name insta2slk.$(date  +%m%d%y%H%M%S) \
             -v ~/.hckr:/usr/etc \
             tigerj/hckr bash -c "insta2slk $1 '$1'"
}

# setup buildx
setup_buildx() {
  docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64 && \
  docker buildx create --use --name mybuilder
}

# new and improved
scrp2slk() {
  docker run -d \
             --rm \
             --name scrp2slk.$(date  +%m%d%y%H%M%S) \
             -v ~/.hckr:/usr/etc \
             -e UPLD_NM="$2" \
             -e SLACKUP='true' \
             tigerj/hckr bash -c "scrp2slk $1 '#meeting' '$1'"
}
