# Add project test code here

Execute 'norlab-build-system' repo shell script test via 'norlab-shell-script-tools' library

Usage:
```shell
bash run_bats_core_test_in_ns2t.bash ['<test-directory>[/<this-bats-test-file.bats>]' ['<image-distro>']]
```
Arguments:
  - `['<test-directory>']`        The directory from which to start test, default to 'tests'
  - `['/<this-bats-test-file.bats>']`  A specific bats file to run, default will run all bats file in the test directory

---

### Bats shell script testing framework references

- [bats-core on github](https://github.com/bats-core/bats-core)
- [bats-core on readthedocs.io](https://bats-core.readthedocs.io)
- `bats` helper library (pre-installed in `norlab-shell-script-tools` testing containers in
  the `tests/` dir)
    - [bats-assert](https://github.com/bats-core/bats-assert)
    - [bats-file](https://github.com/bats-core/bats-file)
    - [bats-support](https://github.com/bats-core/bats-support)
- Quick intro:
    - [testing bash scripts with bats](https://www.baeldung.com/linux/testing-bash-scripts-bats)

