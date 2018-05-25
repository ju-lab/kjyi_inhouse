import sys
fn_file=open(sys.argv[1]) #tumor \t normal
id_file=open(sys.argv[2])
fn_line=fn_file.readline().strip()
id_line=id_file.readline().strip()
while fn_line:
	fn_indi=fn_line.split('\t')
	tfn=fn_indi[0]
	nfn=fn_indi[1]
	out_file=open(id_line+'.seqzcmd.sh','w')
	out_file.write("samtools mpileup -B -Q 20 -q 20 -f /home/users/data/01_reference/human_g1k_v37/human_g1k_v37.fasta -o %s.tumor.mpileup %s\n" % (id_line, tfn))
	out_file.write("samtools mpileup -B -Q 20 -q 20 -f /home/users/data/01_reference/human_g1k_v37/human_g1k_v37.fasta -o %s.normal.mpileup %s\n" % (id_line, nfn))
	out_file.write("/home/users/tools/sequenza/sequenza/exec/sequenza-utils.py pileup2seqz -gc /home/users/data/01_reference/human_g1k_v37/human_g1k_v37_noM.gc50Base.txt.gz -n %s.normal.mpileup -t %s.tumor.mpileup > %s.seqz\n" % (id_line, id_line, id_line))
	out_file.write("/home/users/tools/sequenza/sequenza/exec/sequenza-utils.py seqz-binning -w 100 -s %s.seqz > %s.comp.seqz\n" % (id_line, id_line))
	out_file.write("cat %s.comp.seqz |grep -v MT |grep -v GL > %s.comp.seqz.rmGLMT\n" % (id_line, id_line))
	out_file.write("gzip %s.comp.seqz.rmGLMT\n" % id_line)
	out_file.write("/home/users/kjyi/tools/R/R-3.4.0/bin/Rscript /home/users/sypark/01_Python_files/Rscript/04_Run_sequenza.R %s.comp.seqz.rmGLMT.gz %s_sequenza\n" % (id_line, id_line))
	fn_line=fn_file.readline().strip()
	id_line=id_file.readline().strip()
