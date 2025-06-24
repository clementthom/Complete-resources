# Annex: Storing Data (Samples, Presets, etc.) on an External SD Drive — Bare Metal Approach – Part 1

---

## Table of Contents

1. Introduction: Why and How to Store Data Externally
    - The need for mass storage in samplers and synths
    - Emulator III/Emax inspiration: architecture and workflow
    - Challenges in embedded systems (especially bare metal)
    - Overview of SD card technology and interfaces
2. SD Card Technology: Principles and Protocols
    - SD card basics: structure, memory cells, blocks, wear leveling
    - Physical and electrical interface: SPI vs. SDIO
    - SD card commands and initialization sequence
    - Data transfer: blocks, sectors, and addressing
    - MicroSD cards: differences and compatibility
3. Electronic/Embedded Hardware Implementation
    - Wiring SD cards to microcontrollers and Raspberry Pi
    - Voltage levels, power supply, and protection
    - SPI bus: pinout, signals, and multiplexing
    - Example circuits: pull-ups, level shifters, decoupling
    - SD card sockets and ESD precautions
4. Bare-Metal SD Card Driver in C: Foundations
    - SPI initialization for bare-metal access
    - Sending SD card commands (CMD0, CMD8, ACMD41, CMD58, etc.)
    - Card initialization state machine
    - Reading and writing single/multiple blocks
    - Handling timeouts, errors, and retries

---

## 1. Introduction: Why and How to Store Data Externally

### 1.1 The Need for Mass Storage

- **Samples, presets, and user data** can easily exceed on-chip flash or RAM.
- Classic samplers (Emulator III, Emax) used floppy drives or SCSI HDDs for large sample banks.
- Modern SD cards are compact, affordable, and offer gigabytes of storage — ideal for embedded synths.

### 1.2 Emulator III/Emax Inspiration

- These instruments stored samples, presets, and firmware on removable media.
- System used a custom filesystem and sector-based access for speed and reliability.
- Fast load/save, patch management, and user sample import/export were key features.

### 1.3 Embedded Challenges (Especially Bare Metal)

- No OS: must implement all storage logic, error handling, and file management in C.
- SD cards use complex protocols and require careful timing and error checking.
- Filesystem management (FAT/exFAT) is nontrivial and often needs a library.
- Real-time audio needs fast, deterministic access to data (e.g., streaming samples).

### 1.4 Overview of SD Card Technology

- **SD cards** are block devices (like hard drives), accessed in 512-byte sectors.
- Support two main protocols: **SPI** (easy, universal) and **SDIO** (faster, more complex).
- Most microcontrollers (and Pi bare metal) use SPI for simplicity.

---

## 2. SD Card Technology: Principles and Protocols

### 2.1 SD Card Basics

- **Physical layers:** Full-size SD, miniSD, microSD (all electrically similar).
- **Capacity classes:** Standard (SDSC, up to 2GB), High Capacity (SDHC, up to 32GB), Extended (SDXC, up to 2TB).
- **Block device:** Reads/writes in fixed-size 512-byte sectors (“blocks”).
- **Wear leveling:** Managed internally by card controller; avoid excessive writes.

### 2.2 Memory Structure

- Organized in blocks and pages.
- Each block: typically 512 bytes (sector).
- Cards may have erase blocks (larger units) and internal cache.

### 2.3 Physical and Electrical Interface

#### SPI Mode (Most Common for Bare Metal)

- **Pins:** CS (chip select), SCK (clock), MOSI (master out, slave in), MISO (master in, slave out), VCC, GND.
- **Voltage:** Most cards are 3.3V; use level shifter if MCU is 5V.
- **Speed:** Up to 25MHz, but start at low speed (100–400kHz) for initialization.

#### SDIO Mode

- Parallel data lines (DAT0–3), higher speeds.
- Not recommended for simple bare-metal designs.

### 2.4 SD Card Commands and Initialization Sequence

#### Key Commands (in SPI mode):

- **CMD0**: GO_IDLE_STATE (reset, enter SPI mode)
- **CMD8**: SEND_IF_COND (voltage check)
- **CMD55**: APP_CMD (prefix for ACMD)
- **ACMD41**: SD_SEND_OP_COND (initiate initialization)
- **CMD58**: READ_OCR (read operation conditions register)
- **CMD16**: SET_BLOCKLEN (set block length; must be 512 bytes for SDHC/SDXC)
- **CMD17**: READ_SINGLE_BLOCK
- **CMD24**: WRITE_BLOCK

#### Initialization Summary

1. Power up, provide 74+ clock cycles with CS high.
2. Send CMD0 to reset and enter SPI mode.
3. Send CMD8 to check voltage range (for SDHC/SDXC).
4. Repeat CMD55 + ACMD41 until card is ready (returns 0x00).
5. Send CMD58 to read OCR (check capacity).
6. For SDHC/SDXC, always use 512-byte blocks.

### 2.5 Data Transfer

- **Read:** Issue CMD17, then read 512 bytes after receiving start token (0xFE).
- **Write:** Issue CMD24, send start token (0xFE), then 512 bytes + CRC (dummy for most cards).
- **Multi-block:** Can use CMD18/CMD25 for faster sequential transfers.

