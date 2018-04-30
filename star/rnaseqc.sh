#!/bin/bash
##PBS -j oe
#PBS -e /dev/null
#PBS -o /dev/null
cd $PBS_O_WORKDIR
input_absolute_path=`readlink -f $outdir_star/${sample_name}Aligned.sortedByCoord.out.bam` &&
cat <<EOF > $log/$sample_name.03.rnaseqc.log &&
# Output files list
gene_rpkm - $outdir_rsem/$sample.gene_rpkm.gct.gz
gene_counts - $outdir_rsem/$sample.gene_reads.gct.gz
exon_counts - $outdir_rsem/$sample.exon_reads.gct.gz
count_metrics - $outdir_rsem/$sample.metrics.tsv
count_outputs - $outdir_rsem/$sample.tar.gz
EOF
python3 ~kjyi/src/star/rnaseqc.py \
	$input_absolute_path $sjdbGTFfile $reference $sample_name \
	--output_dir $outdir_rsem \
	--java $java \
	--jar $rnaseqc \
	--memory $MEMORY \
	--rnaseqc_flags noDoC strictMode \
	--gatk_flags $gatk_flags &>> $log/$sample_name.03.rnaseqc.log && 
mv $log/$sample_name.03.rnaseqc.log $log/$sample_name.03.rnaseqc.done.log
if [ -f $log/$sample_name.03.rnaseqc.log ]; then
	mv $log/$sample_name.03.rnaseqc.log $log/$sample_name.03.rnaseqc.fail.log 
fi
