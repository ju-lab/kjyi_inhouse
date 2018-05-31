# loop in bash script

## basic
```
# space seperated list
for i in a b c; do
	echo $i
done
# array
array=(a b c)
for i in ${array[@]}; do
	echo $i
done

# alternative array (i is number)
array=(a b c)
for i in ${!array[@]}; do
	echo ${array[i]}
done

# along files
for in ./bam/*.bam; do
	echo $i
	basename $i
done
```

## batch jobs
```
for i in ./bam/*.bam; do
	if [ I == 4 ]; then ((I = I - 4)); wait; fi; ((I++))
	(
		something -- with $i
		somtething2 -- with $i
		# never change I in your code.. it iterate 0 1 2 3 0 1 2 3 ...
	)&
done
wait
```

## kill all child processes when parent is killed
```
# only for workstation
# in server(PBS), all child will be automatically killed by qdel
trap 'kill -TERM $PID' TERM INT
for i in ./bam/*.bam; do
	if [ I == 4 ]; then ((I = I -4)); wait; fi; ((I++))
	(
		something --with $i
		PID="$! $PID"
		something2 --with $i
		PID="$! $PID"
	)&
done
wait
```
