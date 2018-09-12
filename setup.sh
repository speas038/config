#!/bin/bash

ln_opts=

function die {
    echo >&2 "$@"
    exit 1
}


if [ -z $HOME ]; then
    echo HOME not set
    die
fi


while getopts f opt
do
    case $opt in
    f)  ln_opts="-f"
    esac
done

echo ln_opts=$ln_opts

sudo apt install -y vim emacs gcc make screen gdb


for file in `ls ./dotfiles`; do

    if [ -f $HOME/.$file ]; then
        echo .$file already exists in $HOME, run with -f to overwrite
    fi
    ln -s $ln_opts $PWD/dotfiles/$file $HOME/.$file 
done

INSERT_STR='source .my_env'

docmd(){
    echo "Command: $*"
    $*
}

grep "source .my_env" $HOME/.bashrc
if [ $? -eq 1 ]; then
    echo $INSERT_STR >> $HOME/.bashrc
fi
