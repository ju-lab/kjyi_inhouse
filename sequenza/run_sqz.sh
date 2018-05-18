#!/bin/bash
. ~kjyi/src/parse
PARSE $@ << EOF
-t <bam>	tumor_bam
-n <bam>	normal_bam
-l <path>	log			./log
-THREAD		thread 		10	thread of each mpileup job
-mpdir		mpdir		./mpileup
-sqzdir		sqzdir		./sequenza
-ref		reference	/home/users/data/01_reference/human_g1k_v37/human_g1k_v37.fasta
-gc			gc			/home/users/data/01_reference/human_g1k_v37/human_g1k_v37_noM.gc50Base.txt.gz
EOF
mkdir -p $log $mpdir 
tumor_name=$(basename ${tumor_bam/.bam/})
normal_name=$(basename ${normal_bam/.bam/})
tumor_mpileup=$mpdir/$tumor_name.mpileup.vcf
normal_mpileup=$mpdir/$normal_name.mpileup.vcf
LOG=$log/$tumor_name.sequenza

mpileup1=$(qsub -q week -l nodes=1:ppn=$thread,mem=$((thread * 4))gb -N pile.$tumor_name \
	-e /dev/null -o /dev/null \
	/home/users/kjyi/src/sequenza/mpileup.sh \
	-F "-t $thread -r $reference -o $mpdir $tumor_bam -e $LOG.mp1.log")
mpileup2=$(qsub -q week -l nodes=1:ppn=$thread,mem=$((thread * 4))gb -N pile.$normal_name \
	-e /dev/null -o /dev/null \
	/home/users/kjyi/src/sequenza/mpileup.sh \
	-F "-t $thread -r $reference -o $mpdir $normal_bam -e $LOG.mp2.log")
echo $mpileup1
echo $mpileup2
export tumor_mpileup normal_mpileup reference gc sqzdir tumor_name LOG
arguments=tumor_mpileup,normal_mpileup,reference,gc,sqzdir,tumor_name,LOG

qsub -q week -l nodes=1:ppn=1,mem=20gb -N sqza.$tumor_name \
	-v $arguments \
	/home/users/kjyi/src/sequenza/sqz.qsh
	-W depend=afterok:$mpileup1:$mpileup2 \

