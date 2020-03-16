#!/bin/bash

template_file=$1
release_version=$2

if [[ $# -ne 2 ]] ; then
  echo """
Usage:
    ./render-appdata-template.sh TEMPLATE_FILE RELEASE_VERSION
Example:
    ./render-appdata-template.sh resources/appdata.template.xml 1.0.0
    ./render-appdata-template.sh resources/appdata.template.xml SNAPSHOT
    """
  exit
fi

if [[ "$release_version" != "SNAPSHOT" ]] ; then
  # non-SNAPSHOT release: render <releases/> section
  version_suffix=`echo $release_version | sed -nr "s/[0-9]+\.[0-9]+\.[0-9]+(-.*)/\1/p"`
  [ -z "$version_suffix" ] && release_type="stable" || release_type="development"
  release_date=`date --iso-8601`

  cat "$template_file" |
    sed -e ':a' -e 'N' -e '$!ba' -e 's/{{{releases\(.*\)}}}/\1/g' \
        -e "s/{{release_version}}/$release_version/g" \
        -e "s/{{release_date}}/$release_date/g" \
        -e "s/{{release_type}}/$release_type/g"
else
  # SNAPSHOT release: omit <releases/> section
  cat "$template_file" |
    sed -e':a' -e 'N' -e '$!ba' -e 's/{{{releases\(.*\)}}}//g'
fi





