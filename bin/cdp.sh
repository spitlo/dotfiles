#!/bin/bash


path1=~/Projects/$1/src/$1
path2=~/Projects/$1/$1
path3=~/Projects/$1

if [ -d $path1 ]; then
     cd $path1
     pwd
elif [ -d $path2 ]; then
    cd $path2
    pwd
elif [ -d $path3 ]; then
    cd $path3
    pwd
fi


if [ -e ~/.virtualenvs/$1/bin/activate ]; then
    source /usr/local/bin/virtualenvwrapper.sh
    workon $1
elif [ "$VIRTUAL_ENV" != "" ]; then
    source /usr/local/bin/virtualenvwrapper.sh
    deactivate
fi
