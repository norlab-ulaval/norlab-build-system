#!/bin/bash
#
# Import norlab-build-system function library and dependencies
#
# Usage:
#   $ source import_norlab_build_system_lib.bash
#
#

function nbs::source_lib(){
  local TMP_CWD
  TMP_CWD=$(pwd)

  # ====Begin======================================================================================
  _PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
  NBS_PATH="$(dirname "${_PATH_TO_SCRIPT}")"
  export NBS_PATH

  # (NICE TO HAVE) ToDo: append lib to PATH (ref task NMO-414)
#  cd "${NBS_PATH}/src/build_tools"
#  PATH=$PATH:${NBS_PATH}/src/build_tools

  # ....Load environment variables from file.......................................................
  cd "${NBS_PATH}" || exit
  set -o allexport
  source .env.nbs
  set +o allexport

  # ....Source NBS dependencies....................................................................
  source "${NBS_PATH}/utilities/norlab-shell-script-tools/import_norlab_shell_script_tools_lib.bash"

  # ....Source NBS functions.......................................................................
  cd "${NBS_PATH}/src/function_library/build_tools" || exit
  for each_file in "$(pwd)"/*.bash ; do
      source "${each_file}"
  done

  cd "${NBS_PATH}/src/function_library/container_tools" || exit
  for each_file in "$(pwd)"/*.bash ; do
      source "${each_file}"
  done

  cd "${NBS_PATH}/src/function_library/dev_tools" || exit
  for each_file in "$(pwd)"/*.bash ; do
      source "${each_file}"
  done

  # ====Teardown===================================================================================
  cd "${TMP_CWD}"
}

nbs::source_lib
