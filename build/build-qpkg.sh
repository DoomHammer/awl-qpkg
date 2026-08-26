#!/bin/bash

export PATH=$PATH:/usr/share/QDK/bin
export VERSION=${AWL_TAG:-1}
export AWL_UI_PORT=${AWL_UI_PORT:-8639}

qbuild --create-env awl --build-version $VERSION

cp out/awl-386 /awl/x86/awl
cp out/awl-386 /awl/x86_ce53xx/awl
cp out/awl-amd64 /awl/x86_64/awl

cp out/awl-armv7 /awl/arm-x41/awl
cp out/awl-armv7 /awl/arm-x31/awl
cp out/awl-armv5 /awl/arm-x19/awl
cp out/awl-arm64 /awl/arm_64/awl

chmod +x /awl/*/awl

cp /data/package_routines /awl/package_routines

mkdir -p /awl/shared/var/run/awl
mkdir -p /awl/shared/var/lib/anywherelan
mkdir -p /awl/shared/var/log

sed -i '/QPKG_AUTHOR/cQPKG_AUTHOR="Piotr Gaczkowski"' /awl/qpkg.cfg

sed -i '/#QPKG_SERVICE_PORT/cQPKG_SERVICE_PORT="22000"' /awl/qpkg.cfg

sed -i "/#QPKG_WEB_PORT/cQPKG_WEB_PORT=\"$AWL_UI_PORT\"" /awl/qpkg.cfg
sed -i '/#QPKG_USE_PROXY/cQPKG_USE_PROXY="0"' /awl/qpkg.cfg

sed -i '/QTS_MINI_VERSION/cQTS_MINI_VERSION="4.0.2"' /awl/qpkg.cfg

# AWL_USER and AWL_UI_PORT are placeholders and are replaced later
sed -i '/: ADD START ACTIONS HERE/c \
    export AWL_DATA_DIR=$QPKG_ROOT/var/lib/anywherelan \
    if [ ! -f "$AWL_DATA_DIR/config_awl.json" ]; then \
      # Run once and let it fail \
      $QPKG_ROOT/awl </dev/null >/dev/null 2>&1 || true \
    fi \
    sed -i "s/:8080/:18080/" "$AWL_DATA_DIR/config_awl.json" \
    sed -i "s/127.0.0.1:'"$AWL_UI_PORT"'/0.0.0.0:'"$AWL_UI_PORT"'/" "$AWL_DATA_DIR/config_awl.json" \
    $QPKG_ROOT/awl </dev/null >>$QPKG_ROOT/var/log/awl.log 2>&1 & \
    echo $! > $QPKG_ROOT/var/run/awl/awl.pid \
    sleep 3' /awl/shared/awl.sh

sed -i "s/AWL_UI_PORT/$AWL_UI_PORT/g" /awl/shared/awl.sh

sed -i '/: ADD STOP ACTIONS HERE/c\
    ID=$(more $QPKG_ROOT/var/run/awl/awl.pid)\
    if [ -e $QPKG_ROOT/var/run/awl/awl.pid ]; then\
        kill $ID\
        rm -f $QPKG_ROOT/var/run/awl/awl.pid\
    fi' /awl/shared/awl.sh

qbuild --root /awl --build-arch x86 --build-dir /out/pkg
qbuild --root /awl --build-arch x86_ce53xx --build-dir /out/pkg
qbuild --root /awl --build-arch x86_64 --build-dir /out/pkg
qbuild --root /awl --build-arch arm-x19 --build-dir /out/pkg
qbuild --root /awl --build-arch arm-x31 --build-dir /out/pkg
qbuild --root /awl --build-arch arm-x41 --build-dir /out/pkg
qbuild --root /awl --build-arch arm_64 --build-dir /out/pkg

chmod -R 777 /out
