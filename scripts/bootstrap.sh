#!/bin/sh

set -eu

DOCKER_BUILDER_URL=https://raw.githubusercontent.com/amery/docker-builder/master

if [ "$USER" = root ]; then
	BINDIR="/usr/local/bin"
	SUDO=
else
	BINDIR="$HOME/bin"
	SUDO=sudo
fi

mkdir -p "$BINDIR/"

# submodules
#
git submodule update --init

# docker
#
if [ ! -x "$(which docker)" ]; then
	$SUDO apt-get install docker.io
	[ "$USER" = root ] || $SUDO usermod -aG docker $USER
fi

fetch_bin() {
	local f0= f1= temp=

	f0="$DOCKER_BUILDER_URL/$1"
	f1="${2:-${1##*/}}"
	temp="${TMPDIR:-/tmp}/docker-builder-$f1.$$"

	echo "curl -o $BINDIR/$f1 $f0" >&2

	curl -q -o "$temp" "$f0"
	chmod +x "$temp"
	$SUDO mv "$temp" "$BINDIR/$f1"
}

# run.sh support
#
[ -x "$(which x)" ] || fetch_bin bin/x
[ -x "$(which docker-builder-run)" ] || fetch_bin docker/run.sh docker-builder-run

# ssh key
#
KP=$HOME/.ssh/id_
for t in rsa ecdsa; do
	K="$KP$t"
	if [ -s "$K.pub" ]; then
		cat "$K.pub"
		K=
		break
	fi
done
if [ -n "$K" ]; then
	ssh-keygen -t ecdsa -q -f "$K" -N ""
	cat "$K.pub"
fi
