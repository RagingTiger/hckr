## About
<p align="center">
  <img src="https://github.com/RagingTiger/docker-hckr/blob/898669be1849ef6ef1c1379cfb73ee8bd374a7da/.hckrmn.png">
</p>

## Features
  + **OS**: `Alpine Linux`
  + **Shell**: `BASH (w/bash-completion)`
  + **Tools**:
    + [`curl`](https://en.wikipedia.org/wiki/CURL)
    + [`ffmpeg`](https://www.ffmpeg.org/)
    + [`gallery-dl`](https://github.com/mikf/gallery-dl)
    + [`git`](https://en.wikipedia.org/wiki/Git)
    + [`openssh`](https://en.wikipedia.org/wiki/OpenSSH)
    + [`python3`](https://docs.python.org/3/)
    + [`rsync`](https://en.wikipedia.org/wiki/Rsync)
    + [`slack-cli`](https://github.com/rockymadden/slack-cli)
    + [`youtube-dl`](https://ytdl-org.github.io/youtube-dl/index.html)
  + **Functions**:
    ```
      get_youtube_video(){
      youtube-dl --restrict-filename -o -ciw '%(title)s.%(ext)s' $1
      }

      get_youtube_audio(){
      youtube-dl -x --audio-format mp3 $1
      }

      get_youtube_playlist(){
      youtube-dl --restrict-filenames -o -ciw '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' $1
      }

      get_youtube_channel(){
      youtube-dl --restrict-filename -o -ciw '%(uploader)s/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' $1
      }
    ```
  + **Convenience Scripts**:
    Located in `/root/ytb2slk.sh` is a script to pull down videos with
    `youtube-dl` and push them to `slack`:
    ```
    # download from youtube, upload to slack
    youtube_2_slack(){
     local payload="ytbdl.$(date +%m%d%y%H%M%S)"
     local channel=${2:-'#general'}
     local message=${3:-"New upload from youtube-dl on $(date)"}
     youtube-dl --restrict-filename -f 'best' -ciw -o "${payload}"'.%(title)s.%(ext)s' $1 && \
     slack file upload -fl "${payload}".* -chs ${channel}  -cm "${message}"
    }

    youtube_2_slack $1 $2 $3
    ```
    Located in `/root/insta2slk.sh` is a script to pull images from websites
    with `gallery-dl` and push them to `slack`:
    ```
    # download from instagram/twitter, upload to slack
    instagram_2_slack(){
      local message=${2:-"New upload from gallery-dl on $(date)"}
      local exstr="slack file upload -fl {} -chs '#general' -cm '${message}'"
      gallery-dl --exec "${exstr}" $1
    }

    instagram_2_slack $1 $2
    ```

## Shell Scripting Examples
The following is a series of example `shell functions` for using the
`ghcr.io/ragingtiger/hckr:master` image. These are meant to be placed in your `.${SHELL}rc` file or
`.profile` but could easily be used in any `*.sh` file.

### Deploying Docker Containers
The following `shell functions` wrap the creation and deployment of `docker
containers` running in daemon mode, that **self-delete** on completion.

#### youtube-dl to Slack pipeline
First we have the `youtube-dl` to `slack` pipeline. The pipeline is created in
the `/root/ytb2slk.sh`. Important to remember to mount the directory containing
the `slack-cli access token` to the `/usr/etc` directory (see
[Slack-CLI Configuration](https://github.com/rockymadden/slack-cli#configuration))
```
# ytb to slk pipeline
ytb2slk() {
  docker run -d \
              --rm \
              --name ytb2slk.$(date  +%m%d%y%H%M%S) \
              -v ~/.hckr:/usr/etc \
              ghcr.io/ragingtiger/hckr:master bash -c "ytb2slk $1 $2 $3
}
```
+ **Usage**: `$ ytb2slk https://youtu.be/oHg5SJYRHA0 'Special surprise :)' '#humor'`
+ **Notes**: The `/root/ytb2slk.sh` script has defaults for `$2` argument two
(i.e. the `channel` name) and `$3` argument three (i.e. the `message`) (see
 [source](https://github.com/RagingTiger/docker-hckr/blob/347c6c2d95b756382916a4b7fc38b3aa6bed0412/root/ytb2slk.sh#L4-L5)
).

#### youtube-dl to rsync
Next we have the `youtube-dl` to `rsync` pipeline. This simply allows you to
download with `youtube-dl` and then `rsync` the files to a different location or
host. **Important to notice the `-v ~/.ssh:/root/.ssh`** which volume mounts your
ssh keys into the container so that you can connect to your remote host:
```
ytb2rsnc(){
  local payload="ytbdl.$(date +%m%d%y%H%M%S)"
  docker run -d \
             --rm \
             --name ytb2rsnc.$(date  +%m%d%y%H%M%S) \
             -v ~/.ssh:/root/.ssh \
             ghcr.io/ragingtiger/hckr:master bash -c "youtube-dl --restrict-filename \
                                              -f 'best' \
                                              -ciw \
                                              -o "${payload}"'.%(title)s.%(ext)s' \
                                              $1 && \
                                   rsync -havP ytbdl.* \
                                          ${USER}@${IP_ADDRESS}:/videos/"

}
```
+ **Usage**: `$ ytb2rsnc https://youtu.be/oHg5SJYRHA0`
+ **Notes**: Make sure to set the values for `USER` and `IP_ADDRESS` for the
  `rsync` command accordingly.

#### Multiple youtube-dl to rsync
As the name implies, this `shell function` is for loading up multiple
`youtube-dl` downloads and using `rsync` to send them to a remote host or
location. **Important to notice the `-v ~/.ssh:/root/.ssh`** which volume mounts
your ssh keys into the container so that you can connect to your remote host:
```
batch_ytb2rsnc(){
  local payload="ytbdl.$(date +%m%d%y%H%M%S)"
  local urls=$(while read line; do echo "$line"; done)
  docker run -d \
            --rm \
            --name ytb2rsnc.$(date  +%m%d%y%H%M%S) \
            -v ~/.ssh:/root/.ssh \
            ghcr.io/ragingtiger/hckr:master \
              bash -c \
              "echo '${urls}' | \
              youtube-dl \
                --batch-file - \
                --restrict-filename \
                --max-sleep-interval 60 \
                --min-sleep-interval 1 \
                -f 'best' \
                -ciw \
                -o "${payload}"'.%(title)s.%(ext)s' \
                --exec 'rsync {} ${USER}@${IP_ADDRESS}:/videos'"
}
```
+ **Usage**: `$ batch_ytb2rsnc < list_of_vid_urls.txt`
+ **Notes**: Make sure to set the values for `USER` and `IP_ADDRESS` for the
  `rsync` command accordingly. The format of the list is simply newline
  terminated URLs like such:
```
$ cat list_of_vid_urls.txt
https://youtu.be/ub82Xb1C8os
https://youtu.be/oHg5SJYRHA0
https://youtu.be/dQw4w9WgXcQ
```

#### gallery-dl to Slack
This `shell function` will use the script located at `/root/insta2slk.sh`, and as
the name implies it will scrape from `instagram` as well as many other image
sharing sites (see [gallery-dl docs](https://github.com/mikf/gallery-dl#gallery-dl))
:
```
# insta to slk pipeline
insta2slk() {
  docker run -d \
             --rm \
             --name insta2slk.$(date  +%m%d%y%H%M%S) \
             -v ~/.hckr:/usr/etc \
             ghcr.io/ragingtiger/hckr:master bash -c "insta2slk $1 $2"
}
```
+ **Usage**: `$ insta2slk https://www.instagram.com/p/B-kHf1UHIpq/`

#### Slack Upload
This will grab a file and push it to `Slack`. It will mount your current
directory (on default) and your `slack-cli` credentials (see
[Slack-CLI Configuration](https://github.com/rockymadden/slack-cli#configuration))
:
```
# slack upload
slackup() {
  docker run -d \
             --rm \
             --name slackup.$(date +%m%d%y%H%M%S) \
             -v ~/.hckr:/usr/etc \
             -v $PWD:/home/hckr \
             ghcr.io/ragingtiger/hckr:master bash -c "slack file upload -fl $1 -chs '#general'"
}
```
+ **Usage**: `$ slackup  yourfile.mkv `

#### Login With BASH
Calling this `shell function` will deploy a `BASH` session in the container,
and mount your current directory:
```
# hack it
hckr() {
  local mountpnt=${1:-"$PWD"}
  docker run --rm -v $mountpnt:/home/hckr -it ghcr.io/ragingtiger/hckr:master
}
```
+ **Usage**: `$ hckr`

### Remotely Launching Scripts
In the [Deploying Docker Containers](#deploying-docker-containers) section we
covered how to write `shell functions` to wrap the configuration and deployment
of `daemon` docker containers. Here we will shows some examples of how to write
some `shell functions` to remotely connect with a `docker` host system (i.e. a
remote server) and launch the deploy scripts (again see
[Deploying Docker Containers](#deploying-docker-containers)). Clearly you will
need to fill out your `USER` name and `IP_ADDRESS` for your remote server.

#### Remote Execute ytb2slk
```
ytb2slk() {
    ssh ${USER}@${IP_ADDRESS} "source ~/.profile && ytb2slk '${1}'"
}
```

#### Remote Execute batch_ytb2rsnc
```
batch_ytb2rsnc() {
  cat ${1} | awk '{printf "%s\n", $1}' | ssh ${USER}@${IP_ADDRESS} 'source ~/.profile && batch_ytb2rsnc'
}
```

#### Remote Execute insta2slk
```
insta2slk() {
      ssh ${USER}@${IP_ADDRESS} "source ~/.profile && insta2slk '${1}'"
}
```
