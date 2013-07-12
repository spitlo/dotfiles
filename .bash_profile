#!/bin/bash

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit. 
for file in ~/.{exports,colors,aliases,bash_prompt,functions,extras}; do
    [ -r "$file" ] && . "$file"
done
unset file

. ~/bin/z/z.sh 2>&1 /dev/null
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
  . /usr/local/bin/virtualenvwrapper.sh
fi
