#!/usr/bin/make -f

RESDIR=$(CURDIR)/sodium/chrome/browser/resources
SRCDIR=$(CURDIR)/../../chromium/src

all: clean sodium.js videomark-log-view deploy

clean:
	rm -rf $(RESDIR)
	mkdir -p $(RESDIR)

sodium.js:
	cd $(CURDIR)/sodium.js && npm run build
	cp $(CURDIR)/sodium.js/dist/sodium.js $(RESDIR)/sodium.js

videomark-log-view:
	cd $(CURDIR)/videomark-log-view && npm run build-android
	cp -r $(CURDIR)/videomark-log-view/build $(RESDIR)/sodium_result

deploy:
	rm -rf $(SRCDIR)/chrome/browser/resources/sodium*
	cp -r $(CURDIR)/sodium/* $(SRCDIR)

.PHONY: all clean sodium.js videomark-log-view deploy
