#!/bin/bash
source $SNAP/bin/directorySetup.sh

# Set usernames for gogs
export USERNAME=root
export USER=root

# Implement a minimal help/minimal interface
case "$1" in
  help)
      less $SNAP/README.md
      exit 0
    ;;
  cert)
    cd $SNAP/bin; exec ./gogs $@ -o $SDATA/certs/
    ;;
  enableHttps)
      grep -q 'https://' $appini && \
        echo "Already enabled. If not, please manually edit $appini" && \
        exit 1
      env | grep -q root || \
        ( echo "You're not running as root. Please manually edit $appini" && \
        exit 0 )

      sed -i 's!\(ROOT_URL\ \ \ \ \ \ \ \ \ \ =\ http\):!\1s:!g' $appini
      sed -i 's!:3001!!g' $appini
      sed -i 's!^PROTOCOL\ \ \ \ \ \ \ \ \ \ =\ http$!\0s!' $appini
      sed -i 's!\(HTTP_PORT\ \ \ \ \ \ \ \ \ =\) 3001!\1\ 443!' $appini
      echo "Please restart the service:"
      echo "systemctl restart snap.$SNAP_NAME.$SNAP_NAME.service"
      exit 0
    ;;
  snap)
    para=$(echo "$@" | sed 's_^snap __')
    if echo "$para" | grep -q -e 'app.ini'; then
      cd $SNAP/bin; exec ./gogs $para
    else
      cd $SNAP/bin; exec ./gogs $para -c $appini
    fi
    ;;
  direct)
    para=$(echo "$@" | sed 's_^direct __')
    cd $SNAP/bin; exec ./gogs $para
    ;;
  *)
    cd $SNAP/bin; exec ./gogs web -c $appini
    ;;
esac
