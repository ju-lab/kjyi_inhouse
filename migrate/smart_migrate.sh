#!/bin/bash
. ~kjyi/src/parse
PARSE $@ -x << EOF
-c	c	-1
-i	i	0
-C	cutoff	80
EOF
# df
eval "$(sh ~kjyi/src/migrate/df.sh)"
echo "# recommanded striping: $recommand"
full=${full//|/ }
echo "# full: $full"
sedcmd=$(for i in $full;do
	echo -n "/$i/ s/^#/ /;";done
)
# setstripe

# migrate
echo migrate=/home/users/kjyi/src/migrate/migrate.sh
for i in ${REMAIN[@]}; do
	find $(readlink -f $i) -size +1G | xargs -i{} sh -c "echo -n \# \\\$migrate {} \# _;
	lfs getstripe -q {} | cut -f2 | tail -n+3 | sed 's/ //g; \$ d' | tr '\n' '_'; echo " |
	sed -e "$sedcmd"
done
