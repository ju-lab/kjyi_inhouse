#!/bin/bash
# parsing args
. ~kjyi/src/parse
PARSE $@ << EOF
# run_bwa.sh by kjyi performs alignment of fastq files using BWA MEM, sorting, 
# mark duplicates, realign around indels, BQSR, and indexing.
# Usage: $0 <sample_name> <in1.fa.gz> [in2.fa.gz] [--outdir PATH]
<sample_name>		sample	""
<in1.fa.gz>			fastq1	""
<in2.fa.gz>			fastq2	""
-o|--outdir			outdir	./bam
-l|--log			log		./log
--reference			ref		/home/users/kjyi/ref/hg38/Homo_sapiens_assembly38.fasta
--indel				indel	""
--dbsnp				dbsnp	/home/users/kjyi/ref/hg38/dbsnp.vcf
--process			process	all		all|bwa|gatk|picard comma-seperated
--dry				dry		false
--thread			thread	12
--memory			memory	16gb
EOF

# tools
bwa=/home/users/kjyi/tools/bwa/bwa
samtools=/home/users/kjyi/tools/samtools/samtools-1.5/bin/samtools
sambamba=/home/users/kjyi/tools/sambamba-0.6.7/sambamba
k8=~kjyi/tools/k8/k8-0.2.5/k8-Linux
postaltjs=~kjyi/tools/bwa/bwa.kit/bwa-postalt.js
ref_alt=/home/users/kjyi/ref/hg38/Homo_sapiens_assembly38.fasta.64.alt
bam_postalt=$OUTDIR/tmp_$sample/tmp.sort.bam
seqtk=~kjyi/tools/bwa/bwa.kit/seqtk

# Run pipeline
if [ "$process" == "all" ]; then
	process="bwa,picard,gatk"
fi
process=$(echo $process | sed 's/ /,/g')

if $dry; then
	sub() {
		echo "# qsub $@"
		cat /dev/stdin
	}
else
	sub() {
		qsub $@ < /dev/stdin
	}
fi
for i in $process; do
	case $i in 
		bwa)
			runBWA=$(
				cat << CODE > qsub -v $arguments -q week -l nodes=1:ppn=$thread,mem=$memory -N bwa_$sample -e /dev/null -o /dev/null -
cd \$PBS_O_WORKDIR
bwa_log=$log/$sample.01.bwa.log
temp1=$outdir/tmp_$sample/tmp.unsort.pre_postalt.bam
temp2=$outdir/tmp_$sample/tmp.sort.pre_postalt.bam
temp3=$outdir/tmp_$sample/tmp.postalt.bam
mkdir -p $outdir/tmp_$sample $log
(
	set -e # stop when error occur
	echo '# bwa mapping' 1>&2
	$bwa mem -t $thread \
		-K 100000000 -p -v 2 \
		-R "@RG\tID:${sample}\tLB:${sample}\tSM:${sample}\tPL:ILLUMINA" \
		$ref $fastq1 $fastq2 | \
		$samtools view -1 - >  $temp1

	echo '# sorting' 1>&2
	$sambamba sort $temp1 -t $thread -o $temp2 && rm -rf $temp1

	echo '# postalt' 1>&2
	$k8 $postaltjs $ref_alt $aligned > $temp3 && rm -rf $temp2
)2> \$bwa_log
CODE
			) ;;
		picard)
			runPICARD=$(
				cat << CODE > sub ${runBWA/#/-W depend=afterok:} -v $arguments -q week -l nodes=1:ppn=$thread,mem=$memory -N bwa_$sample -e /dev/null -o /dev/null -
cd \$PBS_O_WORKDIR
#iodef
#mkdir
(

)2> $picard_log
CODE
			)
	esac
done
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
