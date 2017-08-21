#!/bin/bash
source $SNAP/bin/directorySetup.sh

# Set usernames for gogs
export USERNAME=root
export USER=root

if [ ! -f $appini ]; then
  echo "app.ini not found. Initializing Configuration."
  out=$(sed s!SNAP_DIR_DATA!$SDATA!g $SNAP/app.ini)
  out=$(echo "$out" | sed s!SNAP_DIR_COMMON!$SCOMMON!g)
  echo "$out" > $appini
fi

mkdirData   certs              \
            sshkeytest         \
            static/templates   \
            static/scripts     \
            static/public      \

mkDirCommon pictures           \
            repositories       \
            attachments        \
            log

# Configure Git to use the right templates
mkdir -p $SDATA/git/
cp -r --preserve=mode $SNAP/usr/share/git-core/templates $SDATA/git/
git config --global init.templateDir $SDATA/git/templates/

# Implement a minimal help/minimal interface

case "$1" in
  help)
      less $SNAP/README.md
      exit 0
    break;;
  enableHttps)
      grep -q 'https://' $appini && \
        echo "Already enabled. If not, please manually edit $appini" && \
        exit 1
      env | grep -q root || \
        ( echo "You're not running as root. Please manually edit $appini" && \
        exit 1 )

      sed -i 's!\(ROOT_URL\ \ \ \ \ \ \ \ \ \ =\ http\):!\1s:!g' $appini
      sed -i 's!:3001!!g' $appini
      sed -i 's!^PROTOCOL\ \ \ \ \ \ \ \ \ \ =\ http$!\0s!' $appini
      sed -i 's!\(HTTP_PORT\ \ \ \ \ \ \ \ \ =\) 3001!\1\ 443!' $appini
      echo "Please restart the service:"
      echo "systemctl restart snap.$SNAP_NAME.$SNAP_NAME.service"
    break;;
  snap)
    para=$(echo "$@" | sed 's_^snap __')
    if echo "$para" | grep -q 'app.ini'; then
      cd $SNAP/bin; exec ./gogs $para
    else
      cd $SNAP/bin; exec ./gogs $para -c $appini
    fi
    break;;
  direct)
    para=$(echo "$@" | sed 's_^direct __')
    cd $SNAP/bin; exec ./gogs $para
    break;;
  *)
    cd $SNAP/bin; exec ./gogs web -c $appini
    break;;
esac
