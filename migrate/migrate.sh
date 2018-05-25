#!/bin/bash
. ~kjyi/src/parse
PARSE $@ << EOF
# asdf
-c	c	"-1"
-i	I	0
-d	dry	false
EOF
if $dry; then
	exit 0
fi
for args in ${REMAIN[@]}; do
	target=`readlink -f $args`
	path=`dirname $target`
	orig=`md5sum $target | cut -f1 -d' '`
	lfs setstripe -c $c -i $I $path
	cp $target $target.migraTing
	after=`md5sum $target.migraTing | cut -f1 -d' '`
	if [ "x$orig" == "x$after" ]; then
		mv -f $target.migraTing $target
		echo "migrate sucess: $target"
	else
		echo "migrate fail  : $target"
		rm $target.migraTing
	fi
done
