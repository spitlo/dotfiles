#!/usr/bin/env bash

# Load the shell dotfiles, and then some:
# * ~/.extras can be used for other settings you don’t want to commit.
# Make a copy of .extras-sample and edit it to your needs.
for file in $HOME/.{exports,colors,functions,aliases,git-aliases,extras,bash_prompt}; do
  [ -r "$file" ] && source "$file"
done

if [ -d "$HOME/.bash_completions" ]; then
  for file in "$HOME"/.bash_completions/*; do
    source "$file"
  done
fi
unset file

# Load z
[ -s "$HOME/bin/z/z.sh" ] && source "$HOME/bin/z/z.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$NVM_DIR/versions/node/$(<"$NVM_DIR"/alias/default)/bin:$PATH"
function nvm() {
  unset nvm;
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
  nvm "$@"
}

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
