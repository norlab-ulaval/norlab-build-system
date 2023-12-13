#!/bin/bash
#
# Import norlab-build-system function library and dependencies
#
# Usage:
#   $ cd <path/to/norlab-build-system/root>
#   $ source import_norlab_build_system_lib.bash
#
function nbs::source_lib(){
  local TMP_CWD
  TMP_CWD=$(pwd)

  # ====Begin======================================================================================
#  NBS_PATH=$(git rev-parse --show-toplevel)
  _PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]:-'.'}")"
  NBS_PATH="$(dirname "${_PATH_TO_SCRIPT}")"
  export NBS_PATH

  # (NICE TO HAVE) ToDo: append lib to PATH (ref task NMO-414)
  # cd "${NBS_PATH}/src/build_tools"
  # PATH=$PATH:${NBS_PATH}/src/build_tools

  # ....Load environment variables from file.......................................................
  cd "${NBS_PATH}" || exit
  set -o allexport
  source .env.nbs
  set +o allexport

  # ....Source NBS dependencies....................................................................
  cd "${NBS_PATH}/utilities/norlab-shell-script-tools"
  source "import_norlab_shell_script_tools_lib.bash"

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

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  # This script is being run, ie: __name__="__main__"
  echo "${MSG_ERROR_FORMAT}[ERROR]${MSG_END_FORMAT} This script must be sourced from an other script"
else
  # This script is being sourced, ie: __name__="__source__"
  nbs::source_lib
fi
