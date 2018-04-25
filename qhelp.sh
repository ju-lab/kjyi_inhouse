#!/bin/bash
echo """#!/bin/bash
#       ----------------
#PBS -N $1
#       ----------------
# $2
#
#PBS -q week
#PBS -j oe
#PBS -o /dev/null
#PBS -l nodes=1:ppn=1
cd `pwd`

"""
