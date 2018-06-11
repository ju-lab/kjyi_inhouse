#!/bin/bash
# generate qsh script in given fastq files
if [ "x$1" == "x" ]; then
    cat << eof
# Generate qsh script for (1)adapter sequence detection and (2)generate another script (trim.qsh) to trim them in given fastq files
# Paired-end sequencing = adapter-help-pe.sh
# Single-end sequencing = adapter-help-se.sh
# Input in any order <1.R1> <2.R1>  <3.R1> <4.R1> ...

# Usage:

  adapter-help-pe.sh ./fastq/*.gz > adapter_detection.qsh
	  or
  adapter-help-se.sh ./fastq/*.gz > adapter_detection.qsh
  qsub adapter_detection.qsh

# then, check trim.qsh, and then,
  qsub trim.qsh
eof
exit 0
fi

cat << eof 
#!/bin/bash
#       ----------------
#PBS -N adaptor_detect
#       ----------------
# This script run fastqc & multiqc for multiple files
# This script is generaged by the command below
# $0 <...>
#
#PBS -q day
#PBS -o /dev/null
#PBS -e /dev/null
#PBS -l nodes=1:ppn=2,mem=8gb
cd `pwd`

# output file
TRIM=./trim.qsh
# parameter
ERR_RATE=0.2 # cutadapt allow mismatch
# input
FILES="$*"

rm -rf \$TRIM
cat <<EOF > \$TRIM
#!/bin/bash
#PBS -N cut_adapt
#PBS -q day
#PBS -o /dev/null
#PBS -e /dev/null
#PBS -l nodes=1:ppn=2,mem=8gb
cd \\\$PBS_O_WORKDIR
ERR_RATE=\$ERR_RATE
LOG=./log/cut_adapt.log
mkdir -p ./log
rm -rf \\\$LOG
##############################
EOF
F=( \$FILES )
for i in \${#F[@]};do
	echo \$i / \${#F[@]}
	F1=\${F[i]}
	python3 ~/src/detect_adapter.py \$F1 2>> \$TRIM |
	sed '$ s/^/AD1=/; $ s/\t/;F1=/' >> \$TRIM
	cat <<EOF >> \$TRIM
O1=\\\$(echo \\\$F1 | sed 's/[^/]*$/trim_&/');
cutadapt -m 5 -e \\\$ERR_RATE -a \\\$AD1 -o \\\$O1 \\\$F1 >>\\\${F1/.fastq.gz}'.cutadapt.log'
EOF
done
exit 0 
eof
echo $* | sed 's/ /\n/g' 1>&2
