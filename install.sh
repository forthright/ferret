#!/usr/bin/env sh

set -e

ARCH=`uname -m`
OS=`uname -s`
VERSION="0.19.6"

# Note: Should we be proactive and use /var/tmp instead?
TMP_PATH=/tmp/ferret
INSTALL_DIR=/opt/ferret
OPT_BIN_FILE=/opt/ferret/bin/ferret
USR_BIN_FILE=/usr/bin/ferret

DEB_FILE="ferret_$VERSION-1_amd64.deb"
RPM_FILE="ferret-$VERSION-1.x86_64.rpm"

LIN_DIR="ferret-$VERSION-linux-x86_64"
LIN_FILE="$LIN_DIR.tar.gz"

MAC_DIR="ferret-$VERSION-mac-x86_64"
MAC_FILE="$MAC_DIR.tar.gz"

SUM_FILE=sha256_sums.txt

RELEASE_URL="https://github.com/forthright/ferret_temp/releases/download/$VERSION"

DOWNLOAD=""
PACKAGER=""

cleanup() {
  if [ -d "$TMP_PATH" ]; then
    rm -rf "$TMP_PATH"
  fi
}
trap cleanup EXIT

as_root() {
  UID=`id -u`

  if [ $UID -eq 0 ]; then
    "$@"
  else
    echo "We need root permission to run $@"
    if [ ! -z $(command -v sudo) ]; then
      sudo -k "$@"
    elif [ ! -z $(command -v su) ]; then
      su root -c "$@"
    else
      echo "Can't continue without sudo/su." && exit 1
    fi
  fi
}

get_shasums() {
  "$DOWNLOAD $RELEASE_URL/$SUM_FILE" > "$TMP_PATH/$SUM_FILE"
}

check_arch() {
  case $ARCH in
  x86_64)
    echo "  -> $ARCH: ok"
    ;;
  *)
    echo ""
    echo "$ARCH not supported" && exit 1
    ;;
  esac
}

check_packager() {
  if [ ! -z "$(command -v pacman)" ]; then
    PACKAGER="pacman"
  elif [ ! -z "$(command -v yast)" ]; then
    PACKAGER="yast"
  elif [ ! -z "$(command -v dnf)" ]; then
    PACKAGER="dnf"
  elif [ ! -z "$(command -v yum)" ]; then
    PACKAGER="yum"
  # TODO
  #elif [ ! -z "$(command -v add-apt-repository)" ]; then
    #PACKAGER="add-apt-repository"
    #elif [ ! -z "$(command -v apt)" ]; then
  elif [ ! -z "$(command -v dpkg)" ]; then
    PACKAGER="dpkg"
  elif [ "$OS" = "Darwin" ] && [ ! -z "$(command -v brew)" ]; then
    PACKAGER="brew"
  fi
}

check_for_shasum() {
  if [ -z "$(command -v shasum)" ]; then
    echo ""
    echo "Need shasum installed" && exit 1
  fi
}

check_can_download() {
  if [ ! -z "$(command -v curl)" ]; then
    DOWNLOAD="curl -fL "
  elif [ ! -z "$(command -v wget)" ]; then
    DOWNLOAD="wget -qO- "
  else
    echo ""
    echo "Need wget or curl installed"
    exit 1
  fi
}

check_sums() {
  cd $TMP_PATH
  shasum -a 256 -c $SUM_FILE
  cd -
}

get_rpm() {
  $URL="$RELEASE_URL/$RPM_FILE"
  echo "==> Downloding $URL"
  "$DOWNLOAD $URL" > "$TMP_PATH/$RPM_FILE"
  check_sums
}

get_deb() {
  $URL="$RELEASE_URL/$DEB_FILE"
  echo "==> Downloding $URL"
  "$DOWNLOAD $URL" > "$TMP_PATH/$DEB_FILE"
  check_sums
}

extract_tarball() {
  echo "==> Extracting $TARBALL"
  TARBALL=$0
  cd $TMP_PATH
  shasum -a 256 -c $SUM_FILE
  tar -xvf "$TARBALL"
  cd -
}

get_tarball() {
  $FILE_NAME=$0
  $URL="$RELEASE_URL/$FILE_NAME"
  echo "==> Downloading $FILE_NAME"
  "$DOWNLOAD $URL" > "$TMP_PATH/$FILE_NAME"
}

install_files() {
  $PKGDIR=$0
  echo "==> Installing files..."
  if [ -d "$INSTALL_DIR" ]; then
    # in case we have a previous install
    as_root rm -rf $INSTALL_DIR
  fi
  as_root mkdir -p $INSTALL_DIR
  as_root cp -r $PKGDIR/* $INSTALL_DIR
  as_root ln -s $OPT_BIN_FILE $USR_BIN_FILE
}

install_mac_tarball() {
  get_tarball $MAC_FILE
  extract_tarball $MAC_FILE
  as_root install_files $MAC_DIR
}

install_linux_tarball() {
  get_tarball $LIN_FILE
  extract_tarball $LIN_FILE
  as_root install_files $LIN_DIR
}

install_via_tarball() {
  if [ $OS = "Darwin" ]; then
    install_mac_tarball
  elif [ $OS = "Linux" ]; then
    install_linux_tarball
  else
    echo "$OS-$ARCH not supported. Please see manual instructions:"
    echo "  https://docs.ferretci.com/start"
    exit 0
  fi
}

install_via_pacman() {
  echo "  -> Installing pacaur for AUR support"
  as_root pacman -S pacaur --noconfirm
  as_root pacaur -S ferret-bin --noconfirm
}

install_via_yast() {
  get_rpm
  as_root yast -i -y "$TMP_PATH/$RPM_FILE"
}

install_via_dnf() {
  get_rpm
  as_root dnf install -y "$TMP_PATH/$RPM_FILE"
}

install_via_yum() {
  get_rpm
  as_root yum install -y "$TMP_PATH/$RPM_FILE"
}

install_via_dpkg() {
  get_deb
  as_root dpkg -i -y "$TMP_PATH/$DEB_FILE"
}

install_via_homebrew() {
  brew tap forthright/ferret
  brew install -y ferret
}

configure() {
  mkdir -p "$TMP_PATH"

  check_arch

  check_for_shasum
  echo "  -> shasum: ok"

  echo "  -> curl/wget: ok"
  check_can_download

  echo "==> Getting checksums"
  get_shasums

  echo "==> Checking for local package managers"
  check_packager

  if [ -z "$PACKAGER" ]; then
    echo "  -> No supported package manager detected"
    echo "  -> Falling back to manual install method"
  else
    echo "  -> Using $PACKAGER"
  fi

}

install() {
  case $PACKAGER in
    pacman)
      install_via_pacman
      ;;
    yast)
      install_via_yast
      ;;
    dnf)
      install_via_dnf
      ;;
    yum)
      install_via_yum
      ;;
    # TODO: detect + install via ppa/apt/add-apt-repository
    # apt)
    dpkg)
      install_via_dpkg
      ;;
    brew)
      install_via_homebrew
      ;;
    *)
      install_via_tarball
      ;;
  esac
}

install() {
  echo "==> Configuring environment"
  configure

  echo "==> Installing package"
  install

  echo ""
  if [ ! -z "$(command -v ferret)" ]; then
    echo "Success! Run \`ferret -h\` for usage."
    exit 1
  else
    echo "Fail! Can't detect $USR_BIN_FILE?"
  fi
}

install
