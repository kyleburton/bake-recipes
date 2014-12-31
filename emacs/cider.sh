
function cider_pushd_to_local_path () {
  test -d $HOME/.emacs.d/krb || mkdir -p $HOME/.emacs.d
  pushd $HOME/.emacs.d/krb
}

bake_task install-cider "Install Emacs/Clojure Cider IDE"
function cider-install () {
  cider_pushd_to_local_path
  if [ ! -d cider ]; then
    git clone git@github.com:clojure-emacs/cider.git
  fi

  cd cider
  git checkout master
  git pull origin master
  git checkout v0.7.0
  cd ..
  cd ..
}

bake_task cider-install-ac-cider "Install Emacs auto completion for Cider"
function install-ac-cider () {
  cider_pushd_to_local_path
  cd software
  if [ ! -d ac-cider ]; then
    git clone git@github.com:clojure-emacs/ac-cider.git
  fi

  cd ac-cider
  git checkout master
  git pull origin master
  git checkout 0.2.0
  cd ..
  cd ..
}

