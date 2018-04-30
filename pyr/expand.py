import sys

db_file=file(sys.argv[1])
sep=sys.argv[2]

col_list=sys.argv[3].split(',')
col_list=map(int,col_list)
for i in range(len(col_list)):
    col_list[i] -= 1
db_line=db_file.readline().rstrip()
ln=1
while db_line:
    db_info=db_line.split('\t')
#    print db_info
#    raw_input()
    col_cmp_list=[]
    for col in col_list:
            col_cmp_list.append(len(db_info[col].split(sep)))
    if len(set(col_cmp_list))!=1:
#        print db_line
        print ln +'\t' + db_line
        print "error"
        sys.exit(1)
    for i in range(0,len(db_info[col_list[0]].split(sep))):
        out_line_list=[]
        for k in range(0, len(db_info)):
            if not k in col_list:
                out_line_list.append(db_info[k])
            else:
                out_line_list.append(db_info[k].split(sep)[i])
        print '\t'.join(out_line_list)
    ln+=1
    db_line=db_file.readline().rstrip()
    continue
                
                    
        
