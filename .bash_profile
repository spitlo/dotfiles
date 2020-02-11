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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"
