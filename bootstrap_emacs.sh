#!/bin/bash

FONT_DIR=~/.fonts
OPER_SYS=`uname -s`
if [ "$OPER_SYS" = "Darwin" ]; then
    FONT_DIR=~/Library/Fonts
fi

install_nerd_font () {
    fontName=$1
    release=`curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r '.name'`
    fname=`curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r '.assets[].name' | grep -i $fontName`
    mkdir -p ~/.fonts
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/$release/$fname -o $FONT_DIR/$fname
    if [ $? = 0 ]; then
	pushd $FONT_DIR
	unzip -o $fname
	popd
    else
	echo "problems downloading the font $fontName!"
    fi
}    

setup_emacs_things () {
    mkdir -p ~/Documents/Agenda/
    mkdir -p ~/Documents/Org/

    if [ -f ~/plantuml/plantuml.jar ]; then
	echo "plantuml found"
    else
	echo "installing latest version of plantuml from github release"
	pversion=`curl -s https://api.github.com/repos/plantuml/plantuml/releases/latest | jq -r '.tag_name' | sed -r 's/^v//g'`
	curl -L https://github.com/plantuml/plantuml/releases/download/v${pversion}/plantuml-${pversion}.jar -o plantuml.jar
	mkdir ~/plantuml
	cp ./plantuml.jar ~/plantuml/
    fi

    # merge changes to our elfeed.org file if it exists, otherwise create it.
    if [ -f ~/.emacs.d/elfeed.org ]; then
	echo "elfeed.org exists -- please merge..."
	emacs --eval '(ediff-merge-files "~/.emacs.d/elfeed.org" "./elfeed.org")'
    else
	echo "copying elfeed.org to ~/.emacs.d/elfeed.org"
	cp ./elfeed.org ~/.emacs.d/elfeed.org 
    fi

    # merge changes to our config if it exists, otherwise create it.
    if [ -f ~/.emacs.d/init.el ]; then
	echo "init.el found -- please merge..."
	emacs --eval '(ediff-merge-files "~/.emacs.d/init.el" "./init.el")'
    else
	echo "copying init.el to ~/.emacs.d/init.el"
	cp ./init.el ~/.emacs.d/init.el
    fi
}


setup_tool_deps() {
    # Insure we have a baseline of tools
    PROCESSED_FILE=".installed_deps"
    if [ -f "$PROCESSED_FILE" ]; then
	echo "dependencies already installed..."
	return
    fi

    if [ "$OPER_SYS" = "Linux" ]; then
	has_apt=`which apt`
	echo "has_apt is $has_apt"
	if [[ $has_apt == "/"* ]]; then
	    # We have apt, so it's a debian based system
	    echo "installing deb tooling dependencies..."
	    ./deps/debian_deps.sh
	    if [ $? = 0 ]; then
		touch ./.installed_deps
	    fi
	fi
	has_pacman=`which pacman`
	if [[ $has_pacman == "/"* ]]; then
	    # We have arch, so pacman it up...
	    echo "installing arch tooling dependencies..."
	    ./deps/arch_deps.sh
	    if [ $? = 0 ]; then
		touch ./.installed_deps
	    fi
	fi
    elif [ "$OPER_SYS" = "Darwin" ]; then
	has_brew=`which brew`
	if [[ $has_brew == "/"* ]]; then
	    echo "installing homebrew dependencies..."
	    brew bundle
	    if [ $? = 0 ]; then
		touch ./.installed_deps
	    fi
	else
	    echo "You might need to install homebrew..."
	fi
    else
	echo "Ewww... "
    fi
}

get_rustup () {
    has_rustup=`which rustup`
    if [[ $has_rustup == "/"* ]]; then
	echo "Found rustup, skipping install."
    else 
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	if [ $? = 0 ]; then
	    rustup toolchain install stable
	else
	    echo "Failed to install rustup"
	fi
    fi
}

install_cli_tools () {
    # update or install oh my zsh
    type omz &>/dev/null && (echo "omz() found, calling update." && omz update) || echo "omz() not found. installing " && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # install rust based cli tools
    cargo_path=`which cargo`
    if [[ $cargo_path == "/"* ]]; then
	# we have cargo installed let's grab handy cli tools
	$($cargo_path install exa)
	$($cargo_path install ripgrep)
	$($cargo_path install bat)
    else
	echo "Cargo not installed"
    fi
}

if [ $INSTALL_FONTS = 1 ]; then
    install_nerd_font "RobotoMono.zip"
    install_nerd_font "Inconsolata.zip"
    install_nerd_font "Hack.zip"
    install_nerd_font "FiraCode.zip"
    if [ "$OPER_SYS" = "Linux" ]; then
	fc-cache -f -v
    fi
fi

setup_tool_deps
get_rustup
install_cli_tools
setup_emacs_things
