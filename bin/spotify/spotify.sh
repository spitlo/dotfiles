#!/usr/bin/env bash

# Copyright (c) 2012 Harish Narayanan
# http://harishnarayanan.org/projects/shpotify/

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

showHelp () {
    echo "------------------------------------";
    echo "A command-line interface for Spotify";
    echo "------------------------------------";
    echo "Usage: spfy <option>";
    echo;
    echo "Options:";
    echo " status   = Shows Spotify's status, current track details.";
    echo " play     = Start playing Spotify.";
    echo " pause    = Pause Spotify.";
    echo " next     = Go to the next track.";
    echo " prev     = Go to the previous track.";
    echo " vol up   = Increase Spotify's volume by 10%";
    echo " vol down = Increase Spotify's volume by 10%";
    echo " vol #    = Set Spotify's volume to # [0-100]";
    echo " quit     = Quit Spotify.";
}

if [ $# = 0 ]; then
    showHelp;
fi

while [ $# -gt 0 ]; do
    arg=$1;
    case $arg in
        "status" ) state=`osascript -e 'tell application "Spotify" to player state as string'`;
            echo "Spotify is currently $state.";
            if [ $state = "playing" ]; then
                artist=`osascript -e 'tell application "Spotify" to artist of current track as string'`;
                album=`osascript -e 'tell application "Spotify" to album of current track as string'`;
                track=`osascript -e 'tell application "Spotify" to name of current track as string'`;

                echo -e "Artist: $artist\nAlbum: $album\nTrack: $track";
            fi
            break ;;

        "play"    ) echo "Playing Spotify.";
            osascript -e 'tell application "Spotify" to play';
            break ;;

        "pause"    ) echo "Pausing Spotify.";
            osascript -e 'tell application "Spotify" to pause';
            break ;;

        "next"    ) echo "Going to next track." ;
            osascript -e 'tell application "Spotify" to next track';
            break ;;

        "prev"    ) echo "Going to previous track.";
            osascript -e 'tell application "Spotify" to previous track';
            break ;;

        "vol"    ) echo "Changing Spotify volume level.";
            vol=`osascript -e 'tell application "Spotify" to sound volume as integer'`;

            if [ $2 = "up" ]; then
                newvol=$(( vol+10 ));
            elif [ $2 = "down" ]; then
                newvol=$(( vol-10 ));
        elif [ $2 -gt 0 ]; then
        newvol=$2;
            fi

            osascript -e "tell application \"Spotify\" to set sound volume to $newvol";
            break ;;

        "quit"    ) echo "Quitting Spotify.";
            osascript -e 'tell application "Spotify" to quit';
            exit 1 ;;

        "help" | * ) echo "help:";
            showHelp;
            break ;;
    esac
done