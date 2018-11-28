#!/bin/sh

set -x
set -e

if [ "$TRAVIS_OS_NAME" = "osx" ]; then
  curl -sL https://github.com/aktau/github-release/releases/download/v0.7.2/darwin-amd64-github-release.tar.bz2 | tar -xjO > /tmp/github-release
  brew install openssl || brew upgrade openssl || true
  curl -sL https://curl.haxx.se/ca/cacert.pem > /usr/local/etc/openssl/cacert.pem || true
  OPENSSL_DIR="/usr/local/etc/openssl"
  TEMP_DIR="$(mktemp -d)"
else
  curl -sL https://github.com/aktau/github-release/releases/download/v0.7.2/linux-amd64-github-release.tar.bz2 | tar -xjO > /tmp/github-release
  apt-get install -y -q openssl || true
  update-ca-certificates || true
  OPENSSLDIR="/etc/ssl"
  TEMP_DIR="$(mktemp -d --tmpdir=/root .rubyc-build.XXXXXX)"
fi

ruby -Ilib bin/rubyc bin/rubyc \
  --openssl-dir=${OPENSSLDIR} \
  --tmpdir=${TEMP_DIR} \
  --clean-tmpdir \
  --ignore-file=.git \
  --ignore-file=.travis.yml \
  --ignore-file=.travis/deploy.sh \
  --ignore-file=.travis/osx_deps.sh \
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
