#!/usr/bin/false
trap 'teardown $?' EXIT INT TERM
2>&- >&3 || exec 3>/dev/null

logger() { command logger -t "$0#$$" "$@"
# wrap posix logger to redirect to log stream
} 2>&3

enc() { echo $@ | base64 | tr -d \\n
# portable base64 encode with newlines stripped
}

teardown() {
# generic handler to log status at exit
	logger -sp DEBUG "Teardown" -- "trace=$0" "pid=$$" "status=$1"

	# remove any tmp files specific to the (current) process being torn down
	if [ "${GOBIN-}" ]; then
		rm -rvf "$GOBIN"/tmp/$$ >&3 2>&1
	fi
}

tmppath() { local tmpl=$1
# generates a temporary file path, following the convention $GOBIN/tmp/$$
# and using the given tmpl
	printf "%s/tmp/%s/%s" "$GOBIN" "$$" "$tmpl"
}
