# Chapter 31: Optimization for Embedded Linux and Bare Metal  
## Part 2: Advanced Real-Time, Scheduling, Kernel Tweaks, Audio/MIDI Performance, and Troubleshooting

---

## Table of Contents

- 31.200 Kernel Configuration and Building for Real-Time Audio
  - 31.200.1 Choosing the Kernel: Mainline, LTS, RT-patched
  - 31.200.2 Essential Kernel Config Options
  - 31.200.3 Building and Deploying a Custom Kernel
  - 31.200.4 Kernel Modules, DKMS, and Out-of-Tree Drivers
- 31.201 Low-Latency Tuning: System, Kernel, and Application
  - 31.201.1 CPU Isolation and Affinity
  - 31.201.2 Disabling Power Management and C-States
  - 31.201.3 Memory Locking (mlock/rtkit), HugePages, and Cache Tuning
  - 31.201.4 IRQ Threading, Priorities, and Handling
  - 31.201.5 Tuning for USB Audio/MIDI and PCIe Audio Devices
- 31.202 Advanced Scheduling and Real-Time Guarantees
  - 31.202.1 SCHED_FIFO vs SCHED_RR vs SCHED_DEADLINE
  - 31.202.2 Priority Inversion and Avoiding Kernel Lock Contention
  - 31.202.3 Real-Time Process Capabilities: setrlimit, capabilities, and POSIX APIs
  - 31.202.4 Avoiding Common Pitfalls: Zombie Processes, CPU Starvation
- 31.203 MIDI and Audio Stack Internals
  - 31.203.1 ALSA Sequencer, RawMIDI, and Kernel MIDI Routing
  - 31.203.2 JACK Internals: Graph Management, Client Registration, XRUNs
  - 31.203.3 PipeWire and Modern Routing: Policies, Session Management
  - 31.203.4 Custom MIDI Drivers for Bare Metal
  - 31.203.5 Multi-client MIDI/Audio in Resource-Constrained Environments
- 31.204 Bare Metal Optimization: ISR, DMA, and Memory-Tight Audio
  - 31.204.1 Writing Ultra-Fast Interrupt Service Routines
  - 31.204.2 DMA for Audio: Setup, Ping-Pong Buffers, and Error Recovery
  - 31.204.3 Synthesizer Voice Scheduling Without an OS
  - 31.204.4 Memory Usage: Stack, Heap, and Static Allocation
  - 31.204.5 Measuring and Minimizing Cycles per Sample
- 31.205 IO, Filesystem, and Storage Tuning
  - 31.205.1 Mount Options, Journaling, and Sync
  - 31.205.2 Raw Device Access and Direct IO
  - 31.205.3 File Buffering, mmap, and Asynchronous IO
  - 31.205.4 Wear-Leveling, Bad Block Management, and Recovery
  - 31.205.5 Filesystem Corruption: Detection and Automated Repair
- 31.206 Debugging, Profiling, and Benchmarking Tools
  - 31.206.1 Tracing and Profiling: ftrace, perf, eBPF, SystemTap
  - 31.206.2 Real-Time Analysis: cyclictest, latencytop, rt-tests
  - 31.206.3 Measuring Audio Latency: jack_delay, alsa_delay, custom tools
  - 31.206.4 Bare Metal: Oscilloscope, Logic Analyzer, GPIO Timing
- 31.207 Example C Code: Kernel, Scheduling, MIDI/Audio, and Real-Time
  - 31.207.1 Setting SCHED_FIFO/SCHED_RR in User Audio Apps
  - 31.207.2 Real-Time ALSA and JACK Client Skeleton
  - 31.207.3 Bare Metal: ISR-Driven MIDI and Audio Loop
  - 31.207.4 Custom DMA Buffer Management
  - 31.207.5 Storage: Direct IO and Safe Recording
- 31.208 Appendices: Kernel Configs, Tuning Scripts, Audio Stack Diagrams, Latency Benchmarks

---

## 31.200 Kernel Configuration and Building for Real-Time Audio

### 31.200.1 Choosing the Kernel: Mainline, LTS, RT-patched

- **Mainline Kernel**:  
  - Best for most hardware compatibility and newest features.
  - Not fully real-time; suitable for general embedded use.
