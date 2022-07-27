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

  # fzf https://github.com/junegunn/fzf
  if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
  else
    if [ -d ~/.fzf ]; then
      ~/.fzf/install
    else
      echo "Instalation of fzf"
      cd
      git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
      ~/.fzf/install --key-bindings --completion --no-update-rc
      cd -
      source ~/.fzf.bash
    fi
  fi
}

function bash__gTools__ {
  BASH_GTOOLS__CLION_PATH__=/var/fpwork/${USER}/clion-2021.3
  BASH_GTOOLS__GNB_PATH__=/var/fpwork/${USER}/gnb
  function BASH_GTOOLS__PRINT__SECTION {
    echo -e  "---------| ${1} ---------------------"  | head -c 35 ; echo ""
  }

  function BASH_GTOOLS__PRINT__COMMAND {
	tabs 35  
    echo -e "${1}  \t => ${2}"
	tabs 4 > /dev/null 
  }

  BASH_GTOOLS__PRINT__SECTION "GO"

  BASH_GTOOLS__PRINT__SECTION "HELP"

  BASH_GTOOLS__PRINT__COMMAND "Help all"  \
          "gha"
  function gha {
	BASH_GTOOLS__PRINT__COMMAND "Help Tools"  \
            "ght"
    function ght {
      BASH_GTOOLS__PRINT__SECTION "MOVEMENT"
	  BASH_GTOOLS__PRINT__COMMAND "move to Gnb"  \
			  "gmg"
      function gmg() {
        cd $BASH_GTOOLS__GNB_PATH__
      }

	  BASH_GTOOLS__PRINT__COMMAND "move to Uplane"  \
              "gmu"
      function gmu {
        cd ${BASH_GTOOLS__GNB_PATH__}/uplane
      }

	  BASH_GTOOLS__PRINT__COMMAND "move to Run"  \
              "gmr"
      function gmr() {
        cd $BASH_GTOOLS__GNB_PATH__/uplane/L2-PS/run
      }

	  BASH_GTOOLS__PRINT__COMMAND "move to Source"  \
              "gms"
      function gms() {
        cd $BASH_GTOOLS__GNB_PATH__/uplane/L2-PS/src/
      }

	  BASH_GTOOLS__PRINT__COMMAND "create savePoint at current place"  \
               "gmv"
      function gmv() {
        pwd >~/last_saved_path.tmp
      }

	  BASH_GTOOLS__PRINT__COMMAND "go to savePoint"  \
              "gm-"
      function gm-() {
        cd $(cat ~/last_saved_path.tmp)
      }

      BASH_GTOOLS__PRINT__SECTION "GREP"

	  BASH_GTOOLS__PRINT__COMMAND "find word in All files"  \
            "gga [word_to_find] "
      function gga() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH "$1" ./
      }

	  BASH_GTOOLS__PRINT__COMMAND "find word in onlySource files"  \
            "ggs  [word_to_find]"
      function ggs() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH "$1" ./ --exclude-dir="ut"
      }

	  BASH_GTOOLS__PRINT__COMMAND "find word in onlyTests files"  \
            "ggt"
      function ggt() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
	   fgrep --color=auto -riInH "$1" ./ | fgrep --color=auto "/ut/"  | fgrep --color=auto  "$1" 
      }

	  BASH_GTOOLS__PRINT__COMMAND "reversed grep, use pipe"  \
            "ggr [word_to_find]"
      function ggr() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -v "$1"
      }

      BASH_GTOOLS__PRINT__SECTION START
	  BASH_GTOOLS__PRINT__COMMAND "start Vim with special flags"  \
            "gsv"
      function gsv() {
        vim -c 'set ic' $1
      }

	  BASH_GTOOLS__PRINT__COMMAND "start Tmux"  \
            "gst"
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

	  BASH_GTOOLS__PRINT__COMMAND "start Clion"  \
            "gsc"
      function gsc() {
        gck
        "${BASH_GTOOLS__CLION_PATH__}"/bin/clion.sh >/dev/null 2>&1 &
      }

    }
	
	BASH_GTOOLS__PRINT__COMMAND "Help build"  \
            "ghb"
    function ghb {
      BASH_GTOOLS__PRINT__SECTION BUILD

	  BASH_GTOOLS__PRINT__COMMAND "Clean old data and install newer, hight chanse of fixing"  \
            "gbc"
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

	  BASH_GTOOLS__PRINT__COMMAND "build L2PS"  \
            "gbl"
      function gbl() {
        gmr
        # no need with new scripts, but can be use full later
        # ./buildscript/universal/run_nb_scripts.sh
        # prepare-5g-env
        ./buildL2ps.sh --only_sct_binary --icecc

        cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "do Source"  \
              "gbs"
      function gbs() {
        gmr
        # no need with new scripts, but can be use full later
        # ./buildscript/universal/run_nb_scripts.sh
        # prepare-5g-env
        source ./prepareShell.sh
        cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "Install gnb"  \
            "gbr"
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
        gbs
      }
    }

	BASH_GTOOLS__PRINT__COMMAND "Help Clion"  \
            "ghc"
    function ghc {
      BASH_GTOOLS__PRINT__SECTION Clion

	  BASH_GTOOLS__PRINT__COMMAND "Kill all clion tasks"  \
            "gck"
      function gck() {
        ps aux | grep "/var/fpwork/${USER}/clion-2021.3/bin/clion.sh" | awk '{print $2;}' | xargs -I % -n 1 sh -c 'kill -9 %'
        ps aux | grep "/var/fpwork/${USER}/clion-2021.3/bin/fsnotifier" | awk '{print $2;}' | xargs -I % -n 1 sh -c 'kill -9 %'
        ps aux | grep "/var/fpwork/${USER}/clion-2021.3/jbr/bin/java" | awk '{print $2;}' | xargs -I % -n 1 sh -c 'kill -9 %'
      }

	  BASH_GTOOLS__PRINT__COMMAND "install clion"  \
            "gci"
      function gci() {
        mkdir cd /var/fpwork/${USER}/
        cd /var/fpwork/${USER}/
        wget --no-check-certificate https://download.jetbrains.com/cpp/CLion-2021.3.tar.gz
        tar xzf CLion-2021.3.tar.gz
        cd /var/fpwork/${USER}/clion-2021.3/bin/

        echo idea.config.path=/var/fpwork/${USER}/.CLion/config >>idea.properties
        echo idea.system.path=/var/fpwork/${USER}/.CLion/system >>idea.properties
        echo idea.plugins.path=/var/fpwork/${USER}/.CLion/config/plugins >>idea.properties

        sed -e '1d' clion64.vmoptions
        echo -Xmx10000m >>clion64.vmoptions
      }

      echo "--- clangd additional flags "
      echo -ferror-limit=0 , -Wno-error , -Wno-unknown-warning-option , -Wno-reserved-user-defined-literal , -Wdeprecated-declarations

      echo "--- clang tidy 5g path"
      echo "/5g/tools/llvm/12.0_034/bin/clang-format"

      echo "--- SCT cmake build"
      echo "-GNinja -DSCT_COMP_L2PS=ON -DCMAKE_BUILD_TYPE=Debug"

      echo "--- FUSE cmake build"
      echo "-GNinja -DFUSE=ON -DCMAKE_BUILD_TYPE=Debug"
    }

	  BASH_GTOOLS__PRINT__COMMAND "Help Git"  \
            "ghi"
    function ghi {
      BASH_GTOOLS__PRINT__SECTION GIT
	  BASH_GTOOLS__PRINT__COMMAND "git pull"  \
			"gip"
	  function gip {
        gmg
        git pull --ff-only
        git submodule sync --recursive
        git submodule update --init --recursive
        cd -
      }
	  
	  BASH_GTOOLS__PRINT__COMMAND "git add all and format "  \
            "gia"
      function gia {
	    gmg
		git diff --name-only | egrep --color=auto "(*.cpp$|*.hpp$|*.h$)" | xargs -I % -n 1 sh -c 'clang-format -i ./%  && echo "ClangFormat on %"'  
        git add ./uplane/L2-PS
		cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "git commit + push "  \
            "gic"
      function gic {
        gmg
        git commit --amend --no-edit --reset-author
        git push origin HEAD:refs/for/master
        cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "only install gnb"  \
            "gii"
      function gii {
        git clone ssh://${USER}@gerrit-wrsl1.int.net.nokia.com:29418/MN/5G/NB/gnb &&
          scp -p -P 29418 ${USER}@gerrit-wrsl1.int.net.nokia.com:hooks/commit-msg gnb/.git/hooks/
      }

	  BASH_GTOOLS__PRINT__COMMAND "git checkout -b"  \
            "gib [new branch name]"
	  function gib {
        git checkout -b $1
      }
	  
	  BASH_GTOOLS__PRINT__COMMAND "git delete all branches"  \
            "gid"  
      function gid {
        git branch | grep -v "master" | xargs git branch -D
      }
	  
	  BASH_GTOOLS__PRINT__COMMAND "git status"  \
            "gis" 
      function gis {
        git status
      }
	  
	  BASH_GTOOLS__PRINT__COMMAND "git checkout"  \
            " gih [name](default master) "
      function gih {
		if [ "$1" == "" ]; then
			$1="master"
		fi
        git checkout $1
      }
    }

	  BASH_GTOOLS__PRINT__COMMAND "Help fuse"  \
            "ghf"
    function ghf {
      BASH_GTOOLS__PRINT__SECTION "FUSE"

	  BASH_GTOOLS__PRINT__COMMAND "Build "  \
            "gfb"
      function gfb() {
        gbs
        gmr
        ./fuse/build_binary_for_host_icecc.sh
        ./fuse/build_sct_fuse_framework_icecc.sh
        cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "rebuildTest"  \
            "gft [testName]"
      function gft() {
        gmr
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
		 ./fuse/rebuild_and_run_single_sct_fuse_and_binary_icecc.sh
        cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "rebuildTest and Bin"  \
            "gftb [testName]"
      function gftb() {
        gmr
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        ./fuse/rebuild_and_run_single_sct_and_binary_icecc.sh
        cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "find test"  \
            "gff [testName]"
      function gff() {
        gmr
        if [ $1 == "" ]; then
          echo provide name of the test
          return 0
        fi
        ./fuse/list_sct.sh | fgrep "$1"
        cd -
      }


	  BASH_GTOOLS__PRINT__COMMAND "build all fuse sct"  \
            "gfa"
      function gfa() {
        gbs
        gmr
        ./fuse/build_all_sct_fuse_icecc.sh
        cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "clean logs "  \
            "gfc"
      function gfc() {
        gmg
        rm -rf ./uplane/logs
        rm -rf ./logs
        cd -
      }
    }

	 BASH_GTOOLS__PRINT__COMMAND "Help UnitTests"  \
            "ghu"
    function ghu {
      BASH_GTOOLS__PRINT__SECTION UT
      echo "Build => gub"
      function gub() {
        gbs
        gmr
        source ./ut/build_all_ut_icecc.sh
        cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "test "  \
            "gut [testname]"
      function gut() {
        gmr
        if [ $1 == "" ]; then
          echo provide name of the test
          return 0
        fi
        ./ut/rebuild_and_run_single_ut.sh $1
        cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "find"  \
            "guf [testname]"
      function guf() {
        if [ $1 == "" ]; then
          echo provide name of the test
          return 0
        fi
        gue
        ninja -C build/l2_ps/ut_build/ -t targets | grep $1
        cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "test all"  \
            "gua"
      function gua() {
        gmr
        ./ut/build_and_run_all_ut_icecc.sh
        cd -
      }
    }

	  BASH_GTOOLS__PRINT__COMMAND "Help remote updater"  \
            "ghr"
    function ghr {
      BASH_GTOOLS__PRINT__SECTION Update
      echo "update bashrc from github => gru"
      function gru {
        cd "${BASH__REMOTE_UPDATER_DIRNAME}"
        git pull
        cd -
        source ~/.bashrc
      }

      function grn {
        BASH__WORK__GUN_DEAMON__PIDFILE=${BASH__REMOTE_UPDATER_DIRNAME}/server/BASH__WORK__GUN_DEAMON__PIDFILE.txt
        cd "${BASH__REMOTE_UPDATER_DIRNAME}"
        source ./server/autoPullDeamon.sh &
        cd -
      }

	  function grf {
        rm ${BASH__WORK__GUN_DEAMON__PIDFILE}
      }
    }
  }
}

function bash__auto_start_on_bash_source {
  gha
  ght
  ghi
  ghb
  ghf
  ghu
  ghc
  ghr
  
  gmg
}

function bash__main__ {
  bash___basics__
  
  bash__fixes__
  
  bash__gTools__
  
  bash__decorations__

  bash__auto_start_on_bash_source
}

bash__main__ 