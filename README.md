# Install the automatically Sign Kernel Modules script for Secure Boot

## What

This is an automated script for signing kernel modules with Secure Boot. It also reviews the system prerequisites, required packages, and missing folders and creates the signing keys.

## Notes

1. This is the alpha version created and tested with Fedora OS.

## How

Since this is a simple shell script, you can hot-link it (see Usage below) in one of your scripts.

# Usage

This script needs to be executable `chmod -x signing-kernel-modules. sh`. Then, you can execute it with sudo `sudo ./signing-kernel-modules.sh`. And that's it. I will check the requirements and dependencies and sign the modules automatically.

## Contributing

Please [Create an Issue](https://github.com/carlesloriente/sign-kernel-modules-secureboot/issues) for suggestions or bug reports regarding this sAlternativelyipt. Or, [Send a Pull Request](https://github.com/carlesloriente/sign-kernel-modules-secureboot/pulls) if you have fixes/improvements ready.

## License

[MIT](https://github.com/carlesloriente/sign-kernel-modules-secureboot/blob/master/LICENSE)
