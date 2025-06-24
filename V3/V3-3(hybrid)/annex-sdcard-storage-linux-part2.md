# Annex: Storing Data (Samples, Presets, etc.) on an External SD Drive — Minimal Linux Approach – Part 2

---

## Table of Contents

5. Real-Time Streaming and Sample Playback on Linux
    - Why streaming is different on Linux compared to bare metal
    - Avoiding blocking I/O in audio threads
    - Buffering strategies: double buffering, ring buffers, and prefetch
    - Using pthreads and asynchronous I/O (aio, poll, select)
    - Example: Real-time sample streaming code
6. Safe Writing, Preset Saving, and Data Integrity
    - Atomic file writes, temp files, and renaming
    - Syncing, flushing, and journaling for crash-safe storage
    - Handling power loss and unclean unmounts
    - Filesystem barriers, fsync, and storage guarantees
    - Error handling: ENOSPC, ENODEV, and recovery strategies
7. Organizing Samples and Presets on SD
    - Directory layout best practices for synth/sampler projects
    - Naming conventions, metadata, and index files
    - Handling large libraries and search/browse UI
    - Deletion, renaming, and garbage collection
    - Permissions and multi-user scenarios
8. Advanced Storage Features and Optimization
    - Using mmap for large files and fast random access
    - File locking, concurrency, and safe updates
    - Journaling and transactional updates
    - Using SQLite or other simple databases for patch management
    - Performance tuning: SD card class, filesystem mount options, caching
    - Monitoring storage health and handling wear-out

---

## 5. Real-Time Streaming and Sample Playback on Linux

### 5.1 Streaming on Linux vs. Bare Metal

- **Linux advantage:** Kernel handles SD card and filesystem access, giving higher-level APIs.
- **Linux challenge:** The kernel may block I/O to SD (especially with slow cards), risking audio dropouts if not handled properly.
- **Solution:** Separate real-time audio from file I/O using threads and buffering.

### 5.2 Avoiding Blocking I/O in Audio Threads

- **Never** call blocking I/O (fread, open, etc.) from your audio callback or real-time thread.
- Audio thread should only access pre-filled, in-memory buffers.
- Use a background thread to read sample data from SD and fill buffers.

### 5.3 Buffering Strategies

#### Double Buffering

- Two buffers: one played, one filled from SD.
- When play buffer is empty, swap and refill.

#### Ring Buffer (Circular Buffer)

- Large buffer in RAM, producer thread fills, audio thread consumes.
- Ensures smooth playback even if SD read is slightly delayed.

#### Prefetching

- Predict which sample data will be needed next and read ahead.
- Good for fast patch changes, sample preview, or large multi-sample playback.

### 5.4 Using Pthreads and Async I/O

- Use `pthread_create` to spin up a dedicated SD/file I/O thread.
- Use mutexes or lock-free techniques to manage buffer access.
- For advanced use, consider Linux’s `aio_read`/`aio_write` (asynchronous I/O) or `epoll`/`select` for event-driven file access.

#### Example: Threaded Buffer Fill Skeleton

```c
#include <pthread.h>
#define BUF_SIZE 4096
uint8_t audio_buf[2][BUF_SIZE];
int buf_ready[2] = {0, 0};
pthread_mutex_t buf_mutex = PTHREAD_MUTEX_INITIALIZER;

void *buffer_fill_thread(void *arg) {
    FILE *fp = (FILE*)arg;
    while (1) {
        for (int i = 0; i < 2; ++i) {
            pthread_mutex_lock(&buf_mutex);
            if (!buf_ready[i]) {
                size_t n = fread(audio_buf[i], 1, BUF_SIZE, fp);
                buf_ready[i] = (n > 0);
            }
            pthread_mutex_unlock(&buf_mutex);
        }
        usleep(1000);
    }
}
```

Audio thread only reads from `audio_buf` if `buf_ready` is set.

### 5.5 Example: Real-Time Sample Streaming Code

#### Skeleton for Audio + File Thread Coordination

```c
// In main thread:
pthread_t th;
FILE *fp = fopen("/mnt/sdcard/samples/BASSGTR2.RAW", "rb");
pthread_create(&th, NULL, buffer_fill_thread, (void*)fp);

// In audio callback:
int play_buf = ...; // which buffer to use
if (buf_ready[play_buf]) {
    // Copy BUF_SIZE samples to output
    // Mark buf_ready[play_buf] = 0 after consuming
}
```
- Use condition variables or semaphores for more robust synchronization.
- Always handle buffer underrun (output silence or repeat last data).

---

## 6. Safe Writing, Preset Saving, and Data Integrity

### 6.1 Atomic File Writes and Temp Files

- Write new preset/sample to a temp file (e.g., `PATCH1.PST.tmp`).
- After writing and closing, rename to final name (`rename()` is atomic on POSIX filesystems).
- Prevents corruption if power loss during write.

### 6.2 Syncing and Flushing

- Always call `fflush()` and `fsync(fileno(fp))` after writing to ensure data is on SD, not just in kernel cache.
- Only after successful flush/sync should you rename the file.

