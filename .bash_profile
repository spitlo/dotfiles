#!/bin/bash

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit. 
for file in ~/.{exports,colors,aliases,bash_prompt,functions,extras}; do
    [ -r "$file" ] && . "$file"
done
unset file

# Load z
[[ -s ~/bin/z/z.sh ]] && . ~/bin/z/z.sh

# Load virtualenvwrapper
[[ -s /usr/local/bin/virtualenvwrapper.sh ]] && . /usr/local/bin/virtualenvwrapper.sh

# Load NVM
[[ -s /home/spitlo/.nvm/nvm.sh ]] && . /home/spitlo/.nvm/nvm.sh # This loads NVM
