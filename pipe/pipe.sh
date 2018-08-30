#!/bin/bash
. ~kjyi/src/parse
PARSE $@ 1 << EOF
#snakemake qsub submitter by kjyi
#
#Usage:
# pipe command [options]
#   available commands: qsub, create_templates, plot_flow, dry
#
# example usage
# # search other users pipelines
# pl ls
# # copy one pipeline to local directory
# mkdir -p ./pipelines
# pl cp test@kjyi ./pipelines/test.kjyi
# # run
# pipe dry -s ./pipelines/test.kjyi
# pipe plot_flow -s ./pipelines/test.kjyi
# pipe qsub -j 10 -s ./pipelines/test.kjyi
#
#
-j|--cores|--jobs	thread		1
-s|--snakefile		snakefile	./Snakefile	
EOF
# snakemake wrapper code
SNAKEMAKE=/home/users/cjyoon/anaconda3/bin/snakemake
case $1 in
	create_templates)
		setup_dir=$(dirname $(readlink -f $0))
		cp $setup_dir/Snakefile \
		   $setup_dir/sampleConfig.tsv \
		   $setup_dir/pathConfig.yaml \
		   .
		exit 0
		;;
	plot_flow)
		echo draw_command her
		$SNAKEMAKE --forceall --dag ${@:2} | dot -Tpng > workflow.png
		echo workflow.png is created
		exit 0
		;;
	dry)
		echo drycommand here
        $SNAKEMAKE -np ${@:2}
		exit 0
		;;
	qsub)
		cat << EOF | qsub -e /dev/null -o /dev/null
#!/bin/bash
#PBS -N $(basename $snakefile)
#PBS -l nodes=1:ppn=$((thread + 1))
cd \$PBS_O_WORKDIR

if [ ! -f sample.tsv ]; then
echo "Sample:" > sampleConfig.yml
sed '/^#/d;/^$/d' sampleConfig.tsv |
(
while read name type fq1 fq2 bam coment;do
	cat << eof
	${samplename}: $comment
	fq1: $fq1
	fq2: $fq2
eof
done
) > sampleConfig.yml
fi
$SNAKEMAKE ${@:2} &> snakemake_$(basename snakefile).out
#if [ ! -f sample.tsv ]; then
#	rm sampleConfig.yml
#fi
EOF
		exit 0
		;;
esac
$SNAKEMAKE $@
