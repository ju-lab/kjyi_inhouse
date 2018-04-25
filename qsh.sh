#/bin/bash
if [[ "`hostname`"=="bnode0" ]];then
ncpu=""
mem=""
echo -en "How many CPUs will you use? (default=2)"; read -p "" ncpu
echo -en "How much memory will you use? (default=4gb)"; read -p "" mem 
if [[ "$ncpu" == "" ]]; then ncpu=3 ; fi
if [[ "$mem" == "" ]]; then mem=4gb ; fi
echo "Submitting ticket: -l number of CPU=$ncpu, memory=$mem"
eval qsub -I -l nodes=1:ppn=$ncpu -l mem=$mem -X

else
	echo "Please restart shell if you already activated interacting PBS shell"
	exit 1
fi

