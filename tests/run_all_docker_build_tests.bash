#!/bin/bash
# =================================================================================================
# Run all tests in 'tests/tests_docker_build' directory
#
# Usage:
#   $ bash run_all_docker_build_tests.bash
#
# =================================================================================================
test_dir="tests/tests_docker_build"

# ....Setup........................................................................................
path_to_script="$(realpath "$0")"
script_dir_path="$(dirname "${path_to_script}")"
NBS_PATH="$( realpath -q "${script_dir_path}/.." )"

# ....Begin........................................................................................
source "${NBS_PATH:?err}/src/utility_scripts/nbs_run_all_test_and_dryrun_in_directory.bash" "${NBS_PATH}/${test_dir}"
exit $?
