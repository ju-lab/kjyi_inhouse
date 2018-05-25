#!/bin/bash
. ~kjyi/src/parse
PARSE $@ 1 << EOF
-C|--cutoff	cutoff	80
EOF
current=$(lfs df | grep OST | \
	sed ':x; s/  / /g; tx;s/%//g' | \
	cut -f5 -d' ' | tr '\n' ',' | sed 's/,$//')
R --slave << EOF
current=c($current)
cat("full=\"",paste0(paste0("_",which(current>=max(current)-1)-1,"_"), collapse="|"),"\";",sep="")
x <- current < $cutoff
r <- rle(x)
i <- which(with(r, rep(lengths == max(lengths[values]) & values, lengths)))[1] - 1
l <- max(r\$length[r\$value])
cat ("recommand=\"-c ", l, " -i ", i, "\"\n")
EOF

