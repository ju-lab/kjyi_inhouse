#/bin/bash
# This is a wrapper of java binary, automatically find jar files in the path from $MYJARPATH
# It detect the argument after -jar (original) and exchange with full path if 1) (orignial) is not exist (as absolute or relative path), and 2) (orignial) exists in $MYJARPATH.
# made by KJYI

JAVA=/usr/java/jre1.8.0_91/bin/java

# copy all argments to new array (because BASH_ARGV is read only)
ARGS=( "$@" )

for i in "${!ARGS[@]}";do
	case "${ARGS[i]}" in
		'')	#skip if empty
			continue;;
		-jar)	JAR="${ARGS[i+1]}";
			if [ ! -f $JAR ] & [ -f $MYJARPATH/$JAR ]; then 
				ARGS[i+1]=$MYJARPATH/$JAR
			fi
			continue;;
				
		--)	#end of argment, stop looping
			break;;
		*)	#not matched, keep it in ARGS
			continue;;
	esac
done
$JAVA "${ARGS[@]}"
