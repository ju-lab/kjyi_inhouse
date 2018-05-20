echo "asdf	asdf	tab
qwer,cooma,cooma
azxcv	asdf	as,commadf
qwer,comma,comma
asdf,comma" |
sed  -n '
/\t/!{/,/ p}
'
