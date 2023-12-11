#!/bin/bash
#
# Install python development tools
#
# usage:
#   $ bash nbs_install_python_dev_tools.bash
#
set -e

# ....Pre-condition................................................................................
if [[ "$(basename "$(pwd)")" != "utility_scripts" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] 'nbs_install_python_dev_tools.bash' script must be sourced from the 'norlab-build-system/src/utility_scripts/' directory!\n Curent working directory is '$(pwd)'"
  echo '(press any key to exit)'
  read -r -n 1
  exit 1
fi

# ....path resolution logic........................................................................
# (CRITICAL) ToDo: add cwd check to make sure its executed with bash and from the container_tools dir
_PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
NBS_ROOT_DIR="$(dirname "${_PATH_TO_SCRIPT}")/../.."

# ....Helper function..............................................................................
# import shell functions from utilities library
source "${NBS_ROOT_DIR}/import_norlab_build_system_lib.bash"


# ====Begin========================================================================================
nbs::install_python_dev_tools
