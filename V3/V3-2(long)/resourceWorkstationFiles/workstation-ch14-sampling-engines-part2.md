# Chapter 14: Sampling Engines — Recording, Editing, and Playback  
## Part 2: Sample Editing, Playback Engines, Mapping, Live Sampling, and Performance Integration

---

## Table of Contents

- 14.7 Introduction: From Raw Audio to Playable Instrument
- 14.8 Sample Editing: Tools, Algorithms, and Workflow
  - 14.8.1 Trim, Cut, Copy, Paste, and Normalize
  - 14.8.2 Fade In/Out, Crossfade, DC Offset, Silence
  - 14.8.3 Slicing: Manual, Auto (Transient, Grid, BPM), and Slices as Zones
  - 14.8.4 Time-Stretch, Pitch-Shift, and Resample
  - 14.8.5 Reverse, Scrub, and Non-Destructive Editing
  - 14.8.6 Batch Processing, Undo, and Redo
  - 14.8.7 Sample Editing UI: Waveform, Markers, Zoom, and Hardware Controls
- 14.9 Playback Engines: Pitch, Time, Granular, and Polyphony
  - 14.9.1 Basic Playback: One-Shot, Looped, Keytracking
  - 14.9.2 Pitch Transpose: Interpolation, Key Follow, and Root Note
  - 14.9.3 Time-Stretching Algorithms: Granular, Phase Vocoder, Slicing
  - 14.9.4 Granular Playback: Grain Size, Density, Position, Jitter
  - 14.9.5 Multisample and Zone Playback: Velocity, Round Robin, Articulation
  - 14.9.6 Polyphony, Voice Allocation, and Voice Stealing
  - 14.9.7 Streaming Large Samples: Buffering, Prefetch, and Dropout Handling
- 14.10 Advanced Mapping, Modulation, and Parameter Locks
  - 14.10.1 Key/Velocity/Zone Mapping: UI, Data Structures, and Editing
  - 14.10.2 Modulation Sources: Envelopes, LFOs, Random, Velocity, MIDI, CV
  - 14.10.3 Pitch and Filter Envelopes, AHDSR, Multi-Segment
  - 14.10.4 Sample Start/End/Loop Modulation
  - 14.10.5 Parameter Locks and Per-Step Automation in Samplers
  - 14.10.6 Macro Controls, Morphing, Scenes, and Performance Sets
- 14.11 Live Sampling, Resampling, and Performance Features
  - 14.11.1 Live Sampling Workflow: Recording on the Fly, Overdub, Replace
  - 14.11.2 Resampling: Internal Bus, FX, and Pattern Capture
  - 14.11.3 Auto-Chop, Auto-Slice, and Instant Mapping to Pads/Keys
  - 14.11.4 Live Loopers: Overdub, Undo, Redo, Quantize, Sync
  - 14.11.5 Performance FX: Stutter, Reverse, Glitch, Slice FX
  - 14.11.6 Sampler Integration with Sequencer and FX Engines
- 14.12 Performance, UI, and Storage Optimization
  - 14.12.1 Audio Buffer Management for Low Latency and Streaming
  - 14.12.2 Storage Access Patterns: SD, NAND, Flash, USB
  - 14.12.3 CPU and DSP Load: Prioritization and Dropout Handling
  - 14.12.4 Sample Pool Management, Preload, and Caching
  - 14.12.5 Smart Sample Unloading and Reference Counting
  - 14.12.6 Battery/Power Considerations for Portable Samplers
- 14.13 Glossary and Reference Tables

---

## 14.7 Introduction: From Raw Audio to Playable Instrument

Turning raw audio into expressive, playable instruments is the core of sampling.  
Modern sampling engines must support:
- Deep, non-destructive editing
- High-quality time/pitch manipulation
- Advanced mapping and modulation
- Low-latency streaming and performance features
- Seamless integration with sequencer and FX

This section is a **detailed, exhaustive, and beginner-friendly reference** for all aspects of sample editing, playback, mapping, and performance integration.

---

## 14.8 Sample Editing: Tools, Algorithms, and Workflow

