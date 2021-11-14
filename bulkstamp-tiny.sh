#!/bin/bash
printf "Working directory [/]: "
read directory
directory="$directory/"
printf "Description label [ ]: "
read label
if [[ $label != "" ]]
then
  label="-$label"
fi
printf "File extension(s) [*]: "
read ext
z=0
cd "$directory"
for file in *
do
  oldfilebase="$(echo "$file" | cut -d'.' -f1)"
  ls -1 | grep $oldfilebase$ext > /dev/null
  if [ "$?" -eq "0" ] || [ $ext = "" ]
  then
    offset=0
    ostring=""
    echo $file | grep "\."
    if [ "$?" -eq "0" ]
    then
      _ext=".$(echo $file | rev | cut -d'.' -f1 | rev)"
    else
      _ext=""
    fi
    oldfilepath="$directory$file"
    newfile="$(date -r "$directory$file" +"%Y%m%d")$label"
    newfilepath="$directory$newfile"
    if [[ $ext = "" ]]
    then
      while [ $(ls -1 "$newfilepath$ostring$_ext" 2>/dev/null) ]
      do
        offset=$((offset + 1))
        printf -v ostring "%03d" $offset
        ostring="-$ostring"
      done
      mv "$oldfilepath" "$newfilepath$ostring$_ext"
    else
      while [ $(ls -1 "$newfilepath$ostring$ext" 2>/dev/null) ]
      do
        offset=$((offset + 1))
        printf -v ostring "%03d" $offset
        ostring="-$ostring"
      done
      mv "$oldfilepath" "$newfilepath$ostring$ext"
    fi
    if [ "$?" -eq "0" ]
    then
      z=$((z + 1))
    fi
  fi
done
echo "" ; echo "$z files renamed." ;
