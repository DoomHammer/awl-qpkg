#!/usr/bin/env bash

set -e

# disable CGO to link binaries static (some QNAP systems ship old glibc versions)
export CGO_ENABLED=0

git clone https://github.com/anywherelan/awl.git -b $AWL_TAG
git clone https://github.com/anywherelan/awl-flutter.git -b $AWL_TAG

awlflutterdir=$PWD/awl-flutter
awldir=$PWD/awl
filename=awl

cd ./awl-flutter

flutter build web --release --no-web-resources-cdn --pwa-strategy=none --csp
cp -r "$awlflutterdir/build/web" "$awldir/static"

cd -

cd ./awl

rm -rf static/canvaskit/*symbols
rm -rf static/canvaskit/skwasm*
rm -rf static/canvaskit/chromium
rm -rf static/assets/NOTICES

cd cmd/awl

for GOARCH in 386 amd64 arm64; do
  CGO_ENABLED=0 GOOS=linux GOARCH=$GOARCH go build -trimpath -ldflags "-buildid= -s -w -X github.com/anywherelan/awl/config.Version=${AWL_TAG}" -o "$filename"
  mv ./$filename /out/$filename-$GOARCH
done

for GOARM in 5 7; do
  export GOARM
  CGO_ENABLED=0 GOOS=linux GOARCH=arm go build -trimpath -ldflags "-buildid= -s -w -X github.com/anywherelan/awl/config.Version=${AWL_TAG}" -o "$filename"
  mv ./$filename /out/$filename-armv$GOARM
done
