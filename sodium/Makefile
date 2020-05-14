RESDIR=chrome/browser/resources
SRCDIR=../../../chromium/src/$(RESDIR)

all: clean sodium.js videomark-log-view install

clean:
	rm   -rf $(RESDIR)
	mkdir -p $(RESDIR)

sodium.js:
	cd ../sodium.js && npm run build
	cp ../sodium.js/dist/sodium.js $(RESDIR)
	cp ../videomark-extension/content_script.js $(RESDIR)

videomark-log-view:
	cd ../videomark-log-view && npm run build-android
	cp -r ../videomark-log-view/build $(RESDIR)/sodium_result

install:
	rm -rf $(SRCDIR)/sodium*
	cp -r  $(RESDIR)/* $(SRCDIR)

npm-install:
	npm ci --prefix ../sodium.js
	npm ci --prefix ../videomark-log-view

.PHONY: all clean sodium.js videomark-log-view install npm-install
