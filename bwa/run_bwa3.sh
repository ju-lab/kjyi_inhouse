#!/bin/bash
. ~kjyi/src/parse
PARSE $@ << EOF
# run_bwa.sh by kjyi performs alignment of fastq files using BWA MEM, sorting, 
# mark duplicates, realign around indels, BQSR, and indexing.
# Usage: $0 <sample_name> <in1.fa.gz> [in2.fa.gz] [--outdir PATH]
<sample_name>		SAMPLE	""
<in1.fa.gz>			FASTQ1	""
<in2.fa.gz>			FASTQ2	""
-i|--inputfiles		INPUT
-o|--outdir <path>	OUTDIR	./bam
-l|--log			LOG		./log
-t|--thread			THREAD	16
-m|--memory			MEMORY	16G
--reference			REF		/home/users/kjyi/ref/hg38.fa
--indel				INDEL	
--dbsnp				DBSNP	
--dry				dry		false
EOF

cat << __LOOP__ |
loop
__LOOP__
cat  - 1

exit 0

($dry && cat || qsub) << __SCRIPTS__
#PBS -N align
#PBS -e /dev/null
#PBS -o /dev/null
#PBS -q month
#PBS -l nodes=1:ppn=24
cd \$PBS_O_WORKDIR
$(cat bwa.qsh)

__SCRIPTS__
