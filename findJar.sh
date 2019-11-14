#!/usr/bin/env bash
searchString=$1
for datei in `find . -name "*.jar" -o -name "*.zip"` ; do
#   echo $datei
  found=`unzip -l $datei | grep "$searchString"`
  if [ -n "$found" ] ; then
    echo $datei enthaelt: $found
  fi
done
