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
pre-commit install --hook-type commit-msg
```

## Keeping a clean code/git

All the commits must follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification. It is checked both locally by the `pre-commit` hook and by the CI on pull requests.
