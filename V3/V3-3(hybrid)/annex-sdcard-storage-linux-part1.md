# Annex: Storing Data (Samples, Presets, etc.) on an External SD Drive — Minimal Linux Approach – Part 1

---

## Table of Contents

1. Introduction: SD Card Storage in Embedded Linux Synths
    - Comparison: Bare Metal vs. Linux-based storage
    - Overview of Linux SD card support (block devices, filesystems)
    - Why Linux simplifies storage (drivers, filesystems, multitasking)
    - Key differences for synth/sample usage
2. SD Card Hardware & Linux Integration
    - SD card hardware interface on Raspberry Pi and similar SBCs
    - Device tree overlays, SPI vs. native SD/MMC
    - /dev nodes: mmcblk, sdX, partitions (mmcblk0p1, sda1)
    - Power, ESD, and hot-plug considerations on Linux
3. Filesystems: FAT, exFAT, ext4, and Others
    - Choosing a filesystem: interoperability vs. performance
    - Mounting and unmounting SD cards (manual and automatic)
    - File permissions, ownership, and access control
    - Handling removable media, automount, and fstab
    - Checking and repairing filesystems (fsck, dosfsck, etc.)
4. Accessing SD Storage in C on Linux
    - Using standard C file I/O (fopen, fread, fwrite, fclose)
    - Directory operations (opendir, readdir, stat)
    - File attributes, metadata, and error handling
    - Large file support, buffering, and memory mapping
    - Practical example: enumerating patches/presets

---

## 1. Introduction: SD Card Storage in Embedded Linux Synths

### 1.1 Comparison: Bare Metal vs. Linux-based Storage

- **Bare Metal:** You must implement (or port) SD card drivers, block device logic, and a filesystem (often FAT).
- **Linux:** The kernel provides SD/MMC drivers, block device abstraction, and mature filesystems (FAT, exFAT, ext4, etc.)—you focus on application logic.
- **Key advantages with Linux:** Robust error handling, multitasking, caching, hot-plug support, and ready-to-use file/directory APIs.
- **Disadvantages:** More overhead, possibly less deterministic timing for real-time streaming unless carefully managed.

### 1.2 Overview of Linux SD Card Support

- Standard Linux kernel includes drivers for SD/MMC cards (via native MMC or SPI).
- SD card appears as a block device (`/dev/mmcblk0`, `/dev/mmcblk1`, etc.).
- Filesystems (FAT, exFAT, ext4) are supported out-of-the-box on most distros.
- Mounting can be manual (`mount`), automatic (via fstab/udev), or handled by desktop environments.

### 1.3 Why Linux Simplifies Storage

- No need to write low-level drivers for SD card communication.
- Filesystem handled by kernel—no need to parse FAT structures in your code.
- Well-defined APIs for file and directory access (`fopen`, `fread`, `fwrite`, etc.).
- Access to advanced features: file locking, memory mapping, asynchronous I/O.

### 1.4 Key Differences for Synth/Sample Usage

- **Bare Metal:** You must avoid blocking calls; all timing is your responsibility.
- **Linux:** Kernel can cache/buffer reads and writes, but you must manage latency and avoid blocking in real-time audio threads.
- **Hot-plug and media removal:** Linux detects mount/unmount, but your synth must gracefully handle missing files or device removal.

---

## 2. SD Card Hardware & Linux Integration

### 2.1 SD Card Hardware Interface on Raspberry Pi and SBCs

- Most SBCs (Raspberry Pi, BeagleBone, etc.) use native SD/MMC interface for the boot/system card.
- For additional/removable SD, use USB SD readers or the SPI interface.
- **Native SD/MMC** offers higher performance than SPI.
- Linux abstracts all block devices; the card shows up as `/dev/mmcblk0` (with partitions like `/dev/mmcblk0p1`).

### 2.2 Device Tree Overlays, SPI vs. Native SD/MMC

- Device Tree configures interfaces on boot (see `/boot/overlays/` on Raspberry Pi OS).
- For SPI SD (e.g., with MCP23S17 or custom hardware), enable SPI in `/boot/config.txt` and use overlays.
- Native SD/MMC is preferred for speed, but SPI SD is useful for DIY expansion.

### 2.3 /dev Nodes: mmcblk, sdX, and Partitions

- **/dev/mmcblk0**: Main (boot) SD card block device.
- **/dev/mmcblk0p1**: First partition (e.g., boot or data).
- **/dev/sda1**: First partition of first USB SD reader.
- Use `lsblk`, `blkid`, or `dmesg | grep mmc` to identify devices.

