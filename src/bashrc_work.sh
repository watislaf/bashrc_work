# .bashrc

function bash___basics__ {
  if [ -f /etc/bashrc ]; then
    . /etc/bashrc
  fi
  PATH=/5g/tools/llvm/12.0_034/bin:$PATH
  TMPDIR=/var/fpwork/$USER/tmp
  TMP=$TMPDIR
  TEMP=$TMPDIR
  export TMPDIR TMP TEMP
  if [[ ! -e $TMP ]]; then
    mkdir $TMP
  fi

  # sometimes used ??
  function prepare-5g-env() {
    export CCACHE_DIR=/var/fpwork/ccache # common ccache for all users on server (faster compilation)
    export CCACHE_ENABLE=1
    export CCACHE_PREFIX=icecc
    export CCACHE_PREFIX_CPP=icecc
    export CCACHE_UMASK=002 # allows to share ccache with other users - for CCACHE_DIR=/var/fpwork/ccache only
    export PARALLEL_BUILD_JOBS=$(($(nproc) / 2))
    export CCACHE_MAXSIZE=100G
    export CCACHE_DEPEND=1
    export CCACHE_SLOPPINESS=pch_defines,time_macros
    export ICECC_REMOTE_CPP=1
    export BB_ENV_EXTRAWHITE+=' CCACHE_DEPEND CCACHE_SLOPPINESS ICECC_REMOTE_CPP'
    export GNB_CCACHE_ENABLED=true
    export ICECC_TEST_REMOTEBUILD=1
    host /var/fpwork/$USER/gnb/set_gnb_env.sh
  }
}

function bash__fixes__ {
  # allows to download files from the internet
  export http_proxy=http://defra1c-proxy.emea.nsn-net.net:8080
  export https_proxy=$http_proxy
  export ftp_proxy=$http_proxy
  export no_proxy=localhost,127.0.0.0/8,10.0.0.0/8,*.local,nsn-net.net,inside.nokiasiemensnetworks.com,access.nokiasiemensnetworks.com,nsn-intra.net,nsn-rdnet.net,int.net.nokia.com,nesc.nokia.net

  # build error 02.2022
  export PARALLEL_BUILD_JOBS=$(($(nproc) / 2))

  # fixes compile error 04.2022
  export LANG=en_US.UTF-8

  #fixes tmux error with displays 06.2022
  echo $DISPLAY >~/.tmp42.txt
  ~/local/bin/tmux attach-session -t 0
  export DISPLAY=$(cat ~/.tmp42.txt)

}

function bash__decorations__ {
  # adds current branch
  git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
  }
  export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+({$debian_chroot})}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[00;32m\]\$(git_branch)\[\033[00m\]\$ "
}

