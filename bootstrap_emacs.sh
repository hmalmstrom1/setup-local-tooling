#!/bin/bash


install_nerd_font () {
    fontName=$1
    release=`curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r '.name'`
    fname=`curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r '.assets[].name' | grep -i $fontName`
    mkdir -p ~/.fonts
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/$release/$fname -o ~/.fonts/$fname
    if [ $? = 0 ]; then
	pushd ~/.fonts
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
    OPER_SYS=`uname -s`
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


install_nerd_font "RobotoMono.zip"
install_nerd_font "Inconsolata.zip"
install_nerd_font "Hack.zip"
install_nerd_font "FiraCode.zip"
setup_tool_deps
setup_emacs_things
