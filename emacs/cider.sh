#!/usr/bin/env bash

CIDER_CIDER_VERISON="v0.8.2"
CIDER_AC_CIDER_VERISON="0.2.1"

function cider_pushd_to_local_path () {
  test -d $HOME/.emacs.d/krb || mkdir -p $HOME/.emacs.d/krb
  pushd $HOME/.emacs.d/krb
}

bake_task emacs-install-cider "Install Emacs/Clojure Cider IDE"
function emacs-install-cider () {
  cider_pushd_to_local_path
  if [ ! -d cider ]; then
    git clone https://github.com/clojure-emacs/cider.git
  fi

  cd cider
  git checkout master
  git pull origin master
  git checkout $CIDER_CIDER_VERISON
  popd
}

bake_task emacs-install-ac-cider "Install Emacs auto completion for Cider"
function emacs-install-ac-cider () {
  cider_pushd_to_local_path
  if [ ! -d ac-cider ]; then
    git clone https://github.com/clojure-emacs/ac-cider.git
  fi

  cd ac-cider
  git checkout master
  git pull origin master
  git checkout $CIDER_AC_CIDER_VERISON
  popd
}

