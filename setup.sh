#!/bin/bash

exec_location=`pwd`
relative_location=`dirname $0`

LOG=$relative_location/log

# print log
print_log() {
    echo -e  "\033[0;31;1m==> $1\033[0m"
    echo $1 >> $LOG
}
# check software
check_software() {
    echo "-> checking app $1..."
    which $1 >> /dev/null
    if [ $? = 0 ]; then
        echo "-> $1 had been installed"
    else
        echo "-> $1 has not been installed, installing now"
        sudo $2 $1
    fi
}
# update system
update_system() {
    clear
    print_log "update system..."
    check_software wget "pacman -S --noconfirm"
    wget http://download.tuxfamily.org/gericom/gericom.asc
    sudo pacman-key --add gericom.asc
    sudo pacman -Syyu
    print_log "done"

}
# install software
install_software() {
    clear
    print_log 'install software...'
    chmod +x $relative_location/res/app/install.sh
    $relative_location/res/app/install.sh
    print_log "done"

}
# config etc files
config_etc() {
    clear
    print_log "config etc..."
    chmod +x $relative_location/res/etc/etc_conf_apply.sh
    $relative_location/res/etc/etc_conf_apply.sh
    print_log "done"

}
# config ssh for github
config_ssh() {
    clear
    print_log "config ssh for github..."
    chmod +x $relative_location/res/ssh/ssh.sh
    $relative_location/res/ssh/ssh.sh
    print_log "done"

}
# config mirrors list
config_mirrors() {
    clear
    print_log "config mirrors list"
    sudo pacman-mirrors -g -c China
    print_log "done"

}
# config vim
config_vim() {
    clear
    print_log "do config for vim..."
    # vim had been installed?
    check_software vim 'pacman -S --noconfirm'
    # clang had been installed?
    check_software clang 'pacman -S --noconfirm'
    # cmake had been installed?
    check_software cmake 'pacman -S --noconfirm'
    # powerline-fonts
    check_software powerline-fonts 'pacman -S --noconfirm'
    # for .vimrc
    if [ -f "$HOME/.vimrc" ]; then
        print_log "mv $HOME/.vimrc to $HOME/.vimrc.bak"
        mv $HOME/.vimrc $HOME/.vimrc.bak
    fi
    # for .vim
    if [  -d "$HOME/.vim" ]; then
        print_log "mv $HOME/.vim to $HOME/.vim.bak"
        mv $HOME/.vim $HOME/.vim.bak
    fi
    # do config
    cp $relative_location/res/vim/.vimrc $HOME/
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    cp -r $relative_location/res/vim/colors ~/.vim/
    vim +PluginInstall +qall
    print_log "done"
}
# config zsh
config_zsh() {
    clear
    print_log "do config for zsh..."
    check_software zsh 'pacman -S --noconfirm'
    check_software autojump 'pacman -S --noconfirm'
    check_software powerline-fonts 'pacman -S --noconfirm'
    # for .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        print_log "mv $HOME/.zshrc to $HOME/.zshrc.bak"
        mv $HOME/.zshrc $HOME/.zshrc.bak
    fi
    # oh my zsh
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
    cp $relative_location/res/zsh/.zshrc ~/.zshrc
    chsh -s /bin/zsh

    if [ $? = 0 ]
    then print_log "chsh successfully"
    else
        print_log "error when chsh"
    fi
    print_log "done"
}

# vscode
config_vscode() {
    print_log "do for vscode"
    mkdir -p $HOME/.config/Code/User/
    cp $relative_location/res/code/* $HOME/.config/Code/User/
    print_log "done"
}
# i3wm
config_i3() {
    print_log "do for i3wm"
    chmod +x $relative_location/manjaro_i3_conf_apply.sh
    $relative_location/manjaro_i3_conf_apply.sh
    echo "done"
}


echo > $LOG

while getopts 012345678AB option
do
    case "$option" in
        1)
            echo "install applications"
            update_system
            install_software
            echo "done";;

        2)
            echo "config zsh"
            config_zsh
            echo "done";;
        3)
            echo "config vim"
            config_vim
            echo "done";;
        4)
            echo "visual studio code"
            config_vscode
            echo "done";;
        5)
            echo "ssh for github"
            config_ssh
            echo "done";;
        6)
            echo "config etc files"
            config_etc
            echo "done";;

        7)
            echo "config mirrors list"
            config_mirrors
            echo "done";;

        A)
            echo "do all who doesn't use i3wm"
            config_etc
            config_mirrors
            update_system
            install_software
            config_font
            config_vim
            config_zsh
            config_vscode
            config_ssh
            echo "done";;

        \?)
            echo "------------------------------HELP------------------------------------"
            echo "|-1  install applications                                            |"
            echo "|-2  config zsh                                                      |"
            echo "|-3  config vim                                                      |"
            echo "|-4  visual studio code                                              |"
            echo "|-5  ssh for github                                                  |"
            echo "|-6  config etc files                                                |"
            echo "|-7  config mirrors list                                             |"
            echo "|                                                                    |"
            echo "|-A  do all for your system, if your system is new one               |"
            echo "----------------------------------------------------------------------"
            echo "bye";;
    esac
done
