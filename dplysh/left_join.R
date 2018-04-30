#!/home/users/kjyi/bin/Rscript
#' leftjoin of dplyr
library(readr)
library(magrittr)
args <- commandArgs(trailingOnly=TRUE)

A <- read_tsv(args[1], progress=F, col_names=F, comment="##",
			  col_types=cols(.default=col_character()))
B <- read_tsv(args[2], progress=F, col_names=F, comment="##",
			  col_types=cols(.default=col_character()))
colnames(A) <- paste0("A",1:ncol(A))
colnames(B) <- paste0("B",1:ncol(B))
args[-c(1:2)] %>% stringr::str_replace('=', '"="') %>% paste0('"', ., '"') %>%
		paste(collapse = ',') %>% paste0('c(', ., ')') ->BY
dplyr::left_join(A, B, by=eval(parse(text = BY))) %>%
	data.table::fwrite(nThread=3,
					   showProgress = F,
					   verbose = F,
					   eol = "\n",
					   sep = "\t",
					   na = "NA",
					   col.names= F)