function bash__gTools__ {
  CLION_PATH__=/var/fpwork/${USER}/clion-2021.3/
  BASH_GTOOLS__GNB_PATH__=/var/fpwork/${USER}/gnb

  echo "---------- Go ---------------"

  echo "--------------- HELP ---------------"
  echo "All => gha"
  function gha {
    echo "go Help Tools => ght"
    function ght {
      echo "--------------- Movement ---------------"
      echo "Gnb -> gmg"
      function gmg() {
        cd $BASH_GTOOLS__GNB_PATH__
      }

      echo "Uplane -> gmu"
      function gmu {
        cd ${BASH_GTOOLS__GNB_PATH__}/uplane
      }

      echo "Run -> gmr"
      function gmr() {
        cd $BASH_GTOOLS__GNB_PATH__/uplane/L2-PS/server
      }

      echo "Source -> gms"
      function gms() {
        cd $BASH_GTOOLS__GNB_PATH__/uplane/L2-PS/src/
      }

      echo "--------------- Grep ---------------"
      echo "All word_to_find ->gga"
      function gga() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH "$1" ./
      }

      echo " onlySource word_to_find ->ggs"
      function ggs() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH "$1" ./ --exclude-dir="ut"
      }

      echo "onlyTests word_to_find ->ggt"
      function ggt() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH "$1" ./
      }

      echo "Reversed word_to_find ->ggr"
      function ggr() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH -v "$1" ./
      }

      echo "--------------- Start ---------------"
      echo "ClionStart -> gsc"
      function gsc() {
        ./"${CLION_PATH__}"/bin/clion.sh >/dev/null 2>&1 &
      }

      echo "Vim - gsv"
      function gsv() {
        vim -c 'set ic' $1
      }

      echo "Tmux-> gst"
      function gst() {
        ~/local/bin/tmux attach-session -t 0
      }
    }
    echo "Build -> ghb"
    function ghb {
      echo "-------------- Build--------------"

      echo "clean -> gbc"
      function gbc() {
        gmg
        git clean -xfd
        rm -rf uplane/sdkuplane/cache/
        rm -rf externals/integration
        git restore externals/
        gpl
        gpl
        gpl
        cd -
      }

      echo "source -> gbs"
      function gbs() {
        grn
        # no need with new scripts, but can be use full later
        # ./buildscript/universal/run_nb_scripts.sh
        # prepare-5g-env
        host ./prepareShell.sh
        cd -
      }

      echo "Reinstall -> gbr"
      function gra() {
        cd /var/fpwork/
        mkdir "${USER}"
        cd "${USER}"
        rm -rf tmp
        rm -rf gnb
        mkdir tmp
        gil
        cd ./gnb &&
          gip &&
          gip
      }
    }

    function ghi {
      echo "-------------- gIt--------------"

      echo "pull => gip"
      function gip {
        gmg
        git pull --ff-only
        git submodule sync --recursive
        git submodule update --init --recursive
        cd -
      }

      echo "Commit  => gic"
      function gic {
        gmg
        git diff --name-only | egrep --color=auto "(*.cpp|*.hpp|*.h)" | xargs -I % -n 1 sh -c 'clang-format -i %'
        git commit --amend --no-edit --reset-author
        git push origin HEAD:refs/for/master
        cd -
      }
      echo "Install  => gii"
      function gii {
        git clone ssh://${USER}@gerrit-wrsl1.int.net.nokia.com:29418/MN/5G/NB/gnb &&
          scp -p -P 29418 ${USER}@gerrit-wrsl1.int.net.nokia.com:hooks/commit-msg gnb/.git/hooks/
      }
    }

    echo "Fuse => ghf"
    function ghf {
      echo "-------------- sct-Fuse--------------"
      echo "Build-> gfb"
      function gfb() {
        gbs
        gmr
        ./fuse/build_binary_for_host_icecc.sh
        ./fuse/build_sct_fuse_framework_icecc.sh
        ./fuse/build_all_sct_fuse_icecc.sh
        cd -
      }

      echo "rebuildTest testName=> gft"
      function gft() {
        gmr
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        ./fuse/rebuild_and_run_single_sct.sh
        cd -
      }

      echo "rebuildBinaryAndTest testName=> gfb"
      function gft() {
        gmr
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        ./fuse/rebuild_and_run_single_sct_and_binary_icecc.sh
        cd -
      }

      echo "Find testName -> gff "
      function gff() {
        gmr
        if [ $1 == "" ]; then
          echo provide name of the test
          return 0
        fi
        ./fuse/list_sct.sh | gga "$1"
        cd -
      }

      echo "clean logs-> gfc"
      function gcl() {
        gmg
        rm -rf ./uplane/logs
        rm -rf ./logs
        cd -
      }
    }

    echo "UnitTests => ghu"
    function ghu {

      echo "-------------------UT---------------"
      echo "go build Ut0 -> gbU0"
      function gbU0() {
        gmg
        gbs
        gmg
        ./uplane/L2-PS/server/ut/build_all_ut_icecc.sh
        #    ./buildscript/L2-PS/server ut_build --extra_cmake_flags "-DCMAKE_BUILD_TYPE=Debug" --icecc
      }

      echo "go test Ut -> gut name"
      function gut() {
        if [ $1 == "" ]; then
          echo provide name of the test
          return 0
        fi

        cd -
      }

      echo "go find Ut -> guf"
      function guf() {
        if [ $1 == "" ]; then
          echo provide name of the test
          return 0
        fi
        gue
        ninja -C build/l2_ps/ut_build/ -t targets | grep $1
        cd -
      }
    }
  }
  gha
  ght
  ghi
  ghb
  ghf
  ghu
}

function bash__remote_updater__ {
  echo "update bashrc => sourceBashrc"
  function sourceBashrc {
    cd "${BASH__REMOTE_UPDATER_DIRNAME}"
    git pull
    cd -
    source ~/.bashrc
  }
  sourceBashrc
}

function bash__main__ {
  bash___basics__
  bash__fixes__
  bash__gTools__
  bash__decorations__
  bash__remote_updater__
}
