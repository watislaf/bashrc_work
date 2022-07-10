function bash__remote_updater__init__ {
  BASH__REMOTE_UPDATER_DIRNAME=$(dirname -- "$0")
  git pull
  echo "export BASH__REMOTE_UPDATER_DIRNAME=${BASH__REMOTE_UPDATER_DIRNAME}" >>~/.bashrc
  echo "source \${BASH__REMOTE_UPDATER_DIRNAME}/../src/bashrc_work.sh" >>~/.bashrc
  cmod +x ./autoPullDeamon.sh
  source ~/.bashrc
}

bash__remote_updater__init__
