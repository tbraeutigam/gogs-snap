# GOGS snap

This is a revamp of the original gogs snap from the snappy playpen.

## Default Daemon

This snap launches a daemon with the following defaults:
 * Run on http://localhost:3001/
 * Provide sqlite3 settings OOTB
 * All data stored in `$SNAP_DATA` and `$SNAP_COMMON`
 * Configuration is at `$SNAP_DATA/app.ini`

The daemon can be disabled with:
```bash
systemctl stop snap.$SNAP_NAME.$SNAP_NAME.service
systemctl disable snap.$SNAP_NAME.$SNAP_NAME.service
```

## User-Mode

Gogs can also be launched by any user.
It will then use the `$SNAP_USER_DATA` and `$SNAP_USER_COMMON` locations to store its data.

Please note that when launching in user mode there is
no check for whether the port is already taken or not.
If you haven't disabled the root daemon, you will likely
need to modify `$SNAP_USER_DATA/app.ini` and give it a new port number.

## Current state

Somewhat tested functionality:
 * sqlite3 as backend (no other ones tried)
 * Create repository
 * Clone repository
 * Create branch
 * Upload file
 * Create PR/Merge PR
 * Create Wiki pages
 * Create issues
 * Create self-signed certificates
 * HTTPS Server

TODO:
 * Make it build on Ubuntu 16.04 (which misses `the golang-1.8-go` package)
 * Maybe: provide a simple config setter/getter
 * Migrate to go-plugin/fix go-plugin build for gogs
 * Write a better patch for adding a output dir for self-signing certs
   and upstream it.
