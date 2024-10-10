# CUT 
#### ChromeOS Unenrollment Toolkit
An Alpine-based miniroot system designed to run ChromeOS exploits, utilizing the RMA shim rootfs verification exploit.

## Features
- Minimal rootfs - 25mb rootfs, compared to SH1MMER's 200mb, making it load much faster on slow USB drives.
- Proper wireless support - Comes with a utility to connect to networks using WPA_supplicant, allowing for previously-impossible payloads such as the full Mr. Chromebox firmware utility. (Not implemented)
- Failsafes - Only permits you to run payloads when their conditions are met (no csmite on 119+, for example)
- More payload auditing - Doesn't allow joke payloads like the infamous troll.sh SH1MMER payload to be merged.
- More fine-grained control - Along with the typical non-interactive payloads, there are also utilities for actions that require user input, such as setting specific GBB flags.
- More cohesive - All modules are organized into their proper catagories, and all ChromeOS requirements are documented 
- Multishim support - One board not enough for you? Try a few more. (Not implemented)
- System information - Ships with a very in-depth system information utility that shows everything recovery mode does, and more. See GBB flags, VPD settings, FWMP status, ChromeOS version, etc.

## Payloads
The following payloads are planned for initial release; PRs are welcome, but it has to be useful.
### Enrollment
- Legacy unenrollment
- Defog
- Cryptosmite
- Caliginosity
- Pencilmod WP (including FWMP removal via ctrl+U mode)
### Misc
- Mr. Chromebox firmware utility script (requires internet connection)
- Kernver rollback
- Clobber-based update blocker

## Utilities
- Set GBB flags
- Remove FWMP
- Set FWMP flags
- Set kernver
- Connect to a WPA network

## Building
CUT uses modified versions of the [Shimboot](https://github.com/ading2210/shimboot) build scripts, and as such building is similar.
To build a complete image, use `doas ./build_complete.sh <board>` from inside the `scripts` directory
