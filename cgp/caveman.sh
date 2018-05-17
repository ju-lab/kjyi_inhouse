#!/bin/bash
if ssh -o PasswordAuthentication=no -o BatchMode=yes 10.2.1.53 -p 2030 -x exit &>/dev/null; then
	cat <<EOF | ssh 10.2.1.53 -p 2030 -xT
export PATH=/home/users/kjyi/opt/bin:$PATH
export LD_LIBRARY_PATH=/home/users/kjyi/opt/lib:$LD_LIBRARY_PATH
export CPATH=/home/users/kjyi/opt/include:$CPATH
export PERL5LIB=/home/users/kjyi/opt/lib/perl5:$PERL5LIB
export HTSLIB_DIR=/home/users/kjyi/opt/lib
if [ -d $(pwd) ]; then
	cd '$(pwd)' &> /dev/null
	caveman.pl '$@'
else
	echo Error: must run in syncronized directory 1>&2; exit 2
fi
EOF
else
	echo Error: Passwordless authentication required 1>&2
	exit 1
fi
