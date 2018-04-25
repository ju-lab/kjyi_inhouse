#!/bin/bash
usage()
{
	USAGE="""	options:
	        -s sequenza_segments.txt
	        -c sequenza_alternative_solutions.txt
		-d directory containing only one pair of *segments.txt and *alternative_solutions.txt
	           (alternative to -s, -c.)
	[example] $0 \\
			-s LU14_segments.txt \\
			-a LU14_alternative_solutions.txt > LU14_cnv.seg"""
	echo "$USAGE"
}
while getopts ":hs:n:a:d:" opt; do
	case $opt in
		s)
			sample=$OPTARG
			;;
		h)
			usage
			exit 1
			;;
		a)
			solution=$OPTARG
			;;
		d)
			directory="$OPTARG"
			solution=$directory/$(ls $directory|grep "alternative_solutions.txt$")
			sample=$directory/$(ls $directory|grep "segments.txt$")
			;;
		:)
			echo "Option -$OPTARG require an argment" >&2
			exit 1
			;;
	esac
done
if [[ $# == 0 ]];then 
	echo "Tranform Sequenza result files to .seg file for IGV. See $0 -h"
	exit 1
fi
main()
{
	purity=$(awk 'FNR == 2 {print $1}' $solution)
	ploidy=$(awk 'FNR == 2 {print $2}' $solution)
	awk '{OFS="\t"}{print $1, $2, $3, $11}' $sample | sed 's/\"//g;1s/^/ID\t/;2,$s/^/purity:'${purity}'\t/' | cat
	awk '{OFS="\t"}{print $1, $2, $3, $12}' $sample | sed '1d;s/\"//g;1s/^/ID\t/;2,$s/^/ploidy:'${ploidy}'\t/' | cat
}
main
exit 1

############################### garbage
Example of segment file
"chromosome"	"start.pos"	"end.pos"	"Bf"	"N.BAF"	"sd.BAF"	"depth.ratio"	"N.ratio"	"sd.ratio"	"CNt"	"A"	"B"	"LPP"
"1"	10231	1378235	0.320255619921236	424	0.127885947440116	0.979199403560858	34186	0.258430611104572	2	2	0	-6.80838499563847
"1"	1380046	2749921	0.365064455139665	1676	0.102099766327084	0.989301715906201	54854	0.243461868926257	2	2	0	-6.84403790504705
"1"	2750437	5727587	0.400703240221489	3684	0.0807269386445343	0.986303546123099	105574	0.247568498289869	3	2	1	-6.87464989969158
"1"	5727589	5729995	0.232258828891315	62	0.114588585348282	0.852617867190011	255	0.30442614407477	5	5	0	-6.73675974397808
"1"	5730050	5734802	0.385038760991741	176	0.0879815548481981	0.879991719183074	496	0.180730355007347	1	1	0	-6.74287218856333
"1"	5734809	5734940	0.186699423286918	14	0.127468677471227	1.0356652576152	25	0.146233922193176	13	12	1	-6.7359134671043
"1"	5734979	12888878	0.402766424461839	5310	0.0773362130527763	0.987453196048006	267957	0.246600226118179	3	2	1	-7.04483491947814
"1"	12888881	13465986	0.331792575215457	1123	0.106467810261742	0.963990220571379	9342	0.274156412560265	2	2	0	-6.75243300429698
"1"	13465997	16833763	0.405780311190562	2491	0.075002286803377	0.985804657423244	115137	0.2416126790661	3	2	1	-6.89660738496052
...truncated

Example of conflints_CP.txt
"cellularity"	"ploidy.estimate"	"ploidy.mean.cn"
0.28	2.5	2.51420400888732
0.31	2.6	2.51420400888732
0.33	2.7	2.51420400888732

JKL-LU-14-cancer_blood-wgs-ILLUMINA_alternative_solutions.txt
"cellularity"	"ploidy"	"SLPP"
0.31	2.6	0.310616732981765
0.2	3.2	4.97784806569682e-11
0.22	3.9	1.24356836065694e-12
0.29	5.9	3.6507091630132e-13
0.18	5.4	7.7258715067658e-16
