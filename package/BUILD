load("@anotherbazeltest//rules_terraform:defs.bzl", "terraform")

config_setting(
    name = "environment_staging",
    values = {
        "define": "env=staging",
    },
)

config_setting(
    name = "environment_production",
    values = {
        "define": "env=production",
    },
)

terraform(
    name = "project",
    srcs = glob(["**/*.tf"]),
    tfvars = select({
        ":environment_staging": "staging.tfvars",
        ":environment_production": "production.tfvars",
    }),
)