### 14.8.1 Trim, Cut, Copy, Paste, and Normalize

- **Trim:** Set precise start/end points, remove silence or noise
- **Cut:** Delete selected range of audio (zero or crossfade at edges to avoid clicks)
- **Copy/Paste:** Duplicate or move sections; may support clipboard/history
- **Normalize:** Scale audio so peak is at max level (0dBFS), optional RMS normalization

#### 14.8.1.1 Trim/Normalize Workflow

1. Zoom to transient or region of interest.
2. Set start marker at first significant peak, end marker at last.
3. Apply trim (non-destructive if possible).
4. Normalize to -1dBFS (or user target).
5. Preview and undo if needed.

### 14.8.2 Fade In/Out, Crossfade, DC Offset, Silence

- **Fade In/Out:** Apply linear, exponential, or custom fade curves at start/end or anywhere
- **Crossfade:** Smooth transition between regions (e.g., for seamless loops)
- **DC Offset Removal:** Subtract mean value to center waveform at zero
- **Silence:** Insert or replace region with zeroed samples

#### 14.8.2.1 Crossfade Loop Example

- Select loop region, set overlap, apply crossfade to overlap for smooth sustain

### 14.8.3 Slicing: Manual, Auto (Transient, Grid, BPM), and Slices as Zones

- **Manual Slicing:** User sets slice markers (transients, beats, onsets)
- **Auto Slicing:** Detect transients (energy, zero-crossing, spectral flux), or slice by grid (1/8, 1/16), or BPM
- **Slices as Zones:** Each slice can be mapped to pad/key, edited individually, or rearranged

#### 14.8.3.1 Auto-Slice Algorithm

1. Calculate energy envelope or onset strength.
2. Find peaks above threshold or at regular intervals.
3. Place slice markers at those points.

### 14.8.4 Time-Stretch, Pitch-Shift, and Resample

- **Time-Stretch:** Change speed without affecting pitch
  - **Granular:** Overlap small grains, adjust playback pointer
  - **Phase Vocoder:** FFT-based, manipulate phase and magnitude bins
  - **Slicing:** Repeat or skip slices to match tempo (hip-hop, MPC style)
- **Pitch-Shift:** Change pitch without affecting speed
  - **Resample:** Changes both pitch and speed (classic sampler sound)
  - **Formant Correction:** Preserve timbre when shifting pitch (for vocals)
- **Algorithm Choice:** Trade-off between quality, CPU, and “character”

### 14.8.5 Reverse, Scrub, and Non-Destructive Editing

- **Reverse:** Play buffer backwards, reverse region or whole sample
- **Scrub:** Move playhead interactively via knob/touch (DJ, tape stop FX)
- **Non-Destructive Editing:** Edits stored as metadata, can always revert to original sample

### 14.8.6 Batch Processing, Undo, and Redo

- **Batch Processing:** Apply edits (normalize, trim, fade) to multiple samples at once
- **Undo/Redo:** Infinite or limited history; store parameter changes, not just raw audio
- **Background Processing:** Edits can be scheduled while user works elsewhere

### 14.8.7 Sample Editing UI: Waveform, Markers, Zoom, and Hardware Controls

- **Waveform Display:** High-res, zoomable, with color-coded markers and selection
- **Markers:** Start, end, loop, slices, cue points
- **Zoom/Scroll Controls:** Encoders, sliders, pinch-zoom, arrow keys
- **Hardware Controls:** Pads/keys jump to slices, encoders nudge markers, buttons toggle snap/grid

---

## 14.9 Playback Engines: Pitch, Time, Granular, and Polyphony

### 14.9.1 Basic Playback: One-Shot, Looped, Keytracking

- **One-Shot:** Trigger sample once, no retrigger until finished or polyphonic
- **Looped:** Sustain loop between points, may support crossfade or forward/backward (“ping-pong”)
- **Keytracking:** Map MIDI note to pitch playback (transpose from root note)

### 14.9.2 Pitch Transpose: Interpolation, Key Follow, and Root Note

