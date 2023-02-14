# btwifi-daemon

- Bash script to maintain a [BTWiFi](https://www.btwifi.co.uk) login
- Runs in the background or interactively for debugging
- supplies username and password from btwifi-daemon.config

## Interactive Usage:

```
$ btwifi-daemon.sh
```

## Background Task:

Add this to the bottom of `/etc/rc.local`:

```
$ echo /path/to/btwifi-daemon.sh & >> /etc/rc.local
```
