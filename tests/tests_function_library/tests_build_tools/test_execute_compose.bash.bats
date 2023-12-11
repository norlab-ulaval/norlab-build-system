#!/usr/bin/env bats
#
# Usage in docker container
#   $ REPO_ROOT=$(pwd) && RUN_TESTS_IN_DIR='tests'
#   $ docker run -it --rm -v "$REPO_ROOT:/code" bats/bats:latest "$RUN_TESTS_IN_DIR"
#
#   Note: "/code" is the working directory in the bats official image
#
# bats-core ref:
#   - https://bats-core.readthedocs.io/en/stable/tutorial.html
#   - https://bats-core.readthedocs.io/en/stable/writing-tests.html
#   - https://opensource.com/article/19/2/testing-bash-bats
#       ↳ https://github.com/dmlond/how_to_bats/blob/master/test/build.bats
#
# Helper library: 
#   - https://github.com/bats-core/bats-assert
#   - https://github.com/bats-core/bats-support
#   - https://github.com/bats-core/bats-file
#

BATS_HELPER_PATH=/usr/lib/bats
if [[ -d ${BATS_HELPER_PATH} ]]; then
  load "${BATS_HELPER_PATH}/bats-support/load"
  load "${BATS_HELPER_PATH}/bats-assert/load"
  load "${BATS_HELPER_PATH}/bats-file/load"
  load "${SRC_CODE_PATH}/${N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH}/bats_helper_functions"
  #load "${BATS_HELPER_PATH}/bats-detik/load" # << Kubernetes support
else
  echo -e "\n[\033[1;31mERROR\033[0m] $0 path to bats-core helper library unreachable at \"${BATS_HELPER_PATH}\"!"
  echo '(press any key to exit)'
  read -r -n 1
  exit 1
fi

# ====Setup========================================================================================

TESTED_FILE="execute_compose.bash"
TESTED_FILE_PATH="./src/function_library/build_tools"
TESTED_FCT="nbs::execute_compose"

# executed once before starting the first test (valide for all test in that file)
setup_file() {
  BATS_DOCKER_WORKDIR=$(pwd) && export BATS_DOCKER_WORKDIR

  ## Uncomment the following for debug, the ">&3" is for printing bats msg to stdin
#  pwd >&3 && tree -L 1 -a -hug >&3
#  printenv >&3
}

# executed before each test
setup() {
  source import_norlab_build_system_lib.bash
  cd "${SRC_CODE_PATH}/$TESTED_FILE_PATH" || exit
}

# ====Teardown=====================================================================================

# executed after each test
teardown() {
  bats_print_run_env_variable_on_error
}

## executed once after finishing the last test (valide for all test in that file)
#teardown_file() {
#}

# ====Test casses==================================================================================

@test "nbs_execute_compose_over_build_matrix.bash › dependencies image › execute ok › expect pass" {
#  skip "tmp mute" # ToDo: on task end >> delete this line ←
  DOTENV_BUILD_MATRIX="${SRC_CODE_PATH}"/build_system_templates/.env.build_matrix.dependencies.template

  cd "${SRC_CODE_PATH}/src/utility_scripts/" || exit

  run bash "nbs_execute_compose_over_build_matrix.bash" "${DOTENV_BUILD_MATRIX}" --fail-fast -- build
  assert_success
  assert_output --regexp "=========".*"Starting".*"nbs_execute_compose_over_build_matrix.bash".*"[NBS]".*"Build images specified in".*"'docker-compose.dependencies.yaml'".*"following".*".env.build_matrix"
  assert_output --regexp "Status of tag crawled:".*"Pass".*"› latest-ubuntu-bionic".*"Pass".*"› latest-ubuntu-focal".*"Completed".*"nbs_execute_compose_over_build_matrix.bash".*"========="
}


@test "${TESTED_FILE} › function ${TESTED_FCT} › --help › execute ok › expect pass" {
#  skip "tmp mute" # ToDo: on task end >> delete this line ←

  run ${TESTED_FCT} --help

  assert_success
  assert_output --regexp "=========".*"Starting".*"${TESTED_FCT}".*"\$".*"${TESTED_FCT}".*"<docker-compose.yaml>".*"[<optional flag>]".*"[".*"<any docker cmd+arg>]"
}

@test "${TESTED_FILE} › function ${TESTED_FCT} › execute ok › expect pass" {
#  skip "tmp mute" # ToDo: on task end >> delete this line ←

  PATH_TO_DOCKERFILE="${SRC_CODE_PATH}"/build_system_templates/nbs_container/project-dependencies/Dockerfile.dependencies

  run nbs::execute_compose "$PATH_TO_DOCKERFILE"

  assert_success
  assert_output --regexp "=========".*"Starting".*"${TESTED_FCT}".*"[NBS]".*"Environment variables set for compose:".*"REPOSITORY_VERSION=latest".*"CMAKE_BUILD_TYPE=RelWithDebInfo".*"DEPENDENCIES_BASE_IMAGE=ubuntu".*"DEPENDENCIES_BASE_IMAGE_TAG=focal"

  assert_output --regexp "[NBS]".*"Environment variables used by compose:".*"REPOSITORY_VERSION=latest".*"CMAKE_BUILD_TYPE=RelWithDebInfo".*"DEPENDENCIES_BASE_IMAGE=ubuntu".*"DEPENDENCIES_BASE_IMAGE_TAG=focal".*"Completed".*"${TESTED_FCT}".*"=========".*
#  fail ""
}

# ToDo: implement >> test for IS_TEAMCITY_RUN==true casses
# (NICE TO HAVE) ToDo: implement >> test for python intsall casses with regard to distribution

