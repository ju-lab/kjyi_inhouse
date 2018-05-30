#!/bin/bash
export PATH=/home/users/kjyi/opt/bin:$PATH
export LD_LIBRARY_PATH=/home/users/kjyi/opt/lib:$LD_LIBRARY_PATH
export CPATH=/home/users/kjyi/opt/include:$CPATH
export PERL5LIB=/home/users/kjyi/opt/lib/perl5:$PERL5LIB
export HTSLIB_DIR=/home/users/kjyi/opt/lib
battenberg.pl $@
