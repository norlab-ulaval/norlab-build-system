#!/bin/bash
# =================================================================================================
# Run all bash script in a directory with name prefixed by "test_" or "dryrun_"
#
# Usage in a script:
#
#   #!/bin/bash
#   path_to_script="$(realpath "$0")"
#   script_dir_path="$(dirname "${path_to_script}")"
#   test_dir="$script_dir_path/tests_docker_dryrun_and_config"
#   source "${script_dir_path}/../src/utility_scripts/nbs_run_all_test_and_dryrun_in_directory.bash" "${test_dir}"
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
      each_file_name="$( basename "${each_file}" )"
      n2st::print_msg "Starting ${each_file_name}"
      bash "${each_file}"
      exit_code=$?
      if [[ ${exit_code} != 0 ]]; then
        n2st::print_msg_error "Completed ${each_file_name} with error"
        file_name+=( "${MSG_ERROR_FORMAT}   exit code $exit_code ‹ ${each_file_name}${MSG_END_FORMAT}")
        overall_exit_code=${exit_code}
      else
        n2st::print_msg_done "Completed ${each_file_name}"
        file_name+=( "${MSG_DONE_FORMAT}   exit code $exit_code ‹ ${each_file_name}${MSG_END_FORMAT}")
      fi
    fi
  done

  # ....Run bash script prefixed with "test_"......................................................
  for each_file in "${target_dir_path}"/test_*.bash ; do
    if [[ -f $each_file ]]; then
      each_file_name="$( basename "${each_file}" )"
      n2st::print_msg "Starting ${each_file_name}"
      bash "${each_file}"
      exit_code=$?
      if [[ ${exit_code} != 0 ]]; then
        n2st::print_msg_error "Completed ${each_file_name} with error"
        file_name+=( "${MSG_ERROR_FORMAT}   exit code $exit_code ‹ ${each_file_name}${MSG_END_FORMAT}")
        overall_exit_code=${exit_code}
      else
        n2st::print_msg_done "Completed ${each_file_name}"
        file_name+=( "${MSG_DONE_FORMAT}   exit code $exit_code ‹ ${each_file_name}${MSG_END_FORMAT}")
      fi
    fi
  done


  # ....Show result................................................................................
  (
    set +o nounset    # Dont exit on exit on unbound variable
    n2st::set_is_teamcity_run_environment_variable
    n2st::norlab_splash "${NBS_SPLASH_NAME_BUILD_SYSTEM:-NorLab-Build-System}" "https://github.com/norlab-ulaval/norlab-build-system.git"
  )
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
  # ....Find path to script........................................................................
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

#  # This script is being sourced, ie: __name__="__source__"
#  script_path="$(realpath -q "${BASH_SOURCE[0]:-.}")"
#  target_path="$(dirname "${script_path}")"
  source "${target_path}/../../import_norlab_build_system_lib.bash" || exit 1

  nbs::run_all_script_in_directory "$@"
  exit $?
fi
