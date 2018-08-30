#!/bin/bash
#~/src/snv/pon.sh
if [ ! "x$PBS_O_WORKDIR" == "x" ]; then touch dont_run_with_qsub; exit 1; fi

. ~kjyi/src/parse
PARSE $@ << EOF
#USAGE: $0 -s samplename [options] <1.bam> [2.bam] [other bams ...]
-S|--pon_name <str>		pon_name		pon
-o|--outdir <path>		outdir			./pon
-r|--ref <fa>			ref				/home/users/kjyi/ref/hg19.fa
-i|--interval <bed>		interval
-l|--log <path>			log				./log
-t|--scatter_count		scatter_count	6		6~8
-c|--create_pon			create_pon		false
EOF

if $create_pon; then
	qsub -N pon_create -q day -v $arguments \
		-l nodes=1:ppn=4,mem=16g \
		-W depend=afterok:${jobs/%:/} \
		~kjyi/src/snv/pon_create.qsh
	exit 1
fi
for i in ${REMAIN[@]};do
#	export sample=`basename $i | sed 's/\..*//'`
	export input_normal=$i
#	echo $sample $i
	jobs=$jobs:$(
		qsub -N pon_$sample \
			-q week \
			-v ${arguments},input_normal \
			-l nodes=1:ppn=$((scatter_count*2)),mem=$((scatter_count * 12))gb \
			~kjyi/src/snv/pon_individual.qsh
		)
done
echo $jobs
jobs_numbers=`echo $jobs | sed 's/.bnode0.kaist.ac.kr//g'`
qsub -N pon_create \
	-q day \
	-v ${arguments} \
	-W depend=afterok$jobs \
	-l nodes=1:ppn=4,mem=16gb \
	~kjyi/src/snv/pon_create.qsh
