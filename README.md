# zipstream

[![Built with Crystal](https://img.shields.io/badge/built%20with-crystal-000000.svg?style=?style=plastic&logo=appveyor)](https://crystal-lang.org/)
[![Build Status](https://travis-ci.org/mamantoha/zipstream.svg?branch=master)](https://travis-ci.org/mamantoha/zipstream)
[![zipstream](https://snapcraft.io/zipstream/badge.svg)](https://snapcraft.io/zipstream)
[![Snap Status](https://build.snapcraft.io/badge/mamantoha/zipstream.svg)](https://build.snapcraft.io/user/mamantoha/zipstream)

A command line tool that allows you to easily share files and directories over the network

## Installation

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/zipstream)

### Snap-specific information

Due to the snap's confined nature, the application can only access files in the user's home directory.
To access files under `/media` or `/mnt` directories you have to manually connect the snap
to the `removable-media` interface by running the following command in a terminal

`sudo snap connect zipstream:removable-media`

### Build from source

Clone the repository:

`git clone https://github.com/mamantoha/zipstream.git`

Switch to repo-directory

`cd zipstream`

Build:

`shards build`

Copy `./bin/zipstream` to executable path.

Enjoy!

## Usage

Help message:

```console
NAME
    zipstream - is a command line tool that allows you to easily share files and directories over the network

VERSION
    0.8.0

SYNOPSIS
    zipstream PATH [options]

If PATH is not specified it point to current directory

OPTIONS
    -h, --help                       Show this message
    -H HOST, --host=HOST             Specifies the host (default: `127.0.0.1`)
    -p PORT, --port=PORT             Specifies the port (default: `8090`)
    -f FORMAT, --format=FORMAT       Specifies the format of output archive, zip, tar or tgz (default: `zip`)
    -o FILENAME, --output=FILENAME   Specifies the output file name without extension (default: `download`)
    -e PATH, --endpoint=PATH         Specifies the URL path to the resource (default: ``)
    --user=user                      Specify the username user for file retrieval
    --password=password              Specify the password password for file retrieval
```

Sharing a directory (all the files in it):

```console
$ zipstream /media/disk/music -f tar
Serving `/media/disk/music` as `download.tar`

To download the file please use one of the commands below:

wget --content-disposition http://127.0.0.1:8090/
curl -OJ http://127.0.0.1:8090/

Or place all files into current folder:

wget -O- http://127.0.0.1:8090/ | tar -xvf -
curl http://127.0.0.1:8090/ | tar -xvf -

Or just open in browser: http://127.0.0.1:8090/
```

## Contributing

1. Fork it (<https://github.com/mamantoha/zipstream/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anton Maminov](https://github.com/mamantoha) - creator and maintainer
