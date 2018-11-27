#!/bin/sh

set -x
set -e

if [ "$TRAVIS_OS_NAME" = "osx" ]; then
  curl -sL https://github.com/aktau/github-release/releases/download/v0.7.2/darwin-amd64-github-release.tar.bz2 | tar -xjO > /tmp/github-release
  UPLOAD_OS="darwin"
else
  curl -sL https://github.com/aktau/github-release/releases/download/v0.7.2/linux-amd64-github-release.tar.bz2 | tar -xjO > /tmp/github-release
  UPLOAD_OS="linux"
fi


chmod +x /tmp/github-release

ruby -Ilib bin/rubyc bin/rubyc -o rubyc --clean-tmpdir


strip rubyc || true

./rubyc --version

gzip rubyc

GITHUB_TOKEN="${GH_TOKEN}" /tmp/github-release upload \
    --user kke \
    --repo ruby-packer \
    --tag $TRAVIS_TAG \
    --name "rubyc-${TRAVIS_TAG#v}-${UPLOAD_OS}-amd64.gz" \
    --file ./rubyc.gz
