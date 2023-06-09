def detect_platform_arch(ctx):
    """
    Helper that detects the platform and architecture of the current system so that it can be used for downloading
    the correct Terraform toolchain from https://releases.hashicorp.com/terraform/.
    """
    if ctx.os.name == "linux":
        platform = "linux"
        res = ctx.execute(["uname", "-m"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            if uname not in ["x86_64", "i386"]:
                fail("Unable to determing processor architecture.")

            arch = "amd64" if uname == "x86_64" else "386"
        else:
            fail("Unable to determing processor architecture.")
    elif ctx.os.name == "mac os x":
        platform, arch = "darwin", "amd64"
    elif ctx.os.name.startswith("windows"):
        platform, arch = "windows", "amd64"
    else:
        fail("Unsupported operating system: " + ctx.os.name)

    return platform, arch

url_template = "https://releases.hashicorp.com/terraform/{version}/terraform_{version}_{os}_{arch}.zip"

def _format_url(version, os, arch):
    """
    Generate the URL for downloading the Terraform toolchain from https://releases.hashicorp.com/terraform/.

    @param version: The version of Terraform to download. [e.g. 1.4.6]
    @param os: The operating system to download for. [linux, darwin, windows]
    @param arch: The architecture to download for. [arm, arm64, amd64, 386]
    @return: The URL for downloading the Terraform toolchain.
    """
    return url_template.format(version = version, os = os, arch = arch)

# this is a dict of all the supported toolchains
def _toolchain(os, arch, version, sha):
    """
    Generate platform dict and translates terraform lingo to bazel lingo
    (because of course people can't align on instruction set or os naming...)
    """
    _os_os = os
    _os_platform = os
    if os == "darwin":
        _os_os = "darwin"
        _os_platform = "osx"

    _arch_arch = arch
    _arch_platform = arch
    if arch == "amd64":
        _arch_arch = "amd64"
        _arch_platform = "x86_64"
    if arch == "386":
        _arch_arch = "i386"  # not sure if this is correct
        _arch_platform = "x86_32"

    return {
        "arch": _arch_arch,
        "os": _os_os,
        "version": version,
        "sha": sha,
        "url": _format_url(version, os, arch),
        "exec_compatible_with": [
            "@platforms//os:" + _os_platform,
            "@platforms//cpu:" + _arch_platform,
        ],
        "target_compatible_with": [
            "@platforms//os:" + _os_platform,
            "@platforms//cpu:" + _arch_platform,
        ],
    }

def _generate_toolchains(map):
    toolchains = {}
    for version, oss in map.items():
        for os, archs in oss.items():
            for arch, sha in archs.items():
                if version not in toolchains:
                    toolchains[version] = {}
                if os not in toolchains[version]:
                    toolchains[version][os] = {}
                toolchains[version][os][arch] = _toolchain(os, arch, version, sha)
    return toolchains

# this uses terraform lingo for os and arch
_toolchain_shas = {
    "1.4.6": {
        "linux": {
            "arm64": "b38f5db944ac4942f11ceea465a91e365b0636febd9998c110fbbe95d61c3b26",
            "386": "f802ead8d46b90e5b5ec2ef5aaf5a0438bd9a7621fcc80f192b3a93ba25d679c",
            "amd64": "e079db1a8945e39b1f8ba4e513946b3ab9f32bd5a2bdf19b9b186d22c5a3d53b",
        },
        "darwin": {
            "arm64": "30a2f87298ff9f299452119bd14afaa8d5b000c572f62fa64baf432e35d9dec1",
            "amd64": "5d8332994b86411b049391d31ad1a0785dfb470db8b9c50617de28ddb5d1f25d",
        },
    },
}

toolchains = _generate_toolchains(_toolchain_shas)