- **LTS (Long-Term Support)**:  
  - Maintained for years; safer for production devices.
  - Often the base for PREEMPT_RT patch sets.
- **RT-patched Kernel**:  
  - PREEMPT_RT patches mainline/LTS for true real-time scheduling.
  - Lower latency, required for pro audio and timing-critical MIDI.
  - Available from kernel.org or maintained by distributions (e.g., Debian RT, Ubuntu Studio).

### 31.200.2 Essential Kernel Config Options

```
CONFIG_PREEMPT_RT_FULL=y
CONFIG_HZ_1000=y
CONFIG_SND=y
CONFIG_SND_USB_AUDIO=y
CONFIG_SND_SOC=y
CONFIG_MLOCK=y
CONFIG_MEMCG=y
CONFIG_CGROUPS=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_IRQ_MULTI_HANDLER=y
CONFIG_NO_HZ_FULL=y
CONFIG_RCU_BOOST=y
```
- Enable ALSA/JACK, high-res timers, memory locking, and IRQ threading.
- For bare metal, skip most of these and focus on register-level IRQ, DMA.

### 31.200.3 Building and Deploying a Custom Kernel

- **Obtain Sources**:  
  - kernel.org, distribution source packages, or SoC vendor SDKs.
- **Configure**:  
  - `make menuconfig` or use defconfig as starting point; enable preemption, disable unneeded drivers.
- **Patch**:  
  - Apply PREEMPT_RT patch if needed.
- **Build**:  
  - Cross-compile for target architecture; e.g., `arm-linux-gnueabihf-`.
- **Deploy**:  
  - Copy kernel/zImage, DTB, and modules to target (SD, eMMC, TFTP, NFS).
- **Test**:  
  - Boot, run `uname -a`, check `/proc/config.gz` for config correctness.

### 31.200.4 Kernel Modules, DKMS, and Out-of-Tree Drivers

- **Kernel Modules**:  
  - For audio/MIDI hardware, use dynamic kernel modules (.ko); can be loaded/unloaded at runtime.
- **DKMS**:  
  - Dynamic Kernel Module Support; auto-recompiles modules on kernel upgrade (good for ALSA/JACK, custom boards).
- **Out-of-Tree Drivers**:  
  - External source trees (GitHub, vendor SDKs); maintain separate from kernel, update as needed.

---

## 31.201 Low-Latency Tuning: System, Kernel, and Application

### 31.201.1 CPU Isolation and Affinity

- **CPU Isolation**:  
  - Use kernel boot args: `isolcpus=2,3 nohz_full=2,3 rcu_nocbs=2,3` to dedicate CPU cores to audio threads.
- **CPU Affinity**:  
  - Use `taskset` or `pthread_setaffinity_np()` to pin real-time threads to isolated cores.
- **NUMA Considerations**:  
  - On multi-socket, ensure RAM is local to CPU handling audio.

### 31.201.2 Disabling Power Management and C-States

- **C-states**:  
  - Deeper CPU sleep = higher latency; disable via BIOS or kernel args: `intel_idle.max_cstate=1 processor.max_cstate=1`
- **Turbo, Frequency Scaling**:  
  - Disable or set to “performance” governor:  
    - `cpufreq-set -g performance`
    - `echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`

### 31.201.3 Memory Locking (mlock/rtkit), HugePages, and Cache Tuning

- **mlockall()**:  
  - Pins process memory; prevents paging/swapping.
    ```c
    #include <sys/mman.h>
    mlockall(MCL_CURRENT | MCL_FUTURE);
    ```
- **rtkit**:  
  - D-Bus service for raising thread priorities and locking memory in user apps.
- **HugePages**:  
  - Reduces TLB misses for large buffers; configure with `/proc/sys/vm/nr_hugepages`.
- **Cache Tuning**:  
  - Align audio buffers to cache lines; avoid cache-thrashing in DSP code.

### 31.201.4 IRQ Threading, Priorities, and Handling

- **IRQ Threading**:  
  - Linux RT: all IRQs are kernel threads, can set priorities via `/proc/irq/*/smp_affinity` and `rtirq` script.
- **Priorities**:  
  - Assign highest priority to audio/MIDI IRQs.
- **Handling**:  
  - Keep ISRs short; defer heavy processing to threaded context.

### 31.201.5 Tuning for USB Audio/MIDI and PCIe Audio Devices

