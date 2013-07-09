#!/bin/bash

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{exports,colors,aliases,bash_prompt,functions,extras}; do
    [ -r "$file" ] && . "$file"
done
unset file

. ~/bin/z/z.sh 2>&1 /dev/null
. /usr/local/bin/virtualenvwrapper.sh

# If possible, add tab completion for many more commands
##[ -f /etc/bash_completion ] && source /etc/bash_completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
. $(brew --prefix)/etc/bash_completion
fi
#[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion