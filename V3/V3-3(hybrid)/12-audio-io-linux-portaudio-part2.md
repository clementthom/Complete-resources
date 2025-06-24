# Chapter 12: Audio I/O on Linux with PortAudio – Part 2

---

## Table of Contents

6. Advanced Callback Design and Audio Processing
    - Audio callback structure and thread safety
    - Integrating your synth engine into the callback
    - Buffer management, circular/ring buffers
    - Multi-channel and multi-stream support
    - Mixing, panning, and basic DSP in the callback
7. Synchronizing MIDI and Audio (Timing and Real-Time)
    - MIDI event handling in real-time contexts
    - MIDI-to-audio scheduling and latency sources
    - Threading models: single-thread vs. producer-consumer
    - Timestamping and scheduling notes/events
    - Handling MIDI input with PortMidi/RtMidi alongside PortAudio
8. Low-Latency Tuning for Synths on Linux and Raspberry Pi
    - Kernel and OS tuning: preempt-rt, priorities, CPU isolation, etc.
    - PortAudio and ALSA buffer/period parameters
    - Real-time thread priorities, stack size, and SCHED_FIFO
    - Measuring and minimizing round-trip latency
    - Benchmarking and troubleshooting xruns/underruns
9. Troubleshooting and Debugging Audio I/O
    - Audio device enumeration and quirks (USB, I2S, onboard, etc.)
    - Diagnosing no-sound, glitches, and distortion
    - Handling device disconnects and hot-plugging
    - Using ALSA/PortAudio diagnostic tools
    - Scripting and logging for automated tests
10. Exercises and Projects
    - Building a simple synth or audio effect with PortAudio
    - Measuring latency and buffer sizes practically
    - Implementing a real-time audio/MIDI test harness
    - Exploring multi-device and multi-client setups

---

## 6. Advanced Callback Design and Audio Processing

### 6.1 Audio Callback Structure and Thread Safety

- **The audio callback is real-time critical.**
    - It is called by a high-priority thread in the audio backend.
    - Must complete quickly, avoid blocking (no disk/network I/O, no locks, no malloc/free).
    - Any shared data (e.g. GUI controls, MIDI buffers) must use lock-free or atomic techniques.

**Callback prototype:**
```c
int audioCallback(const void *input, void *output,
                  unsigned long frameCount,
                  const PaStreamCallbackTimeInfo* timeInfo,
                  PaStreamCallbackFlags statusFlags,
                  void *userData);
```
- **input/output**: Buffers for audio in/out (may be NULL).
- **frameCount**: Number of frames (samples per channel) to process.
- **userData**: Pointer to your synth state, voice array, etc.

#### Best Practices:

- Pre-allocate all memory.
- Avoid global variables unless they are read-only or atomic.
- Use lock-free queues (ring buffers) to communicate with non-audio threads.
- Consider double-buffering for MIDI/event queues.

### 6.2 Integrating Your Synth Engine Into the Callback

- The callback should pull MIDI/events from a thread-safe buffer and advance your synth engine state.
- Render audio into the output buffer, one frame at a time, per channel.

**Example:**
```c
int audioCallback(const void *input, void *output,
                  unsigned long frameCount,
                  const PaStreamCallbackTimeInfo *timeInfo,
                  PaStreamCallbackFlags statusFlags,
                  void *userData)
{
    SynthState *synth = (SynthState*)userData;
    float *out = (float*)output;

    for (unsigned long i = 0; i < frameCount; ++i) {
        // 1. Pull and apply MIDI/events for this frame
        process_midi_events(synth, i);

        // 2. Synthesize one sample per channel
        float left, right;
        synth_render_sample(synth, &left, &right);

        // 3. Write to output
        out[2*i] = left;
        out[2*i+1] = right;
    }
    return paContinue;
}
```

### 6.3 Buffer Management, Circular/Ring Buffers

- Use circular/ring buffers for:
    - MIDI input (from main/UI thread to audio thread)
    - Audio output (for analysis, logging, or multi-client output)
- Use atomic read/write pointers or lock-free libraries for thread safety.
- Tune buffer size for worst-case event bursts without overflow.

### 6.4 Multi-Channel and Multi-Stream Support

- PortAudio supports mono, stereo, and multichannel (e.g., 4/6/8/16) audio.
- Use correct `channelCount` in `PaStreamParameters`.
- Interleaved (default) vs. non-interleaved (planar) buffer layouts.
- For multi-stream (e.g., separate output for headphones/line-out), open multiple streams or use a mixing matrix inside your callback.

### 6.5 Mixing, Panning, and Basic DSP in the Callback

- Apply gain, pan, and simple effects (EQ, filter, delay, etc.) in the callback.
- For more complex DSP (FFT, convolution), ensure computation fits in the available buffer time.
- Use SIMD intrinsics or optimized DSP libraries if CPU is a bottleneck.

---

## 7. Synchronizing MIDI and Audio (Timing and Real-Time)

### 7.1 MIDI Event Handling in Real-Time Contexts

- MIDI can arrive asynchronously (from USB, serial, or ALSA).
- Use a ring buffer to collect MIDI events in the main/UI thread.
- Audio callback pulls all MIDI events with timestamps <= current audio frame.

### 7.2 MIDI-to-Audio Scheduling and Latency Sources

- **Sources of latency:**
    - MIDI hardware and OS buffering
    - PortAudio/ALSA buffer size
    - Synth engine event scheduling
