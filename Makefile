VERSION ?= 1.15
MARKDOWN := mbentley/grip@sha256:8f29196870e8c03bccd82d0de256cc1532705bda8e6072bde0872084bcb94298

-include common.mk

dist: README.md src
# build dist target to be linked against
	$(call logger ,enter)
	mkdir -p "$@" "$@"/src
	ln -f ./src/main.sh $@/go
	ln -f ./README.md $@
	ln -f ./src/common.sh $@/src
	cp -lrf ./env $@

install: dist
# push dist onto PATH as inline declaration to exec a new shell
		$(call logger ,enter)
		PATH=$(PWD)/dist:$(PATH) \
		GOENV=$(PWD)/dist/env/base \
			exec $(SHELL) -i

clean:
# clean target
	$(call logger ,enter)
	rm -rvf dist
