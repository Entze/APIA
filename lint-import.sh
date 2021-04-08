#!/usr/bin/env bash

find . -type f -name '*.tex' \
    -exec perl -i -pe 's/\. +/.\n/g' '{}' \; \
    -exec perl -i -pe 's/(i\.e\.)\n/\1 /g' '{}' \; \
    -exec perl -i -pe 's/(e\.g\.)\n/\1 /g' '{}' \; \
    -exec perl -i -pe 's/(i\.e\.) +/\1~/g' '{}' \; \
    -exec perl -i -pe 's/(e\.g\.) +/\1~/g' '{}' \; \
    -exec perl -i -pe 's/(etc\.) +/\1~/g' '{}' \; \
    -exec perl -i -pe 's/“/``/g' '{}' \; \
    -exec perl -i -pe "s/”/''/g" '{}' \; \
    -exec perl -i -pe 's/‘/`/g' '{}' \; \
    -exec perl -i -pe "s/’/'/g" '{}' \; \
    -exec perl -i -pe 's/…/.../g' '{}' \; \
    -exec perl -i -pe 's/\.\.\./\\dots/g' '{}' \; \
    -exec perl -i -pe 's/\\ldots/\\dots/g' '{}' \; \
    -exec perl -i -pe 's/–/--/g' '{}' \; \
    -exec perl -i -pe 's/•\t/    \\item /g' '{}' \; \
    -exec perl -i -pe 's/(?<!\$\\mathcal{)\b(AIA|APL|AOPL|APIA|AL)\b(?!}\$)/\$\\mathcal{\1}\$/g' '{}' \;
    # -exec perl -i -pe 's/(etc\.)\n/\1 /g' '{}' \; \

clear
echo 'Next: Converting Word lists'
read -r -p "Press [Enter] to view continue"
codemod --extensions tex '\t'

clear
echo 'Next: Converting citations'
read -r -p "Press [Enter] to view continue"
codemod --extensions tex '\([A-Za-z,. ]+? \d+(;[A-Za-z,. ]+? \d+)*\)'

clear
# echo 'Next: Converting $math$ to $ math $'
# read -r -p "Press [Enter] to view continue"
# codemod --extensions tex '\$([^\$ ])(.*?)\$' '$ \1\2$'
# codemod --extensions tex '\$(.*?)([^\$ ])\$' '$\1\2 $'
