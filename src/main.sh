#!/bin/sh
# Encapsulates golang runtime in docker container
set -eu
. "$( dirname $0 )"/src/common.sh

## env
: ${GOENV:?required}
: ${VERSION:=1.15}

argv=$@
action=$1

## main
logger -sp DEBUG "Main" -- "$(enc "$@")"

dirname $GOENV \
	| xargs -I% -- echo %/$action \
	| xargs -- sh -c '! cat $@ 2>&-' _ \
	| sort -u -t"=" -k"1,1" - $GOENV \
	| tee /dev/fd/3 \
	| { echo docker run \
				-i \
				--rm \
				--env "CONTAINER=true" \
				--env "DOCKER=true" \
				--env-file /dev/stdin \
				--volume "$PWD:/opt/main:rw" \
				--volume "$GOENV:/root/.config/go/env" \
				--workdir /opt/main \
			golang:$VERSION go ${@:-help}
		} \
	| tee /dev/fd/3 \
	| sh -eu
