#!/bin/bash

function nbs::source_lib(){
  local TMP_CWD
  TMP_CWD=$(pwd)

  # ====Begin======================================================================================
  _PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
  NBS_ROOT_DIR="$(dirname "${_PATH_TO_SCRIPT}")"

  cd "${NBS_ROOT_DIR}/src/build_scripts"
  for each_file in "$(pwd)"/*.bash ; do
      source "${each_file}"
  done

  cd "${NBS_ROOT_DIR}/src/container_tools"
  for each_file in "$(pwd)"/*.bash ; do
      source "${each_file}"
  done

  cd "${NBS_ROOT_DIR}/src/dev_scripts"
  for each_file in "$(pwd)"/*.bash ; do
      source "${each_file}"
  done

  # (NICE TO HAVE) ToDo: append lib to PATH (ref task NMO-414)
#  cd "${NBS_ROOT_DIR}/src/build_scripts"
#  PATH=$PATH:${NBS_ROOT_DIR}/src/build_scripts

  # ====Teardown===================================================================================
  cd "${TMP_CWD}"
}

nbs::source_lib
