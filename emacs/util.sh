#!/usr/bin/env bash

bake_task emacs-install-dot-emacs
function emacs-install-dot-emacs () {
  if [ -e $HOME/.emacs ]; then
    echo "$HOME/.emacs already exists."
    return 0
  fi

  ln -s $HOME/.bake/packages/github.com/kyleburton/bake-recipies/files/emacs/.emacs $HOME/.emacs
}

bake_task emacs-install-all "Install the full support for CIDER"
function emacs-install-all () {
  emacs-install-cider
  emacs-install-ac-cider
  emacs-install-dot-emacs
}

