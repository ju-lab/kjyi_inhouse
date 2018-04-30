# ENCODE ATAC-seq pipeline

`sh run_atac_pipe.sh --help`

```
# pseudocode
function atac_PE(replicate) {
	if (!trimmed)
		ad1 = detect_adapter(fq1)
		ad2 = detect_adapter(fq2)
		p1,p2 = cutadapt(f1q,ad1,fq2,ad2)
	else f1,f2 = p1,p2
	(raw.bam,log) = bowtie2(p1, p2)
	(bam, dupqc, pbcqc) = postalign_dedup(bam)
	(bedpe,tagAlign,subsampled_PE2SE) = bam2tag(bam)
	
	#tn5 shift,first
	(final_tag) = tn5_shift(tagAlign)

	#subsampled_tab = subsample_tag(final_tag, subsample=[1|2|3])
	#I cannot understand how to do
	subsampled_tag = final_tag
	
	#spr
	tag_pr1,tagpr2 = spr(subsampled_tag)
	
	#calling
	peak_pr1=macs2(final_tag_pr1)
	pead_pr2=macs2(final_tag_pr2)
	peak	=macs2(final_tag)

	#crosscorrelation plot (kind of QC)
	xcor_qc,xcor_plot = xcor(subsampled_PE2SE)

}
void ataqc (replicate) {
	sort bam
	if rep == 1; idr_peak = idr_pr_rep1
	else idr_peak = idr_opt

	if(se)
	if(pe) ataqc(fq1,fq2,bam,align_log,pbc_qc,sort_bam,dedupqc,
		filt_bam,final_tag,pval_bigwig,peak,idr_peak,peak_overlap) # ????
}

function main() {
	smooth_win=150
	for rep{
		if(se) atac_se(rep)
		if(pe) atac_pe(rep)
	}
	# pool
	tag_pooled,tag_ppr1,tag_ppr2 = ppr(tag_rep1, tag_pr1_rep1, tag_pr2_rep1,
										tag_rep2, tag_pr1_rep2, tag_pr2_rep2,
										tag_rep3, tag_pr1_rep3, tag_pr2_rep3) ...
	# call on pool
	peak_ppr1 = macs2(tag_ppr1)
	peak_ppr2 = macs2(tag_ppr2)
	peak_pool = macs2(tag_pooled)

	# Overlaps between ..
	# rep1, rep2, pool            ->tr
	# pr1rep1, pr2rep1, peak_rep1 ->pr_rep1
	# pr1rep2, pr2rep2, peak_rep2 ->pr_rep2
	# ppr1 ppr2 pool			  ->ppr

	overlap_qc, overlap_opt, overlap_consv = finalqc(tr, pr_rep1, pr_rep2, ppr)

	FRIP (fraction of reads in peaks)
	...

	ATAQC
	for rep, ataqc(rep)
}

```

