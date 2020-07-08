#!/usr/bin/env bash

clear
echo 'Next: Adding vertical space between sentences'
read -p "Press [Enter] to view continue"
codemod --extensions tex '\. +' '.\n'
codemod --extensions tex '(i\.e\.)\n' '\1'
codemod --extensions tex '(e\.g\.)\n' '\1'
codemod --extensions tex '(etc\.)\n' '\1'
codemod --extensions tex '(i\.e\.) +' '\1~'
codemod --extensions tex '(e\.g\.) +' '\1~'

clear
echo 'Next: Converting smart quotes'
read -p "Press [Enter] to view continue"
codemod --extensions tex '“' '``'
codemod --extensions tex '”' "''"
codemod --extensions tex '‘' '`'
codemod --extensions tex '’' "'"
codemod --extensions tex '…' "..."
codemod --extensions tex '...' "\dots"
codemod --extensions tex '\ldots' "\dots"

clear
echo 'Next: Converting Word lists'
read -p "Press [Enter] to view continue"
codemod --extensions tex '•\t' '    \\item '
codemod --extensions tex '\t'

clear
echo 'Next: Converting citations'
read -p "Press [Enter] to view continue"
codemod --extensions tex '\([A-Za-z,. ]+? \d+(;[A-Za-z,. ]+? \d+)*\)'

clear
# echo 'Next: Converting $math$ to $ math $'
# read -p "Press [Enter] to view continue"
# codemod --extensions tex '\$([^\$ ])(.*?)\$' '$ \1\2$'
# codemod --extensions tex '\$(.*?)([^\$ ])\$' '$\1\2 $'
