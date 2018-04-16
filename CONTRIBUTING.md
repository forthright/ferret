# Contributing

Current list of [Contributors](https://github.com/forthright/ferret/graphs/contributors).

## Code Of Conduct

By participating in this project you agree to our [Code of Conduct](CODE_OF_CONDUCT.md).

## Submitting Issues

Current issue tracker is on [GitHub](https://github.com/forthright/ferret/issues).

Even if you are uncomfortable with code, an issue or question is welcome.

Note: If you are reporting a bug or feature request
for [ferretci.com](https://ferretci.com) itself, please see [forthright/ferretci.com](https://github.com/forthright/ferretci.com) instead.

## Contributing Documentation

See the [Docs](#docs) section.

## Contributing Code

All you need to do is submit a [Pull Request](https://github.com/forthright/ferret/pulls).

1. Please consider tests and code quality before submitting.
2. Please try to keep commits clean, atomic and well explained (for others).

Note: If you prefer to submit a `patch` then please [open an issue](https://github.com/forthright/ferret/issues/new) and link to it.

## Development Setup

Ferret is centered around the exectution of [plugins](https://docs.ferretci.com/plugins) that generate various types of [data](https://docs.ferretci.com/metadata).

A plugin can be written in JavaScript, or easily [shell out](https://docs.ferretci.com/#writing-non-javascript-plugins) to another language.

The core library and cli is written in [TypeScript](http://www.typescriptlang.org).

Test code is written in [CoffeeScript](http://coffeescript.org).

### Requirements

For core lib development:

* [Node.js]()
* [Git]()
* [EditorConfig](https://github.com/editorconfig)

For non-essential dev tasks (docs, packaging, etc):

* [info-zip]()
* [curl]()
* [MkDocs]()
* [Homebrew](https://brew.sh)
* [Chocolatey](https://chocolatey.org)
* [dh-make](http://packaging.ubuntu.com/html/packaging-new-software.html)
* [makepkg]()
* [fedora-packager](https://docs.fedoraproject.org/quick-docs/en-US/creating-rpm-packages.html)

Additional OSes required for all non-essential builds and testing:

* [Windows]()
* [macOS]()
* [Ubuntu](http://packaging.ubuntu.com/html/getting-set-up.html)
* [Fedora]()
* [Arch Linux]()

### Getting Setup

If on Windows:

    choco install zip unzip git nodejs curl mkdocs mkdocs-material

If on macOS:

    brew install zip unzip git nodejs python
    pip install mkdocs mkdocs-matertial

If on Arch Linux:

    pacman -S zip unzip git nodejs python-pip
    pip install mkdocs mkdocs-matertial

Clone the repos:

    git clone git@github.com:forthright/ferret.git
    cd ferret

Install packages:

    npm i -g yarn npm
    npm i

### Build Commands

See all available build commands:

    npm run

Compile from `src` to `lib`:

    npm run -s c

To run the CLI locally:

    node bin/ferret -h

### Testing

To run tests:

    npm -s t

### Docs

Everything resides in `docs`.

To develop run `mkdocs serve` in your project root:

### Dev Helpers

To run compile task with file watch in the background:

    npm run dev

### Compiling Release Packages

To build packages:

    ./bin/build

Note: Extracting Node.js's zipfile might hit the Windows path limit for CMD.exe and PowerShell.
If it is regarding `node_modules/npm...` you can safely ignore this as this is not copied over
during packaging.
