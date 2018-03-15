#!/usr/bin/env sh

TMP_PATH="/tmp/ferret"
ARCH=`uname -m`
OS=`uname -s`
REQ=""
PACKAGER=""

cleanup() {
  if [ -d "$TMP_PATH" ]; then
    rm -rf "$TMP_PATH" > /dev/null
  fi
}

# TODO: fall back to su if sudo dne
ask_for_root() {
  UID=`id -u`
  if [ $UID -eq 0 ]; then
    echo "Root permissions needed to continue..."
    exec sudo -k "$0" "$@"
  else
    "$@"
  fi
}

get_rpm() {
}

get_deb() {
}

get_tarball() {
}

# check pkgsums for each one!
get_sums() {
  # map to VARS
}

check_sums() {
  shasum -a 256 ...
}

check_arch() {
  case $ARCH in
  x86_64)
    ;;
  *)
    echo "$ARCH not supported" && exit(1)
    ;;
  esac
}

check_packager() {
  if [ command -v pacman > /dev/null ]; then
    PACKAGER="pacman"
  elif [ command -v yast > /dev/null ]; then
    PACKAGER="yast"
  elif [ command -v dnf > /dev/null ]; then
    PACKAGER="dnf"
  elif [ command -v yum > /dev/null ]; then
    PACKAGER="yum"
  elif [ command -v add-apt-repository > /dev/null ]; then
    PACKAGER="add-apt-repository"
  # TODO: support when add-apt-repository is not installed
  # elif [ command -v apt > /dev/null ]; then
  elif [ command -v dpkg > /dev/null ]; then
    PACKAGER="dpkg"
  elif [ "$OS" = "Darwin" ] && [ command -v brew > /dev/null ]; then
    PACKAGER="brew"
  fi
}

check_shasum() {
  if [ ! command -v shasum > /dev/null ]; then
    echo "Can't find shasum, refusing to continue"
  fi
}

check_curl() {
  if [ command -v curl > /dev/null ]; then
    REQ="curl -fL"
  elif [ command -v wget > /dev/null]; then
    REQ="wget -qO-"
  else
    echo "Need wget or curl installed" && exit(1)
  fi
}

install_via_tarball() {
  if [ $OS = "Darwin" ]; then
    download_mac
    as_root PKGBUILD like install...
  elif [ $OS = "Linux" ]; then
    download_linux
    as_root PKGBUILD like install...
  else
    echo "$OS-$ARCH not supported" && exit(1)
  fi
}

install() {
  check_shasum

  case $PACKAGER in
    pacman)
      as_root pacman -S pacaur --noconfirm
      as_root pacaur -S ferret-bin --noconfirm
      ;;
    yast)
      get_rpm
      as_root yast -i -y ..
      ;;
    dnf)
      get_rpm
      as_root dnf install -y $TMP..
      ;;
    yum)
      get_rpm
      as_root yum install -y $TMP..
      ;;
    add-apt-repository)
      as_root add-apt-repository....
      as_root apt update
      as_root apt install -y ferret
      ;;
    # TODO: detect if apt-get is installed vs apt (older ubuntu)
    # apt)
    # echo blah into sources
    dpkg)
      get_deb
      as_root dpkg -i -y ...
      ;;
    brew)
      brew tap forthright/ferret
      brew install -y ferret
      ;;
    *)
      install_via_tarball
      ;;
  esac
}

trap cleanup EXIT

install
