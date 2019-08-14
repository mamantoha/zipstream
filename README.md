# zipstream

[![Built with Crystal](https://img.shields.io/badge/built%20with-crystal-000000.svg?style=?style=plastic&logo=appveyor)](https://crystal-lang.org/)
[![Snap Status](https://build.snapcraft.io/badge/mamantoha/zipstream.svg)](https://build.snapcraft.io/user/mamantoha/zipstream)

A command line tool that allows you to easily share files and directories over the network

## Installation

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
    0.4.0

SYNOPSIS
    zipstream PATH [options]

If PATH is not specified it point to current directory

OPTIONS
    -h, --help                       Show this message
    -H HOST, --host=HOST             Specifies the host (default: 127.0.0.1)
    -p PORT, --port=PORT             Specifies the port (default: 8090)
    -f FORMAT, --format=FORMAT       Specifies the format of output archive, zip or tar (default: zip)
    -o FILENAME, --output=FILENAME   Specifies the output file name without extension (default: download)
```

Sharing a directory (all the files in it):

```console
$ zipstream /media/disk/music -f tar
Serving `/media/disk/music` as `download.tar`

To download the file please use one of the commands below:

wget --content-disposition http://127.0.0.1:8090
curl -OJ http://127.0.0.1:8090

Or place all files into current folder:

wget -O- http://127.0.0.1:8090 | tar -xvf -
curl http://127.0.0.1:8090 | tar -xvf -

Or just open in browser: http://127.0.0.1:8090
```

## Contributing

1. Fork it (<https://github.com/mamantoha/zipstream/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anton Maminov](https://github.com/mamantoha) - creator and maintainer
