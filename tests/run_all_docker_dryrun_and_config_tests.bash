#!/bin/bash
# =================================================================================================
# Run all tests in directory
#
# Usage:
#   $ bash run_all_docker_dryrun_and_config_tests.bash
#
# =================================================================================================

path_to_script="$(realpath "$0")"
script_dir_path="$(dirname "${path_to_script}")"
test_dir="$script_dir_path/tests_docker_dryrun_and_config"

source "${script_dir_path}/../src/utility_scripts/nbs_run_all_test_and_dryrun_in_directory.bash" "${test_dir}"

