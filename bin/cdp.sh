#!/bin/bash

if [[ -z "$PROJECT_FOLDER" ]]; then
    echo "You have not set your project folder in .extras. Exiting."
else
    path1=$PROJECT_FOLDER/$1/src/$1
    path2=$PROJECT_FOLDER/$1/$1
    path3=$PROJECT_FOLDER/$1

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

    . $HOME/.bash_profile && cls
    echo -e "Project ${YELLOW}$1${RESET} activated."
fi
