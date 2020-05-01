## About
<p align="center">
  <img src="https://github.com/RagingTiger/docker-hckr/blob/898669be1849ef6ef1c1379cfb73ee8bd374a7da/.hckrmn.png">
</p>

## Features
  + **OS**: `Alpine Linux`
  + **Shell**: `BASH (w/bash-completion)`
  + **Tools**:
    + [`ffmpeg`](https://www.ffmpeg.org/)
    + [`python3`](https://docs.python.org/3/)
    + [`gallery-dl`](https://github.com/mikf/gallery-dl)
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
