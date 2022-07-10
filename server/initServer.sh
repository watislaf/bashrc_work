function bash__remote_updater__init__ {
  echo $(realpath  $(dirname  $0))

  BASH__REMOTE_UPDATER_DIRNAME=$(realpath -- $0)
  cd ${BASH__REMOTE_UPDATER_DIRNAME}
  if [ $? == 0 ]; then
    echo error ${BASH__REMOTE_UPDATER_DIRNAME} is not a path
    return 1
  fi
  cd -
  git pull
  echo "export BASH__REMOTE_UPDATER_DIRNAME=${BASH__REMOTE_UPDATER_DIRNAME}" >>~/.bashrc
  echo "source \${BASH__REMOTE_UPDATER_DIRNAME}/src/bashrc_work.sh" >>~/.bashrc
  source ~/.bashrc
}

bash__remote_updater__init__
