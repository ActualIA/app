# app
ActualIA Android app

## Setup Dev environment


### Install Flutter

You need to install flutter, by following this [tutorial](https://docs.flutter.dev/get-started/install).

Then, add the recommended extensions to your IDE. On VSCode, this list can be fetched with the `@recommended` tag in the Marketplace.

### Run

The application can be run using the following command:

```sh
flutter run
```

or using the dedicated run configuration of your IDE.

### Git hooks

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
pre-commit install --hook-type commit-msg --hook-type pre-commit
```

## Keeping a clean code/git

All the commits must follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification. It is checked both locally by the `pre-commit` hook and by the CI on pull requests.

## Figma

To direct the design process, a [Figma Board](https://www.figma.com/files/project/216524201) has been setup for team members. It houses the main design elements.
