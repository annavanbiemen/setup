# Anna's local setup

This repository contains configurations and scripts I commonly use in my local
[Ubuntu] setup.

It provides:

- `env` to load your ~/.env and ~/.path files.
- `setup` to install your entire dev toolchain.
- `update` to update everything all at once.
- `py` to start a Python repl with rich colors.

## Demo

Try this setup using [Docker] and the demo script:

```bash
./demo.sh
```

## Installation

First find a nice location in your home directory to clone this setup in, then:

```bash
./install.sh
```

The installation will ask for your name and email to store in .env for later
use (e.g. git configuration)

[Docker]: https://docs.docker.com/engine/install/ubuntu/
[Ubuntu]: https://releases.ubuntu.com/