#### Example: Listing SD Devices

```bash
lsblk
# Output:
# NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# mmcblk0      179:0    0 29.8G  0 disk
# ├─mmcblk0p1  179:1    0  256M  0 part /boot
# └─mmcblk0p2  179:2    0 29.5G  0 part /
```

### 2.4 Power, ESD, and Hot-Plug Considerations on Linux

- Linux drivers handle card insertion/removal events.
- Sudden removal during write can corrupt files—always unmount safely.
- Use ESD-safe sockets and handle cards at edges.
- Use `udevadm monitor` to watch device events.

---

## 3. Filesystems: FAT, exFAT, ext4, and Others

### 3.1 Choosing a Filesystem

- **FAT32 (vfat):** Universal, supported by all OSes and samplers. Max file size 4GB.
- **exFAT:** Needed for >32GB cards or >4GB files. Supported by most modern OSes.
- **ext4:** Linux-native, robust, supports large files. Not readable by Windows/macOS natively.
- For sample sharing and compatibility, FAT32 or exFAT is preferred.

### 3.2 Mounting and Unmounting SD Cards

#### Manual Mounting

```bash
sudo mount /dev/mmcblk0p1 /mnt/sdcard
# ... access files ...
sudo umount /mnt/sdcard
```

#### Automatic Mounting

- Use `/etc/fstab` for persistent mounts at boot.
- Use `udiskctl` or desktop environment for automounting on insertion.

#### Example /etc/fstab entry

```
/dev/mmcblk0p1  /mnt/sdcard  vfat  defaults,noatime  0  2
```

### 3.3 File Permissions, Ownership, and Access Control

- Removable media may default to root ownership, or `pi`/`user` if automounted.
- Set ownership/permissions as needed (`sudo chown`, `chmod`).
- For headless synths, mount as root or set up udev rules for access.

### 3.4 Handling Removable Media, Automount, and fstab

- Use `udisks2`/`udev` for automount on insertion (desktop).
- On embedded systems, use scripts or systemd rules to detect and mount SD cards.
- Always check if mount succeeded before accessing files in code.

### 3.5 Checking and Repairing Filesystems

- Use `fsck.vfat`, `dosfsck` for FAT/exFAT, `fsck.ext4` for ext4.
- On boot, Linux may auto-run fsck if corruption is detected.
- Never remove power or SD card during a write.

---

## 4. Accessing SD Storage in C on Linux

### 4.1 Using Standard C File I/O

- All filesystems are abstracted as simple files and directories.
- Use standard C library: `fopen`, `fread`, `fwrite`, `fseek`, `fclose`.

#### Example: Reading a Sample File

```c
#include <stdio.h>
#define BUF_SIZE 4096

FILE *fp = fopen("/mnt/sdcard/samples/PIANO01.WAV", "rb");
if (!fp) { perror("fopen failed"); exit(1); }
uint8_t buf[BUF_SIZE];
size_t n;
while ((n = fread(buf, 1, BUF_SIZE, fp)) > 0) {
    // Process audio buffer here
}
fclose(fp);
```

### 4.2 Directory Operations

- Use `opendir`, `readdir`, `closedir` to enumerate files for UI, patch browsing, etc.

#### Example: List All Presets

```c
#include <dirent.h>
DIR *dir = opendir("/mnt/sdcard/presets");
struct dirent *ent;
while ((ent = readdir(dir)) != NULL) {
    printf("Found file: %s\n", ent->d_name);
}
closedir(dir);
```

### 4.3 File Attributes, Metadata, and Error Handling

- Use `stat`/`fstat` for file size, timestamps, permissions.
- Always check for errors (NULL, -1) and report to the user or log.
- On file access failure, check if the card is mounted or present.

### 4.4 Large File Support, Buffering, and Memory Mapping

- For files >2GB, compile with `-D_FILE_OFFSET_BITS=64`.
- Use buffered I/O for streaming large samples.
- For very large samples, consider `mmap` to map file directly into address space (advanced).

### 4.5 Practical Example: Enumerating Patches/Presets

- Use directory listing to build patch browser UI.
- Store metadata (patch name, category) in filename or in a separate index file.

---

*End of Part 1. The next part will go deep into: real-time streaming, safe writing/saving, sample and preset organization, robust error recovery, optimization strategies for Linux-based synths, and advanced storage concepts (e.g., safe power-down, journaling, and database usage on SD).*