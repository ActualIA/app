# app

![Build](https://github.com/actualia/app/actions/workflows/flutter.yml/badge.svg?branch=main)
![Sonarcloud](https://github.com/actualia/app/actions/workflows/sonarcloud.yml/badge.svg?branch=main)
![Supabase](https://github.com/actualia/app/actions/workflows/supabase.yml/badge.svg?branch=main)

ActualIA Android app


## App Description

Get your own 1 minute daily summary of news that you choose, tailored to your needs. Wake up with the latest in tech, politics, society, or any subject you’d like. You can listen to your customized news feed, read a transcript, and look into the original sources of the headlines that caught your eye.

## Architecture Diagram
![image](https://github.com/ActualIA/app/assets/18498650/0da64a62-e640-48a0-9c65-2d62b11d3696)

[Download Excalidraw file](https://github.com/ActualIA/app/raw/ad.excalidraw)
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
pre-commit run --all-files
```

## Keeping a clean code/git

All the commits must follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification. It is checked both locally by the `pre-commit` hook and by the CI on pull requests.

## Figma

To direct the design process, a [Figma Board](https://www.figma.com/) has been setup for team members. It houses the main design elements.

You can find the board [here](https://www.figma.com/design/8GfgXznK0gmJuPWhfBwGBs/ActualIA%3A%3Amockup?version-id=5901485944&node-id=0-1&t=sIX4uiqU0DQVb2eI-0)
