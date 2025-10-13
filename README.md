# utils

Some utilities for Linux and MacOS I have found useful.

* `start` starts something in the background.
* `setup/*.sh` will setup various things on a new machine.
* `setup/all.sh` will execute all the setup/*.sh scripts.

# Installation

To install or update these utilities, use the following command:

```sh
cd ~/GitHub
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/jsware/utils/HEAD/install.sh)"
```

# Usage

1. After installing this repository to your machine (see above).
2. To setup everything, run `setup/all.sh`
3. You can run individual `setup/*.sh` scripts.
4. If you just want some, `setup/all.sh` with a list of the scripts to run in turn.