- **Goal:** Keep total latency (MIDI-in to audio-out) below 10–15ms for good playability.

### 7.3 Threading Models: Single-Thread vs Producer-Consumer

- **Single-thread:** All audio and MIDI processed in one callback (simple, but must poll MIDI frequently).
- **Producer-consumer:** Separate MIDI thread feeds events into a ring buffer read by the audio callback (preferred for complex synths).

### 7.4 Timestamping and Scheduling Notes/Events

- Timestamp MIDI events when received.
- Schedule events for the correct sample frame in the audio callback.
- For tight sync with external MIDI/clock, use ALSA’s sequencer timestamps if available.

### 7.5 Handling MIDI Input with PortMidi/RtMidi Alongside PortAudio

- PortMidi and RtMidi are cross-platform MIDI I/O libraries.
- Use their polling APIs to collect events in the main thread.
- Push events into a ring buffer for the audio callback.

---

## 8. Low-Latency Tuning for Synths on Linux and Raspberry Pi

### 8.1 Kernel and OS Tuning

- Use a real-time kernel (`preempt-rt`) if possible.
- Add your user to the `audio` group.
- Set `ulimit -r unlimited` and increase `memlock` limits.
- Use `chrt` or `schedtool` to set your process to `SCHED_FIFO` or `SCHED_RR`.
- Isolate CPUs (`isolcpus=3` in /boot/cmdline.txt) for audio thread.

### 8.2 PortAudio and ALSA Buffer/Period Parameters

- ALSA backend allows explicit control over buffer and period size.
- Prefer power-of-two buffer sizes.
- Test for lowest stable buffer size without xruns (try 128 or 64 at 48kHz).

### 8.3 Real-Time Thread Priorities, Stack Size, and SCHED_FIFO

- Audio callback runs in a high-priority thread.
- Set stack size large enough for processing needs (default is often sufficient).
- Don’t perform blocking calls or long computations in audio thread.

### 8.4 Measuring and Minimizing Round-Trip Latency

- Use `jack_delay` or a loopback cable to measure input→output latency.
- Try different buffer sizes, experiment with thread priorities.
- Monitor xrun counts and CPU usage.

### 8.5 Benchmarking and Troubleshooting Xruns/Underruns

- Use PortAudio’s return codes to log xruns.
- Monitor system logs (`dmesg`, `journalctl`) for ALSA errors.
- Use `htop` to watch CPU usage by core.

---

## 9. Troubleshooting and Debugging Audio I/O

### 9.1 Audio Device Enumeration and Quirks

- List devices with `Pa_GetDeviceCount()`, `Pa_GetDeviceInfo()`.
- Some devices (USB, HDMI, I2S) may require different sample rates or formats.
- Devices may appear/disappear with hot-plug—handle gracefully.

### 9.2 Diagnosing No-Sound, Glitches, and Distortion

- Check all PortAudio/ALSA return codes and error messages.
- Ensure correct channel count, sample format, and buffer size.
- Mismatched sample rates can cause pitch/speed errors.

### 9.3 Handling Device Disconnects and Hot-Plugging

- PortAudio streams may abort if device is disconnected.
- Monitor stream status and re-enumerate devices on error.
- Consider restarting streams on device change.

### 9.4 Using ALSA/PortAudio Diagnostic Tools

- `aplay -l`, `arecord -l` list devices.
- `alsamixer` to check volume/mute.
- Enable PortAudio debug output (`export PA_DEBUG=1`).
- Use PortAudio’s `Pa_GetLastHostErrorInfo()` for backend-specific errors.

### 9.5 Scripting and Logging for Automated Tests

- Use shell/Python scripts to run synth with various devices, buffer sizes.
- Log errors, buffer underruns, latency.
- Integrate with CI/CD for regression testing.

---

## 10. Exercises and Projects

1. **Build a simple synth or audio effect with PortAudio:**
    - Start from sine wave, add envelope, filter, and LFO.
    - Experiment with buffer size and observe latency changes.
2. **Measure latency and buffer sizes practically:**
    - Use a loopback cable and test signals to measure input→output delay.
    - Document your results with different audio devices.
3. **Implement a real-time audio/MIDI test harness:**
    - Integrate PortAudio (audio) and RtMidi/PortMidi (MIDI).
    - Log timing of MIDI-in to audio-out events.
4. **Explore multi-device and multi-client setups:**
    - Try running your synth with JACK and connect to multiple outputs.
    - Route audio to different devices/channels.

---

## 11. Summary and Further Reading

- PortAudio is a powerful, flexible tool for cross-platform audio I/O.
- Real-time audio programming requires careful design, thread safety, and OS tuning.
- Combine PortAudio with MIDI libraries for full synth interactivity.
- Always test and tune for latency, buffer overruns, and device quirks on your target platform.

**Further Reading & Tools:**
- “Audio Programming Book” by Richard Boulanger & Victor Lazzarini
- PortAudio documentation: http://www.portaudio.com/docs/
- “Designing Audio Effect Plug-Ins in C++” by Will Pirkle
- ALSA and JACK project docs
- Linux Audio Wiki: https://wiki.linuxaudio.org/
- Real-time Linux guides (rt.wiki.kernel.org)

---

*End of Chapter 12. Next: Testing, Debugging, and Simulation (deep dive into validation, test harnesses, simulation tools, and real-world troubleshooting for embedded synths).*