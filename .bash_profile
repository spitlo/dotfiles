#!/bin/bash

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit. 
for file in $HOME/.{exports,colors,aliases,functions,extras,bash_prompt}; do
    [ -r "$file" ] && . "$file"
done
unset file

# Load z
[ -s "$HOME/bin/z/z.sh" ] && . "$HOME/bin/z/z.sh"

# Load RVM
[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm"

# Load virtualenvwrapper
[ -s "/usr/local/bin/virtualenvwrapper.sh" ] && . "/usr/local/bin/virtualenvwrapper.sh"

# Load NVM
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
