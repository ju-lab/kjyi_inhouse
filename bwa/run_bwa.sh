#!/bin/bash
. ~kjyi/src/parse
PARSE $@ << EOF
# run_bwa.sh by kjyi performs alignment of fastq files using BWA MEM, sorting, 
# mark duplicates, realign around indels, BQSR, and indexing.
# Usage: $0 <sample_name> <in1.fa.gz> [in2.fa.gz] [--outdir PATH]
<sample_name>		SAMPLE	""
<in1.fa.gz>			FASTQ1	""
<in2.fa.gz>			FASTQ2	""
-o|--outdir <path>	OUTDIR	./bam
-l|--log			LOG		./log
-t|--thread			THREAD	16
-m|--memory			MEMORY	16G
--reference			REF		/home/users/data/01_reference/human_g1k_v37/human_g1k_v37.fasta
--indel				INDEL	/home/users/data/02_annotation/01_GATK/01_golden_standard/Mills_and_1000G_gold_standard.indels.b37.vcf
--dbsnp				DBSNP	/home/users/data/02_annotation/01_GATK/02_db_snp/dbsnp_138.b37.vcf
--script			script	false	Do not submit the jobs to PBS, but print the script to standard output 
--dry				dry		false	Check whether files are exist, then exit
EOF


# Run pipeline
SCRIPT=~kjyi/src/bwa
if $script; then
	echo -e "#!/bin/bash\n# Environment"
	args=`echo $arguments | sed 's/,/ /g'`
	for i in $args; do echo $i=`printenv $i`; done
	cat ~kjyi/src/bwa/bwa.qsh ~kjyi/src/bwa/picard.qsh ~kjyi/src/bwa/gatk.qsh | \
		sed '/^#PBS/d; /^#!\/bin\/bash/d; /^cd $PBS_O_WORKDIR/d'
else
	echo -en "$SAMPLE\t"; ls $FASTQ1 $FASTQ2
	if $dry; then exit 0; fi
	runBWA=$(qsub -V -q long -l nodes=1:ppn=$THREAD -N bwa_$SAMPLE $SCRIPT/bwa.qsh)
	runPICARD=$(qsub -W depend=afterok:$runBWA -V -q long -l nodes=1:ppn=6 -N picard_$SAMPLE $SCRIPT/picard.qsh)
	runGATK=$(qsub -W depend=afterok:$runPICARD -V -q long -l nodes=1:ppn=6 -N GATK_$SAMPLE $SCRIPT/gatk.qsh)
fi
