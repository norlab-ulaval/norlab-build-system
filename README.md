<div align="center">
<br>
<br>
<a href="https://norlab.ulaval.ca">
<img src="visual/norlab_logo_acronym_dark.png" width="200">
</a>
<br>

# _Norlab Build System (NBS)_

</div>


[//]: # (<b>Project related link: </b> &nbsp; )

[//]: # (Project related link:)
<div align="center">
<p>
<sup>
<a href="https://http://132.203.26.125:8111">NorLab TeamCity GUI</a>
(VPN or intranet access) &nbsp; • &nbsp;  
<a href="https://hub.docker.com/repositories/norlabulaval">norlabulaval</a>
(Docker Hub) &nbsp;
</sup>
</p>  

**`NBS` is a build-infrastructure-agnostic build system custom-made to meet our need in robotic software engineering at NorLab.**

Maintainer: [Luc Coupal](https://redleader962.github.io)

</div>




#### `v0.2.1` release notes:
- Be advised, this a beta release and we might introduce API breaking change without notice. 
- This version is used in `libpointmatcher-build-system` and `libnabo-build-system` 
- We are currently refactoring out the `dockerized-norlab` build-system logic to `norlab-build-system` for release `v1.0.0`. Stay tuned for the first stable release. 

---

<details>
  <summary style="font-weight: bolder;font-size: large;">How to use this repository as a git submodule</summary>

Just clone the *norlab-build-system* as a submodule in your project repository (ie the
_superproject_), in an arbitrary directory eg.: `my-project/build_system/utilities/`.

```bash
cd <my-project>
mkdir -p build_system/utilities

git submodule init

git submodule \
  add https://github.com/norlab-ulaval/norlab-build-system.git \
  build_system/utilities/norlab-build-system

# Traverse the submodule recursively to fetch any sub-submodule
git submodule update --remote --recursive --init

# Commit the submodule to your repository
git add .gitmodules
git add build_system/utilities/norlab-build-system
git commit -m 'Added norlab-build-system submodule to repository'
```

### Notes on submodule

To **clone** your repository and its submodule at the same time, use

```bash
git clone --recurse-submodules <project/repository/url>
```

Be advise, submodules are a snapshot at a specific commit of the *norlab-build-system*
repository. To **update the submodule** to its latest commit, use

```
[sudo] git submodule update --remote --recursive --init [--force]
```

Notes:

- Add the `--force` flag if you want to reset the submodule and throw away local changes to it.
  This is equivalent to performing `git checkout --force` when `cd` in the submodule root
  directory.
- Add `sudo` if you get an error such
  as `error: unable to unlink old '<name-of-a-file>': Permission denied`

To set the submodule to **point to a different branch**, use

```bash
cd <the/submodule/directory>
git checkout the_submodule_feature_branch_name
```

and use the `--recurse-submodules` flag when switching branch in your main project

```bash
cd <your/project/root>
git checkout --recurse-submodules the_feature_branch_name
```

---

### Commiting to submodule from the main project (the one where the submodule is cloned)

#### If you encounter `error: insufficient permission for adding an object to repository database ...`

```shell
# Change the `.git/objects` permissions
cd <main/project/root>/.git/objects/
chown -R $(id -un):$(id -gn) *
#       <yourname>:<yourgroup>

# Share the git repository (the submodule) with a Group
cd ../../<the/submodule/root>/
git config core.sharedRepository group
# Note: dont replace the keyword "group"
```

This should solve the problem permanently.

</details>

---
# NBS caracteristics
- **build infrastructure agnostic**: can be used locally or on any build infrastructure e.g. _TeamCity_, _GitHub workflow_ 
- support _**TeamCity**_ log via _teamcity service messages_: collapsable bloc, build tag, slack notifications ...
- **build/test isolation** using a _**Docker container**_ 
- portable
  - multi OS support (Ubuntu and OsX)
  - minimal dependencies: `docker`, `docker compose` and `docker buildx` for multi-architecture build
- simple to use
  - configuration through `.env` and `.env.build_matrix` files
  - convenient build script
  - convenient install script
- easy to update via _**git submodule**_

# NBS main usage
Note: Execute `cd src/utility_scripts && bash nbs_execute_compose_over_build_matrix.bash --help` for more details.

The main tool of this repository is a build matrix crawler named `nbs_execute_compose_over_build_matrix.bash`.
Assuming that the superproject (i.e. the project which have cloned `norlab-build-system` as a submodule) as the following structure,
`build_system/` would be containing all file required to run `nbs_execute_compose_over_build_matrix.bash` (i.e. `docker-compose.yaml`
, `Dockerfile`, `.env` and `.env.build_matrix`)

```shell
myCoolSuperProject
┣━━ src/
┣━━ test/
┣━━ build_system/
┃   ┣━━ mycoolproject_crawl_dependencies_build_matrix.bash
┃   ┣━━ nbs_container
┃   ┃   ┣━━ Dockerfile.dependencies
┃   ┃   ┣━━ Dockerfile.project.ci_PR
┃   ┃   ┗━━ entrypoint.bash
┃   ┣━━ .env.build_matrix.dependencies
┃   ┣━━ .env.build_matrix.project
┃   ┣━━ .env
┃   ┣━━ docker-compose.dependencies.yaml
┃   ┗━━ docker-compose.project_core.yaml
┣━━ utilities/
┃   ┣━━ norlab-build-system/
┃   ┗━━ norlab-shell-script-tools/
┣━━ .git
┣━━ .gitmodules
┗━━ README.md
```

Invoking the crawler from a shell script `mycoolproject_crawl_dependencies_build_matrix.bash`
```shell
#!/bin/bash

# ....path resolution logic.............................................
_PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
SUPER_ROOT_DIR="$(dirname "${_PATH_TO_SCRIPT}")../"

# ====begin=============================================================
DOTENV_BUILD_MATRIX=${SUPER_ROOT_DIR}/build_system/.env.build_matrix.dependencies

cd "${SUPER_ROOT_DIR}"
set -o allexport && source ./build_system/.env && set +o allexport

cd ./utilities/norlab-build-system/src/utility_scripts
bash nbs_execute_compose_over_build_matrix.bash \
                      "${DOTENV_BUILD_MATRIX}" \
                      --fail-fast \
                      -- build --dry-run
```
with `.env.build_matrix.dependencies` defining a build matrix `[latest] x [None] x [ubuntu] x [focal, jammy]`,
will result in the following 

![](visual/NBS_dryrun_1.jpg)
![](visual/NBS_dryrun_2.jpg)

In TeamCity, with NBS support for `##teamcity[blockOpened` and `##teamcityblockClosed` service messages, 
a larger build matrix such as `[latest] x [Release, RelWithDebInfo, MinSizeRel] x [ubuntu] x [bionic, focal, jammy]`
will result in the following:

Note: [-] and [+] are collapsible row

![](visual/NBS_dryrun_teamcity.jpg)


# NBS shell script function/script library

- Most code in this repository is tested using _**bats-core**_ and _**docker compose config**_ 
- Most code is well documented: each script header and each function definition
- Go to `build_system_templates/` for `docker-compose.yaml`, `Dockerfile`, `.env` and `.env.build_matrix` templates required to use
  `nbs_execute_compose_over_build_matrix.bash`
- Go to `src/utility_scripts` for utility script:
  - execute compose over build matrix
  - install python dev tools
  - run all test and dryrun in directory
- Go to `src/function_library` for shell script functions:
  - in progress
  
### NBS library import

To import the library functions, execute the following
```shell
cd <path/to/norlab-build-system>

bash import_norlab_build_system_lib.bash
# All `norlab-build-system` functions are now sourced in your current shell.
```
Note: `norlab-build-system` function are prefixed with `nbs`, i.e.: `nbs::<function_name>`


---

### References:

#### Git Submodules

- [Git Tools - Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Git Submodules: Tips for JetBrains IDEs](https://www.stevestreeting.com/2022/09/20/git-submodules-tips-for-jetbrains-ides/)
- [Git submodule tutorial – from zero to hero](https://www.augmentedmind.de/2020/06/07/git-submodule-tutorial/)


---
