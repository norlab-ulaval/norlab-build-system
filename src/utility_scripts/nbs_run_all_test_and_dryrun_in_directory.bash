#!/bin/bash
# =================================================================================================
# Run all bash script in a directory with name prefixed by "test_" or "dryrun_"
#
# Usage in a script:
#
#   #!/bin/bash
#   path_to_script="$(realpath "${BASH_SOURCE[0]:-'.'}")"
#   target_dir_path="$(dirname "${path_to_script}")"
#   nbs_util_script="${target_dir_path}/../../src/utility_scripts"
#   source "${nbs_util_script}/nbs_run_all_test_and_dryrun_in_directory.bash" "${target_dir_path}"
#
# Globals:
#   none
# =================================================================================================

function nbs::run_all_script_in_directory(){
  local tmp_cwd
  tmp_cwd=$(pwd)

  set +e            # Propagate exit code ‹ Dont exit on error
  set +o pipefail   # Propagate exit code ‹ Dont exit if errors within pipes

  local target_dir_path="$1"
  if [[ ! -d ${target_dir_path}  ]]; then
    n2st::print_msg_error_and_exit "test/dryrun directory is unreachable"
  fi
  cd "${target_dir_path:?err}" || exit 1

  local overall_exit_code=0
  declare -a file_name

  # ====Begin======================================================================================

  # ....Run bash script prefixed with "dryrun_"....................................................
  for each_file in "${target_dir_path}"/dryrun_*.bash ; do
    if [[ -f $each_file ]]; then
      bash "${each_file}"
      exit_code=$?
      if [[ ${exit_code} != 0 ]]; then
          file_name+=( "${MSG_ERROR_FORMAT}   exit code $exit_code ‹ $( basename "${each_file}" )${MSG_END_FORMAT}")
          overall_exit_code=${exit_code}
      else
        file_name+=( "${MSG_DONE_FORMAT}   exit code $exit_code ‹ $( basename "${each_file}" )${MSG_END_FORMAT}")
      fi
    fi
  done

  # ....Run bash script prefixed with "test_"......................................................
  for each_file in "${target_dir_path}"/test_*.bash ; do
    if [[ -f $each_file ]]; then
      bash "${each_file}"
      exit_code=$?
      if [[ ${exit_code} != 0 ]]; then
          file_name+=( "${MSG_ERROR_FORMAT}   exit code $exit_code ‹ $( basename "${each_file}" )${MSG_END_FORMAT}")
          overall_exit_code=${exit_code}
      else
        file_name+=( "${MSG_DONE_FORMAT}   exit code $exit_code ‹ $( basename "${each_file}" )${MSG_END_FORMAT}")
      fi
    fi
  done


  # ....Show result................................................................................
  n2st::norlab_splash "${NBS_SPLASH_NAME_BUILD_SYSTEM:-NorLab-Build-System}" "https://github.com/norlab-ulaval/norlab-build-system.git"

  echo -e "Results from ${MSG_DIMMED_FORMAT}$0${MSG_END_FORMAT} in directory ${MSG_DIMMED_FORMAT}$( basename "${target_dir_path}" )/${MSG_END_FORMAT} \n"
  for each_file_run in "${file_name[@]}" ; do
      echo -e "$each_file_run"
  done

  # ====Teardown===================================================================================
  cd "${tmp_cwd}" || exit 1

  return $overall_exit_code
}

# ::::Main:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  # This script is being run, ie: __name__="__main__"
  echo -e "${MSG_ERROR_FORMAT}[ERROR]${MSG_END_FORMAT} This script must be sourced i.e.: $ source $( basename "$0" )" 1>&2
  exit 1
else
  # This script is being sourced, ie: __name__="__source__"
  script_path="$(realpath "${BASH_SOURCE[0]:-'.'}")"
  script_path_parent="$(dirname "${script_path}")"
  source "${script_path_parent}/../../import_norlab_build_system_lib.bash" || exit 1

  nbs::run_all_script_in_directory "$@"
  exit $?
fi
