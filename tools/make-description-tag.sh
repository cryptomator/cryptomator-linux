#!/bin/bash

# A utility script which
# 1. downloads the readme from the Cryptomator repo
# 2. extracts relevant sections from it, and
# 3. transforms the markdown text into markup text compliant with the AppStream spec:
#    https://www.freedesktop.org/software/appstream/docs/chap-CollectionData.html#sect-AppStream-XML
# The output is to be used as description in the appdata.xml

version=${1:-develop}
readme=`curl -s https://raw.githubusercontent.com/cryptomator/cryptomator/$version/README.md`
sections=("Introduction" "Features" "Privacy" "Consistency" "Security Architecture" "License")

function extract_section() {
  printf '%s\n\n' "$readme" |
    sed -n "/# $1/,/# /p" |                                                 # Extract header-to-header section
    sed "s/- \(.*\)/<li>\1<\/li>/g" |                                       # Replace dashes with <li> tags
    sed -e ':a' -e 'N' -e '$!ba' -e 's/\n\n<li>/\n\n<ul>\n<li>/g' |         # Insert <ul> tags
    sed -e ':a' -e 'N' -e '$!ba' -e 's/<\/li>\n\n/<\/li>\n<\/ul>\n\n/g' |   # Insert </ul> tags
    sed "s/\[.*\](\(.*\?\))/\1/g" |                                         # Replace markdown links with plaintext links
    head -n-1 | tail -n+2 |                                                 # Strip section headings
    sed -r '/^\s*$/d'                                                       # Remove empty lines
}

for section in "${sections[@]}"
do
  printf "<p>$section:</p>\n"
  printf "<p>\n$(extract_section $section)\n</p>\n"
done
