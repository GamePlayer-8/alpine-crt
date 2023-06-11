#!/bin/sh

apk add --no-cache markdown tar gzip

echo '<!DOCTYPE html>' > index.html
echo '<html lang="en-US">' >> index.html
cat docs/head.html >> index.html

echo '<body>' >> index.html
echo '<div>' >> index.html
markdown README.md >> index.html
echo '</div>' >> index.html
echo '</body>' >> index.html
echo '</html>' >> index.html

BACK_PATH=$(pwd)

mkdir -p /runner/page/
cp -rv /source/* /runner/page/
cd /runner/page
tar -czvf pack.tar.gz *

cd $BACK_PATH

apk add --no-cache podman fuse-overlayfs

cp pipeline/containers.conf /etc/containers/containers.conf
chmod 644 /etc/containers/containers.conf && \
    sed -i -e 's|^#mount_program|mount_program|g' -e \
    '/additionalimage.*/a "/var/lib/shared",' -e \
    's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
    /etc/containers/storage.conf && \
    mkdir -p /var/lib/shared/overlay-images \
    /var/lib/shared/overlay-layers /var/lib/shared/vfs-images \
    /var/lib/shared/vfs-layers && \
    touch /var/lib/shared/overlay-images/images.lock && \
    touch /var/lib/shared/overlay-layers/layers.lock && \
    touch /var/lib/shared/vfs-images/images.lock && \
    touch /var/lib/shared/vfs-layers/layers.lock && \
    mkdir /listen

export _CONTAINERS_USERNS_CONFIGURED=""

podman system migrate

podman pull alpine

podman build -t chimmie/alpine-crt .

echo "$REGISTRY_TOKEN" | podman login "$REGISTRY_DOMAIN" -u "$REGISTRY_USER" --password-stdin

podman tag chimmie/alpine-crt:latest "$REGISTRY_DOMAIN"/"$REGISTRY_USER"/alpine-crt:latest

podman push "$REGISTRY_DOMAIN"/"$REGISTRY_USER"/alpine-crt:latest