- **Simple Resample:** Linear interpolation, fast but can alias
- **High-Quality Interpolation:** Sinc, Hermite, cubic, or windowed sinc for cleaner pitch shift
- **Key Follow:** Pitch adjusted based on played note, using root note as reference
- **Formant Correction:** Shift pitch without “chipmunk”/“munchkinization” effect

#### 14.9.2.1 Interpolation Example

- For upsampling: interpolate between sample points to fill in values
- For downsampling: use lowpass filter to prevent aliasing

### 14.9.3 Time-Stretching Algorithms: Granular, Phase Vocoder, Slicing

- **Granular:** Overlay grains (small windows) and adjust overlap/spacing for time change
- **Phase Vocoder:** FFT, manipulate frequency bins for time/pitch adjustment
- **Slicing:** For rhythmic material, repeat or skip slices to fit new tempo

### 14.9.4 Granular Playback: Grain Size, Density, Position, Jitter

- **Grain Size:** Length of each grain (5–100ms typical)
- **Density:** Grains per second; more = smoother, less = more “grainy”
- **Position:** Where grains are sampled from source buffer
- **Jitter:** Randomizes grain start position for texture
- **Pitch, Envelope, Pan:** Each grain can have its own parameters

### 14.9.5 Multisample and Zone Playback: Velocity, Round Robin, Articulation

- **Velocity Mapping:** Different sample/zone based on velocity of trigger
- **Round Robin:** Cycle through different samples for repeated notes
- **Articulation:** Switch sample/zone based on key switch, MIDI CC, or sequencer state
- **Sample Groups:** For drums (kick, snare, etc.), orchestral (legato, staccato), or synths (waveforms)

### 14.9.6 Polyphony, Voice Allocation, and Voice Stealing

- **Polyphony Limit:** Max simultaneous voices (RAM/CPU bound)
- **Voice Allocation:** Strategies (round robin, last note priority, oldest, quietest)
- **Voice Stealing:** Release or fade out oldest/quietest voice when polyphony exceeded
- **Dynamic Polyphony:** Increase/decrease voices based on available resources

### 14.9.7 Streaming Large Samples: Buffering, Prefetch, and Dropout Handling

- **Prefetch Buffer:** Read ahead from storage to avoid glitches
- **Block Size:** Tune for latency vs. reliability
- **Dropout Handling:** Fill with silence, crossfade, or mute on underrun
- **Prioritization:** Drop lowest-priority voices/samples if bandwidth is limited

---

## 14.10 Advanced Mapping, Modulation, and Parameter Locks

### 14.10.1 Key/Velocity/Zone Mapping: UI, Data Structures, and Editing

- **Graphical Mapping:** Show keyboard/grid with zones, velocity/color overlays
- **Editing:** Drag/drop, resize, split/merge zones with touchscreen, encoder, mouse
- **Data Structures:** Array or tree of zones, each linked to sample and mapping parameters

### 14.10.2 Modulation Sources: Envelopes, LFOs, Random, Velocity, MIDI, CV

- **Envelopes:** ADSR, AHDSR, multi-segment, assignable to amplitude, filter, pitch, pan, sample start
- **LFOs:** Sync to tempo, free-run, assign to pitch, filter, pan, loop points, etc.
- **Random/S&H:** Randomize parameters for analog feel, round robin, or per-note variation
- **Velocity/Aftertouch:** Modulate filter, amplitude, start point, FX
- **MIDI/CV:** Map CC, pitch bend, mod wheel, external CV to sample parameters

### 14.10.3 Pitch and Filter Envelopes, AHDSR, Multi-Segment

- **Pitch Envelope:** Attack rise or drop (classic drum, synth, percussive FX)
- **Filter Envelope:** Dynamic filter sweeps, open/close based on velocity or CC
- **AHDSR:** Attack, Hold, Decay, Sustain, Release; more control over envelope shape
- **Multi-Segment:** Custom curves, per-step, for advanced modulation

### 14.10.4 Sample Start/End/Loop Modulation

- **Start Point Modulation:** Vary start for every note (velocity, random, CC, LFO)
- **Loop Point Modulation:** Move loop window in real time for timbre shifting
- **Reverse and Scrub:** Dynamic direction or scrubbing via controller

