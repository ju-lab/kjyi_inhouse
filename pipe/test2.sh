rm {1,2,3,4,5}.log
touch {1,2,3,4,5}.log

for i in 1 2 3 4 5;do
echo "sh test.sh > $i.log" | ./sema -P 5 -p 2
done
watch -n 1 tail '*.log'
