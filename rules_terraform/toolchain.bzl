load("//rules_terraform:toolchain_versions.bzl", "detect_platform_arch", "toolchains")
load("//rules_terraform:provider.bzl", "TerraformInfo")

def _terraform_build_file(ctx, version):
    """
    Generate the BUILD.bazel file for the Terraform toolchain.
    (Needed to make the terraform binary visible to Bazel.)

    @param ctx: The context object.
    @param version: The version of Terraform to generate the BUILD.bazel file for.
    """
    ctx.template(
        "BUILD.bazel",
        Label("@anotherbazeltest//rules_terraform:BUILD.bazel.tmpl"),
        executable = False,
        substitutions = {
            "{name}": "terraform_executable",
            "{version}": version,
        },
    )

def _download_terraform(ctx, url, sha):
    """
    Download the Terraform toolchain.

    @param ctx: The context object.
    @param url: The URL to download the Terraform toolchain from.
    @param sha: The SHA256 checksum of the downloaded file.
    """
    ctx.download_and_extract(
        url = url,
        sha256 = sha,
        type = "zip",
        output = "terraform",
    )

def _terraform_register_toolchains_impl(ctx):
    """
    Sets up the repository where terraform lives by downloading terraform and exporting it via a BUILD.bazel file.
    """

    # find out which toolchain we need
    platform, arch = detect_platform_arch(ctx)
    version = ctx.attr.version
    toolchain = toolchains[version][platform][arch]

    # download and extract terraform
    _download_terraform(ctx, toolchain["url"], toolchain["sha"])

    # make it visible
    _terraform_build_file(ctx, version)

# rule which creates a repository containing the terraform toolchain
_terraform_register_toolchains = repository_rule(
    _terraform_register_toolchains_impl,
    attrs = {
        "version": attr.string(),
    },
)

def terraform_register_toolchains(version = "1.4.6"):
    """
    Setup and register the Terraform toolchains.

    This rule will download the Terraform toolchains to the "@terraform_toolchains" repository.

    @param version: The version of Terraform to download.
    """
    _terraform_register_toolchains(
        name = "terraform_toolchains",
        version = version,
    )

def _terraform_toolchain_impl(ctx):
    """
    Creates a basic
    """
    toolchain_info = platform_common.ToolchainInfo(
        barcinfo = TerraformInfo(
            sha = ctx.attr.sha,
            url = ctx.attr.url,
        ),
    )
    return [toolchain_info]

terraform_toolchain = rule(
    implementation = _terraform_toolchain_impl,
    attrs = {
        "sha": attr.string(),
        "url": attr.string(),
    },
)

def declare_terraform_toolchains(version):
    for os, archs in toolchains[version].items():
        for arch, info in archs.items():
            name = "terraform_{}_{}_{}".format(version, os, arch)
            toolchain_name = "{}_toolchain".format(name)

            terraform_toolchain(
                name = name,
                url = info["url"],
                sha = info["sha"],
            )

            native.toolchain(
                name = toolchain_name,
                exec_compatible_with = info["exec_compatible_with"],
                target_compatible_with = info["target_compatible_with"],
                toolchain = name,
                toolchain_type = "@anotherbazeltest//:toolchain_type",
            )
