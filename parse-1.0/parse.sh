#!/bin/bash
# made by kjyi
cat << devnull > /dev/null
#############################EXMPLE##########################################
#!/bin/bash
. ~/src/parse.sh
PARSE $@ << EOF
#Help message
#Help message
#Help message
#Help message
#flag		varName		default		description_
<fastq>		input		""			Description of first positional arugment
<outpu>		input2		''		 
<outpu>		input3		
#						default and description can be ommited	
<fastq>		input2		""		some text like <fastq> required for pos. arg.
#									One can add additional line of comment btw arg.
#									with some tabs and spaces, spaces are
#			_ here		_ here		and text here
-a <int>    apple		"sagwa" Description and default value can be ommitted
-b|--BB     varName		default    Description
-v			flag		false		default as false or "false" treated as boolean
EOF
fi #########################################################################
devnull

PARSE() {
	VERBOSE=false
    IN=`cat /dev/stdin |
    sed '
    /^$/ s/^/#/
    /^[^#]/ {
		     :a s/\t\t/\t/g; ta;
		     :b s/  / /g;    tb;
		     :c s/\t /\t/g;  tc;
		     :d s/ \t/\t/g;  td;
		        s/^\t//
		/^[^-]/ s/^/-@P/
    }
	/^#/ {
		:e s/\t\t/\t/g; te;
	}
    '`
	shopt -s extglob 
#echo "$IN" | sed '/^#/d;s/$/\t""/;s/[^\t]*\t\([^\t]*\)\t\([^\t]*\).*/\1=\2/;/^=$/d'
eval `echo "$IN" | sed '/^#/d;s/$/\t""/;s/[^\t]*\t\([^\t]*\)\t*\([^\t]*\).*/\1="\2"/;s/""\(.*\)""/"\1"/g;s/"'\''\(.*\)'\''"/"\1"/g;/^=$/d'`
$VERBOSE && echo "$IN" | sed '/^#/d;s/$/\t""/;s/[^\t]*\t\([^\t]*\)\t*\([^\t]*\).*/\1="\2"/;s/""\(.*\)""/"\1"/g;s/"'\''\(.*\)'\''"/"\1"/g;/^=$/d'
    USAGE1=`echo "$IN" | sed '/^[^#]/,$ d; s/^# //;s/^#//'`
    USAGE2=`echo "$IN" | sed -n '/^[^#]/,$ p'| sed '/^#/ {:x s/\t\t/\t/g;tx;s/\t//};/^#/! s/\t[^\t]*//; s/^-@P/ /;s/^#//'|column -t -s $'\t'`
    if [ $# == 0 ]; then echo "$USAGE1"; echo "$USAGE2"; echo "no argument submitted"; exit 1; fi
    MATRIX=`echo "$IN"|sed '/^#/d;/^$/d;/^\s*$/d;'`
    FLAGS=( `echo "$MATRIX" | cut -d ' ' -f1| cut -f1` )
    VARS=( `echo "$MATRIX" | cut -f2` )
    POS=( `echo "$MATRIX" | grep "^-@P" | cut -f2` )
    ARGS=( "$@" )
	$VERBOSE &&	ARGS_bak=( "$@" )
    for i in "${!ARGS[@]}"; do
		$VERBOSE && echo "~ARGS[i] $i ${ARGS[i]}"
		case "${ARGS[i]}" in
		    '') continue ;;
		    -h|--help) echo "$USAGE1"; echo "$USAGE2"; exit 1;;
		    -*) 
				BOOL=false
				for j in "${!VARS[@]}"; do
					$VERBOSE && echo ~~~~VARS[$j] ${ARGS[i]} ${VARS[j]} search ${FLAGS[@]}
					test='@('${FLAGS[j]}')'
				    case ${ARGS[i]} in
						$test)
							$VERBOSE && echo "case ARGS[$i] ${ARGS[i]}, in FLAGS[$j] ${FLAGS[j]}"
							$VERBOSE && echo challenge VARS[$j] ${VARS[j]}, '$(eval echo $`echo ${VARS[j]}`)' $(eval echo $`echo ${VARS[j]}`) == "false"?
							if [ "x$(eval echo $`echo ${VARS[j]}`)" == "xfalse" ]; then
								$VERBOSE && echo VARS[$j] ${VARS[j]}'x$(eval echo $`echo ${VARS[j]}`) == "xfalse", value turns true'
								eval "${VARS[j]}=\"true\""
								BOOL=true
							else
								eval "${VARS[j]}=${ARGS[i+1]}"
								#eval "${VARS[j]}=\"${ARGS[i+1]}\""
							fi
							;;
					esac
				done
				if ! $BOOL; then unset 'ARGS[i+1]'; fi ;;
		    --) unset 'ARGS[i]'; break;;
		    *) continue;;
		esac
		unset 'ARGS[i]'
    done
    REMAIN=( "${ARGS[@]}" )
    for i in "${!POS[@]}"; do
	eval "${POS[i]}=\"${REMAIN[i]}\""
    done
    arguments=`echo ${VARS[@]} |sed 's/ /,/g'`
    export `echo ${VARS[@]}`
if $VERBOSE ; then
echo "MATRIX:"
echo "$MATRIX"|sed 's/\t/\t\|/g'|column -t -s $'\t'
echo "FLAGS: ${FLAGS[@]}"
echo "VARS : ${VARS[@]}"
echo "POS  : ${POS[@]}"
echo "ARGS : ${ARGS_bak[@]}"
echo "REMAIN: ${REMAIN[@]}"
fi
}
