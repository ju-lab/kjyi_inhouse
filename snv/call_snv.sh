#!/bin/bash
~kjyi/.parse
PARSE $@ << EOF
# run multiple callers: mutect2, 
# Usage: call_snv.sh [options] <in1.bam> [in2.bam] [in3.bam] ...
-o|--outdir		outdir		snv		output directory (will create subdirectory by callers)
--process		process		all		all|mutect2|varscan
--reference		reference	hg19	hg19|hg38|mm10
--dbsnp			dbsnp		~kjyi/Projects/database/dbsnp/all.vcf
--cosmic		cosmic		~kjyi/Projects/database/cosmic/mutations.vcf
EOF

