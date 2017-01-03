#!/bin/bash

if [ $# -eq 0 ]; then
  echo 'No files specified'
  exit 1
fi

gimp -i -b "$(cat ntsc-to-pal.scm)" -b "(ntsc-to-pal \"$@\")" -b "(gimp-quit 0)"

