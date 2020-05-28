RESDIR=chrome/browser/resources
SRCDIR=../../../chromium/src/$(RESDIR)

all: clean sodium.js videomark-log-view install

clean:
	rm   -rf $(RESDIR)
	mkdir -p $(RESDIR)

sodium.js:
	cd ../videomark/packages/sodium && npm run build
	cp ../videomark/packages/sodium/dist/sodium.js $(RESDIR)
	cp ../videomark/packages/videomark-extension/content_script.js $(RESDIR)

videomark-log-view:
	cd ../videomark/packages/videomark-mini-stats && npm run build
	cd ../videomark/packages/videomark-log-view && npm run build-android
	cp -r ../videomark/packages/videomark-log-view/build $(RESDIR)/sodium_result

install:
	rm -rf $(SRCDIR)/sodium*
	cp -r  $(RESDIR)/* $(SRCDIR)

npm-install:
	npm install --no-save --prefix ../videomark/packages/sodium
	npm install --no-save --prefix ../videomark/packages/videomark-log-view
	npm install --no-save --prefix ../videomark/packages/videomark-mini-stats

.PHONY: all clean sodium.js videomark-log-view install npm-install
