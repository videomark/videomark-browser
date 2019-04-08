#!/bin/bash
set -eu
CURDIR=$(cd $(dirname $0) && pwd)
RESDIR=${CURDIR}/sodium/chrome/browser/resources

rm -rf ${RESDIR}
mkdir -p ${RESDIR}

cd ${CURDIR}/sodium.js && ./node_modules/.bin/webpack --config webpack.prod.js
sed -e 's/"/\\"/g' ${CURDIR}/sodium.js/dist/sodium.js | tr -d "\r\n" > ${RESDIR}/sodium.js

cd ${CURDIR}/videomark-log-view && ./build-for-android.sh
cp -r ${CURDIR}/videomark-log-view/build ${RESDIR}/sodium_result