- **USB**:  
  - Set `usbcore.autosuspend=-1` kernel arg; avoid USB hubs when possible.
  - Use high-quality cables, avoid "bus sharing" with other devices.
- **PCIe**:  
  - Remap IRQs if needed to avoid sharing with GPU/network.
- **Buffer Size**:  
  - Smallest buffer that doesn’t cause xruns; typically 32–256 samples for pro audio.

---

## 31.202 Advanced Scheduling and Real-Time Guarantees

### 31.202.1 SCHED_FIFO vs SCHED_RR vs SCHED_DEADLINE

- **SCHED_FIFO**:  
  - Runs until it blocks/yields; highest-priority gets CPU.  
  - Use with care; starvation possible if not balanced.
- **SCHED_RR**:  
  - Like FIFO, but gets a time slice; good for multiple audio clients.
- **SCHED_DEADLINE**:  
  - New RT scheduler; tasks declare runtime, period, deadline – kernel guarantees execution or logs missed deadlines.

### 31.202.2 Priority Inversion and Avoiding Kernel Lock Contention

- **Priority Inversion**:  
  - Low-priority thread holds lock needed by RT thread; use priority inheritance (mutexes), avoid global locks.
- **Lock Contention**:  
  - Minimize shared data, use lock-free queues, atomic ops where possible.

### 31.202.3 Real-Time Process Capabilities: setrlimit, capabilities, and POSIX APIs

- **setrlimit()**:  
  - Raise RLIMIT_RTPRIO, RLIMIT_MEMLOCK for user apps.
- **Capabilities**:  
  - `CAP_SYS_NICE` to set real-time priorities.
- **POSIX APIs**:  
  - Use `pthread_setschedparam()`, `sched_setscheduler()`.

### 31.202.4 Avoiding Common Pitfalls: Zombie Processes, CPU Starvation

- **Zombie Processes**:  
  - Always reap child threads; avoid fork() in RT code.
- **CPU Starvation**:  
  - Monitor with `top`, `htop`, `ps`; leave a core for housekeeping.
- **Watchdog**:  
  - Use a software/hardware watchdog in critical systems.

---

## 31.203 MIDI and Audio Stack Internals

### 31.203.1 ALSA Sequencer, RawMIDI, and Kernel MIDI Routing

- **ALSA Sequencer**:  
  - Kernel module for MIDI; supports multi-client, queueing, timestamping.
  - `/dev/snd/seq`, `/dev/snd/midiC*D*`
- **RawMIDI**:  
  - Lower-level, byte-stream MIDI; `/dev/snd/midi*`
- **Routing**:  
  - Use `aconnect`, `aseqnet` to route between apps, hardware, network.

### 31.203.2 JACK Internals: Graph Management, Client Registration, XRUNs

- **Graph**:  
  - JACK builds a graph of clients (apps, plugins, hardware); sample-accurate routing.
- **Registration**:  
  - Clients register ports; can be dynamically connected/disconnected.
- **XRUNs**:  
  - Buffer underrun/overrun; monitor with `jack_lsp`, `jack_iodelay`.

### 31.203.3 PipeWire and Modern Routing: Policies, Session Management

- **PipeWire**:  
  - Modern replacement for Pulse/JACK; session manager (WirePlumber), fine-grained policy, sandboxed clients.
- **Routing**:  
  - D-Bus API, dynamic graph, per-client permissions.

### 31.203.4 Custom MIDI Drivers for Bare Metal

- **UART/USART**:  
  - Set baud to 31250, 8N1; use ISR for RX, TX; buffer with circular queue.
- **Parsing**:  
  - Running status, real-time, Sysex, error recovery.
- **Timing**:  
  - Use hardware timer for MIDI clock, timestamping.

### 31.203.5 Multi-client MIDI/Audio in Resource-Constrained Environments

- **Message Queues**:  
  - Lock-free ring buffers for events.
- **Polling vs Interrupts**:  
  - Prefer interrupts for events, polling for status.

---

## 31.204 Bare Metal Optimization: ISR, DMA, and Memory-Tight Audio

### 31.204.1 Writing Ultra-Fast Interrupt Service Routines

- ISRs must:
  - Be as short as possible (ideally <10us on ARM/STM32).
  - Avoid printf, malloc, and blocking calls.
  - Use volatile for shared data; clear flags as early as possible.

