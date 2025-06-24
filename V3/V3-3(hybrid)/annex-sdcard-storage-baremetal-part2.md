# Annex: Storing Data (Samples, Presets, etc.) on an External SD Drive — Bare Metal Approach – Part 2

---

## Table of Contents

5. Minimal FAT16/FAT32 Filesystem Implementation
    - Why use a filesystem?
    - FAT basics: sectors, clusters, directory entries, and allocation tables
    - Partition table and boot sector
    - Mounting the filesystem: root dir and filesystem structures
    - Directory listing, file open/read/write/close
    - Error handling and filesystem integrity
6. Strategies for Sample/Bank/Presets Storage
    - File organization: directories, naming, and extensions
    - Fixed-size vs variable-size sample storage
    - Handling large files and multi-part samples
    - Metadata: patch info, sample mapping, and custom formats
    - Example: Emulator/Emax-like bank and preset layout
7. Streaming Large Files and Audio Data
    - Why streaming matters (real-time sample playback)
    - Buffering, prefetching, and double-buffering
    - Reading large files in chunks/sectors
    - Latency, timing, and error recovery
    - Implementing circular/ring buffers for audio sample data
8. Real-World C Code Examples
    - Open source FAT libraries (FatFs, Petit FatFs, ChaN FAT, Elm Chan)
    - Integrating SD and FAT code in your bare metal synth
    - Reading directory, loading a sample, and error checks
    - Saving presets and patch data
    - Sample code for streaming and buffer refill
    - Performance benchmarks and tuning tips

---

## 5. Minimal FAT16/FAT32 Filesystem Implementation

### 5.1 Why Use a Filesystem?

- Allows easy interchange with computers (drag-and-drop samples/presets).
- Enables structured storage: directories, filenames, file attributes.
- Standard storage for samplers, portable recorders, and synthesizers.

### 5.2 FAT Basics

#### Sectors, Clusters, and Allocation Table

- **Sector:** Basic unit, always 512 bytes.
- **Cluster:** One or more sectors (e.g., 4KB = 8 sectors).
- **FAT (File Allocation Table):** Maps each cluster to the next, or marks end-of-file/free.

#### Directory Entries

- Each file = 32-byte entry: name, ext, attributes, first cluster, size, timestamps.
- Root dir is fixed size on FAT16, expandable on FAT32.

### 5.3 Partition Table and Boot Sector

- First sector: MBR (Master Boot Record or partition table).
- Boot sector: filesystem parameters (bytes/sector, sectors/cluster, FAT location, etc.).
- Must parse these to mount and locate filesystem structures.

#### Example: Key Boot Sector Fields

| Offset | Field                | Description                |
|--------|----------------------|----------------------------|
| 0x0B   | bytes/sector         | Usually 512                |
| 0x0D   | sectors/cluster      | 1, 2, 4, 8, etc.           |
| 0x0E   | reserved sectors     | Typically 1                |
| 0x10   | number of FATs       | 2                          |
| 0x16   | sectors per FAT      | Size of FAT                |
| 0x1C   | root directory start | (FAT16 only)               |

### 5.4 Mounting the Filesystem

- Read boot sector, extract parameters.
- Locate FAT region, root directory, data area.
- Keep track of current sector, cluster, and file pointers.

#### Example: Mount Procedure (Pseudocode)

```c
int fat_mount() {
    read_sector(boot_sector, 0);
    parse_boot_sector(boot_sector);
    locate_fat_and_root();
    return 0; // Or error
}
```

### 5.5 Directory Listing

- Directory = series of 32-byte entries.
- To list files: read directory sector(s), parse each entry for names and file info.
- Skip deleted or empty entries.

#### Example: Parse Directory Entry

```c
typedef struct {
    char name[8];
    char ext[3];
    uint8_t attr;
    uint8_t reserved[10];
    uint16_t time;
    uint16_t date;
    uint16_t start_cluster;
    uint32_t size;
} __attribute__((packed)) DirEntry;
```

### 5.6 File Open/Read/Write/Close

- **Open:** Find file entry, store first cluster and size.
- **Read:** Follow cluster chain via FAT, read sectors as needed.
- **Write:** Allocate clusters in FAT, update directory entry size/chain.
- **Close:** Update directory entry, flush buffers.

### 5.7 Error Handling and Filesystem Integrity

- Handle lost clusters, bad sectors, and allocation errors.
- Always update FAT and directory safely (power-loss protection).
- Consider read-only mode to protect samples on stage.

---

## 6. Strategies for Sample/Bank/Presets Storage

