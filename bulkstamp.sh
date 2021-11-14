#!/bin/bash

printf "Working directory [/]: " # IE /home/user/Documents
read directory
directory="$directory/"

printf "Description label [ ]: " # IE hello
read label
if [[ $label != "" ]]
then 
  label="-$label"
fi

printf "File extension(s) [*]: " # IE .txt
read ext

z=0

cd "$directory"
for file in *
do
  # echo "_______________________/_/__"
  # echo "[ FILE $file ]" ; echo ""
  
  oldfilebase="$(echo "$file" | cut -d'.' -f1)"
  ls -1 | grep $oldfilebase$ext > /dev/null
  if [ "$?" -eq "0" ] || [ $ext = "" ]
  then
    offset=0
    ostring=""

    echo $file | grep "\." # > /dev/null
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
        # ostring="-$offset"
        # echo "modfile: $ostring"
      done

      # echo "keepext: $_ext"
      mv "$oldfilepath" "$newfilepath$ostring$_ext"
      # echo "written: $newfilepath$ostring$_ext"

    else

      while [ $(ls -1 "$newfilepath$ostring$ext" 2>/dev/null) ]
      do
        offset=$((offset + 1))
        printf -v ostring "%03d" $offset
        ostring="-$ostring"
        # echo "modfile: $ostring"
      done

      # echo "stdiext: $_ext"
      mv "$oldfilepath" "$newfilepath$ostring$ext" 
      # echo "written: $newfilepath$ostring$ext"

    fi

    if [ "$?" -eq "0" ] 
    then
      z=$((z + 1))
    fi
  # else
    # echo "skipped: $oldfilebase"
  fi
  # echo "done"
done

echo "" ; echo "$z files renamed." ;
