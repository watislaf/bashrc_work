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
  
  # fix GO script gxt
 if [ ! -d /var/fpwork/${USER} ]; then 
	mkdir /var/fpwork/${USER}
	fi;
}

function bash__decorations__ {
  # adds current branch
  git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
  }
  
   get_current_save() {
    echo  "$(gxt)"
  }
   get_current_sdk() {
   CUR_SDKKK=$(gfss)
    echo  "${CUR_SDKKK::3}"
  }
  
  function _home {
      currentPath=$PWD
      if [ $currentPath == "/home/${USER}" ]; then
         echo "~"
          return 
     fi; 
	 cuttedPath=$(echo $PWD | awk -F"/var/fpwork/${USER}/gnb/uplane/sct/cpp_testsuites/fuse" '{print$2}')
	 if [ "$cuttedPath" == "" ]; then 
		cuttedPath=$(echo $PWD | awk -F"/var/fpwork/${USER}/gnb" '{print$2}')
		 if [ "$cuttedPath" == "" ]; then 
			currentPath=$PWD
		else
			currentPath="=>GNB$cuttedPath"
		fi;
	 else
		currentPath="=>FUSE$cuttedPath"
	 fi;
	 
	echo -e $currentPath
  }
  
  function _host {
	echo $HOSTNAME | tr -dc '0-9' 
  }
  GREETING__="\[\e[01;32m\]\u@\$(_host)\[\e[00m\]:"
  HOME__="\[\e[01;34m\]\$(_home)\[\033[00m\] "
  BRANCH__="\[\033[00;32m\]\$(git_branch)"
  SAVED_TEST__="[\[\e[6;4;35m\]\$(get_current_save)\[\e[0;32m\]]"
  SAVED_SDK__="<\[\e[6;31m\]\$(get_current_sdk)\[\e[0;32m\]>"
  TEXT__COLOR__="\[\033[00m\]"
  export PS1="${GREETING__}${HOME__}${BRANCH__}${SAVED_TEST__}${SAVED_SDK__}${TEXT__COLOR__}\$ "

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
  
  BASH_GTOOLS__START_COLORS_VAL=31
  BASH_GTOOLS__END_COLORS_VAL=37
  BASH_GTOOLS__DEFAULT_END_COLOR="\e[0;40m"
  BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_SECTION_IS_CALLED=$BASH_GTOOLS__START_COLORS_VAL
  function BASH_GTOOLS__PRINT__SECTION {
      BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_SECTION_IS_CALLED=$(( BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_SECTION_IS_CALLED + 1 ))
	  if [ ${BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_SECTION_IS_CALLED} == $BASH_GTOOLS__END_COLORS_VAL ]; then 
		BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_SECTION_IS_CALLED=$BASH_GTOOLS__START_COLORS_VAL
	  fi;

	  echo -e "${BASH_GTOOLS__START_COLOR}||${BASH_GTOOLS__MIDDLE_COLOR}"
	
	  BASH_GTOOLS__START_COLOR="\e[0;${BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_SECTION_IS_CALLED}m"
	  BASH_GTOOLS__MIDDLE_COLOR="\e[7;${BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_SECTION_IS_CALLED}m"
	  echo -e  "${BASH_GTOOLS__START_COLOR}---------------------${BASH_GTOOLS__MIDDLE_COLOR} ${1} ${BASH_GTOOLS__START_COLOR}------------------------"  | head -c 70 
	  echo -e "${BASH_GTOOLS__DEFAULT_END_COLOR}"
  }
  
  BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_IS_CALLED=0
  function BASH_GTOOLS__PRINT__COMMAND { 
    BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_IS_CALLED=$((BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_IS_CALLED+1))
    BASH_GTOOLS__VAR_HELP=$1
    BASH_GTOOLS__VAR_COMMAND=$2
	if [[ $((BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_IS_CALLED % 2)) == 0 ]]; then 
		BASH_GTOOLS__VAR_LINE='============================>'
	else 
		BASH_GTOOLS__VAR_LINE='-  -  -  -  -  -  -  -  -  ->'
	fi;
	printf "${BASH_GTOOLS__START_COLOR}||${BASH_GTOOLS__DEFAULT_END_COLOR}     %s ${BASH_GTOOLS__START_COLOR}%s${BASH_GTOOLS__DEFAULT_END_COLOR} $BASH_GTOOLS__VAR_COMMAND \n" "$BASH_GTOOLS__VAR_HELP" "${BASH_GTOOLS__VAR_LINE:${#BASH_GTOOLS__VAR_HELP}}"
  }
  
	function BASH_GTOOLS__ADDITIONAL_PRINT__COMMAND {
	  BASH_GTOOLS__START_COLOR_UNDER="\e[4;${BASH_GTOOLS__VAR_INCREMENT_EACH_TIME_PRINT_SECTION_IS_CALLED}m"
	  
	  echo -en "${BASH_GTOOLS__START_COLOR}||${BASH_GTOOLS__MIDDLE_COLOR}"
	  echo -en "${BASH_GTOOLS__DEFAULT_END_COLOR}"
	  echo -en  "${BASH_GTOOLS__START_COLOR_UNDER}           ${1}"    
	  echo -e "${BASH_GTOOLS__DEFAULT_END_COLOR}" 
	  
	  echo -en "${BASH_GTOOLS__START_COLOR}||${BASH_GTOOLS__MIDDLE_COLOR}"
	  echo -en "${BASH_GTOOLS__DEFAULT_END_COLOR} $2 ${BASH_GTOOLS__DEFAULT_END_COLOR}"
	  echo -e "${BASH_GTOOLS__DEFAULT_END_COLOR}"
	}
	
