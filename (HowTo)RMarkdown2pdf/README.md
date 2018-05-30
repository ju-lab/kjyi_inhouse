# Default julab cluster's pdflatex is outdate.
# Use mine
- to use specific pdflatex in Rstudio-server, pdflatex must be in right PATH environment
- the PATH can be set by R command `Sys.setenv`. It is useless to set your bash environment 
  (e.g. export, write in ~/.bashrc, or ~/.bash_profile)
```R
> Sys.setenv(PATH = paste0("/home/users/kjyi/tools/texlive/bin/x86_64-linux:", Sys.getenv("PATH")))
```
- You can add the R code to your $HOME/.Rprofile file.

- You can compile your Rmarkdown document by clicking the button, or using `rmarkdown::render` function.

```R
> rmarkdown::render("myscript.R", output_format = "pdf_document")
```
