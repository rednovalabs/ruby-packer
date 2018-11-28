#!/bin/sh

set -uex

if [ "$TRAVIS_OS_NAME" = "osx" ]; then
  OPENSSLDIR="/usr/local/etc/openssl"
  curl -sL https://github.com/aktau/github-release/releases/download/v0.7.2/darwin-amd64-github-release.tar.bz2 | tar -xjO > /tmp/github-release
  curl -sL https://curl.haxx.se/ca/cacert.pem > ${OPENSSLDIR}/cacert.pem
  TEMP_DIR="$(mktemp -d)"
else
  curl -sL https://github.com/aktau/github-release/releases/download/v0.7.2/linux-amd64-github-release.tar.bz2 | tar -xjO > /tmp/github-release
  sudo update-ca-certificates
  OPENSSLDIR="/etc/ssl"
  TEMP_DIR="$(sudo mktemp -d --tmpdir=/root .rubyc-build.XXXXXX)"
fi

mksquashfs -version

sudo ruby -Ilib bin/rubyc bin/rubyc \
  --openssl-dir=${OPENSSLDIR} \
  --tmpdir=${TEMP_DIR} \
  --clean-tmpdir \
  --ignore-file=.git \
  --ignore-file=.travis.yml \
  --ignore-file=.travis/deploy.sh \
  --ignore-file=.travis/install_deps.sh \
  -o rubyc

strip rubyc || true

./rubyc --version

gzip rubyc

chmod +x /tmp/github-release
GITHUB_TOKEN="${GH_TOKEN}" /tmp/github-release upload \
    --user kke \
    --repo ruby-packer \
    --tag $TRAVIS_TAG \
    --name "rubyc-${TRAVIS_TAG}-${TRAVIS_OS_NAME}-amd64.gz" \
    --file ./rubyc.gz
