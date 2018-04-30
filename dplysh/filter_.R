#!/home/users/kjyi/bin/Rscript
#' tsv filter using R
library(magrittr)
args <- commandArgs(trailingOnly=TRUE)

file_obj = file('stdin', "rb") 
# "rb" enables line-by-line processing as well as read_tsv
line = readLines(file_obj, n = 1)
if (length(line) == 0 ) break
if(substr(line, 1, 2) != "##") {
	cat(paste0("## filter(",paste0(args), ")"), "\n")
	suppressMessages(
		readr::read_tsv(file_obj,
						progress = F,
						col_names = strsplit(line, "\t")[[1]], 
						# as header was already read & stored in line
						comment = "##", 
						guess_max = 10000)
		) %>%
	dplyr::filter_(paste0(args))%>%
	data.table::fwrite(nThread = 3,
					   showProgress = F, 
					   verbose = F, 
					   eol = "\n", 
					   sep = "\t", 
					   na = "NA")
	break
}
cat(line, "\n") # cat comment lines starting with ##

