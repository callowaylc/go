#!/bin/sh
# Encapsulates golang runtime in docker container
set -eu
. "${0%/*}"/src/common.sh

## env
: ${GOBIN:="${0%/*}"}
: ${GOENV:=/dev/null}
: ${VERSION:=latest}

argv=$@
action=$1 # go $action arg [argn], eg "go build path/to/source"
composite=$( mktemp -ut "env.XXX" )

## main
logger -sp DEBUG "Main" -- \
	"gobin=$GOBIN" \
	"goenv=$GOENV" \
	"version=$VERSION" \
	"action=$action" \
	"composite=$composite" \
	"argv=$(enc "$@")"

# deterministic merge of dotenv (like) files with the latter-most taking
# precedence; invalid paths and duplicates have no effect on result set.
cat $GOBIN/env/$action $GOBIN/env/base $GOENV 2>&3 \
	| sort -u -t"=" -k"1,1" \
	| tee $composite $GOBIN/env/composite >&3

sh -euc "
$(cat <<eof | tee /dev/fd/3
	docker run \
		-it \
		--rm \
		--env "CONTAINER=true" \
		--env "DOCKER=true" \
		--env-file $env \
		--volume "$PWD:/opt/main:rw" \
		--volume "$GOBIN/env/composite:/root/.config/go/env" \
		--workdir /opt/main \
	golang:$VERSION go ${@:-help}
eof
)"

