#!/bin/bash
. ~kjyi/src/parse
PARSE $@ << __PARSE__
# mutect2 wrapper
--pon			pon
--gnomad		gnomad
--drf			drf
--aoanir		aoanir
--outdir		outdir
--ref			ref
--interval		interval
--tb			input_tumor
--nb			input_normal
__PARSE__
java=~kjyi/src/java.sh
tumor_name=`$java -jar gatk4.jar GetSampleName -I $input_tumor -O /dev/stdout 2>/dev/null`
normal_name=`$java -jar gatk4.jar GetSampleName -I $input_normal -O /dev/stdout 2>/dev/null`
LOG=$outdir/$log/$tumor_name.mutect2.log
$java -Xmx16g -jar gatk4.jar Mutect2 \
		-I $input_tumor \
		-I $input_normal \
		-tumor $tumor_name \
		-normal $normal_name \
		--genotype-germline-sites \
		`echo $pon | sed 's/./-pon &/'` \
		`echo $gnomad | sed 's/./--germline-resource &/'` \
		`echo $drf | sed 's/./--disable-read-filter &/'` \
		`echo $aoanir | sed 's/./--af-of-alleles-not-in-resource &/'` \
		-O $outdir/$tumor_name.vcf.gz \
		-R $ref \
		-L $interval 2> $LOG.log &&
		mv $LOG.log $LOG.done
		if [ -f $LOG.log ]; then mv $LOG.log $LOG.fail; exit 1; fi


