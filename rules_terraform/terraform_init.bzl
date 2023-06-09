def _terraform_init(ctx):
    deps = depset(ctx.files.srcs + ctx.files.tfvars)
    folder = ctx.files.srcs[0].path.split("/")[0]
    fixed_tf_vars_path = ctx.files.tfvars[0].path[len(folder) + 1:]
    ctx.actions.run(
        executable = ctx.executable._exec,
        inputs = deps.to_list(),
        outputs = [ctx.outputs.out],
        mnemonic = "TerraformInitialize",
        arguments = [
            "-chdir=" + folder,
            "init",
            "-var-file=" + fixed_tf_vars_path,
        ],
        env = {
            "TF_LOG_PATH": ctx.outputs.out.path,
        },
    )

terraform_init = rule(
    implementation = _terraform_init,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "tfvars": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "_exec": attr.label(
            default = Label("@terraform_toolchains//:terraform_executable"),
            allow_files = True,
            executable = True,
            cfg = "host",
        ),
    },
    outputs = {"out": "%{name}.out"},
)
