#!/bin/sh
set -e -u -o pipefail

shared_dependencies() {
  local EXECUTABLE=$1
  for PACKAGE in $(ldd "$EXECUTABLE" | grep "=> /" | awk '{print $3}'); do 
    LC_ALL=c pacman -Qo $PACKAGE
  done | awk '{print $5}'
}

pkgbuild_dependencies() {
  local PKGBUILD=$1
  local EXCLUDE=$2
  source "$PKGBUILD"
  for DEPEND in ${depends[@]}; do
    echo "$DEPEND" | sed "s/[>=<].*$//"
  done | grep -v "$EXCLUDE"
}

if [ ! -e /usr/bin/pacman ]; then
	echo "Cannot found /usr/bin/pacman"
	exit
fi

wget -q -O /tmp/pacman_PKGBUILD https://git.archlinux.org/svntogit/packages.git/plain/trunk/PKGBUILD?h=packages/pacman

# Main
{ 
  shared_dependencies "/usr/bin/pacman"
  pkgbuild_dependencies "/tmp/pacman_PKGBUILD" "bash"
} | sort -u | xargs

rm -rf "/tmp/pacman_PKGBUILD"
echo "Extras"
echo "bash coreutils findutils readline ncurses gmp libcap"

