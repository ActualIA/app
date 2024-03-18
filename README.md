# app
ActualIA Android app

## Setup Dev environment

This repository uses client hooks to ensure the quality of the commits. You need to install the `pre-commit` python package to set up those:

```sh
# Using apt
apt-get update
apt-get install pip
pip install pre-commit

# Using pacman
pacman -S python-pre-commit
```

Then run:

```sh
pre-commit install
```