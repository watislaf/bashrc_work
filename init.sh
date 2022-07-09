function bash__remote_updater {
  BASH__REMOTE_UPDATER_DIRNAME=$(dirname -- "$0")
  function bash__remote_updater__init__ {
    echo "source ${BASH__REMOTE_UPDATER_DIRNAME}/.bashrc" >>~./bashrc
  }
  bash__remote_updater__init__
}

bash__remote_updater
