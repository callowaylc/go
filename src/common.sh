#!/usr/bin/false
trap 'teardown $?' EXIT INT TERM
2>&- >&3 || exec 3>/dev/null

logger() { command logger -t "$0#$$" "$@"
# wrap posix logger to redirect to log stream
} 2>&3

enc() { echo $@ | base64 | tr -d \\n
# portable base64 encode with newlines stripped
}

teardown() { logger -sp DEBUG "Teardown" -- "trace=$0" "pid=$$" "status=$1"
# generic handler to log status at exit
}
