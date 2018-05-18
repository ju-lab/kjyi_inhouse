#!/bin/bash
#~/src/snv/mutect2.sh
if [ ! "x$PBS_O_WORKDIR" == "x" ]; then touch dont_run_with_qsub; exit 1; fi
. ~kjyi/src/parse
PARSE $@ << EOF
#USAGE: $0 -s samplename [options] <1.bam> [2.bam] [other bams ...]
-t|--tumor_bam						input_tumor		
-n|--normal_bam						input_normal		
-p|--pon							pon			
-o|--outdir							outdir		./mutect2		./mutect2/sample_name.mt2.vcf.gz
-l|--log_dir						log			./log
-r|--reference_fa					ref			hg19
-L|--interval						interval	
-g|--germline_resource				gnomad		/home/users/kjyi/ref/hg19/gnomad/gnomad.exomes.AFonly.vcf.gz
--af-of-alleles-not-in-resource		aoanir		
--disable-read-filter				drf			MateOnSameContigOrNoMappedMateReadFilter
--scatter_count						scatter_count	6	6~8
EOF

case $ref in
	hg19)
		ref=/home/users/kjyi/ref/hg19.fa ;;
	hg38)
		ref=/home/users/kjyi/ref/hg38.fa ;;
esac

qsub -N mt2_$(basename $input_tumor) \
	-q week \
	-v $arguments \
	-l nodes=1:ppn=$((scatter_count * 2)),mem=$((scatter_count * 16))gb \
	~kjyi/src/snv/mutect2.qsh



