#!/bin/bash

SDATA=''; SCOMMON='';
if env | grep -q root; then
  export SDATA=$(echo $SNAP_DATA | sed s!$SNAP_REVISION!current!)
  export SCOMMON="$SNAP_COMMON"
else
  export SDATA=$(echo $SNAP_USER_DATA | sed s!$SNAP_REVISION!current!)
  export SCOMMON="$SNAP_USER_COMMON"
fi

export appini="$SDATA/app.ini"

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
            $SDATA/$dir/ 2>/dev/null
    fi
  done
}
