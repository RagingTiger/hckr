#!/bin/sh

main(){
  # notify slack
  slack chat send "$NOTIFYMSG" "$NOTIFYCHNL"
}

main
