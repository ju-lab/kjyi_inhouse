#!/bin/bash
users=$(qstat|tail -n +3 | awk '{ print $3 }' | sort | uniq)
#watch -n 1 'for i in '$users'; do echo $i; ls -tl /home/users/$i/.pbs_spool; done'
for i in $users; do echo $i; ls -tl /home/users/$i/.pbs_spool; done
