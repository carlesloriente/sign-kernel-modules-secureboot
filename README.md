# Install Sign Kernel Modules script for Secure Boot

## What

An automated script for signing kernel modules with Secure Boot. It also reviews the prerequisites for the system, required packages, and missing folders and creates the signing keys.

## Notes

1. This is the alpha version created and tested with Fedora OS.

## How

Since this is a simple shell script, it can be hot-linked (see Usage below) in one of your scripts.

# Usage

This script needs to be executable `chmod -x signing-kernel-modules.sh`. After that you can execute with sudo `sudo ./signing-kernel-modules.sh`. And that's it, will check requirements, dependencies and sign the modules automatically.

## Contributing

Please [Create an Issue](https://github.com/carlesloriente/sign-kernel-modules-secureboot/issues) for suggestions, bug report you may have with this script. Or, [Send a Pull Request](https://github.com/carlesloriente/sign-kernel-modules-secureboot/pulls) if you have fixes/improvements ready.

## License

[MIT](https://github.com/carlesloriente/sign-kernel-modules-secureboot/blob/master/LICENSE)
