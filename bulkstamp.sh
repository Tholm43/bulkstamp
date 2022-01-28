#!/bin/bash

function checkValidPath {
  # verifies if the path exists to prevent issues, then enters it
  if [ -d $1 ]
  then
    directory=$1
    cd $directory
  else
    showUsage
    echo 'bulkstamp: error: The specified path is invalid.'
    quitOnFatal
  fi
}

function collisionDetectFile {
  # does simple collision detection and resolution of overlapping names
  local collisionOffset=0
  while [ -e $finalFile ]
  do
    let collisionOffset+=1
    local temporaryLabel=$finalTextLabel
    finalTextLabel=$finalTextLabel-$(printf %04d $collisionOffset)
    generateFileName $initialFile
    finalTextLabel=$temporaryLabel
  done
}

function confirmDestination {
  # prompts the user
  read -p "bulkstamp: prompt: Confirm access to destination \"$directory\"? [Y/any]: " -n 1 confirm
  echo
  if [ "$confirm" != 'Y' ]
  then
    quitOnFatal
  fi
  echo
}

function excludeFolders {
  # only pick files, leaving folders to not be renamed
  local listFilesFolders=(*)
  local initialFile
  for initialFile in "${listFilesFolders[@]}"
  do
    if ! [ -d "$initialFile" ]
    then
      listFiles+=( "$initialFile" )
    fi
  done
  if [ ${#listFiles[@]} -eq 0 ]
  then
    echo 'bulkstamp: error: No files to rename.'
    quitOnFatal
  fi
}

function fixParameterExtensionLabel {
  # fixes the command line argument with the extension to a valid format
  local parameterAlphanumDot=$(echo $1 | tr -d -c [:alnum:]+.)
  if [ $parameterAlphanumDot ]
  then
    local numberOfDots=$(echo $parameterAlphanumDot | tr -d -c . | wc -c)
    local firstChar=$(echo $parameterAlphanumDot | cut -c1)
    case $numberOfDots in
      0)finalExtensionLabel=.$parameterAlphanumDot
        ;;
      1)if [ $firstChar == '.' ]
        then
          finalExtensionLabel=$parameterAlphanumDot
        else
          finalExtensionLabel=.$parameterAlphanumDot
        fi
        ;;
      *)finalExtensionLabel=.$(echo $parameterAlphanumDot | grep -o '[^.]*' | tr [:space:] .)
        ;;
    esac
    local lastChar=$(echo $finalExtensionLabel | rev | cut -c1)
    while [ "$lastChar" == '.' ]
    do
      finalExtensionLabel=${finalExtensionLabel%.}
      local lastChar=$(echo $finalExtensionLabel | rev | cut -c1)
    done
  else
    finalExtensionLabel=''
  fi
}

function fixParameterTextLabel {
  # sets up kebab case tags to append to the name of the file
  local parameterAlphanum=$(echo $1 | tr -d -c [:alnum:] )
  if [ $parameterAlphanum ]
  then
    finalTextLabel='-'$parameterAlphanum
  fi
}

function generateFileName {
  # builds the final filename, also checking if the user wanted no extension
  if [ $parameterExtensionLabel ]
  then
    fixParameterExtensionLabel $parameterExtensionLabel 
  else
    fixParameterExtensionLabel $(echo "$1" | cut -d'.' -f2-) 
  fi
  finalFile=$(date -r "$1" +"%Y%m%d")$finalTextLabel$finalExtensionLabel
}

function quitOnFatal {
  # kills this process through its PID
  kill $$
}

function run {
  confirmDestination $directory
  excludeFolders
  local i=0
  for initialFile in "${listFiles[@]}"
  do
    generateFileName "$initialFile"
    collisionDetectFile $finalFile # TODO interactive confirmation prompt + copy all/skip all
    echo ${listFiles[i]}
    mv "${listFiles[i]}" $finalFile
    echo '  --> '$finalFile
    echo
    let i+=1
  done
  echo Done
}

function showUsage {
  echo 'Usage: ./bulkstamp.sh DIR [TAG] [EXT]'
  echo '       DIR: working path'
  echo '       TAG: optional tag to add after timestamp, can be skipped with "-"'
  echo '       EXT: replace all extensions with EXT, "-" means no extension'
  echo
}


case $# in
  0)showUsage
    echo 'bulkstamp: error: Missing arguments.'
    ;;
  1)checkValidPath $1
    run
    ;;
  2)checkValidPath $1
    fixParameterTextLabel $2
    run
    ;;
  3)checkValidPath $1
    fixParameterTextLabel $2
    parameterExtensionLabel=$3
    run
    ;;
  *)showUsage
    echo 'bulkstamp: error: Too many arguments.'
    ;;
esac
