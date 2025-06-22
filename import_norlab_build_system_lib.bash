#!/bin/bash
# =================================================================================================
# Import norlab-build-system function library and dependencies
#
# Usage:
#   $ cd <path/to/norlab-build-system/root>
#   $ source import_norlab_build_system_lib.bash
#
# =================================================================================================

MSG_ERROR_FORMAT="\033[1;31m"
MSG_END_FORMAT="\033[0m"

function nbs::source_lib(){

  # ....Setup......................................................................................
  local debug_log=false
  local tmp_cwd
  tmp_cwd=$(pwd)
  local script_path
  local target_path

  # ....Find path to script........................................................................
  if [[ -z ${NBS_PATH} ]]; then
    # Note: can handle both sourcing cases
    #   i.e. from within a script or from an interactive terminal session
    # Check if running interactively
    if [[ $- == *i* ]]; then
      # Case: running in an interactive session
      target_path=$(realpath .)
    else
      # Case: running in an non-interactive session
      script_path="$(realpath -q "${BASH_SOURCE[0]:-.}")"
      target_path="$(dirname "${script_path}")"
    fi

    if [[ ${debug_log} == true ]]; then
      echo "
      BASH_SOURCE: ${BASH_SOURCE[*]}

      tmp_cwd: ${tmp_cwd}
      script_path: ${script_path}
      target_path: ${target_path}

      realpath: $(realpath .)
      \$0: $0
      "  >&3
    fi
  else
    target_path="${NBS_PATH}"
  fi

  # ....Load environment variables from file.......................................................
  cd "${target_path}" || return 1
  set -o allexport
  source .env.nbs || return 1
  set +o allexport

  # (NICE TO HAVE) ToDo: append lib to PATH (ref task NMO-414)
  # cd "${NBS_PATH}/src/build_tools"
  # PATH=$PATH:${NBS_PATH}/src/build_tools

  # ....Source NBS dependencies....................................................................
  cd "${N2ST_PATH:?err}" || return 1
  source "import_norlab_shell_script_tools_lib.bash"

  # ====Begin======================================================================================
  # ....Source NBS functions.......................................................................
  cd "${NBS_PATH}/src/function_library/build_tools" || return 1
  for each_file in "$(pwd)"/*.bash ; do
      # shellcheck disable=SC1090
      source "${each_file}" || return 1
  done

  cd "${NBS_PATH}/src/function_library/container_tools" || return 1
  for each_file in "$(pwd)"/*.bash ; do
      # shellcheck disable=SC1090
      source "${each_file}" || return 1
  done

  cd "${NBS_PATH}/src/function_library/dev_tools" || return 1
  for each_file in "$(pwd)"/*.bash ; do
      # shellcheck disable=SC1090
      source "${each_file}" || return 1
  done

  NBS_VERSION="$(cat "${NBS_PATH}"/version.txt)"
  export NBS_VERSION

  # Set reference that the NBS library was imported with this script
  export NBS_IMPORTED=true

  # ====Teardown===================================================================================
  cd "${tmp_cwd}" || { echo "Return to original dir error" 1>&2 && return 1; }
}

# ::::Main:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  # This script is being run, ie: __name__="__main__"
  echo -e "${MSG_ERROR_FORMAT}[NBS error]${MSG_END_FORMAT} This script must be sourced i.e.: $ source $( basename "$0" )" 1>&2
  exit 1
else
  # This script is being sourced, ie: __name__="__source__"
  nbs::source_lib
fi
