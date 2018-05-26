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
    USAGE2=`echo "$IN" | sed -n '/^[^#]/,$ p'| sed '/^#/ {:x s/\t\t/\t/g; tx;}; /^#/! s/\t[^\t]*//; s/^-@P/ /;s/^#//'|column -t -s $'\t'`
    if [ $# == 0 ]; then echo "$USAGE1"; echo "$USAGE2"; echo "no argument submitted"; exit 1; fi
    mAtRiX=`echo "$IN"|sed '/^#/d;/^$/d;/^\s*$/d;'`
    FlAgS=( `echo "$mAtRiX" | cut -d ' ' -f1| cut -f1` )
    VarS=( `echo "$mAtRiX" | cut -f2` )
    POoOOS=( `echo "$mAtRiX" | grep "^-@P" | cut -f2` )
    ArGss=( "$@" )
	$VERBOSE &&	ArGss_bak=( "$@" )
    for iIiI in "${!ArGss[@]}"; do
		$VERBOSE && echo "~ArGss[i] $iIiI ${ArGss[iIiI]}"
		case "${ArGss[iIiI]}" in
		    '') continue ;;
		    --help) echo "$USAGE1"; echo "$USAGE2"; exit 1;;
		    -*) 
				BOOL=false
				for jJjJ in "${!VarS[@]}"; do
					$VERBOSE && echo ~~~~VarS[$jJjJ] ${ArGss[iIiI]} ${VarS[jJjJ]} search ${FlAgS[@]}
					test='@('${FlAgS[jJjJ]}')'
				    case ${ArGss[iIiI]} in
						$test)
							$VERBOSE && echo "case ArGss[$iIiI] ${ArGss[iIiI]}, in FlAgS[$jJjJ] ${FlAgS[jJjJ]}"
							$VERBOSE && echo challenge VarS[$jJjJ] ${VarS[jJjJ]}, '$(eval echo $`echo ${VarS[jJjJ]}`)' $(eval echo $`echo ${VarS[jJjJ]}`) == "false"?
							if [ "x$(eval echo $`echo ${VarS[jJjJ]}`)" == "xfalse" ]; then
								$VERBOSE && echo VarS[$j] ${VarS[jJjJ]}'x$(eval echo $`echo ${VarS[j]}`) == "xfalse", value turns true'
								eval "${VarS[jJjJ]}=\"true\""
								BOOL=true
							else
								eval "${VarS[jJjJ]}=${ArGss[iIiI+1]}"
								#eval "${VarS[j]}=\"${ArGss[i+1]}\""
							fi
							;;
					esac
				done
				if ! $BOOL; then unset 'ArGss[iIiI+1]'; fi ;;
		    --) unset 'ArGss[iIiI]'; break;;
		    *) continue;;
		esac
		unset 'ArGss[iIiI]'
    done
    REMAIN=( "${ArGss[@]}" )
    for i in "${!POoOOS[@]}"; do
	eval "${POoOOS[iIiI]}=\"${REMAIN[iIiI]}\""
    done
    arguments=`echo ${VarS[@]} |sed 's/ /,/g'`
    export `echo ${VarS[@]}`
if $VERBOSE ; then
echo "mAtRiX:"
echo "$mAtRiX"|sed 's/\t/\t\|/g'|column -t -s $'\t'
echo "FlAgS: ${FlAgS[@]}"
echo "VarS : ${VarS[@]}"
echo "POoOOS  : ${POoOOS[@]}"
echo "ArGss : ${ArGss_bak[@]}"
echo "REMAIN: ${REMAIN[@]}"
fi
}
