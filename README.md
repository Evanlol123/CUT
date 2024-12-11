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

## How do I use it?
CUT uses modified versions of the [Shimboot](https://github.com/ading2210/shimboot) build scripts, and as such building is similar.
You need to be on Linux (debian based) or WSL2.

```
git clone https://github.com/Censura-Exploits/CUT/
cd CUT/scripts```
sudo bash build_complete.sh <board>
```
Replace `<board>` with the name of your board. You can find it at chrome://version
![board](/assets/board.png)

Below are the all boards with leaked rma shims

ambassador, banon, brask, brya, clapper, coral, corsola, cyan, dedede, edgar, elm, enguarde, fizz, glimmer, grunt, hana, hatch, jacuzzi, kalista, kefka, kukui, lulu, nami, nissa, octopus, orco, puff, pyro, reef, reks, relm, sand, sentry, snappy, stout, strongbad, tidus, trogdor, ultima, volteer, zork

## regarding inability to boot into shims

**nissa** • Keys rolled, affecting the majority of nissa devices. It is estimated that shims are keyrolled if the manufacture date is after nov 2023.

**corsola & dedede** • Keys rolled, however not as significant. Devices only after april 2024 (estimated)

**trogdor** • Old kernel issue, most likely device specific and doesn't affect all trogdor devices. Ends up booting back to dev mode screen

**hana** • Not sure what's going on here, might be same as trogdor. Ends up booting back to os verification screen 

**kukui** • Old kernel issue. The reason why the screen is black though is because the older kernel doesn't support the device's panel, hence a black screen


## Todo
1. Add docs so you can access while inside CUT
2. Add the rest of the docs on the website
3. Add cryptosmite renrollment when writable finally shows how to use it
4. Multishim support
5. Make it so it can only run scripts that work based on chromeOS version and if write protection is on
6. Add the ability to add recovery images and customized recovery images

## Credits
1. [Mercury Workshop](https://mercurywork.shop/) - Creating the original [Sh1mmer](https://sh1mmer.me/) exploit
2. [Writable](https://discord.com/users/480818241145536513) - Creating the [Cryptosmite](https://github.com/FWSmasher/CryptoSmite) exploit
3. [OlyB]
4. Symlink - creating the original CUT o7
5. Vk6 - Creating shimboot
6. Hannah - Fact checking
7. Katelyn - Fact checking
8. Rosa Green - User-facing scripts and Shimboot modifications 
9. Alpine Linux Project
10. Kate Ward - shflags
11. ChromiumOS project - Flashrom project and VBOOT utilities
12. Survivor - Making CUT work and updating it after symlink left the community
