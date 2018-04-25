echo
if [ "$1" != "" ]  #if parameter exists, use as base folder
   then cd "$1"
   fi
pwd
find -L . |   \
sed -e 's![^-][^/]*/!--!g' -e 's!--\([^-]\)!+-\1!' -e 's/--/| /g'
#if [ `ls -F -1 | grep "/" | wc -l` = 0 ]   # check if no folders
#   then echo "   -> no sub-directories"
#   fi
echo
exit 0

   .
   |-a
   |-b
   |---A
   |---B
   |---C
   |---D
   |---E
   |-c
   |-d
   |---A
   |-----AAA
   |-----BBB
   |-----CCC
   |---B
   |---C
   |---D
   |---E
   |-e
   |-f
   |-g

   .
   |-a
   |-b
   |---A
   |---B
   |---C
   |---D
   |---E
   |-c
   |-d
   | +-A
   | | `-AAA
   | | `-BBB
   | | `-CCC
   | +-B
   | +-C
   | +-D
   | +-E
   |-e
   |-f
   `-g