### 14.10.5 Parameter Locks and Per-Step Automation in Samplers

- **Parameter Locks:** Set parameter value (pitch, filter, start, etc.) on a per-step basis (Elektron-style)
- **Automation:** Record/play back parameter changes per step, per pattern, or per note
- **UI:** Visual feedback of locked steps, quick assign/edit via UI or hardware

### 14.10.6 Macro Controls, Morphing, Scenes, and Performance Sets

- **Macro Controls:** Assign multiple parameters to a single knob/pad for performance
- **Morphing:** Crossfade or interpolate between parameter sets (“scene morph”)
- **Scenes:** Save/recall full sampler state (zones, params, routings) for live set
- **Performance Sets:** Organize scenes, banks, and macros for fast recall

---

## 14.11 Live Sampling, Resampling, and Performance Features

### 14.11.1 Live Sampling Workflow: Recording on the Fly, Overdub, Replace

- **On-the-Fly Sampling:** Capture audio while playing, assign to pad/key instantly
- **Overdub:** Layer new audio on top of existing sample or loop
- **Replace:** Overwrite existing sample, option to keep previous take for undo
- **Quantize Sampling:** Sync start/end to sequencer clock or beat grid

### 14.11.2 Resampling: Internal Bus, FX, and Pattern Capture

- **Internal Resample:** Record output of sampler, sequencer, or FX to new sample slot (for layering, bounce, FX “printing”)
- **Pattern/Scene Capture:** Record entire pattern or scene as a new sample for performance
- **Resample with FX:** Capture sound with current FX, insert into new track or bank

### 14.11.3 Auto-Chop, Auto-Slice, and Instant Mapping to Pads/Keys

- **Auto-Chop:** Detect onsets, split sample, map each slice to pad or key
- **Instant Mapping:** Assign slices to grid or keyboard for immediate play
- **Edit Slices:** Adjust start/end, fade, crossfade, reassign to different destinations

### 14.11.4 Live Loopers: Overdub, Undo, Redo, Quantize, Sync

- **Looper Engine:** Record and playback loops, overdub new layers, undo/redo stacks
- **Sync to Clock:** Quantize loop start/end to bars, beats, or user grid
- **Multiply/Divide:** Extend or shrink loop length in multiples of clock
- **Reverse, Halftime, Doubletime:** Real-time manipulation of loop playback

### 14.11.5 Performance FX: Stutter, Reverse, Glitch, Slice FX

- **Stutter:** Retrigger small slice of buffer at high speed (DJ, hip-hop, glitch)
- **Reverse:** Instant reverse at playhead or for whole sample
- **Glitch/Granular:** Randomize grains, slices, or playback order
- **Slice FX:** Play slices out of order, randomize or sequence for fills and variation
- **Freeze:** Hold buffer at current point for drone/pad FX

### 14.11.6 Sampler Integration with Sequencer and FX Engines

- **Sequencer Trigger:** Steps trigger sample playback, parameter locks, automation
- **FX Send:** Route sampler output to FX engine (delay, reverb, distortion, etc.)
- **Sidechain:** Use sampler output as trigger for dynamics, ducking, or FX modulation
- **MIDI/CV Output:** Trigger external gear from sample playback, sync with DAW or modular

---

## 14.12 Performance, UI, and Storage Optimization

### 14.12.1 Audio Buffer Management for Low Latency and Streaming

- **Buffer Size:** Tune for minimal latency without dropouts
- **Prefetch and Lookahead:** Read ahead from storage for large/streamed samples
- **Double Buffering:** Swap buffers for glitch-free playback
- **Async I/O:** Read/write in background, notify engine when data ready

### 14.12.2 Storage Access Patterns: SD, NAND, Flash, USB

- **SD/microSD:** Removable, moderate speed, may have high latency on random access
- **NAND Flash:** Fast reads, good for sample streaming; wear-leveling needed for heavy usage
- **USB Storage:** Fast for large files, variable latency, hot-swappable
- **Optimized File Access:** Align reads to storage block size for max speed

### 14.12.3 CPU and DSP Load: Prioritization and Dropout Handling

