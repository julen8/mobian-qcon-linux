# Mobian kernel configuration

We aim for reducing our maintenance effort and stay close to what the
Debian kernel package offers. Therefore, we generate the kernel
configuration from the config fragments extracted from the Debian
kernel [packaging repo](https://salsa.debian.org/kernel-team/linux/)
and combine them along with a Mobian device-agnostic fragment and a
device-specific one.

A kernel package should therefore contain the following files under
`debian/config`:
* `debian.config`: Debian arch-independent config options; copied
  verbatim from Debian's `debian/config/config`
* `debian.arm64.config`: Debian ARM64 config options; copied verbatim
  from Debian's `debian/config/arm64/config`
* `mobian.config`: Mobian device-independent config options
* `<vendor>.config`: Mobian device-specific config options

The `last-update` file contains the date when the Debian config
fragments were last synced from the kernel team repo.
