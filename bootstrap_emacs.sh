#!/bin/sh

mkdir -p ~/Documents/Agenda/
mkdir -p ~/Documents/Org/

if [ -f ~/plantuml/plantuml.jar ]; then
    echo "plantuml found"
else
    echo "installing plantuml"
    curl -L https://github.com/plantuml/plantuml/releases/download/v1.2022.5/plantuml-1.2022.5.jar -o plantuml.jar
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

