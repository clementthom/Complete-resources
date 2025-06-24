# Chapter 13: Testing, Debugging, and Simulation – Part 1

---

## Table of Contents

1. Introduction: The Role of Testing and Debugging in Embedded Synth Design
2. Types of Testing in Embedded Audio Systems
    - Unit testing: Functions, DSP blocks, and drivers
    - Integration testing: Subsystem and module interaction
    - System testing: Full synth behavior, audio, and control
    - Regression and acceptance testing
    - Continuous integration (CI) for embedded projects
3. Test-Driven Development (TDD) for Embedded C Projects
    - Principles of TDD: Write tests first, code to pass tests
    - Setting up a test harness (Unity, CMocka, Google Test)
    - Writing your first unit tests (oscillator, envelope, filter)
    - Stubs, mocks, and fakes for hardware dependencies
    - Achieving high code coverage
    - Automating tests: Makefiles, CMake, and CI
4. Debugging Techniques for Embedded Synths
    - Debugging on PC: GDB, Valgrind, printf, IDEs
    - Debugging on Pi: Serial output, LEDs, remote GDB, JTAG/SWD
    - Hardware debugging: Oscilloscope, logic analyzer, multimeter
    - Signal tracing: Where’s my bug?
    - Common pitfalls in embedded audio (buffer overruns, aliasing, initialization bugs)
    - Using core dumps and stack traces

---

## 1. Introduction: The Role of Testing and Debugging in Embedded Synth Design

Testing and debugging are essential to building a reliable, robust, and musically expressive embedded synthesizer. Unlike software-only projects, embedded synths combine code, hardware, and real-world signals—introducing unique challenges and failure modes. Systematic testing and effective debugging give you confidence that your synth will perform as expected, both in the studio and on stage.

**Why test and debug?**
- Catch errors early (before they hit your speakers!)
- Ensure correct sound, timing, and response for all controls/MIDI
- Guarantee stability under edge cases (buffer overflows, CPU spikes)
- Make refactoring and adding features safer and faster

This chapter will walk you through:
- Designing and running tests for C-based synths
- Debugging both code and hardware
- Using simulation and analysis tools to validate and optimize your synth

---

## 2. Types of Testing in Embedded Audio Systems

### 2.1 Unit Testing: Functions, DSP Blocks, and Drivers

- **Unit tests** focus on the smallest pieces of your code—individual functions or modules.
- You should unit test:
    - DSP blocks (oscillators, filters, envelopes)
    - Utility functions (MIDI parsing, buffer management)
    - Hardware drivers (DAC, GPIO, MIDI I/O)
- Unit tests isolate logic from hardware—using mocks/fakes for dependencies.

#### Example: Unit Test for a Sine Oscillator

```c
TEST_CASE("sine_oscillator_generates_correct_values") {
    float phase = 0.0f;
    for (int i = 0; i < 100; ++i) {
        float sample = osc_sine(&phase, 440.0f, 48000.0f);
        ASSERT_IN_RANGE(sample, -1.0f, 1.0f);
    }
}
```

### 2.2 Integration Testing: Subsystem and Module Interaction

- **Integration tests** verify that multiple modules work together correctly:
    - Envelope modulates VCA
    - MIDI events control oscillators
    - Audio I/O produces correct output with real hardware
- Integration tests may use real drivers or more advanced mocks.

### 2.3 System Testing: Full Synth Behavior

- **System tests** exercise the complete synth—from input (MIDI, knobs) to output (audio, CV).
- Often requires hardware-in-the-loop (HIL) setups.
- Examples:
    - Play a MIDI file, record audio output, and check for expected notes/timbres.
    - Sweep a control and verify the analog output on a scope.

### 2.4 Regression and Acceptance Testing

- **Regression tests** ensure old bugs stay fixed as you change code.
- **Acceptance tests** confirm that the synth meets user and project requirements (e.g., “must play 8-note polyphony at <10ms latency”).

### 2.5 Continuous Integration (CI) for Embedded Projects

- **CI** runs tests automatically on every change (push, PR) to your repository.
- Common CI tools: GitHub Actions, GitLab CI, Travis CI, Jenkins
- Strategies for embedded:
    - Run all unit/integration tests on PC build
    - Use QEMU or emulated Pi for some system tests
    - Deploy to real hardware in advanced setups

---

## 3. Test-Driven Development (TDD) for Embedded C Projects

### 3.1 Principles of TDD

- **Test-driven development**: Write a failing test before writing code.
- Steps:
    1. Write a test that describes the next feature or bug fix.
    2. Run the test (should fail).
    3. Write the minimum code to pass the test.
    4. Refactor code, keeping tests green.

### 3.2 Setting Up a Test Harness

