args=`cat -`
echo "$args" | grep -v "^#" | tr -s '\t' '\t' | awk 'BEGIN {FS="\t"};{ print $2"="$3 }'
echo -en "USAGE=\""
echo "$args" | grep "^#" | sed "s/#//;"
echo "$args" | grep -v "^#" | tr -s '\t' '\t'  | awk 'BEGIN {FS="\t"};{ print $1"\t"$3"\t"$4 }'|column -t -s $'\t'
echo -en "\"\n"
echo 'if [ $# == 0 ]; then echo "$USAGE" 1>&2; exit 2; fi;'
echo 'ARGS=( "$@" )
for i in "${!ARGS[@]}";do
	case "${ARGS[i]}" in
		'\'\'') continue ;;'
		echo '		-h|--help) echo "$USAGE" 1>&2;exit 1;;'
		echo "$args" | grep -v "^#" | tr -s '\t' '\t' | awk 'BEGIN {FS="\t"};{ print "\t\t"$1") "$2"=\"${ARGS[i+1]}\"; unset '\''ARGS[i+1]'\'';;" }' 
		echo '		--) unset '\''ARGS[i]'\'';break;;'
		echo '		*) continue;;'
		echo '	esac'
		echo '	unset '\''ARGS[i]'\'
		echo 'done'
		echo -en 'arguments="'
		echo "$args" | grep -v "^#" | tr -s '\t' '\t' | awk -vORS=, '{ print $2 }'| sed 's/,$/"\n/'
		echo -en 'export '
		echo "$args" | grep -v "^#" | tr -s '\t' '\t' | awk -vORS=' ' '{ print $2 }'| sed 's/,$/\n\n/'
		echo -en "\n"
asdf
