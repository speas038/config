#!/bin/bash

ln_opts=
INSERT_STR="source ~/.my_env"

function die {
    echo >&2 "$@"
    exit 1
}

#for debugging#
docmd(){
    echo "Command: $*"
    $*
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


#install dev programs
sudo apt install -y vim emacs gcc make screen gdb cscope

git config --global user.email "alex.speasmaker@gmail.com"
git config --global user.name  "Alex Speasmaker"

for file in `ls ./dotfiles`; do

    if [ -L $HOME/.$file ]; then
        continue
    fi

    if [ -e $HOME/.$file ]; then
        echo .$file already exists in $HOME, run with -f to overwrite
        continue
    fi

    ln -s $ln_opts $PWD/dotfiles/$file $HOME/.$file 
done


grep -q -F "$INSERT_STR" $HOME/.bashrc
if [ $? -eq 1 ]; then
    echo adding $INSERT_STR to end of .bashrc
    echo $INSERT_STR >> $HOME/.bashrc
fi

sudo cp ./sudo/alex /etc/sudoers.d
