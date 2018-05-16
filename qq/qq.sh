#!/bin/bash
. ~kjyi/src/parse
prevent=true
PARSE $@ 1 << EOF
#Display cpu usage of Julab's cluster
-u|--user		WHO			$USER
-i|--interval	interval	0
EOF

mkdir -p ~/.cpu
PRINT()
{
    for j in `seq $N`; do echo -en "$S"; done
}
# call top
Init=true
while :; do
ssh node0 -x -p 2030 top -b -n 1 > ~/.cpu/0 &
for i in 1 2 3 4 5 6 7 8; do
    ssh node$i -x top -b n 1 > ~/.cpu/$i &
done
wait

rm -rf ~/.cpu/j*
qstat -n1 -u $WHO |\
    sed '1,5d; s/\/.*//;s/.bnode0.kaist.ac.//; s/bnode\([0-9]\)$/~\/.cpu\/j\1/' |\
    awk '$10=="R" {print "echo " $4 " \\\(" $1 "\\\) >> " $12}' 2>/dev/null | bash
C=( 4 24 24 24 24 24 28 28 28 )
for i in {0..8}; do
    T=`awk 'NR>7 { sum += $9;  } END { printf "%.0f\n", (sum+25)/100;  }' ~/.cpu/$i` 
    M=`grep $WHO ~/.cpu/$i | awk '{ sum += $9;   } END { printf "%.0f\n", sum/100;   }'`
    L=${C[$i]}
    MYCOLOR="\033[48;5;6m+\033[0m"
    ALLCOLOR="\033[48;5;8m \033[0m"
    BACKGROUND="\033[48;5;232m \033[0m"
	if ! $Init; then 
		if [ "$i" == "0" ]; then tput cuu 9; fi
		tput el 
	fi
    echo -en " $i "
    S=$MYCOLOR; N=$M; PRINT;
    S=$ALLCOLOR; N=$(($T-$M)); PRINT;
    S=$BACKGROUND; N=$(($L-$T)); PRINT;
    if [ "$i" == "0" ]; then
		echo -en "\t\t\t\t"
		qstat -u $WHO | awk 'BEGIN { R = 0; H = 0; Q = 0 } $10 == "R" { R += 1  } $10 == "H" { H += 1 } $10 == "Q" { Q += 1 } END { print R "R " H "H " Q "Q" }'
    elif [ -f ~/.cpu/j$i ]; then 
		nj=$(wc -l ~/.cpu/j$i | cut -f1 -d ' ')
		if [ $nj -gt 1 ]; then njt="+"$(($nj - 1)); fi
		echo " " $(head -n1 ~/.cpu/j$i) $njt
    else 
		echo
    fi
#	if [ "$i" == 8 ]; then tput cuu 9; fi
done
Init=false
if [ "$interval" == "0" ]; then exit 0; fi
sleep $((interval - 1))
done
