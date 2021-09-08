export VERSION ?= 1.15
MARKDOWN := mbentley/grip@sha256:8f29196870e8c03bccd82d0de256cc1532705bda8e6072bde0872084bcb94298

-include common.mk

dist: README.md src
# build dist target to be linked against
	$(call logger ,enter)
	mkdir -p "$@" "$@"/{src,tmp,env}
	ln -f ./src/main.sh $@/go
	ln -f ./src/common.sh $@/src
	cp -lrf ./env $@

install: export GOBIN=$(PWD)/dist
install: dist
# push GOBIN onto PATH as inline declaration to exec a new shell
	$(call logger ,enter)
	PATH=$(GOBIN):$$PATH exec $(SHELL) -i 3>&-

clean:
# clean target
	$(call logger ,enter)
	rm -rvf dist
