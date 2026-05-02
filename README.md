# HT32F50030 Firmware Skeleton

Minimal standalone GNU Make firmware skeleton for the Holtek HT32F50030 Cortex-M0+ MCU.

## Build

Install the project-local Arm GNU Toolchain, then build:

```sh
./install-tools
make
```

```sh
./install-tools remove
```

Build outputs are written to `build/`:

- `build/ht32f50030.elf`
- `build/ht32f50030.hex`
- `build/ht32f50030.bin`
- `build/ht32f50030.map`
- `build/ht32f50030.lst`

Clean generated files with:

```sh
make clean
```