function cut_preffix {
echo $1 | awk -F"$2" '{print$2}'
}
  ################################################################

  function ghh {
	BASH_GTOOLS__PRINT__SECTION "HELP"
	BASH_GTOOLS__PRINT__COMMAND "Help help"  \
          "ghh"
		  
	BASH_GTOOLS__PRINT__COMMAND "Help movement"  \
            "ghm"
    function ghm {
      BASH_GTOOLS__PRINT__SECTION "MOVEMENT"
	  BASH_GTOOLS__PRINT__COMMAND "move to Gnb"  \[
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

	  BASH_GTOOLS__PRINT__COMMAND "move to Fuse"  \
              "gmf"
      function gmf() {
        cd $BASH_GTOOLS__GNB_PATH__/uplane/sct/cpp_testsuites/fuse/
      }


	  BASH_GTOOLS__PRINT__COMMAND "create save at pwd"  \
               "gmv"
      function gmv() {
        pwd >~/last_saved_path.tmp
      }

	  BASH_GTOOLS__PRINT__COMMAND "go to savePoint"  \
              "gm-"
      function gm-() {
        cd $(cat ~/last_saved_path.tmp)
      }
	}
	
	BASH_GTOOLS__PRINT__COMMAND "Help tools"  \
            "ght"
	function ght() {
		BASH_GTOOLS__PRINT__SECTION "Tools"
				
		BASH_GTOOLS__PRINT__COMMAND "tools: test set"  \
            "gts [testName]"
		function gts {
			FILE_PATH="/var/fpwork/${USER}/BASH_GTOOLS__SAVED_TEST_NAME"
			if [ ! -f "$FILE_PATH" ]; then 
				echo "" > $FILE_PATH			
			fi;
			
			if [ "$1" == "" ]; then
				cat $FILE_PATH
				return
			fi
			echo $1 > $FILE_PATH
		}
		
		BASH_GTOOLS__PRINT__COMMAND "tools: test clear"  \
            "gtc"
		function gtc {
			echo "" > $FILE_PATH
		}
		

		BASH_GTOOLS__PRINT__COMMAND "format file"  \
            "gtf [file_name]"
		function gtf {
			clang-format -i $1  && echo "ClangFormat on %"
		}
	}

	BASH_GTOOLS__PRINT__COMMAND "Help grep"  \
			"ghg"
    function ghg {
	
      BASH_GTOOLS__PRINT__SECTION "GREP"

	  BASH_GTOOLS__PRINT__COMMAND "find in all"  \
            "gga [word_to_find] "
      function gga() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH "$1" ./
      }

	  BASH_GTOOLS__PRINT__COMMAND "find in source"  \
            "ggs [word_to_find]"
      function ggs() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -riInH "$1" ./ --exclude-dir="ut"
      }

	  BASH_GTOOLS__PRINT__COMMAND "find in ut"  \
            "ggt"
      function ggt() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
	   fgrep --color=auto -riInH "$1" ./ | fgrep --color=auto "/ut/"  | fgrep --color=auto  "$1" 
      }

	  BASH_GTOOLS__PRINT__COMMAND "reversed grep(pipe usage)"  \
            "ggr [word_to_find]"
      function ggr() {
        if [ "$1" == "" ]; then
          echo provide word to find
          return
        fi
        fgrep --color=auto -v "$1"
      }
	}
	BASH_GTOOLS__PRINT__COMMAND "Help start"  \
			"ghs"
    function ghs {
      BASH_GTOOLS__PRINT__SECTION START
	  BASH_GTOOLS__PRINT__COMMAND "open log by vin"  \
            "gsv [cb_full_test_name]"
      function gsv() {
        vim -c 'set ic' "${BASH_GTOOLS__GNB_PATH__}/uplane/logs/${1}_0_0.log"
      }

	  BASH_GTOOLS__PRINT__COMMAND "start Tmux"  \
            "gst"
      function gst() {
        #fixes tmux error with displays 06.2022
        echo $DISPLAY >~/.tmp42.txt
		/opt/tmux/x86_64/1.9a/bin-wrapped/tmux set-option -g history-limit 5000
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

	  BASH_GTOOLS__PRINT__COMMAND "clear rubish" \
            "gbc"
      function gbc {
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
      function gbl {
        gmr
        # no need with new scripts, but can be use full later
        # ./buildscript/universal/run_nb_scripts.sh
        # prepare-5g-env
        ./buildL2ps.sh --only_sct_binary --icecc

        cd -
      }


	  BASH_GTOOLS__PRINT__COMMAND "reinstall gnb"  \
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
	  
	  BASH_GTOOLS__PRINT__COMMAND "do Source"  \
              "gbs"
      function gbs() {
        gmr
        # no need with new scripts, but can be use full later
        # ./buildscript/universal/run_nb_scripts.sh
        # prepare-5g-env
        source ./prepareShell.sh --sdk=$(gfss)
        cd -
      }
	
	  BASH_GTOOLS__PRINT__COMMAND "build ut"  \
            "gbu"
      function gbu() {
        gbs
        gmr
		./buildL2ps.sh --sdk=$(gfss) --ut --icecc
        cd -
      }
	  
	  BASH_GTOOLS__PRINT__COMMAND "Build fuse, run all"  \
            "gbf"
      function gbf() {
		gbs
		if [ $(find ./BASH_GTOOLS__GNB_PATH__/uplane/build/tickler/ -name tickler_nops.sh | ws -l) == 2 ]:
			# Fix tickler_nops.sh does not found 30.07.2022
			echo DOUBLE FUSE 
			find ./BASH_GTOOLS__GNB_PATH__/uplane/build/tickler/ -name tickler_nops.sh
			echo Please remove one dir with tickler nops 
			rm -rf ./BASH_GTOOLS__GNB_PATH__/uplane/build/tickler/cpp_testsuites/Tickler-prj-prefix/src/Tickler-prj-build/
			return
		fi; 
		gmr		
        ./runFuseSCT.sh --sdk=$(gfss) --icecc
        cd -
		gfcj 
      }
    }

	BASH_GTOOLS__PRINT__COMMAND "Help Clion"  \
            "ghc"
    function ghc {
      BASH_GTOOLS__PRINT__SECTION "\033[5;3;35mClion"

	  BASH_GTOOLS__PRINT__COMMAND "Kill all clion tasks"  \
            "gck"
      function gck() {
        ps aux | grep "/var/fpwork/${USER}/clion-2021.3/bin/clion.sh" | awk '{print $2;}' | xargs -I % -n 1 sh -c 'kill -9 %'
        ps aux | grep "/var/fpwork/${USER}/clion-2021.3/bin/fsnotifier" | awk '{print $2;}' | xargs -I % -n 1 sh -c 'kill -9 %'
        ps aux | grep "/var/fpwork/${USER}/clion-2021.3/jbr/bin/java" | awk '{print $2;}' | xargs -I % -n 1 sh -c 'kill -9 %'
      }
	
		BASH_GTOOLS__PRINT__COMMAND "Clion Notes"  \
            "gcn"
		function gcn {
		BASH_GTOOLS__PRINT__SECTION Clion NOTES
		BASH_GTOOLS__ADDITIONAL_PRINT__COMMAND \
		"clangd additional flags" \
		"-ferror-limit=0 , -Wno-error , -Wno-unknown-warning-option , -Wno-reserved-user-defined-literal , -Wdeprecated-declarations"

		BASH_GTOOLS__ADDITIONAL_PRINT__COMMAND \
		"clang tidy 5g path" \
		"/5g/tools/llvm/12.0_034/bin/clang-format"

		BASH_GTOOLS__ADDITIONAL_PRINT__COMMAND \
		"SCT cmake build" \
		"-GNinja -DSCT_COMP_L2PS=ON -DCMAKE_BUILD_TYPE=Debug"

		BASH_GTOOLS__ADDITIONAL_PRINT__COMMAND \
		"FUSE cmake build" \
		"-GNinja -DFUSE=ON -DCMAKE_BUILD_TYPE=Debug"
		
		BASH_GTOOLS__ADDITIONAL_PRINT__COMMAND \
		"ToolChain Dir" \
		"/var/fpwork/${USER}/gnb/uplane/sdkuplane/prefix-root-list/${gfss}/bin/cmake"
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
		
		echo -e "Clion was isntalled, please set proxy in settings : \n host_name: defra1c-proxy.emea.nsn-net.net \n port number: 8080 \n no_proxy_for: localhost,127.0.0.0/8,10.0.0.0/8,*.local,nsn-net.net,inside.nokiasiemensnetworks.com,access.nokiasiemensnetworks.com,nsn-intra.net,nsn-rdnet.net,int.net.nokia.com,nesc.nokia.net "
		echo and set flags:
		gcn
      }
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
	  
	  BASH_GTOOLS__PRINT__COMMAND "git add ./ & format"  \
            "gia"
      function gia {
	  function gitFormatAndAdd {
		if [[ "$1" =~ (*.cpp$|*.hpp$|*.h$) ]] ; then 
			clang-format -i ./%  && echo "Clang format on ./%"
		fi;
		git add $1
		}
	  
		export -f cut_preffix
		export -f gitFormatAndAdd
		
		git diff --name-only |
		egrep -v "/externals/integration/" |
		egrep -v "/context/generator/" |
		xargs -I % -n 1 bash -c "cut_preffix % $(cut_preffix $PWD /var/fpwork/${USER}/gnb/)" |
		xargs -I % -n 1 bash -c "gitFormatAndAdd %"
      }

	  BASH_GTOOLS__PRINT__COMMAND "commit ammend + push"  \
            "gic"
      function gic {
        gmg
        git commit --amend --no-edit --reset-author
        git push origin HEAD:refs/for/master
        cd -
      }

	  BASH_GTOOLS__PRINT__COMMAND "git checkout -b"  \
            "gib [new branch name]"
	  function gib {
        git checkout -b $1
      }
	  

	  BASH_GTOOLS__PRINT__COMMAND "git log -2"  \
            "gil"
	  function gil {
        git log -2
      }
	  
	  BASH_GTOOLS__PRINT__COMMAND "git del all branches"  \
            "gid"  
      function gid {
        git branch | grep -v "master" | xargs git branch -D
      }
	  
	  BASH_GTOOLS__PRINT__COMMAND "git status"  \
            "gis" 
      function gis {
        git status
      }
	  
	  BASH_GTOOLS__PRINT__COMMAND "git log"  \
            "gil" 
      function gil {
        git log
      }
	  
	  BASH_GTOOLS__PRINT__COMMAND "git reset --soft"  \
            "girs" 
      function girs {
        git reset --soft HEAD~1
      }
	  
	  BASH_GTOOLS__PRINT__COMMAND "git reset --harq"  \
            "girh" 
      function girh {
        git reset --hard HEAD~1
      }
	  
	  BASH_GTOOLS__PRINT__COMMAND "git checkout"  \
            "gih [name](default master) "
      function gih {
	   BASH_GTOOLS__TMP_VAR=$1
		if [ "$BASH_GTOOLS__TMP_VAR" == "" ]; then
           BASH_GTOOLS__TMP_VAR=master
        fi
        git checkout $BASH_GTOOLS__TMP_VAR
      }
	  
	  
	  BASH_GTOOLS__PRINT__COMMAND "install gnb"  \
            "gii"
      function gii {
        git clone ssh://${USER}@gerrit-wrsl1.int.net.nokia.com:29418/MN/5G/NB/gnb &&
          scp -p -P 29418 ${USER}@gerrit-wrsl1.int.net.nokia.com:hooks/commit-msg gnb/.git/hooks/
      }
    }

	  BASH_GTOOLS__PRINT__COMMAND "Help fuse"  \
            "ghf"
    function ghf {
      BASH_GTOOLS__PRINT__SECTION "FUSE"

	  BASH_GTOOLS__PRINT__COMMAND "rebuildTest"  \
            "gft [testName] (for debug -d)"
      function gft() {
        gmr
		BASH_GTOOLS__TEST_TO_TEST=$1
        if [ "$BASH_GTOOLS__TEST_TO_TEST" == "" ]; then
			BASH_GTOOLS__TEST_TO_TEST=$(gxt)
			if [ "$BASH_GTOOLS__TEST_TO_TEST" == "" ]; then
				echo provide word to find
			    return
			fi;
        fi
		./runFuseSCT.sh --testcase=$BASH_GTOOLS__TEST_TO_TEST $2 --sdk=$(gfss)  --icecc		
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
	  
	  BASH_GTOOLS__PRINT__COMMAND "rebuildTest and Bin"  \
            "gftb [testName]"
      function gftb() {
        gmr
		BASH_GTOOLS__TEST_TO_TEST=$1
        if [ "$BASH_GTOOLS__TEST_TO_TEST" == "" ]; then
			BASH_GTOOLS__TEST_TO_TEST=$(gxt)
			if [ "$BASH_GTOOLS__TEST_TO_TEST" == "" ]; then
				echo provide word to find
			    return
			fi;
        fi
		./runFuseSCT.sh --testcase=$BASH_GTOOLS__TEST_TO_TEST --sdk=$(gfss)  --icecc --rebuild_binary
		cd -
		
		gfcj
      }

	  BASH_GTOOLS__PRINT__COMMAND "clean logs "  \
            "gfc"
      function gfc() {
        gmg
        rm -rf ./uplane/logs
        rm -rf ./logs
        cd -
      }
	  BASH_GTOOLS__PRINT__COMMAND "clean json gz pcap"  \
            "gfcj"
      function gfcj() {
		gmg
		rm ./uplane/logs/*.json
		rm ./uplane/logs/*.gz
		rm ./uplane/logs/*.pcap
        cd -

      }
	  
		BASH_GTOOLS__PRINT__COMMAND "save SDK "  \
			"gfss [sdkName]"
		function gfss {
			if [ "$1" == "" ]; then
				cat ~/.BASH_GTOOLS__SAVED_SDK_NAME
				return
			fi
			echo $1 > ~/.BASH_GTOOLS__SAVED_SDK_NAME
			if [ $PREPARED_SDK != ""]; then 
				echo "You will need to reopen console"
				echo "also use clear_sct_build_artefacts.sh"
			fi;
		}
		BASH_GTOOLS__PRINT__COMMAND "clean SDK "  \
			"gfsc"
		function gfsc {
			echo "" > ~/.BASH_GTOOLS__SAVED_SDK_NAME
		}
    }

	 BASH_GTOOLS__PRINT__COMMAND "Help UnitTests"  \
            "ghu"
    function ghu {
      BASH_GTOOLS__PRINT__SECTION "UnitT"

	  BASH_GTOOLS__PRINT__COMMAND "test "  \
            "gut [testname]"
      function gut() {
        gmr
		BASH_GTOOLS__TEST_TO_TEST=$1
        if [ "$BASH_GTOOLS__TEST_TO_TEST" == "" ]; then
			BASH_GTOOLS__TEST_TO_TEST=$(gxt)
			if [ "$BASH_GTOOLS__TEST_TO_TEST" == "" ]; then
				echo provide word to find
			    return
			fi;
        fi
		./buildL2ps.sh --sdk=$(gfss) --rebuild_single_ut=$BASH_GTOOLS__TEST_TO_TEST
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
		./buildL2ps.sh --sdk=$(gfss)
        cd -
      }
    }

	BASH_GTOOLS__PRINT__COMMAND "Help remote updater"  \
            "ghr"
    function ghr {
      BASH_GTOOLS__PRINT__SECTION Update
	  
	  BASH_GTOOLS__PRINT__COMMAND "update from github"  \
            "gru"
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
	
	
	BASH_GTOOLS__PRINT__COMMAND "Help All"  \
            "gha"
  }
  function gha {	
	#if u don't need some functionality remove it frome here
	ghn
	ghc
	ghr
	ghm
	ghg
	ghx
	ghs
	ghf
	ghu
	ghi
	ghb
	ghh
	
	BASH_GTOOLS__PRINT__SECTION ---
  }
}

function bash__auto_start_on_bash_source {
  ghh > /dev/null # initialise methods
	
  gha
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