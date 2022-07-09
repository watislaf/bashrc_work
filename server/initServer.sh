function bash__remote_updater__ {
  BASH__REMOTE_UPDATER_DIRNAME=$(dirname -- "$0")
  function bash__remote_updater__init__ {
    echo "source ${BASH__REMOTE_UPDATER_DIRNAME}/src/bashrc_work.sh" >>~/.bashrc
    echo "bash___basics__()" >>~/.bashrc
    echo "bash__fixes__()" >>~/.bashrc
    echo "bash__gTools__()" >>~/.bashrc
    echo "bash__decorations__()" >>~/.bashrc
    echo "bash__remote_updater__()" >>~/.bashrc
    bash__remote_updater__init__
  }
}

bash__remote_updater
source ~/.bashrc
