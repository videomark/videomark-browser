SRCDIR=../../../chromium/src

all: build install

build:
	cd ../videomark && ./bin/build-android

install:
	rm -rf $(SRCDIR)/sodium* $(SRCDIR)/content_script.js
	cd $(SRCDIR) && cp -r $(CURDIR)/../videomark/dist/android/* .

yarn-install:
	cd ../videomark && yarn install

.PHONY: all build install yarn-install
