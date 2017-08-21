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
  #echo "Executing: $SNAP/bin/gogs web -c $appini"
  cd $SNAP/bin
  exec ./gogs web -c $appini
elif [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  less $SNAP/README.md
  exit 0
elif [ "$1" = "cert" ]; then
  if [ "$2" = "help" ] || [ "$2" = "-h" ] || [ "$2" = "--help" ]; then
    #echo "Executing: $SNAP/bin/gogs $@"
    cd $SNAP/bin; exec ./gogs cert --help
    exit 0
  fi
  #echo "Executing: $SNAP/bin/gogs $@ -o $SDATA/certs"
  cd $SNAP/bin; exec ./gogs $@ -o $SDATA/certs/
elif [ "$1" = "enableHttps" ]; then
  if grep -q 'https://' $appini; then
    echo "Already enabled. If not, please manually edit $appini"
  elif ! env | grep -q root; then
    "You're not running as root. Please manually edit $appini"
  else
    sed -i 's!\(ROOT_URL\ \ \ \ \ \ \ \ \ \ =\ http\):!\1s:!g' $appini
    sed -i 's!:3001!!g' $appini
    sed -i 's!^PROTOCOL\ \ \ \ \ \ \ \ \ \ =\ http$!\0s!' $appini
    sed -i 's!\(HTTP_PORT\ \ \ \ \ \ \ \ \ =\) 3001!\1\ 443!' $appini
    echo "Please restart the service:"
    echo "systemctl restart snap.$SNAP_NAME.$SNAP_NAME.service"
  fi
elif [ "$1" = "direct" ]; then
  para=$(echo "$@" | sed 's_^direct __')
  #echo "Executing $SNAP/bin/gogs $para"
  if echo "$para" | grep -q 'app.ini'; then
    cd $SNAP/bin; exec ./gogs $para
  else
    cd $SNAP/bin; exec ./gogs $para -c $appini
  fi
fi
