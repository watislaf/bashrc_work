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
}

function bash__decorations__ {
  # adds current branch
  git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
  }
  export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+(${debian_chroot})}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[00;32m\]\$(git_branch)\[\033[00m\]\$ "
  
  # fzf
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash
}

function bash__gTools__ {
  BASH_GTOOLS__CLION_PATH__=/var/fpwork/${USER}/clion-2021.3
  BASH_GTOOLS__GNB_PATH__=/var/fpwork/${USER}/gnb
  function BASH_GTOOLS__PRINT__SECTION {
    echo "---------- ${1} ---------------"
  }
  BASH_GTOOLS__PRINT__SECTION GO

  BASH_GTOOLS__PRINT__SECTION HELP
  echo "All => gha"
  function gha {
    echo "go Help Tools => ght"
    function ght {
      BASH_GTOOLS__PRINT__SECTION MOVEMENT
      echo "Gnb => gmg"
      function gmg() {
        cd $BASH_GTOOLS__GNB_PATH__
      }

      echo "Uplane => gmu"
      function gmu {
        cd ${BASH_GTOOLS__GNB_PATH__}/uplane
      }

      echo "Run => gmr"
      function gmr() {
        cd $BASH_GTOOLS__GNB_PATH__/uplane/L2-PS/run
      }

      echo "Source => gms"
      function gms() {
        cd $BASH_GTOOLS__GNB_PATH__/uplane/L2-PS/src/
      }
	  
	  echo "create save point V here=> gmv"
      function gmv() {
        pwd > ~/last_saved_path.tmp
      }
	  
	  echo "go to save point => gm-"
      function gm-() {
        cd $(cat ~/last_saved_path.tmp)
      }

      BASH_GTOOLS__PRINT__SECTION GREP
      echo "All word_to_find => gga"
      function gga() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH "$1" ./
      }

      echo " onlySource word_to_find => ggs"
      function ggs() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH "$1" ./ --exclude-dir="ut"
      }

      echo "onlyTests word_to_find => ggt"
      function ggt() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH "$1" ./
      }

      echo "Reversed word_to_find =>ggr"
      function ggr() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH -v "$1" ./
      }
	  
      BASH_GTOOLS__PRINT__SECTION START
      echo "Vim => gsv"
      function gsv() {
        vim -c 'set ic' $1
      }

      echo "Tmux => gst"
      function gst() {
        #fixes tmux error with displays 06.2022
        echo $DISPLAY >~/.tmp42.txt
        /opt/tmux/x86_64/1.9a/bin-wrapped/tmux has-session -t 0 2>/dev/null

        if [ $? != 0 ]; then
          /opt/tmux/x86_64/1.9a/bin-wrapped/tmux
        fi

        /opt/tmux/x86_64/1.9a/bin-wrapped/tmux attach-session -t 0
        export DISPLAY=$(cat ~/.tmp42.txt)
      }
	  
	  echo "ClionStart => gsc"
      function gsc() {
	    gck
        "${BASH_GTOOLS__CLION_PATH__}"/bin/clion.sh >/dev/null 2>&1 &
      }
	  
    }
    echo "Build => ghb"
    function ghb {
      BASH_GTOOLS__PRINT__SECTION BUILD

      echo "Clean => gbc"
      function gbc() {
        gmg
        git clean -xfd
        rm -rf uplane/sdkuplane/cache/
        rm -rf externals/integration
        git restore externals/
        gip
		gip
        cd -
      }
	  
	  echo "L2ps => gbl"
      function gbl() {
        gmr
        # no need with new scripts, but can be use full later
        # ./buildscript/universal/run_nb_scripts.sh
        # prepare-5g-env
		./buildL2ps.sh --only_sct_binary --icecc

        cd -
      }
	  
      echo "Source => gbs"
      function gbs() {
        gmr
        # no need with new scripts, but can be use full later
        # ./buildscript/universal/run_nb_scripts.sh
        # prepare-5g-env
        source ./prepareShell.sh
        cd -
      }

      echo "Reinstall => gbr"
      function gbr() {
        cd /var/fpwork/
        mkdir "${USER}"
        cd "${USER}"
        rm -rf tmp
        rm -rf gnb
        mkdir tmp
        gii
        cd ./gnb &&
          gip &&
          gip
      }
    }
	
    echo "go Help Git => ghc"
    function ghc {
	  BASH_GTOOLS__PRINT__SECTION Clion
	  
	  echo "---> clangd additional flags "
	  echo -ferror-limit=0 , -Wno-error , -Wno-unknown-warning-option , -Wno-reserved-user-defined-literal , -Wdeprecated-declarations
	  
	  echo "---> clang tidy 5g path"
	  echo "/5g/tools/llvm/12.0_034/bin/clang-format"
	  
	  echo "---> SCT cmake build"
	  echo "-GNinja -DSCT_COMP_L2PS=ON -DCMAKE_BUILD_TYPE=Debug"
	  
	  echo "---> FUSE cmake build"
	  echo "-GNinja -DFUSE=ON -DCMAKE_BUILD_TYPE=Debug"
	  
	  echo "Kill => gck"
	  function gck() {
	    ps aux | grep "/var/fpwork/${USER}/clion-2021.3/bin/clion.sh" | awk '{print $2;}' | xargs -I % -n 1 sh -c 'kill -9 %'
	    ps aux | grep "/var/fpwork/${USER}/clion-2021.3/bin/fsnotifier" | awk '{print $2;}' | xargs -I % -n 1 sh -c 'kill -9 %'
	    ps aux | grep "/var/fpwork/${USER}/clion-2021.3/jbr/bin/java" | awk '{print $2;}' | xargs -I % -n 1 sh -c 'kill -9 %'
	  }
	  
	  echo "Install => gci"
	  function gci() {
		cd /var/fpwork/${USER}/
		wget --no-check-certificate https://download.jetbrains.com/cpp/CLion-2021.3.tar.gz
		tar xzf CLion-2021.3.tar.gz
		cd /var/fpwork/${USER}/clion-2021.3/bin/


		echo idea.config.path=/var/fpwork/${USER}/.CLion/config >> idea.properties
		echo  idea.system.path=/var/fpwork/${USER}/.CLion/system >> idea.properties
		echo -Xmx10000m >> clion64.vmoptions 
	  }
      
	}	
    echo "go Help Git => ghi"
    function ghi {
      BASH_GTOOLS__PRINT__SECTION GIT
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
      BASH_GTOOLS__PRINT__SECTION FUSE
      echo "Build => gfb"
      function gfb() {
        gbs
        gmr
        ./fuse/build_binary_for_host_icecc.sh
        ./fuse/build_sct_fuse_framework_icecc.sh
        ./fuse/build_all_sct_fuse_icecc.sh
        cd -
      }

      echo "rebuildTest testName => gft"
      function gft() {
        gmr
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        ./fuse/rebuild_and_run_single_sct.sh
        cd -
      }

      echo "rebuildBinaryAndTest testName => gfb"
      function gft() {
        gmr
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        ./fuse/rebuild_and_run_single_sct_and_binary_icecc.sh
        cd -
      }

      echo "Find testName => gff "
      function gff() {
        gmr
        if [ $1 == "" ]; then
          echo provide name of the test
          return 0
        fi
        ./fuse/list_sct.sh | gga "$1"
        cd -
      }

      echo "clean logs => gfc"
      function gfc() {
        gmg
        rm -rf ./uplane/logs
        rm -rf ./logs
        cd -
      }
    }

    echo "Help UnitTests => ghu"
    function ghu {
      BASH_GTOOLS__PRINT__SECTION UT
      echo "Build => gub"
      function gub() {
        gbs
        gmr
        source ./ut/build_all_ut_icecc.sh
        cd -
      }

      echo "Test => gut name"
      function gut() {
	    gmr
        if [ $1 == "" ]; then
          echo provide name of the test
          return 0
        fi
		./ut/build_and_run_all_ut_icecc.sh
        cd -
      }

      echo "Find => guf"
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
  ghc
}

function bash__remote_updater__ {

  BASH_GTOOLS__PRINT__SECTION Update
  echo "Update bashrc => ubr"
  function ubr {
    cd "${BASH__REMOTE_UPDATER_DIRNAME}"
    git pull
    cd -
    source ~/.bashrc
  }

  echo "auto update Onn(default) => aon"
  function aon {
    BASH__WORK__DEAMON__PIDFILE=${BASH__REMOTE_UPDATER_DIRNAME}/server/deamonBASH__WORK__DEAMON__PIDFILE.txt
    cd "${BASH__REMOTE_UPDATER_DIRNAME}"
    source ./server/autoPullDeamon.sh &
    cd -
  }

  echo "auto update Off => aof"
  function aof {
    rm ${BASH__WORK__DEAMON__PIDFILE}
  }
}

function bash__main__ {
  bash___basics__
  bash__fixes__
  bash__gTools__
  bash__decorations__
  bash__remote_updater__
}

bash__main__