- **Prioritize Playback:** Always keep playback engine running, drop background tasks if overloaded
- **Dynamic Polyphony:** Reduce number of voices if CPU/RAM under pressure
- **Dropout Recovery:** Fill with silence, crossfade, or fade out on buffer underrun

### 14.12.4 Sample Pool Management, Preload, and Caching

- **Preload:** Load frequently used samples at startup
- **Caching:** Keep recently used samples in RAM for fast reload
- **LRU (Least Recently Used):** Unload least used samples when pool is full

### 14.12.5 Smart Sample Unloading and Reference Counting

- **Reference Counting:** Only unload samples when not used by any pad/zone/sequence
- **Safe Deletion:** Prevent removing samples still in use
- **Background Unload:** Free up RAM when not performing

### 14.12.6 Battery/Power Considerations for Portable Samplers

- **Low Power Modes:** Pause streaming, power down unused RAM/SD when idle
- **Efficient Buffering:** Minimize RAM/CPU use for long battery life
- **Quick Resume:** Fast wake from sleep, restore sample state

---

## 14.13 Glossary and Reference Tables

| Term         | Definition                                         |
|--------------|----------------------------------------------------|
| Trim         | Remove silence/noise from start/end                |
| Normalize    | Scale audio for max level                          |
| Slice        | Split sample into segments for mapping             |
| Time-Stretch | Change length without affecting pitch              |
| Resample     | Change pitch and speed together                    |
| Polyphony    | Number of sounds that can play at once             |
| Voice Stealing| Release oldest/quietest voice when full           |
| Macro        | Single control mapped to multiple params           |
| Reference Counting| Track usage to manage sample memory           |
| Prefetch     | Read ahead to prevent playback dropouts            |
| Undo/Redo    | Stepwise history of edits                          |

### 14.13.1 Table: Sample Editing Operations

| Operation    | Description                  | Non-Destructive? | Batch?   |
|--------------|-----------------------------|------------------|----------|
| Trim         | Set new start/end            | Yes              | Yes      |
| Normalize    | Scale amplitude              | Yes/No           | Yes      |
| Slice        | Add markers, split           | Yes              | Yes      |
| Fade/Crossfade| Apply fade curves           | Yes/No           | Yes      |
| Reverse      | Playback backwards           | Yes              | Yes      |
| Time-Stretch | Change speed (keep pitch)    | Yes/No           | Yes      |
| Pitch-Shift  | Change pitch (keep speed)    | Yes/No           | Yes      |
| Resample     | Change pitch/speed           | No               | Yes      |

### 14.13.2 Table: Granular and Time-Stretch Parameters

| Parameter    | Typical Range                | Effect                         |
|--------------|-----------------------------|--------------------------------|
| Grain Size   | 5–100ms                      | Small=grainy, Large=smooth     |
| Density      | 1–100 grains/sec             | Sparse=stutter, Dense=smooth   |
| Jitter       | 0–50ms                       | Randomizes grain positions     |
| Pitch        | ±24 semitones                | Grain pitch shift              |
| Envelope     | Sine, Triangle, Hann, etc.   | Shape of each grain            |
| Overlap      | 0–100%                       | Controls "smeared" sound       |

### 14.13.3 Table: Voice Allocation Strategies

| Strategy     | Description                  | Pros              | Cons               |
|--------------|-----------------------------|-------------------|--------------------|
| Round Robin  | Cycle through voices         | Even usage        | May cut off releases|
| Last Note    | Steal oldest voice           | Good for leads    | May cut sustained  |
| Oldest       | Release oldest voice         | Keeps new notes   | May cut chords     |
| Quietest     | Release lowest level voice   | Less audible cuts | May be unpredictable|

---

**End of Part 2 and Chapter 14: Sampling Engines — Recording, Editing, and Playback.**

**You now have a comprehensive, detailed, and performance-oriented reference for sample editing, playback, mapping, live features, and optimization for workstation projects.  
If you want to proceed to the next chapter (Synthesis Engines: Subtractive, FM, Wavetable, Physical Modeling, and More), or want even deeper detail on any topic, just say so!**