#### Example:

```c
void DMA1_Stream0_IRQHandler(void) {
    // Clear DMA interrupt
    DMA1->LIFCR = DMA_LIFCR_CTCIF0;
    // Swap buffer, set flag
    audio_buffer_ready = 1;
    // Return
}
```

### 31.204.2 DMA for Audio: Setup, Ping-Pong Buffers, and Error Recovery

- **Setup**:  
  - Configure DMA for circular or double buffer.
- **Ping-Pong**:  
  - On DMA half/full complete, swap buffer pointers.
- **Error Recovery**:  
  - Check for DMA errors, reset DMA if needed.

### 31.204.3 Synthesizer Voice Scheduling Without an OS

- Use timer ISR for fixed-rate audio tick.
- In ISR, increment envelope, LFO, advance sample pointer, write to output buffer.
- No malloc/free in audio loop; all state statically or statically allocated.

### 31.204.4 Memory Usage: Stack, Heap, and Static Allocation

- **Stack**:  
  - Estimate max usage for deepest call; overflow = crash.
- **Heap**:  
  - Avoid in real-time code; use static or pre-allocated pools.
- **Static**:  
  - Allocate all audio/MIDI state at boot.

### 31.204.5 Measuring and Minimizing Cycles per Sample

- Use DWT cycle counter (Cortex-M), GPIO toggle, or logic analyzer.
- Optimize tight loops (audio, MIDI) with inline, unroll, and fixed-point math.

---

## 31.205 IO, Filesystem, and Storage Tuning

### 31.205.1 Mount Options, Journaling, and Sync

- **Mount Options**:  
  - `noatime`, `nodiratime`, `commit=1`, `barrier=0` for ext4.
  - For flash: `sync` (write-through), `async` (buffered).
- **Journaling**:  
  - Required for power safety; JFFS2/UBIFS for NAND, ext4 for SD/SSD.
- **fsync()**:  
  - Force data flush after critical writes (patches, samples).

### 31.205.2 Raw Device Access and Direct IO

- **Direct IO**:  
  - O_DIRECT flag for unbuffered writes/reads.
- **Raw Devices**:  
  - Use `/dev/sdX` or `/dev/mmcblkX` for direct access.

### 31.205.3 File Buffering, mmap, and Asynchronous IO

- **Buffering**:  
  - stdio (fread, fwrite) is buffered; can cause surprises in RT.
- **mmap()**:  
  - Map files into memory; good for large samples.
- **Async IO**:  
  - POSIX AIO, io_uring, or custom background thread.

### 31.205.4 Wear-Leveling, Bad Block Management, and Recovery

- **Wear-Leveling**:  
  - Managed by SD/eMMC controller, or by JFFS2/UBIFS for raw NAND.
- **Bad Block**:  
  - Mark and skip bad blocks; relocate data.
- **Recovery**:  
  - Auto-repair on boot, or fail-safe boot partition.

### 31.205.5 Filesystem Corruption: Detection and Automated Repair

- **Detection**:  
  - CRC, fsck, journal replay, boot-time checks.
- **Automated Repair**:  
  - Run fsck at boot; mount as read-only if error.

---

## 31.206 Debugging, Profiling, and Benchmarking Tools

### 31.206.1 Tracing and Profiling: ftrace, perf, eBPF, SystemTap

- **ftrace**:  
  - Kernel function tracing, latency measurement.
- **perf**:  
  - CPU cycles, cache misses, function call graph.
- **eBPF**:  
  - Attach probes to kernel/user-space, trace audio stack live.
- **SystemTap**:  
  - Scripting for kernel/user events.

### 31.206.2 Real-Time Analysis: cyclictest, latencytop, rt-tests

- **cyclictest**:  
  - Measures scheduler/IRQ latency (run with `-p95 -m -n -i200`).
- **latencytop**:  
  - Visualizes sources of latency in processes.
- **rt-tests**:  
  - Suite for measuring RT performance: `rt-migrate-test`, `hackbench`, `hwlatdetect`.

### 31.206.3 Measuring Audio Latency: jack_delay, alsa_delay, custom tools

- **jack_delay**:  
  - Loopback test for JACK clients.
- **alsa_delay**:  
  - Measures buffer and device latency.
