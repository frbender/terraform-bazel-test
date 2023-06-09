load("@anotherbazeltest//rules_terraform:terraform_init.bzl", "terraform_init")
load("@anotherbazeltest//rules_terraform:terraform_plan.bzl", "terraform_plan")

def get_common_prefix(srcs):
    """
    Returns the common prefix of all the given srcs.
    """

    #srcs = [src.path for src in srcs]
    if len(srcs) == 0:
        return ""
    prefix = srcs[0]
    for src in srcs[1:]:
        for i in range(len(src)):
            if len(prefix) == 0:
                return ""
            if src.startswith(prefix[:i]):
                break
            else:
                prefix = prefix[:len(prefix) - 1]
    return prefix

def remove_prefix(srcs, prefix):
    """
    Removes the given prefix from all the given srcs.
    """
    return [src[len(prefix):] for src in srcs]

def terraform(name, srcs = [], tfvars = None):
    """
    Generates multiple output targets:
    - <name>.init: runs terraform init
    - <name>.plan: runs terraform plan (depends on <name>.init)
    - <name>.apply: runs terraform apply (depends on <name>.init)
    """

    terraform_init(
        name = name + ".init",
        srcs = srcs,
        tfvars = tfvars,
    )
    terraform_plan(
        name = name + ".plan",
        srcs = srcs,
        deps = [name + ".init"],
        tfvars = tfvars,
    )
