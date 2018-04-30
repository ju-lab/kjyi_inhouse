#!/home/users/kjyi/bin/Rscript
#' tsv filter using R
library(magrittr)
library(stringr)
args <- commandArgs(trailingOnly=TRUE)
x<- c("1:3:4:a", "2:3:4:c", "")
"%:%" <- function(x, y) {str_split(x, ":") %>% lapply(function(x) x[y]) %>% unlist()}
library(memisc)
numericIfPossible <- function(x){
  if(is.atomic(x)) return(.numericIfPossible(x))
  else {
    res <- lapply(x,.numericIfPossible)
    attributes(res) <- attributes(x)
    return(res)
  }
}
.numericIfPossible <- function(x){
  dyn.load("numeric_if_possible.c", local = TRUE, now = TRUE)
  if(is.numeric(x)) return(x)
  else if(is.character(x)) return(.Call("numeric_if_possible", x))
  else if(is.factor(x)) {
    levels <- .Call("numeric_if_possible",levels(x))
    if(is.numeric(levels)){
      return(levels[as.numeric(x)])
    } else return(x)
  }
  else return(x)
}
.numericIfPossible("5")

file_obj = file('stdin', "rb")
# "rb" enables line-by-line processing as well as read_tsv
while (T) {
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
                      guess_max = 10000)) %>%
      dplyr::select_(paste0(args))%>%
      data.table::fwrite(nThread = 3,
                         showProgress = F,
                         verbose = F,
                         eol = "\n",
                         sep = "\t",
                         na = "NA")
    break
  }
  cat(line, "\n") # cat comment lines starting with ##
}
