#!/bin/bash

# ....path resolution logic........................................................................
_PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
LPM_ROOT_DIR="$( realpath "$(dirname "${_PATH_TO_SCRIPT}")/../../" )"
cd "${LPM_ROOT_DIR}"

# ====begin========================================================================================
set -o allexport
source ./build_system_templates/.env
set +o allexport

cd src/utility_scripts

DOTENV_BUILD_MATRIX=${LPM_ROOT_DIR}/build_system_templates/.env.build_matrix.dependencies.template

#export BUILDKIT_PROGRESS=plain # ToDo: on dev task end >> mute this line ←

unset FLAGS
declare -a FLAGS
#FLAGS+=( --no-cache )
#FLAGS+=( --dry-run )
FLAGS+=( --push )  # Note: work when using buildx docker-container
#FLAGS+=( dependencies )

bash nbs_execute_compose_over_build_matrix.bash "${DOTENV_BUILD_MATRIX}" --fail-fast -- build "${FLAGS[@]}"

## Note: Logic required when using default docker builder (not required when using buildx docker-container)
#unset FLAGS
#declare -a FLAGS
#FLAGS+=( --dry-run )
#
#bash nbs_execute_compose_over_build_matrix.bash "${DOTENV_BUILD_MATRIX}" --fail-fast -- push "${FLAGS[@]}"

