# GOGS snap

[![Snap Status](https://build.snapcraft.io/badge/tbraeutigam/gogs-snap.svg)](https://build.snapcraft.io/user/tbraeutigam/gogs-snap)

This is a revamp/rewrite of the original [gogs snap](https://github.com/ubuntu/snappy-playpen/tree/master/gogs) from the snappy playpen.

[Gogs](https://github.com/gogits/gogs) is a self-hosted Git service similar to gitlab and github, written in Go.

This snap provides a quick and easy way to install the latest version of gogs via:
`sudo snap install gogsgit`

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

If you are looking to use *any* of the `gogsgit.cmd` in conjunction with the
daemon, you have to use `sudo` (or your preferred way of starting with root).
Otherwise the commands will run under your user and assume the below User-Mode.

## User-Mode

Gogs can also be launched by any user.
It will then use the `$SNAP_USER_DATA` and `$SNAP_USER_COMMON` locations to store its data.

Please note that when launching in user mode there is
no check for whether the port is already taken or not.
If you haven't disabled the root daemon, you will likely
need to modify `$SNAP_USER_DATA/app.ini` and give it a new port number.

## Commands

| Command              | Description                                                         |
| -------------------- | ------------------------------------------------------------------- |
| gogsgit              | Start the daemon                                                    |
| gogsgit cert         | run gogs cert with pre-filled output dir (`$SNAP_DATA/certs/`)      |
| gogsgit enableHttps  | Sets standard changes to `app.ini` as required for https            |
| gogsgit direct [cmd] | Runs `cmd` directly via gogs. No customizations to commandline      |
|                      |                                                                     |
| gogsgit.help         | Displays this `README.md` file                                      |
| gogsgit.backup       | Runs `gogs backup`. Autofills `app.ini`-location if not provided.   |
| gogsgit.restore      | Runs `gogs restore`. Autofills `app.ini`-location if not provided.  |
| gogsgit.import       | Runs `gogs import`. Autofills `app.ini`-location if not provided.   |
| gogsgit.hook         | Runs `gogs hook`. Autofills `app.ini`-location if not provided.     |
| gogsgit.web          | Runs `gogs web`. Autofills `app.ini`-location if not provided.      |
| gogsgit.sqlite       | Runs an in-snap `sqlite3` to allow database manipulation            |

Note: _You can append `--help` to any `gogsgit.[cmd]` to find out more about the command._
FIXME: `gogsgit direct admin` will not work. There is no way to specify which gogs-instance to use at the moment. Possibly requires upstream change.

## Current state

Somewhat tested functionality:
 * sqlite3 as DB-backend (no other ones tried)
 * Basic Gogs functionality with the default daemon
 * Setting up https with self-signed certificates for daemon

## TODO
 * Provide more full command documentation
 * Maybe: provide a simple config setter/getter
 * Migrate to go-plugin/fix go-plugin build for gogs
 * Write a better patch for adding a output dir for self-signing certs
   and upstream it.