---

## 3. Electronic/Embedded Hardware Implementation

### 3.1 Wiring SD Cards to Microcontrollers and Pi

- Connect SD card pins to MCU’s SPI interface.
- Use voltage dividers or IC level shifters for 5V MCUs.
- Capacitors (0.1uF) close to power pins for stability.

#### Example: SPI Wiring Table

| SD Card Pin | SPI Pin (MCU/Pi) | Notes                 |
|-------------|------------------|-----------------------|
| 1 (CS)      | SPI CS (chip select) | Pull-up to 3.3V (10k) |
| 2 (MOSI)    | SPI MOSI         |                       |
| 3 (VSS)     | GND              |                       |
| 4 (VDD)     | 3.3V             | Decoupling cap        |
| 5 (SCK)     | SPI SCK          |                       |
| 6 (MISO)    | SPI MISO         | Pull-up to 3.3V (10k) |
| 7 (NC)      | —                | Not connected         |
| 8 (NC)      | —                | Not connected         |

### 3.2 Voltage Levels, Power Supply, and Protection

- SD cards are **NOT 5V tolerant**; use 3.3V logic.
- Use LDO regulator if 3.3V rail is not sufficient.
- Level shifters: TXB0104, resistor dividers (for low speed), or discrete MOSFETs.
- Protect against ESD: avoid handling card with power applied.

### 3.3 SPI Bus: Pinout, Signals, and Multiplexing

- Multiple SPI devices: only one CS low at a time.
- Beware of shared bus speeds (SD card may need lower speeds than other peripherals).
- Keep SPI traces short and well-routed.

### 3.4 Example Circuits

- **Pull-ups:** 10k pull-up resistors on CS and MISO recommended.
- **Decoupling:** 0.1uF ceramic cap close to VDD and GND.
- **Socket:** Use push-push or hinged SD card socket for reliability.

### 3.5 SD Card Sockets and ESD Precautions

- Always power down before inserting/removing card (or use hot-swap tolerant hardware).
- Use ESD-rated sockets for robustness in field units.

---

## 4. Bare-Metal SD Card Driver in C: Foundations

### 4.1 SPI Initialization for Bare-Metal Access

- Configure SPI peripheral for:
    - CPOL=0, CPHA=0 (mode 0)
    - Start at 100–400kHz, increase after init
    - 8-bit transfers
- Set CS high before init, low when communicating.

#### Example: Pseudocode (STM32/Pi Pico style C)

```c
void spi_init() {
    // Set SPI clock to 100kHz
    // Configure MOSI, MISO, SCK, CS as outputs/inputs
    // Enable SPI peripheral
}
```

### 4.2 Sending SD Card Commands

- Each command: 6 bytes (start + command + argument + CRC)
- Always deselect card (CS high), send 8 clocks, then select (CS low) before command.
- Read response (R1, R3, etc.)

#### Example: Command Packet

| Byte | Purpose         |
|------|----------------|
| 0    | 0x40 | CMD index (CMD0 = 0x40, CMD8 = 0x48, etc.) |
| 1-4  | Argument (MSB first) |
| 5    | CRC (valid for CMD0/CMD8, dummy 0xFF otherwise)   |

#### Example: Sending CMD0

```c
uint8_t cmd[6] = {0x40 | 0, 0, 0, 0, 0, 0x95}; // CMD0, correct CRC
spi_cs_low();
spi_send(cmd, 6);
resp = spi_wait_for_response();
spi_cs_high();
```

### 4.3 Card Initialization State Machine

- Power up, send 80 clocks with CS high.
- CMD0: go idle.
- CMD8: check for SDHC/voltage.
- Loop: CMD55 + ACMD41 until card ready.
- CMD58: read OCR for card type.

#### Example: C Pseudocode

```c
void sd_init() {
    spi_cs_high();
    spi_clock(80); // send 80 clocks with CS high
    send_cmd(CMD0, 0, 0x95);
    send_cmd(CMD8, 0x1AA, 0x87);
    // Loop: CMD55 + ACMD41 until ready
    // Check response, set flags for SDHC/SDXC
}
```

### 4.4 Reading and Writing Blocks

#### Reading a Block (CMD17)

1. Send CMD17 with block address.
2. Wait for start token (0xFE).
3. Read 512 bytes data + 2 bytes CRC.

#### Writing a Block (CMD24)

1. Send CMD24 with block address.
2. Send start token (0xFE).
3. Write 512 bytes data + 2 bytes CRC.
4. Wait for data response token (should be 0x05).
5. Wait for card to finish (busy signal = 0).

### 4.5 Handling Timeouts, Errors, and Retries

- Always add timeouts to SPI waits (don’t hang indefinitely).
- Retry commands on CRC/data errors (max N times).
- Handle card removal/insertion detection (if supported).

---

*End of Part 1. Part 2 will cover: implementing a minimal FAT16/FAT32 filesystem, sample/preset storage strategies, streaming large files, directory management, error handling, and real-world code examples. Linux-based solutions will be discussed in a separate part.*