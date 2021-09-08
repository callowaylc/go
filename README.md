# go

Encapsulates golang runtime in docker container.


- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Composition](#composition)
- [Environment Configuration](#environment-configuration)
  - [Variable Declaration](#variable-declaration)
  - [Overlay](#overlay)
- [Debug](#stdlog)
- [License](#license)

## Requirements

Minimal runtime depedencies: listed versions reflect development environment at the time of latest commit

- GNU Make, 4.3
```sh
~ $ make -v
GNU Make 4.3
Built for x86_64-apple-darwin17.7.0
Copyright (C) 1988-2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```
- Bash, 5.0.18
```sh
~ $ bash --version
GNU bash, version 5.0.18(1)-release (x86_64-apple-darwin17.7.0)
Copyright (C) 2019 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```
- Docker, 19.03.13
```sh
~ $ docker version
Client: Docker Engine - Community
 Cloud integration  0.1.18
 Version:           19.03.13
 API version:       1.40
 Go version:        go1.13.15
 Git commit:        4484c46d9d
 Built:             Wed Sep 16 16:58:31 2020
 OS/Arch:           darwin/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.13
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.13.15
  Git commit:       4484c46d9d
  Built:            Wed Sep 16 17:07:04 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v1.3.7
  GitCommit:        8fba4e9a7d01810a393d5d25a3621dc101981175
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

## Installation

Ephemeral installation of [golang wrapper](src/main.sh), into current shell session.

1\. Clone repository.
```sh
$ path=/tmp/go
$ git clone git@github.com:callowaylc/go $path
Cloning into '/tmp/go'...
remote: Enumerating objects: 11, done.
remote: Counting objects: 100% (11/11), done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 11 (delta 0), reused 11 (delta 0), pack-reused 0
Receiving objects: 100% (11/11), done.
```

2\. Create build target.
```sh
$ pushd $path
/tmp/go ~ ~/Develop/highlight/go ~
$ make
mkdir -p "dist" "dist"/src
...
```

3\. Install into current shell session.
```sh
$ which go
/usr/local/bin/go
$ file /usr/local/bin/go
/usr/local/bin/go: Mach-O 64-bit executable x86_64
$ make install
$ which go
/tmp/go/dist/go
$ file /tmp/go/dist/go
/tmp/go/dist/go: POSIX shell script text executable, ASCII text
```

## Usage

Please review [official documentation](https://golang.org/cmd/go/) for golang command line tool.
https://golang.org/cmd/go/

```sh
$ go help
Go is a tool for managing Go source code.

Usage:

  go <command> [arguments]
```

## Composition

Descriptions for notable repository files and concepts.

- [Makefile](./Makefile): A prefabbed interface to the repository
- [env](./env): Runtime environment configuration
- [env/base](./env/base): Baseline configuration available to all invocations of tool
- [src/main.sh](./src/main.sh): The golang runtime/docker wrapper
-

## Environment Configuration

Exporting environment variables ("envs") to the runtime must be **explicitly declared** in [GOENV environment configuration](https://golang.org/cmd/go/#hdr-Environment_variables) files.

### Variable Declaration

Envs are declared (and optionally defined) in dotenv style (and shell compliant) files, that declare (and optionally define) name/value pairs.
```sh
$ $ cat env/base
#!/usr/bin/false
## Adds key, value pairs as environment variables to go cmd runtime
## https://golang.org/cmd/go/#hdr-Environment_variables
## https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file

# Declare variable and assign nil value
GOOS=
GOARCH=

# Declare variable and use value exported to local
# environment, if any
HELLO

# Declare variable and assign value
FRANKIE=heart
```

List envs available to golang runtime by running `example/envs.go`.
```sh
$ which go
/Users/christian/Develop/highlight/go/dist/go
$ go run example/envs.go
HOSTNAME=> 893ac30c4dc8
PATH => /go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME => 893ac30c4dc8
FRANKIE => heart
GOARCH =>
GOOS =>
DOCKER => true
CONTAINER => true
GOLANG_VERSION => 1.15.7
GOPATH => /go
HOME => /root
```

Repeat with inline (re-)definition of `HELLO`.
```sh
# Variable `HELLO` is declared but not bound to defined value.
$ cat env/base | grep -i hello
HELLO
```
```sh
# Assign "world" to variable `HELLO`, both inline and within current scope
$ HELLO=world go run example/envs.go  | grep -i hello
HELLO => world
$ HELLO=bye go run example/envs.go  | grep -i hello
HELLO => bye
```

Repeat with inline declaration of variable `FUBAR`.
```sh
# Variable `FUBAR` is not declared in existing configuration.
$ ls -1 env
base
build
run
$ cat env/* | grep -i -- fubar
$ echo $?
1
```
```sh
# Variable `FUBAR` is not availabe in runtime.
$ FUBAR=rabug HELLO=world2 go run example/envs.go  | grep -Ei -- 'hello|fubar'
HELLO => world2
```

Declare `FUBAR` in `dist/env/base` to make available to the runtime.
```sh
$ echo FUBAR=rabuf | tee -a dist/env/base
FUBAR=rabuf

```
```sh
# Check runtime envs again
$ go run example/envs.go | grep -i -- fubar
FUBAR => rabuf
$ echo $?
0
```
### Configuration Overlay

Environment configuration can be split into multiple files, that can be overlaid (atop one another) and presented as a single composite to the runtime. Merge direction follows an established convention, allowing us to strategize precedence, relative to the action being taken. Operators should limit use/reliance on configuration overlays, given that there isn't an official analogue and that it's raison d'etre is to compensate for differences (os, arch, etc) between host and golang runtime.





## DEBUG

The [wrapper](src/main.sh) workflow defines an [additional file descriptor](https://github.com/callowaylc/go/blob/master/src/common.sh#L3), **/dev/fd/3** which receives logger messages and debug payloads.

- By default, STDLOG writes are against /dev/null.
```sh
$ go run example/exitwith.go 3
exit status 3
```

- Redirecting `&3` to STDERR will reveal "STDLOG" payloads
```sh
$ go run example/exitwith.go 0 3>&2
Jan 15 00:18:19  /Users/christian/Develop/highlight/go/dist/go#15496[15502] <Debug>: Main -- cnVuIGV4YW1wbGUvZXhpdHdpdGguZ28gMAo=
docker run --rm --env CONTAINER=true --env DOCKER=true --volume /Users/christian/Develop/highlight/go:/opt/main:rw --workdir /opt/main --env "GOOS=" --env "GOARCH=" golang:1.15 go run example/exitwith.go 0
Jan 15 00:18:20  /Users/christian/Develop/highlight/go/dist/go#15496[15515] <Debug>: Teardown -- trace=/Users/christian/Develop/highlight/go/dist/go pid=15496 status=0
```

## License

[MIT](https://choosealicense.com/licenses/mit/)

