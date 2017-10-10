#!/usr/bin/env bash

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in $HOME/.{exports,colors,functions,aliases,git-aliases,extras,bash_prompt}; do
    [ -r "$file" ] && . "$file"
done

if [ -d "$HOME/.bash_completions" ]; then
  for file in $HOME/.bash_completions/*; do
    source $file
  done
fi
unset file

# Load z
[ -s "$HOME/bin/z/z.sh" ] && . "$HOME/bin/z/z.sh"
