function bash__remote_updater__init__ {
  BASH__REMOTE_UPDATER_DIRNAME="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
  cd $BASH__REMOTE_UPDATER_DIRNAME
if [ $? != 0 ]; then
  git pull
  fi
  cd -
  echo "export BASH__REMOTE_UPDATER_DIRNAME=${BASH__REMOTE_UPDATER_DIRNAME}" >>~/.bashrc
  echo "source \${BASH__REMOTE_UPDATER_DIRNAME}/src/bashrc_work.sh" >>~/.bashrc
  source ~/.bashrc
}

bash__remote_updater__init__
