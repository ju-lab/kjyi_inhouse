#!/bin/bash
# ~kjyi/src/star/run_star.qsh
. ~kjyi/src/parse 
PARSE $@ <<EOF
#Align fastq files using STAR (2-pass protocol), mark duplicates,
#Split'N'Trim, and base quality recalibration. Run on Torque/PBS system.
#
# Usage: $0 \ 
#	<--sample_name 'text'> <in1.fa.gz> [in2.fa.gz] \  
#	[options]
#
<in1.fa.gz>						FASTQ1				''			gz format
[in2.fa.gz]						FASTQ2				''			when PE
-s|--sample_name				sample				''			Output prefix
--outdir_star					outdir_star			./star		
--outdir_rsem					outdir_rsem			./rsem		
--outdir_hcall					outdir_hcall		./haplotypeCaller		output dir for haplotype caller
--reference						reference			hg19		[hg19|hg38|mm10|any_path_to_fasta_file] hg19,hg38,mm10 > will change star_index, rsem_reference, sjdbGTFfile setting
--star_index					star_index			~kjyi/ref/hg19/star_index
--rsem_ref						rsem_ref			~kjyi/ref/hg19/rsem_reference
--sjdbGTFfile					sjdbGTFfile			~kjyi/ref/gencode.v27lift37.gtf		Annotation in GTF format
--rsem_max_frag_len				rsem_max_frag_len	1000		
--rsem_estimate_rspd			rsem_estimate_rspd	true		
--is_stranded					is_stranded			false		
-t|--thread						THREAD				4			
--log							log					./log		
--memory						MEMORY				8G			memory usage in picard, gatk, and rnaseqc 8G
--memory_star					memory_star			31gb		memory usage in star 31gb
-m|--mail_address				mail_address		''			
--picard						picard				~kjyi/tools/picard/2.15.0/picard.jar
--gatk							gatk				~kjyi/tools/GATK/3.8.0/GenomeAnalysisTK.jar
--java							java				/usr/java/jre1.7.0_80/bin/java	java for rnaseqc, 1.7
--rnaseqc						rnaseqc				~kjyi/tools/RNA-SeQC/1.1.9/RNA-SeQC.jar
--platform						platform			ILLUMINA
--library						library				''
--outFilterMultimapNmax			outFilterMultimapNmax			20
--alignSJoverhangMin			alignSJoverhangMin				8
--alignSJDBoverhangMin			alignSJDBoverhangMin			1
--outFilterMismatchNmax			outFilterMismatchNmax			999
--outFilterMismatchNoverLmax	outFilterMismatchNoverLmax		0.1
--alignIntronMin				alignIntronMin					20
--alignIntronMax				alignIntronMax					1000000
--alignMatesGapMax				alignMatesGapMax				1000000
--outFilterType					outFilterType					BySJout
--outFilterScoreMinOverLread	outFilterScoreMinOverLread		0.33
--outFilterMatchNminOverLread	outFilterMatchNminOverLread		0.33
--limitSjdbInsertNsj			limitSjdbInsertNsj				1200000
--outSAMstrandField				outSAMstrandField				intronMotif
--outFilterIntronMotifs			outFilterIntronMotifs			None			Use 'RemoveNoncanonical' for Cufflinks compatibility
--alignSoftClipAtReferenceEnds	alignSoftClipAtReferenceEnds	Yes
--quantMode						quantMode						'TranscriptomeSAM GeneCounts'
--outSAMtype					outSAMtype						'BAM Unsorted'
--outSAMunmapped				outSAMunmapped					Within	Keep unmapped reads in output BAM
--outSAMattributes				outSAMattributes				'NH HI AS nM NM ch'
--chimSegmentMin				chimSegmentMin					15	Minimum fusion segment length
--chimJunctionOverhangMin		chimJunctionOverhangMin			15	Minimum overhang for a chimeric junction
--chimOutType					chimOutType						'WithinBAM SoftClip'
--chimMainSegmentMultNmax		chimMainSegmentMultNmax			1
--genomeLoad					genomeLoad						NoSharedMemory
--sjdbFileChrStartEnd			sjdbFileChrStartEnd				''	Input file as chr<tab>star<tab>end<tab>strand splice jx
--gatk_flags					gatk_flags						allow_potentially_misencoded_quality_scores				Optional flags for GATK
--script_out					script_out						''	if specified, dont run, but just make script
--process						process							all		comma-seperatedd jobs: all,star,rsem,hcall
EOF

case $reference in
	hg19)
		reference=~kjyi/ref/hg19.fa
		star_index=~kjyi/ref/hg19/star_index
		rsem_ref=~kjyi/ref/hg19/rsem_reference
		sjdbGTFfile=~kjyi/ref/gencode.v27lift37.gtf
		;;
	hg38)
		reference=~kjyi/ref/hg38.fa
		star_index=~kjyi/ref/hg38/star_index
		rsem_ref=~kjyi/ref/rsem_reference
		sjdbGTFfile=~kjyi/ref/gencode.v27.gtf
		;;
	mm10)
		reference=~kjyi/ref/mm10.fa
		star_index=~kjyi/ref/mm10/star_index
		rsem_ref=~kjyi/ref/mm10/rsem_reference
		sjdbGTFfile=~kjyi/ref/gencode.vM16.gtf
		;;
esac

export reference star_index rsem_ref sjdbGTFfile

SCRIPT=~kjyi/src/star
if [ "$process" == "all" ]; then
	process="star,rsem,hcall"
fi
process=${process//,/ }
if [ "x$script_out" == "x" ]; then
	for i in $process; do
		case $i in
			star)
				if [ ! -f $log/$sample.01.star.done ]; then
					rm -f $log/$sample.01.star.fail
					runSTAR=$(qsub -q day -l nodes=1:ppn=$THREAD,mem=$memory_star -N STAR_$sample -v $arguments $SCRIPT/star.qsh)
					echo STAR	$sample		$runSTAR
				fi 
				;;
			rsem)
				if [ ! -f $log/$sample.02.rsem.done ]; then
					rm -f $log/$sample.02.rsem.fail
					depend=${runSTAR/#/-W depend=afterok:}
					runRSEM=$(qsub -q day -l nodes=1:ppn=$THREAD,mem=$MEMORY -N RSEM_$sample -v $arguments $depend $SCRIPT/rsem.qsh)
					echo RSEM	$sample		$runRSEM
				fi 
				;;
			hcall)
				if [ ! -f $log/$sample.03.hcall.done ]; then
					rm -f $log/$sample.03.hcall.fail
					depend=${runSTAR/#/-W depend=afterok:}
					runHCALL=$(qsub -q week -l nodes=1:ppn=$THREAD,mem=$MEMORY -N hc_$sample -v $arguments $depend $SCRIPT/hcall.qsh)
					echo HaplotypeCaller	$sample		$runHCALL
				fi 
				;;
		esac
	done
else
	echo -e "#!/bin/bash\n# ENV" > $script_out
	args=`echo $arguments | sed 's/,/ /g'`
	for i in $args;do echo $i=\"`printenv $i`\" >> $script_out; done	
	for i in $process; do
		case $i in
			star) script_files+=" $SCRIPT/star.qsh" ;;
			rsem) script_files+=" $SCRIPT/rsem.qsh" ;;
			hcall) script_files+=" $SCRIPT/hcall.qsh" ;;
		esac
	done
	cat $script_files | sed '/^#PBS/d; /^#!\/bin/bash/d; /^cd $PBS_O_WORKDIR/d' >> $script_out
fi

