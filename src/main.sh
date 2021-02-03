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
env="$( tmppath env )" # path to composite env, eg dist/tmp/$$/$name.xxx

## main
logger -sp DEBUG "Main" -- \
	"gobin=$GOBIN" \
	"goenv=$GOENV" \
	"version=$VERSION" \
	"action=$action" \
	"composite=$env" \
	"argv=$(enc "$@")"

# deterministic merge of dotenv (like) files with the latter-most taking
# precedence; invalid paths and duplicates have no effect on result set.
dirname $env | xargs mkdir -pv >&3 2>&1
cat $GOENV $GOBIN/env/base $GOBIN/env/$action 2>&3 \
	| sort -u -t"=" -k"1,1" \
	| tee $env >&3

cat <<eof | tee /dev/fd/3 | sh -eu
docker run \
	-i \
	--rm \
	--env "CONTAINER=true" \
	--env "DOCKER=true" \
	--env-file $env \
	--volume "$PWD:/opt/main:rw" \
	--volume "$env:/root/.config/go/env" \
	--workdir /opt/main \
golang:$VERSION go ${@:-help}

eof
