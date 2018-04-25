#!/bin/bash
for i in $*;do
	if [[ $i == .* ]]; then
		mv $i ${i#.}
	else
		mv $i .$i
	fi
done

