#!/bin/bash

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

# Load RVM
[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm"

# Load virtualenvwrapper
[ -s "/usr/local/bin/virtualenvwrapper.sh" ] && . "/usr/local/bin/virtualenvwrapper.sh"

# Load NVM
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"

# You might want to run the oneliner below once to get natural scrolling
# echo "pointer = 1 2 3 5 4 7 6 8 9 10 11 12" > ~/.Xmodmap && xmodmap ~/.Xmodmap