- **Unity:** Lightweight C test framework (https://www.throwtheswitch.org/unity)
- **CMocka:** Modern, mock-friendly (https://cmocka.org/)
- **Google Test:** C++ (works for C with adapters)
- **Catch2:** C++ (header-only)

#### Example: Unity Test Runner

```
test/
    test_oscillator.c
    test_envelope.c
    test_filter.c
    unity.c
    unity.h
Makefile or CMakeLists.txt
```

### 3.3 Writing Your First Unit Tests

#### Example: Envelope Generator

```c
void test_envelope_attack_phase(void) {
    Envelope env;
    env_init(&env, 0.01f, 0.5f, 0.7f, 0.2f);
    env_trigger(&env);
    for (int i = 0; i < env.attack_samples; ++i) {
        float out = env_process(&env);
        TEST_ASSERT_TRUE(out >= 0.0f && out <= 1.0f);
    }
}
```

### 3.4 Stubs, Mocks, and Fakes for Hardware Dependencies

- **Stub:** Minimal implementation that returns fixed values.
- **Mock:** Imitates hardware, records calls/parameters, lets you assert on behavior.
- **Fake:** Simplified, but functional, replacement (e.g., fake DAC just logs values).

#### Example: Mocking a DAC Write

```c
int mock_dac_write(uint16_t value) {
    mock_dac_last_written = value;
    return 0;
}
```

### 3.5 Achieving High Code Coverage

- Code coverage tools (gcov, lcov, gcovr) help track which lines/branches are tested.
- Aim for >80% coverage, but focus on critical DSP/hardware logic.
- Uncovered code is a risk for hidden bugs.

### 3.6 Automating Tests: Makefiles, CMake, and CI

- Use Make/CMake targets for `make test`.
- Integrate with CI workflows for auto-run on push/PR.
- Example CMake snippet:

```cmake
enable_testing()
add_executable(test_synth test/test_oscillator.c src/oscillator.c unity.c)
add_test(NAME oscillator_test COMMAND test_synth)
```

---

## 4. Debugging Techniques for Embedded Synths

### 4.1 Debugging on PC: GDB, Valgrind, printf, IDEs

- **GDB:** Step through code, inspect variables, set breakpoints.
- **Valgrind:** Detect memory leaks, invalid accesses, overruns.
- **printf:** Fast/dirty, but effective for small projects.
- **IDEs:** VSCode, CLion, Eclipse CDT, etc., offer integrated debugging.

#### Example: GDB Session

```bash
gcc -g -o synth main.c
gdb ./synth
(gdb) break main
(gdb) run
(gdb) next
(gdb) print variable
```

### 4.2 Debugging on Pi: Serial Output, LEDs, Remote GDB, JTAG/SWD

- **Serial output:** Use UART for debug prints; connect to PC with USB-serial adapter.
- **LEDs:** Blink codes for error states (good for headless or bare-metal).
- **Remote GDB:** Run `gdbserver` on Pi, connect from your PC.
- **JTAG/SWD:** Hardware debugging with OpenOCD, Segger J-Link, or Pi’s GPIO.

#### Example: Serial Debug on Pi

1. Connect Pi UART TX/RX to USB-serial.
2. Use `minicom`/`screen` on PC to view output.
3. Add `printf("Debug: %d\n", value);` in code.

### 4.3 Hardware Debugging: Oscilloscope, Logic Analyzer, Multimeter

- **Oscilloscope:** Observe analog and digital waveforms (DAC output, clock, triggers).
- **Logic analyzer:** Decode SPI/I2C/I2S, check timing, view MIDI data in real-time.
- **Multimeter:** Check power, ground, continuity, and basic voltage levels.

#### Debugging a DAC Output

- Send a test waveform (sine, ramp) to DAC.
- Probe output with scope—check amplitude, noise, glitches.
- Compare against expected digital data.

### 4.4 Signal Tracing: Where’s My Bug?

- Trace the signal path from code to hardware output.
- Insert debug prints or scope probes at each stage.
- Common traps: muted outputs, uninitialized variables, buffer overruns, wrong pin assignments.

### 4.5 Common Pitfalls in Embedded Audio

- **Buffer overruns/underruns:** Audio glitches, clicks, or silence.
- **Aliasing:** Insufficient oversampling/filtering in oscillators, especially digital.
- **Initialization bugs:** Forgetting to init hardware, buffers, or structs.
- **Timing errors:** Missed deadlines in callbacks, causing audio dropouts.
- **Concurrency/race conditions:** Multiple threads or interrupts accessing shared state without locks.

### 4.6 Using Core Dumps and Stack Traces

- **Core dumps:** Save program state on crash for offline analysis.
- **Stack traces:** Show the chain of function calls that led to a bug.

#### Enabling Core Dumps

```bash
ulimit -c unlimited
./synth
# After crash:
gdb ./synth core
(gdb) bt
```

---

*End of Part 1. Part 2 will cover simulation tools, advanced test harnesses, audio file comparison, automated test signals, fuzzing, and strategies for validating both software and hardware in hybrid synths.*