for i in `cat $1`; do
	for j in `find $i -type d`; do
		lfs setstripe -c 1 -i -1 $j
	done
	/home/users/kjyi/src/migrate/migrate.sh `find $i -type f`
done
echo DONE
