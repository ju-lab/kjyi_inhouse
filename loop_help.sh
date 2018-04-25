
echo 'N=4; for i in {1..40}; do ((i=i%N)); ((i++==0)) && wait; do_something; done'
