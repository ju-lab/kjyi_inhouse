#!/bin/bash
# made by kjyi
PARSE() {
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
	eval `echo "$IN" | sed '/^#/d;s/$/\t""/;s/[^\t]*\t\([^\t]*\)\t*\([^\t]*\).*/\1="\2"/;s/""\(.*\)""/"\1"/g;s/"'\''\(.*\)'\''"/"\1"/g;/^=$/d'`
    USAGE1=`echo "$IN" | sed '/^[^#]/,$ d; s/^# //;s/^#//'`
    USAGE2=`echo "$IN" | sed -n '/^[^#]/,$ p'| sed '/^#/ {:x s/\t\t/\t/g; tx;}; /^#/! s/\t[^\t]*//; s/^-@P/ /;s/^#//'|column -t -s $'\t'`
    if [ $# == 0 ]; then echo "$USAGE1"; echo "$USAGE2"; echo "no argument submitted"; exit 1; fi
    mAtRiX=`echo "$IN"|sed '/^#/d;/^$/d;/^\s*$/d;'`
    FlAgS=( `echo "$mAtRiX" | cut -d ' ' -f1| cut -f1` )
    VarS=( `echo "$mAtRiX" | cut -f2` )
    POoOOS=( `echo "$mAtRiX" | grep "^-@P" | cut -f2` )
    ArGss=( "$@" )
    for iIiI in "${!ArGss[@]}"; do
		case "${ArGss[iIiI]}" in
		    '') continue ;;
		    --help) echo "$USAGE1"; echo "$USAGE2"; exit 1;;
		    -*) 
				BOOL=false
				for jJjJ in "${!VarS[@]}"; do
					test='@('${FlAgS[jJjJ]}')'
				    case ${ArGss[iIiI]} in
						$test)
							if [ "x$(eval echo $`echo ${VarS[jJjJ]}`)" == "xfalse" ]; then
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
}
