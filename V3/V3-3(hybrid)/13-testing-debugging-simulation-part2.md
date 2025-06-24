# Chapter 13: Testing, Debugging, and Simulation – Part 2

---

## Table of Contents

5. Simulation Tools for Embedded Audio
    - Why simulate? Limits of hardware-only testing
    - Types of simulation (unit, signal, system, hardware-in-the-loop)
    - Software audio simulators and frameworks
    - Simulating hardware peripherals (DAC, GPIO, MIDI, etc.)
    - Emulation: QEMU and Pi emulators for integration tests
    - Model-based design and co-simulation (Matlab/Simulink, Faust, Pure Data)
6. Advanced Test Harnesses and Automated Validation
    - Building automated test harnesses for DSP and system code
    - Generating and verifying test signals (waveforms, envelopes, noise)
    - Bit-exact reference outputs and tolerance testing
    - Golden files, audio file comparison (diff, spectrogram, RMS error)
    - Continuous regression and non-regression audio testing
    - Fuzzing and stress-testing for robustness
    - Adding tests for user interface and control logic
7. Strategies for Validating Software and Hardware (Hybrid Systems)
    - Hardware-in-the-loop (HIL) approaches
    - Automated I/O testing (relay boards, logic analyzers, scope scripts)
    - Loopback and round-trip audio/MIDI tests
    - Automated calibration and trim routines
    - Systematic stress and soak testing
    - End-to-end performance and user experience validation
8. Closing the Loop: Debug-Driven Redesign and Maintenance
    - Using test and bug data to plan refactoring
    - Documenting known issues, test results, and coverage
    - Maintenance best practices for embedded synths

---

## 5. Simulation Tools for Embedded Audio

### 5.1 Why Simulate? Limits of Hardware-Only Testing

- **Simulations** let you test code and algorithms without needing physical hardware.
- Benefits:
    - Faster iteration (no hardware setup/teardown)
    - Better fault injection (simulate errors easily)
    - Cost savings (no prototype needed for every test)
    - Early validation of design (DSP, timing, system interactions)
- Limits of hardware-only:
    - Slow turnaround
    - Expensive for large-scale or edge-case tests
    - Harder to control/observe all variables

### 5.2 Types of Simulation

- **Unit simulation:** Run DSP blocks/algorithms in isolation with known inputs.
- **Signal simulation:** Generate, process, and analyze signals in software (Python, Matlab, etc.).
- **System simulation:** Simulate interaction of multiple modules (synth engine, MIDI, audio I/O).
- **Hardware-in-the-loop (HIL):** Real code on real or simulated hardware, but with test harnesses or virtual peripherals.

### 5.3 Software Audio Simulators and Frameworks

- **Python/NumPy/Matplotlib:** Quick simulation of DSP, audio, and control signals.
- **Matlab/Octave:** Math-heavy modeling and analysis.
- **Faust:** Functional audio stream language—simulate DSP, generate C/C++ code.
- **Pure Data/Max/MSP:** Visual patching for rapid prototyping.
- **JUCE:** C++ framework with built-in audio simulation/test harness tools.

#### Example: Simulate Envelope in Python

```python
import numpy as np
import matplotlib.pyplot as plt

attack, decay, sustain, release = 0.01, 0.1, 0.7, 0.2
sr = 48000
t_attack = np.linspace(0, attack, int(sr*attack))
t_decay = np.linspace(0, decay, int(sr*decay))
t_sustain = np.linspace(0, 0.5, int(sr*0.5))
t_release = np.linspace(0, release, int(sr*release))

env = np.concatenate([
    t_attack/attack,
    1 - (1-sustain)*(t_decay/decay),
    np.ones_like(t_sustain)*sustain,
    sustain*(1 - t_release/release)
])
plt.plot(env)
plt.title("Simulated ADSR Envelope")
plt.show()
```

### 5.4 Simulating Hardware Peripherals

- **DAC simulation:** Log written values, plot output, verify range/step size.
- **GPIO:** Use software stubs to emulate button/switch input, log output states.
- **MIDI:** Feed test MIDI messages from files or virtual MIDI cables (e.g., `ttymidi`, `aconnect`).
- **Audio I/O:** Use RAM buffers or files instead of real hardware.

#### Example: Mocking a DAC in C

```c
int fake_dac_write(uint16_t val) {
    printf("DAC write: %u\n", val);
    return 0;
}
```

### 5.5 Emulation: QEMU and Pi Emulators

- **QEMU:** Emulates ARM CPUs, can run Pi images for integration/system tests.
- **Pi emulators:** Some support GPIO, SPI, I2C, and even basic audio.
- Use for:
    - Headless CI builds and regression tests
    - System integration before deploying to real hardware

### 5.6 Model-Based Design and Co-Simulation

- **Matlab/Simulink:** Model synth or DSP algorithms, auto-generate C code.
- **Faust:** Prototyping and verifying DSP blocks.
- **Pure Data:** Test control logic, MIDI, and UI behavior.

---

## 6. Advanced Test Harnesses and Automated Validation

