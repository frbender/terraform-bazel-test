# Example for Terraform Toolchain

## Setup

Add this to the WORKSPACE:

```python
# this is probably already set up
workspace(name = "anotherbazeltest")

load("//rules_terraform:toolchain.bzl", "terraform_register_toolchains")
terraform_register_toolchains()
```

## Usage

The terraform rule manages everything:

```python
load("@anotherbazeltest//rules_terraform:defs.bzl", "terraform")

terraform(
    name = "example",
    srcs = glob(["*.tf"]),
)
```

On the console, you can:

```shell
$ bazel build //package:project.init
$ bazel build //package:project.plan
```