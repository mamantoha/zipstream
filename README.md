# zipstream

[![Built with Crystal](https://img.shields.io/badge/built%20with-crystal-000000.svg?style=flat-square)](https://crystal-lang.org/)

A command line tool that allows you to easily share files and directories as ZIP archive over a network

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

```console
NAME
    zipstream - is a command line tool that allows you to easily share files and directories as ZIP archive over a network

VERSION
    0.1.0

SYNOPSIS
    zipstream PATH [options]

If PATH is not specified it point to current directory

OPTIONS
    -h, --help                       Show this message
    -H HOST, --host=HOST             Specifies the host (default: 127.0.0.1)
    -p PORT, --p=PORT                Specifies the port (default: 8090)
    -o FILENAME, --output=FILENAME   Specifies the output file name (default: download.zip)
```

## Contributing

1. Fork it (<https://github.com/mamantoha/zipstream/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anton Maminov](https://github.com/mamantoha) - creator and maintainer
