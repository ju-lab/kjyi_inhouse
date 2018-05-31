# loop in bash script

## basic
```bash
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
```bash
for i in ./bam/*.bam; do
	if [ I == 4 ]; then ((I = I - 4)); wait; fi; ((I++))
	(
		something -- with $i
		somtething2 -- with $i
	)&
done
wait
```

## kill all child processes when parent is killed
```bash
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