### 6.3 Journaling and Crash-Safe Storage

- Journaling filesystems (ext4, btrfs) protect metadata, but data integrity needs atomic file replacement as above.
- FAT/exFAT do not journal—extra care needed (temp files, sync, clean shutdown).

### 6.4 Handling Power Loss and Unclean Unmounts

- Always unmount (`umount`) or use `sync` before removing power or SD card.
- On boot, check for incomplete temp files and clean up/recover.

### 6.5 Filesystem Barriers, fsync, and Storage Guarantees

- `fsync` ensures data is written to physical SD.
- Without fsync, data may be lost on power loss even if the file is closed.
- For critical data (presets, user samples), always fsync.

### 6.6 Error Handling

- Check all return codes from file I/O.
- Handle disk full (`ENOSPC`), device missing (`ENODEV`), or I/O errors (`EIO`).
- Inform user (LED, display, log) if a save fails or SD is missing.

---

## 7. Organizing Samples and Presets on SD

### 7.1 Directory Layout Best Practices

- Use separate directories for samples, presets, banks:
    - `/mnt/sdcard/samples/`
    - `/mnt/sdcard/presets/`
    - `/mnt/sdcard/banks/`
- Consider subdirectories for categories, user banks, or multi-sample sets.

### 7.2 Naming Conventions and Metadata

- Use unique, descriptive filenames.
- For bank/preset metadata, use sidecar files (e.g., `PATCH1.PST`, `PATCH1.META`) or embed info in the sample/preset format.
- Use extensions recognized by your synth (e.g., `.RAW`, `.WAV`, `.PST`).

### 7.3 Handling Large Libraries and UI Search

- Index large libraries with a manifest file or database (see below).
- Paginate UI lists for thousands of files.
- Use search/filter in synth UI for fast patch/sample selection.

### 7.4 File Deletion, Renaming, and Garbage Collection

- Use `remove()` and `rename()` for file management.
- For large deletes, background thread may be needed to avoid blocking UI/audio.
- Garbage collection: Optionally scan for orphaned files and offer cleanup.

### 7.5 Permissions and Multi-User Scenarios

- For desktop Linux, set appropriate permissions (`chmod`, `chown`) so synth and user can both access files.
- For embedded, run synth as root or dedicated user with full SD access.

---

## 8. Advanced Storage Features and Optimization

### 8.1 Using mmap for Large Files

- `mmap()` can map files directly into memory; useful for random access to large samples.
- Be careful: SD cards are slow, and page faults can cause latency.

#### Example: Memory-Mapping a File

```c
#include <sys/mman.h>
int fd = open("/mnt/sdcard/samples/LONGSAMP.RAW", O_RDONLY);
size_t len = ...;
void *addr = mmap(NULL, len, PROT_READ, MAP_PRIVATE, fd, 0);
if (addr == MAP_FAILED) { perror("mmap"); }
```

### 8.2 File Locking, Concurrency, and Safe Updates

- Use `flock()` for exclusive file access if multiple processes may write.
- Lock files before writing presets, releasing after.
- For single-user synths, this is rarely needed, but useful for advanced setups.

### 8.3 Journaling and Transactional Updates

- For critical config/patch info, use journaling or transactional update logic:
    - Write to temp, fsync, rename.
    - Keep backup copies.

### 8.4 Using SQLite or Simple Databases

- For huge patch/sample libraries, a simple database (SQLite) can index and store metadata.
- Store patch names, tags, locations, and parameters.
- Database lives on SD card, can be queried for fast UI/search.

#### Example: SQLite Table for Patches

```sql
CREATE TABLE patches (
    id INTEGER PRIMARY KEY,
    name TEXT,
    filename TEXT,
    category TEXT,
    created_at DATETIME
);
```

- Use C libraries (`sqlite3`) to query and update.

### 8.5 Performance Tuning

- Use high-quality SD cards (Class 10, UHS-I/II) for fast, reliable access.
- Mount with `noatime` to reduce SD write wear.
- Monitor free space and warn before writes.

### 8.6 Monitoring Storage Health

- Periodically check SD card for errors (`fsck`, SMART for USB SD readers).
- Log and notify user of write failures or slowdowns.

---

## 9. Summary and Further Reading

- Linux simplifies SD storage for embedded synths, but real-time streaming still requires careful design.
- Use threads and buffering to separate I/O from audio.
- Always check and fsync writes, especially for presets and user data.
- Consider databases or manifest files for large libraries.
- Use proper mount options and SD card quality for best performance.

**Further Reading:**
- “Linux Device Drivers” by Jonathan Corbet
- “The Linux Programming Interface” by Michael Kerrisk
- FatFs documentation: https://elm-chan.org/fsw/ff/00index_e.html
- SQLite documentation: https://www.sqlite.org/
- ALSA and PortAudio docs (for audio streaming)
- Raspberry Pi, BeagleBone, and embedded Linux forums for SD hardware quirks

---

*End of SD Card Storage Annex (Linux approach). This concludes the deep-dive on both bare-metal and Linux strategies for robust, efficient, and musician-friendly data storage in embedded synth/sampler projects.*