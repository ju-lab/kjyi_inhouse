#!/bin/bash
# wrapping code for left_join.R

. ~kjyi/src/parse
PARSE $@ << EOF
#Left_join.R wrapping code 
#
#Usage: `basename $0` <fileA> <fileB> <mapping> [additional mappings...]
#Mapping format example: A1=B2
#Multiple index column can be applied: A1=B1 A2=B2
#Result will be <fileA>-ordered, <fileB>-left-joined table
#Result include all fileA rows and all fileA,fileB columns
#If there are multiple matched keys in <fileB>, all matched will be included and
#the number of output line will increase
<file1>	f1	""
<file2>	f2	""
<map>	m	""
EOF
/home/users/kjyi/bin/Rscript ~kjyi/src/dplysh/left_join.R $@