- **Custom**:  
  - Use GPIO pulse or oscilloscope for end-to-end measurement.

### 31.206.4 Bare Metal: Oscilloscope, Logic Analyzer, GPIO Timing

- **Oscilloscope**:  
  - Measure output waveform, ISR timing.
- **Logic Analyzer**:  
  - Inspect MIDI, I2S, SPI, or GPIO activity.
- **GPIO**:  
  - Toggle pin at ISR entry/exit to measure latency.

---

## 31.207 Example C Code: Kernel, Scheduling, MIDI/Audio, and Real-Time

### 31.207.1 Setting SCHED_FIFO/SCHED_RR in User Audio Apps

```c
#include <sched.h>
struct sched_param sp;
sp.sched_priority = 95;
if (sched_setscheduler(0, SCHED_FIFO, &sp) == -1) perror("sched_setscheduler");
mlockall(MCL_CURRENT | MCL_FUTURE);
```

### 31.207.2 Real-Time ALSA and JACK Client Skeleton

```c
#include <jack/jack.h>
void process(jack_nframes_t nframes) {
    // Fill buffer...
}
int main() {
    jack_client_t* client = jack_client_open("rt_client", JackNullOption, NULL);
    jack_set_process_callback(client, process, 0);
    jack_activate(client);
    while (1) sleep(1);
}
```

### 31.207.3 Bare Metal: ISR-Driven MIDI and Audio Loop

```c
void USART1_IRQHandler(void) {
    uint8_t midi = USART1->DR;
    midi_ringbuf_push(midi);
}
void TIM6_DAC_IRQHandler(void) {
    for (int i = 0; i < VOICES; ++i) tick_voice(&voices[i]);
    output_to_dac(mix_voices(voices, VOICES));
}
```

### 31.207.4 Custom DMA Buffer Management

```c
#define AUDIO_BUFSZ 256
int16_t audio_buf[2][AUDIO_BUFSZ];
volatile int buf_idx = 0;

void dma_audio_isr() {
    buf_idx ^= 1;
    fill_audio(audio_buf[buf_idx], AUDIO_BUFSZ);
    start_dma(audio_buf[buf_idx], AUDIO_BUFSZ);
}
```

### 31.207.5 Storage: Direct IO and Safe Recording

```c
int fd = open("/dev/mmcblk0", O_WRONLY | O_DIRECT);
uint8_t block[512] __attribute__((aligned(512)));
write(fd, block, 512); // Minimal buffering, safe for RT
fsync(fd);
close(fd);
```

---

## 31.208 Appendices: Kernel Configs, Tuning Scripts, Audio Stack Diagrams, Latency Benchmarks

### 31.208.1 Example Kernel Boot Args

```
root=/dev/mmcblk0p2 rootwait rw quiet splash
isolcpus=2 nohz_full=2 rcu_nocbs=2
intel_idle.max_cstate=1 processor.max_cstate=1
usbcore.autosuspend=-1
```

### 31.208.2 IRQ Priority Tuning Script

```sh
#!/bin/sh
for irq in `cat /proc/interrupts | grep snd | awk '{print $1}' | sed 's/://g'`
do
    echo 99 > /proc/irq/$irq/priority
done
```

### 31.208.3 ALSA/JACK Audio Stack Diagram

```
[App (DAW, synth)] -> [JACK/ALSA] -> [Kernel driver] -> [DMA] -> [Codec] -> [Analog Out]
[MIDI In] -> [ALSA Seq/Raw] -> [App] -> [Synth Engine] -> [Audio Out]
```

### 31.208.4 Audio Latency Benchmarks (Extended)

| Platform          | Buffer (frames) | Kernel     | Latency (ms) | Notes               |
|-------------------|-----------------|------------|--------------|---------------------|
| ARM Cortex-A72    | 128             | RT Patch   | 2–3          | JACK, Pi 4          |
| STM32H7 BareMetal | 32              | None       | <0.5         | DMA + I2S           |
| x86_64 i7         | 64              | RT Patch   | <1           | PCIe audio, JACK    |
| Teensy 4.0        | 16              | None       | <0.2         | Audio lib           |

---

# END OF PART 2

*Continue to the next part for case studies, deployment, troubleshooting, or advanced bare metal strategies.*