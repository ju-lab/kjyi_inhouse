#!/bin/bash
GIT=/usr/bin/git
if [[ "$1" = "help" ]]; then
    cat << EOF
Usage:
  git help  (show this message)
  git link  (init,ignore,add,commit,remote,push)
  git sync  (add,commit,push)
EOF
    exit 0
fi

if [[ "$1" = "ignore" ]]; then
    cat << EOF > .gitignore
*/
.gitignore
*.Rproj
*tmp*
*temp*
*.tsv
*.Rds
*.Rdata
*.txt
*.log
EOF
    exit 0
fi

if [[ "$1" = "sync" ]] || [[ "$1" = "s" ]]; then
	if `git rev-parse --is-inside-work-tree &> /dev/null`; then
		status=`git status --short`
		if [ ! "x" == "x$status" ]; then
			echo "$status"
			if [[ "$1" == "sync" ]]; then 
				read -p ":" cm
			else
				cm=""
			fi
			log=~/.git.last.log
			echo "git add -A" > $log
			$GIT add -A &>> $log &&
	    	$GIT commit -m "`echo $cm | sed 's/^$/./'`" &>> $log &&
	    	$GIT push &>>$log &&
			echo "Sync done!" && rm -f $log &&
			exit 0
			cat $log
			exit 0
		fi
		echo Clean
	else
		echo -e "Not in git tree. Consider *git link*"
	fi
	exit 0
fi

if [[ "$1" = "link" ]]; then
    read -p "Git repository : ju-lab/" repo
    $GIT init
    `which $0` ignore
    $GIT add -A
    $GIT commit -m \"initial\"
	#ssh://[user@]host.xz[:port]/~[user]/path/to/repo.git/
    $GIT remote add origin git@github.com:ju-lab/$repo.git
    #$GIT remote add origin ssh://git@github.com:22/ju-lab/$repo.git
    $GIT push -u origin master
    exit 0
fi
$GIT $*
# asdf
