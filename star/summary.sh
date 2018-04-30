#!/bin/bash
. ~kjyi/src/parse.sh
PARSE $@ <<EOF
# Build sample-expression matrix, to standard output
#
# Usage: `basename $0` [-t type] <input_files> [input files..]
# Arguments
-t|--type	type	auto	auto|star|rsem|fpkm|tmp
EOF
if [ "$type" == "auto" ]; then
	case ${REMAIN[1]} in
		*.rsem.genes.results)
				type=rsem ;;
		*.rsem.isoforms.results)
				type=rsem ;;
		*ReadsPerGene.out.tab)
				type=star ;;
	esac
fi

POSTFIX=".rsem.genes.results"
POSTFIX2=".rsem.isoforms.results"
HEADER_COL_NUMBER=1
case $type in 
	star)
		POSTFIX=".ReadsPerGene.out.tab"
		POSTFIX2="ReadsPerGene.out.tab"
		COLNUMBER=2	;;
	rsem) COLNUMBER=5 ;;
	fpkm) COLNUMBER=6 ;;
	tpm) COLNUMBER=7 ;;
esac
if [ $# -gt 10 ]; then
echo; (for i in ${REMAIN[@]}; do echo $i ;done)|\
	sed '7 {s/.*/  ..total '${#REMAIN[@]}' ../};8,'$((${#REMAIN[@]}-7))' d'
else 
	echo; for i in ${REMAIN[@]}; do echo $i; done
fi
read -p "
Input filenames to save summary, press Ctrl-c to cancel:  " pp
read -p "Transpose? (type anything) (default = no)  " tcmd
# Write header
echo -en "Sample\t" >> $pp
tail -n +2 ${REMAIN[1]} | cut -f1 | tr '\n' '\t' | sed 's/\t$//' >> $pp
echo >> $pp 
# Iterate input files and write ouput rows
for i in ${!REMAIN[@]}; do
	NAME=`basename ${REMAIN[i]} | sed 's/'$POSTFIX'//;s/'$POSTFIX2'//'`
	echo "Parsing $NAME ($i/${#REMAIN[@]})"
	echo -en "$NAME\t" >> $pp
	tail -n +2 ${REMAIN[i]} | cut -f $COLNUMBER | tr '\n' '\t' |\
		sed 's/\t$//' >> $pp
	echo >> $pp
done

if [ ! "x$tcmd" == "x" ]; then
	mv $pp ${pp/%.tsv/.wide.tsv}
	~kjyi/src/transpose ${pp/%.tsv/.wide.tsv} > $pp
fi

if [ "$type" == "star" ]; then
	R --slave << EOF
library(tidyverse)
read_tsv("$pp") -> raw
raw %>% slice(-c(1:3)) %>% select(-Sample) %>% colSums() -> uniq_mapped
raw %>% slice(1:3) %>% add_row() -> tmp
tmp[4, 1] <- "uniq_mapped"
tmp[4, -c(1)] <- uniq_mapped
write_tsv(tmp, "$pp.mapping_summary.tsv")
pdf("$pp.plot.pdf")
tmp[,-c(1)] %>% as.matrix() %>% t() %>% {colnames(.) <- tmp\$Sample;.} %>%
	as.data.frame() %>%
	rownames_to_column("Sample") %>%
	gather(-Sample, key = "key", value = "value") %>%
	ggplot(aes(x = Sample, y = value, fill=key)) + geom_col() + coord_flip()
dev.off()
raw %>% slice(-c(1:4)) %>% write_tsv("$pp")
EOF
mv $pp.mapping_summary.tsv ${pp/%.tsv/.mapping_summary.tsv}
mv $pp.plot.pdf ${pp/%.tsv/.mapping_summary.pdf}
fi

