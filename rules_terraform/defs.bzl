load("//rules_terraform:toolchain.bzl", _terraform_register_toolchains = "terraform_register_toolchains")
load("//rules_terraform:toolchain.bzl", _declare_terraform_toolchains = "declare_terraform_toolchains")
load("//rules_terraform:terraform.bzl", _terraform = "terraform")

terraform_register_toolchains = _terraform_register_toolchains
declare_terraform_toolchains = _declare_terraform_toolchains

terraform = _terraform
