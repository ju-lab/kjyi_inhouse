for i in $@; do
	lc=`wc -l $i|cut -f1 -d' '`
	echo $lc gene sets
	wc=`cut -f2- $i | wc -w | cut -f1 -d' '`
	echo $((wc/lc)) genes per gene set
	echo
	head -n10 $i | sed 's/ /_/g'| awk 'BEGIN{FS = "\t"; OFS="\t"} {print $1,$2,$3,$4}'  | column -t
	echo 
	head -n3 ${i/symbol.txt/weight.txt} | sed 's/ /_/g'| awk 'BEGIN{FS = "\t"; OFS="\t"} {print $1,$2,$3,$4}'  | column -t
	echo
done
