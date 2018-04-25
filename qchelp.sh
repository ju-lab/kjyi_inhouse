#!/bin/bash
echo """#!/bin/bash
#       ----------------
#PBS -N FastQC
#       ----------------
# This script run fastqc & multiqc for multiple files
# This script is generaged by the command below
# qchelp inputfiles.gz
#
#PBS -q week
#PBS -o /dev/null
#PBS -e /dev/null
#PBS -l nodes=1:ppn=1
cd `pwd`

mkdir -p qc/individual
mkdir -p log
echo FastQC start > log/FastQC.log

FILES=\"$*\"

/home/users/tools/fastqc/FastQC/fastqc -o qc/individual \$FILES &>> log/FastQC.log &&\\
echo MultiQC start >> log/FastQC.log &&\\
/usr/local/bin/multiqc -o qc qc/individual &>> log/FastQC.log &&\\
echo done >> log/FastQC.log
exit 0

./$(dirname $1)
$(echo $* | sed 's/ /\n/g')

"""
