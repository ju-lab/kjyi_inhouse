#!/bin/bash

case $1 in
	cp)
		echo "cp ${@:2}" | sed -r 's!(\S*)@(\S*)!$(find /home/users/\2/share -name \1)!g' | bash
		;;
	*)
		echo "share files in \$HOME/pipelines"
		echo "Usage: $0 cp [...] [...] [...]"
		find /home/users/*/pipelines -type f -printf "%T@	%TY/%Tm/%Td_%TH:%TM \033[32m%f\033[38;5;8m@%u\033[0m\n" | sort -n | cut -f 2-
		;;
esac