### 6.1 File Organization

- Use directories: `/SAMPLES/`, `/PRESETS/`, `/BANKS/`
- Use short names (8+3) for maximum compatibility, or long file name (LFN) support if your FAT library allows.

#### Example Directory Layout

```
/SAMPLES/
    PIANO01.WAV
    BASSGTR2.RAW
/PRESETS/
    CLASSIC1.PST
    WARMSTRG.PST
```

### 6.2 Fixed-Size vs Variable-Size Sample Storage

- **Fixed-size:** All samples are same length and format. Fast and easy to index (like old samplers).
- **Variable-size:** More flexible, but needs directory or index to manage start/end and metadata.

### 6.3 Handling Large Files and Multi-Part Samples

- Split files into chunks if needed (e.g., 4MB segments for large SD cards).
- Use file naming conventions or indexes for multi-part samples (PIANO01A.WAV, PIANO01B.WAV).

### 6.4 Metadata: Patch Info, Sample Mapping, and Custom Formats

- Store patch/preset data as separate files or embed in sample file headers (WAV/BWF/AIFF chunks).
- Use simple binary or text formats for fast parsing.
- Emulator/Emax: Used custom formats, but you can use open standards for flexibility.

### 6.5 Example: Emulator/Emax-Like Bank and Preset Layout

- Banks = directory or file bundle of samples+presets.
- Presets = mapping of samples to keys/zones, plus parameter data.
- Each bank could be a directory with `BANKINFO.TXT`, sample files, and preset files.

---

## 7. Streaming Large Files and Audio Data

### 7.1 Why Streaming Matters

- Samples may be too big for RAM; must read in real time as notes play.
- Emulator/Emax read sectors on demand during playback.

### 7.2 Buffering, Prefetching, and Double-Buffering

- Implement a circular/ring buffer in RAM.
- While one buffer is being played back, fill the next with SD card reads.
- Prefetch upcoming sample data to avoid stutters.

### 7.3 Reading Large Files in Chunks/Sectors

- Read N sectors at a time (e.g., 2–8KB).
- Align reads to SD card sector boundaries for speed.
- Handle cluster boundaries in FAT filesystem.

### 7.4 Latency, Timing, and Error Recovery

- Tune buffer size for minimum latency and no underruns.
- Use timer interrupts or DMA for scheduled buffer refills.
- Handle SD read errors by outputting silence or retrying.

### 7.5 Implementing Circular/Ring Buffers

```c
#define AUDIO_BUF_SIZE 4096
uint8_t audio_buffer[2][AUDIO_BUF_SIZE];
volatile int buf_playing = 0, buf_filling = 1;

void audio_isr() {
    // Play from audio_buffer[buf_playing]
    // When done, swap buffers and trigger SD read into buf_filling
}
```

---

## 8. Real-World C Code Examples

### 8.1 Open Source FAT Libraries

- **FatFs (Elm Chan):** https://elm-chan.org/fsw/ff/00index_e.html
- **Petit FatFs:** Tiny read-only version.
- **ChaN FAT:** Used in many hobby and commercial products.

#### FatFs Integration Example

```c
FATFS fs;
FIL file;
f_mount(&fs, "", 0);
f_open(&file, "SAMPLES/BASSGTR2.RAW", FA_READ);
while (f_read(&file, buf, sizeof(buf), &br) == FR_OK && br > 0) {
    // Process audio buffer
}
f_close(&file);
```

### 8.2 Integrating SD and FAT Code in Your Bare Metal Synth

- Initialize SPI and SD card.
- Mount filesystem, list files, select sample or preset.
- Open file, read data in chunks, feed to audio engine.

### 8.3 Reading Directory, Loading a Sample, and Error Checks

- Use file listing to build UI for sample/preset selection.
- Check all return codes from SD and FAT functions.
- Gracefully handle missing/corrupt files.

### 8.4 Saving Presets and Patch Data

- Open/create preset file in `/PRESETS/`.
- Write parameter values, mappings, and metadata.
- Flush and close file.

### 8.5 Sample Code for Streaming and Buffer Refill

- Use double buffering with interrupts or DMA.
- Start SD read for next buffer before current playback finishes.

### 8.6 Performance Benchmarks and Tuning Tips

- Test read speed (KB/s or sectors/ms) with large dummy files.
- Optimize SPI clock after init (up to 25MHz for most cards).
- Minimize filesystem overhead by caching FAT and directory sectors.

---

*End of Bare Metal Part. The next part will discuss minimal Linux-based SD card access, advanced filesystem features, and further optimization strategies.*