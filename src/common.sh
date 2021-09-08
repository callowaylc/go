#!/usr/bin/false
trap 'teardown $?' EXIT INT TERM
2>&- >&3 || exec 3>/dev/null

# wrap posix logger to redirect to log stream
logger() { command logger -t "$0#$$" "$@" ;} 2>&3

# wrap mktemp to force deterministic tmpdir path
mktemp() { TMPDIR="${0%/*}/tmp/$$/" mktemp "$@" ;}

# portable base64 encode with newlines stripped
enc() { echo $@ | base64 | tr -d \\n ;}

# generic handler to log status at exit
teardown() {
	logger -sp DEBUG "Teardown" -- "trace=$0" "pid=$$" "status=$1"

	# remove any tmp files specific to the (current) process being torn down
	if [ "${GOBIN-}" ]; then
		rm -rvf "$GOBIN"/tmp/$$ >&3 2>&1
	fi
}
