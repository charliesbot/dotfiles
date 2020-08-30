#!/usr/bin/env bash

UNAME=$( command -v uname) 
UNAME=$( "${UNAME}" | tr '[:upper:]' '[:lower:]')

case "${UNAME}" in
  linux*)
    printf 'linux\n'
    ;;
  darwin*)
    printf 'darwin\n'
    ;;
  msys*|cygwin*|mingw*)
    # or possible 'bash on windows'
    printf 'windows\n'
    ;;
  nt|win*)
    printf 'windows\n'
    ;;
  *)
    printf 'unknown\n'
    ;;
esac

