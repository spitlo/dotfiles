# Dotfiles

This is ~very much~ somewhat a work in progress.

## Assumptions

These dotfiles assume you have Node.js, Pygments, virtualenvwrapper, Growl for Node by TJ Holowaychuk, Aria2 and a bunch of other stuff installed.

## Installation

Preferred install process is described in detail here:
https://www.atlassian.com/git/tutorials/dotfiles

### Short version (YMMV)
```bash
git clone --bare git@github.com:spitlo/dotfiles.git $HOME/.cfg
alias dot='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dot checkout
dot config --local status.showUntrackedFiles no
source "$HOME/.bash_profile"
```

## Termux

On Termux (Android) you must install `ncurses-utils` before installing:

```bash
$ pkg install ncurses-utils
```

## Todo

- [x] Add possibility to override version check to `update` command (good for first time installs)
- [x] Make `update` work on Rasberry Pi 400
- [ ] Add support for SHA256 checksum to `update` (Some [inspiration](https://github.com/client9/shlib/blob/master/hash_sha256.sh))
- [x] Run ~~`apt update`~~ `pkg install` automatically in termux
- [ ] Consider moving `update` to its own repo
