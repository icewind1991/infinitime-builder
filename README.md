# infinitime-builder

Build InfiniTime firmware images using [nix](https://nixos.org/).

## Building

```shell
nix --experimental-features 'nix-command flakes' build
```

The images to flash will be put into `./result`

(If you already have flakes enabled you can skip the `--experimental-features` bit)

## Customizing

You can customize the build image by editing `package.nix` and adding them to the `patches` array like:

```nix
patches = [
  # grap the patch directly from github
  (fetchpatch {
    name = "double-click-settings.patch";
    url = "https://github.com/InfiniTimeOrg/InfiniTime/commit/d395f6f0857f082ab3e7fc66cb591b12bbd9cd65.patch";
    sha256 = "sha256-2Jng8JDTU7Zd42qD25CQNeF9dQRSLNwWq9IL+ik0ok0=";
  })
  # or from a local file (don't forget to add the patch to git before building)
  ./local-patch.patch
]
```

## Updating

To change the version being build you can edit the `src` directive with a different `rev` and `hash`.

You can determine the correct `hash` for a revision by running

```shell
nix --experimental-features 'nix-command flakes' run github:nix-community/nurl -- https://github.com/InfiniTimeOrg/InfiniTime <revision> --submodules
```