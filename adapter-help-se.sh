#!/bin/bash
# generate qsh script in given fastq files
if [ "x$1" == "x" ]; then
    cat << eof
# Generate qsh script for (1)adapter sequence detection and (2)generate another script (trim.qsh) to trim them in given fastq files
# Paired-end sequencing = adapter-help-pe.sh
# Single-end sequencing = adapter-help-se.sh

# Usage:
  adapter-help-se.sh ./fastq/*.gz > adapter_detection.qsh
  qsub adapter_detection.qsh

# then, check trim.qsh, and then,
qsub trim.qsh  # log will be stored in the same directory of fastq (*.cutadapt.log)
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
#PBS -q weak
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
for F in \$FILES;do
	python3 ~/src/detect_adapter.py \$F 2>> \$TRIM |
	sed '$ s/^/AD=/; $ s/\t/;F=/' >> \$TRIM
	cat <<EOF >> \$TRIM
O=\\\$(echo \\\$i | sed 's/[^/]*$/trim_&/')
cutadapt -m 5 -e \\\$ERR_RATE -a \\\$AD -o \\\$O \\\$F >>\\\${F/.fastq.gz}'.cutadapt.log'
EOF
done
exit 0 
eof
echo $* | sed 's/ /\n/g' 1>&2
