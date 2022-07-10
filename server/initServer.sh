function bash__remote_updater__init__ {
  HOME=$0
  if [ $HOME == "-bash" ]; then
    HOME="."
  fi
  BASH__REMOTE_UPDATER_DIRNAME=$(realpath -- ${HOME}/../)
  git pull
  echo "export BASH__REMOTE_UPDATER_DIRNAME=${BASH__REMOTE_UPDATER_DIRNAME}" >>~/.bashrc
  echo "source \${BASH__REMOTE_UPDATER_DIRNAME}/src/bashrc_work.sh" >>~/.bashrc
  source ~/.bashrc
}

bash__remote_updater__init__
