#!/bin/bash
. ~kjyi/src/parse
PARSE $@ << EOF
# run_bwa.sh by kjyi performs alignment of fastq files using BWA MEM, sorting, 
# mark duplicates, realign around indels, BQSR, and indexing.
# Usage: $0 <sample_name> <in1.fa.gz> [in2.fa.gz] [--outdir PATH]
<sample_name>		SAMPLE	""
<in1.fa.gz>			FASTQ1	""
<in2.fa.gz>			FASTQ2	""
-o|--outdir			OUTDIR	./bam
-l|--log			LOG		./log
--reference			REF		/home/users/kjyi/ref/hg38/Homo_sapiens_assembly38.fasta
--indel				INDEL	""
--dbsnp				DBSNP	/home/users/kjyi/ref/hg38/dbsnp.vcf
--process			process	all		all|bwa|gatk|picard comma-seperated
--script			script	false	Do not submit the jobs to PBS, but print the script to standard output 
--dry				dry		false	Check whether files are exist, then exit
--postalt			postalt	true	post_alt process in bwakit
--thread			THREAD	12
--memory			MEMORY	16gb
EOF
# Run pipeline
SCRIPT=~kjyi/src/bwa
if [ "$process" == "all" ]; then
	process="bwa,picard,gatk"
fi
process=${process//,/ }
if $script; then
	echo -e "#!/bin/bash\n# Environment"
	args=`echo $arguments | sed 's/,/ /g'`
	for i in $args; do echo $i=`printenv $i`; done
	(for i in $process; do
		cat ~kjyi/src/bwa/$i.qsh
	done) |sed '/^#PBS/d; /^#!\/bin\/bash/d; s/^cd $PBS_O_WORKDIR/#cd $PBS_O_WORKDIR/'
else
	echo -en "$SAMPLE\t"; ls $FASTQ1 $FASTQ2
	if $dry; then exit 0; fi
	echo $process
	for i in $process; do
		case $i in
			bwa)
				runBWA=$(qsub -v $arguments -q week -l nodes=1:ppn=12,mem=24gb -N bwa_$SAMPLE $SCRIPT/bwa.qsh)
				;;
			picard)
				depend=${runBWA/#/-W depend=afterok:}
				runPICARD=$(qsub $depend -v $arguments -q week -l nodes=1:ppn=6,mem=16gb -N picard_$SAMPLE $SCRIPT/picard.qsh)
				;;
			gatk)
				depend=${runPICARD/#/-W depend=afterok:}
				runGATK=$(qsub $depend -v $arguments -q week -l nodes=1:ppn=6,mem=16gb -N GATK_$SAMPLE $SCRIPT/gatk.qsh)
				;;
		esac
	done
fi
