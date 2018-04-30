#!/bin/bash
# ~/src/atac/run_atac_pipe.sh
. ~/src/parse.sh
PARSE $@ <<EOF 
# ATAC-seq pipeline
# detect and trim adaptor sequence first, then run this
#
# Usage: `basename $0` <sample_name> <in1.fa.gz> [in2.fa.gz] [options..]
#
# Arguments:
<sample_name>			sample			''			sample name
<fastq.gz>				FASTQ1			''			as .gz 
[fastq.gz2]				FASTQ2			''			
--output_bam <path>		output_bam		./bowtie2	final filtered file = <output_bam>/<sample>.bam
--output_qc <path>		output_qc		./qc/atac	output dir for QC metric files
--output_sig <path>		output_sig		./atac		output dir for atac peak, signal, pvalues //
--log <path>			log				./log/atac	log dir
--memory <nnGB>			memory			30GB		memory
--thread <int>			thread			6			thread
--process [all|...]		process			all			comma seperated list of process
#						 				 			[all|bowtie2|postalign|bam2tag|xcor|spr] 
--bwt2_idx [mm10|path]	bwt2_idx		'mm10'		[mm10|bowtie2_idx]
--multimapping <int>	multimapping	4			bowtie default = 0, ENCODE3 = 4
--script_out <file>		script_out		''			if specified, dont qsub
EOF

# run pipeline
SCRIPT=~kjyi/src/atac
if [ "$process" == "all" ]; then
    process="bowtie2,postalign,bam2tag,xcor,spr"
fi
process=${process//,/ }
if [ "x$script_out" == "x" ]; then
    for i in $process; do
	case $i in
	    bowtie2)
		if [ ! -f $log/$sample.01.align.done ]; then
		    rm -f $log/$sample.01.align.fail
		    runbowtie2=$(qsub -q week -l nodes=1:ppn=$thread,mem=$memory \
			-N bowtie2.${sample} -v $arguments $SCRIPT/bowtie2.qsh)
		    echo "Bowtie2		$sample	$runbowtie2"
		fi ;;
	    postalign)	
		if [ ! -f $log/$sample.02.postalign.done ]; then
		    rm -f $log/$sample.02.postalign.fail
		    depend=${runbowtie2/#/-W depend=afterok:}
		    runpostalign=$(qsub -q day -l nodes=1:ppn=6,mem=24GB \
			-N postalign.${sample} -v $arguments $depend $SCRIPT/postalign.qsh)
		    echo "Postalign		$sample	$runpostalign"
		fi ;;
	    bam2tag)
		if [ ! -f $log/$sample.03.bam2tag.done ]; then
		    rm -f $log/$sample.03.bam2tag.fail
		    depend=${runpostalign/#/-W depend=afterok:}
		    runbam2tag=$(qsub -q day -l nodes=1:ppn=4,mem=24GB \
			-N bam2tag.${sample} -v $arguments $depend $SCRIPT/bam2tag.qsh)
		    echo "Bam2tag		$sample	$runbam2tag"
		fi ;;
	    spr)
		if [ ! -f $log/$sample.04.spr.done ]; then
		    rm -f $log/$sample.04.spr.fail
		    depend=${runxcor/#/-W depend=afterok:}
		    runspr=$(qsub -q day -l nodes=1:ppn=3,mem=12GB \
			-N spr.${sample} -v $arguments $depend $SCRIPT/spr.qsh)
		    echo "Self pseudoreplicates	$sample	$runspr"
		fi ;;
	esac
    done
else
    echo -e "#!/bin/bash\n# ENV" > $script_out
    args=`echo $arguments | sed 's/,/ /g'`
    for i in $args;do echo $i=\"`printenv $i`\" >> $script_out; done
    for i in $process; do
	case $i in
	    bowtie2)	script_files+=" $SCRIPT/bowtie2.qsh" ;;
	    postalign)	script_files+=" $SCRIPT/postalign.qsh" ;;
	    bam2tag)	script_files+=" $SCRIPT/bam2tag.qsh" ;;
	    spr)	script_files+=" $SCRIPT/spr.qsh" ;;
	    *) continue ;;
	esac
    done
    cat $script_files | grep -v "#PBS" | grep -v "#!/bin/bash" | \
	grep -v 'cd $PBS_O_WORKDIR' >> $script_out
fi

