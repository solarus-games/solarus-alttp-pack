#!/bin/bash

if [ $# -eq 0 ]; then
  echo 'No files specified'
  exit 1
fi

gimp -i -b "$(cat pal-to-ntsc.scm)" -b "(pal-to-ntsc \"$@\")" -b "(gimp-quit 0)"