### 6.1 Building Automated Test Harnesses

- **Test harness:** Code or scripts that run tests, check results, and report pass/fail.
- Should support batch runs, parameter sweeps, and edge cases.
- Example: C test main that runs all unit/integration tests and prints summary.

### 6.2 Generating and Verifying Test Signals

- Use known signals (sine, square, noise, impulses, sweeps) as test vectors.
- For each DSP block, check output matches mathematical expectation.
- Store reference ("golden") outputs for later regression tests.

### 6.3 Bit-Exact Reference Outputs and Tolerance Testing

- For critical DSP, generate bit-exact outputs on a reference platform.
- Compare outputs with small tolerance for floating-point math (e.g., RMS error < 1e-6).
- Useful for filters, oscillators, and any code ported from another platform.

### 6.4 Golden Files and Audio File Comparison

- **Golden files:** Store expected output audio (.wav, .csv, .bin) from tests.
- **Comparison:** Use diff tools, RMS error, or spectrograms to compare current and golden output.
- Automate with scripts (Python, Bash, CMake).

#### Example: Checking a Golden File in Python

```python
import numpy as np
from scipy.io import wavfile

sr1, data1 = wavfile.read('test_output.wav')
sr2, data2 = wavfile.read('golden_output.wav')
assert sr1 == sr2
rms_error = np.sqrt(np.mean((data1 - data2)**2))
print("RMS error:", rms_error)
```

### 6.5 Continuous Regression and Non-Regression Audio Testing

- Integrate audio tests into CI/CD pipelines.
- On every push, run synth with test MIDI, capture output, compare with golden files.
- Alert on drift, degradation, or new bugs.

### 6.6 Fuzzing and Stress-Testing

- Fuzz input: Send random or extreme values to test robustness (buffer overflows, parameter edge cases).
- Stress-test: Run for hours/days with rapid note changes, UI interaction, or extreme settings.

### 6.7 Adding Tests for User Interface and Control Logic

- Simulate knob turns, button presses, and UI sequences.
- Use test scripts to ensure all UI controls update underlying synth state correctly.

---

## 7. Strategies for Validating Software and Hardware (Hybrid Systems)

### 7.1 Hardware-in-the-Loop (HIL) Approaches

- **HIL:** Real code running on hardware, with test equipment (or another computer) driving inputs and monitoring outputs.
- Example: Use lab power supply to sweep input voltages, oscilloscope to log DAC outputs.

### 7.2 Automated I/O Testing

- Use relay boards, GPIO expanders, or digital I/O testers to trigger hardware events.
- Logic analyzers and oscilloscopes can be scripted (e.g., Sigrok/PulseView) to capture and analyze outputs.

### 7.3 Loopback and Round-Trip Audio/MIDI Tests

- Send known MIDI/audio in, capture out, and verify timing/accuracy.
- For MIDI: Loopback cable or virtual MIDI ports; for audio: physical loopback or software.

### 7.4 Automated Calibration and Trim Routines

- Design tests that sweep through calibration ranges (e.g., VCO pitch, filter cutoff).
- Store and validate calibration data, report drift or errors.

### 7.5 Systematic Stress and Soak Testing

- Run the synth at max polyphony, rapid parameter changes, for extended time.
- Look for memory leaks, CPU overuse, heat, or hardware drift.

### 7.6 End-to-End Performance and User Experience Validation

- Scripted “user journeys” (from power-on, patch load, play, to shutdown).
- Record and review response time, error logs, and subjective audio quality.

---

## 8. Closing the Loop: Debug-Driven Redesign and Maintenance

### 8.1 Using Test and Bug Data to Plan Refactoring

- Track bugs and test failures to identify weak spots.
- Prioritize fixes and refactors based on test coverage and failure frequency.

### 8.2 Documenting Known Issues, Test Results, and Coverage

- Maintain a test results log and bug tracker (GitHub Issues, Jira, etc.).
- Document all known limitations and edge case failures.
- Share coverage reports in your documentation or README.

### 8.3 Maintenance Best Practices for Embedded Synths

- Regularly re-run all tests after updates or hardware changes.
- Archive and track all test artifacts (audio files, logs, traces).
- Review and update test cases as new features or hardware are added.
- Encourage a “test-first” and “test-always” culture for every code/hardware change.

---

## 9. Further Reading and Tools

- “Practical Embedded Testing” by Alexander Tarlinder
- “Real-Time Digital Signal Processing” by Sen M. Kuo et al.
- “Design Patterns for Embedded Systems in C” by Bruce Powel Douglass
- Unity, CMocka, Catch2 (test frameworks for C/C++)
- Sigrok/PulseView (logic analyzer and oscilloscope software)
- QEMU (emulation), pytest (Python tests), gcov/lcov (coverage)
- GitHub Actions, GitLab CI, Jenkins (CI/CD and test automation)
- Faust, Matlab, Pure Data (DSP and system simulation)

---

*End of Chapter 13. Next: Building the UI—Basic Controls, MIDI (deep dive into user interface design, hardware/software control integration, and MIDI implementation for embedded synths).*