#/bin/bash
#' script to merge files (vcf ..)
#' comment and header of the 1st file + contents of all file
first=true
comment=true
filename=false
>&2 echo -en "Options: you can remove comment lines (lines start with ##)
and/or you can add file name column at the end of lines (see --help)
1)   keep comments,       add file_name column
2)   keep comments, don't add file_name column
3) remove comments,       add file_name column
4) remove comments, don't add file_name colomn
enter option:"
read n
case $n in
    1) comment=true; filename=true ;;
    2) comment=true; filename=false ;;
    3) comment=false; filename=true ;;
    4) comment=false; filename=false ;;
    -h|--help) echo "not ready"; exit 1 ;;
    *) invalid option;;
esac

for i in $1; do
  if [ "$first" = "true" ]; then
    if [ "$comment" = "true" ]; then
      grep "^##" $i
      echo "## merged -comment=true, filename=$filename"
    fi
    if [ "$filename" = "true" ]; then
      grep -v "^##" $i | head -n 1 | sed 's/$/\tfile_name/'
    else
      grep -v "^##" $i | head -n 1
    fi
    first=false
  fi
    if [ "$filename" = "true" ]; then
      grep -v "^##" $i | tail -n +2 | sed 's/$/\t'$i'/'
    else
      grep -v "^##" $i | tail -n +2
    fi
done
