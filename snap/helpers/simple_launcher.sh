#!/bin/bash

source $SNAP/bin/directorySetup.sh

# Set usernames for gogs
export USERNAME=root
export USER=root

cd $SNAP/gogs/; ./gogs $@
