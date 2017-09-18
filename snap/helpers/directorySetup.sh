#!/bin/bash

SDATA=''; SCOMMON='';
if env | grep -q root; then
  export SDATA=$(echo $SNAP_DATA | sed s!$SNAP_REVISION!current!)
  export SCOMMON="$SNAP_COMMON"
  export isRoot=`true`
else
  echo "You are not running gogs as root. This is required for the snap package."
  echo "Please re-run as root."
  exit 1
fi

export appini="$SDATA/custom/conf/app.ini"

function mkDirCommon(){
  for dir in $@; do
    mkdir -p "$SCOMMON/$dir"
  done
}

function mkdirData(){
  for dir in $@; do
    mkdir -p "$SDATA/$dir"
    if [ -d $SNAP/$dir ]; then
      cp -r --preserve=mode           \
            $SNAP/$dir/*              \
            $SNAP/$dir/.[a-zA-Z0-9-]* \
            $SDATA/$dir/ 2> $SCOMMON/log/snap-mkdirData.log
    fi
  done
}

if [ ! -f $appini ]; then
  echo "app.ini not found. Initializing Configuration."
  out=$(sed s!SNAP_DIR_DATA!$SDATA!g $SNAP/gogs/snapApp.ini)
  out=$(echo "$out" | sed s!SNAP_DIR_COMMON!$SCOMMON!g)
  echo "$out" > $appini
fi

mkdirData   certs              \
            sshkeytest         \
            custom/conf        \
            static/templates   \
            static/scripts     \
            static/public

mkDirCommon pictures           \
            repositories       \
            attachments        \
            data               \
            log

# Configure Git to use the right templates
mkdir -p $SDATA/git/
cp -r --preserve=mode $SNAP/usr/share/git-core/templates $SDATA/git/
git config --global init.templateDir $SDATA/git/templates/
