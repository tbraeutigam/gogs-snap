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
if [ -z $1 ] || [ "$1" = "web" ]; then
  echo "Executing: $SNAP/bin/gogs web -c $appini"
  cd $SNAP/bin
  exec ./gogs web -c $appini
elif [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  less $SNAP/README.md
  exit 0
elif [ "$1" = "cert" ]; then
  if [ "$2" = "help" ] || [ "$2" = "-h" ] || [ "$2" = "--help" ]; then
    echo "Executing: $SNAP/bin/gogs $@"
    cd $SNAP/bin; exec ./gogs cert --help
    exit 0
  fi
  echo "Executing: $SNAP/bin/gogs $@ -o $SDATA/certs"
  cd $SNAP/bin; exec ./gogs $@ -o $SDATA/certs
elif [ "$1" = "direct" ]; then
  para=$(echo "$@" | sed 's_^direct __')
  echo "Executing $SNAP/bin/gogs $para"
  cd $SNAP/bin; exec ./gogs $para
fi
