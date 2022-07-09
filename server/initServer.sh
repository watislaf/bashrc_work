function bash__remote_updater__init__ {
  BASH__REMOTE_UPDATER_DIRNAME=$(dirname -- "$0")
    echo "export BASH__REMOTE_UPDATER_DIRNAME=${BASH__REMOTE_UPDATER_DIRNAME}"
    echo "source ${BASH__REMOTE_UPDATER_DIRNAME}/src/bashrc_work.sh" >>~/.bashrc
}

bash__remote_updater__init__
source ~/.bashrc
