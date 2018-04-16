# Getting Started

Ferret is different compared to most continuous analysis services.

You will first need to install its CLI and library on your local machine or CI server.

## Installation

The recommended way to install and update Ferret is through your favourite OS's
package manager. Many Linux distros and package formats are supported,
along with Windows and macOS.

### Package Manager

#### macOS

Using [Homebrew](https://brew.sh):

    brew tap forthright/ferret
    brew install ferret

#### Windows

Using [Chocolatey](https://chocolatey.org/):

    choco install ferret

#### Ubuntu

Using a custom [PPA](https://launchpad.net/~brentlintner/+archive/ubuntu/ferret-code):

    add-apt-repository ....
    apt update
    apt install ferret-code

#### Fedora

Grab the [rpm]() for now:

    curl https://... > ferret..rpm
    dnf install ... ferret..rpm

#### Debian

Grab the latest [deb]().

    curl https://... > ferret-..deb
    dpkg -i ferret-..deb

#### Arch Linux

Using an [AUR](https://aur.archlinux.org/packages/ferret) package:

    pacman -S pacaur
    pacaur -S ferret-bin

Or if you want to install the arch pkg tarball manually, grab it from [releases]():

    curl https://... ferret-..tar.xz
    pacman -U ferret....tar.xz

#### openSUSE

Grab the [rpm]() for now:

    wget https://... > ferret..rpm
    zypper in ferret...rpm

#### CentOS

Grab the [rpm]() for now:

    curl https://... > ferret..rpm
    yum install ... ferret..rpm

#### Other OSes

Ideally things like some [BSDs](), and
even [Flatpak]() or [Snap]() are supported in the future.

Don't see your favourite package manager yet?

Please [open and issue]() and tell us!

### Installing Manually

There are tarball and zip packages available for Linux, Windows and macOS.

Grab a tarball and `sha_sums.txt` from the [Releases](https://github.com/forthright/ferret/releases) page.

    shasum -a 256 -c sha_sums.txt
    tar -xvf ferret-v0.19.6-linux-x86_64.tar.gz
    cd ferret-v0.19.6-linux-x86_64
    ./bin/ferret -h

Or, similarly, on Windows:

    bin\ferret.cmd -h

### Install By "Source"

The main library is written in [TypeScript](https://www.typescriptlang.org) on top of [Node.js](https://nodejs.org) and hosted with [npm](https://www.npmjs.com/).

To install packages manually, or if you are familiar with an npm setup:

    cd my_project/
    npm i --save-dev @forthright/ferret
    npm i --save-dev @forthright/ferret-coverage
    npm i --save-dev @forthright/ferret-stat
    npm i --save-dev @forthright/ferret-comment
    npm i --save-dev @forthright/ferret-typescript
    npm i --save-dev @forthright/ferret-....
    npx ferret configure
    npx ferret analyze

### Installing Custom Plugins

To install custom plugins alongside Ferret's bundled ones:

    cd my_project/
    npm i --save-dev @forthright/ferret
    npm i --save-dev ferret-my-plugin
    ferret configure
    ferret analyze -p my-plugin

Note: If you use something like `npx ferret` in this case,
it will *not* be able to run globally installed plugins.

## Checking The Install

To see exactly what plugins and versions are being used, you can run:

    ferret version
