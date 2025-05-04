#!/bin/bash

Desc="\
$(basename ${BASH_SOURCE[0]}) [ async_def | Async_do ]

Create a link named application.rb to one or another file in lib directory.
Keep this file in the project directory. Changes working directory to directory
where this script is.

Valid arguments are none (show current file linked to) or one of

  async_def
  Async_do
"

[[ "$*" =~ ^(-h|--help)$ ]] && { echo "$Desc" ; exit 1 ; }

if [ "$#" -gt 1 ]; then
    echo "You must zero or 1 command line arguments"
    exit
fi

# Change to the directory where the script is located
cd "$(dirname ${BASH_SOURCE[0]})"

file="lib/application.rb"

# Check the current state of the symlink
expected=false
if [[ -L "$file" && -f "$file" ]]; then
  echo "$file is a symlink to a file"
  actual_fn=$(basename "$(readlink -f "$file")")
  if [[ $actual_fn == '_app_async_def.rb' ||  $actual_fn == '_app_Async_do.rb' ]]; then
    echo "$file links to $actual_fn"
    expected=true
  fi
fi

if [[ ! -f "$file" ]]; then
  echo "$file does not exist"
  echo "run with argument to create symbolic link"
  expected=true
fi

if $expected ; then
  echo "things as expected"
else
  echo "things not as expected"
  exit 1
fi

# If no argument is provided, just report the current state
if [ "$#" -eq 0 ]; then
    echo "Done reporting"
    exit 0
fi

if [[ "$@" == "async_def" ]]; then
  echo got here
  echo "$@"
  echo linking to _app_async_def.rb
  ln -s -r -f lib/_app_async_def.rb lib/application.rb
elif [[ "$@" == "Async_do" ]]; then
  echo linking to _app_Async_do.rb
  ln -s -r -f lib/_app_Async_do.rb lib/application.rb
else
  echo unknown argument
  echo exiting
  exit 1
fi


# ln -s -r -f lib/_app_async_def.rb lib/application.rb
# run when in project directory
# when no argument, report
# lib/application.rb exists and is symbolic link, and it links to either lib/_app_Async_do.rb or lib/_app_async_def.rb
# when arguement, force link to what arguement says

# async_def
# Async_do


#        ln - make links between files

#        ln [OPTION]... TARGET LINK_NAME

#        -s, --symbolic
#               make symbolic links instead of hard links
#        -f, --force
#               remove existing destination files
#        -r, --relative
#               create symbolic links relative to link location
# create a link to TARGET with the name LINK_NAME.

