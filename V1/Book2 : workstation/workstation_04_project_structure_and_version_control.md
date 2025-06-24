# Workstation Synth Project – Document 4  
## Project Structure and Version Control

---

### Table of Contents

1. Why Organization Matters
2. Directory Layout for Large Projects
3. Using Git for Version Control
4. Committing and Branching
5. GitHub/GitLab: Online Collaboration
6. Writing a README and Documentation
7. Issue Tracking and Planning
8. Exercises

---

## 1. Why Organization Matters

- Easy to find, test, and expand code.
- Collaborators can jump in quickly.
- Less risk of bugs and lost work.

---

## 2. Directory Layout

```
workstation_synth/
  src/            # C source files
  include/        # Header files
  gui/            # GUI widgets, screens
  pc_test/        # PC-only test harnesses
  pi_baremetal/   # Pi-only code
  electronics/    # Schematics, layouts
  doc/            # Guides, logs, diagrams
  assets/         # Fonts, icons, images
  Makefile
  README.md
```

---

## 3. Using Git for Version Control

```bash
cd workstation_synth
git init
git add .
git commit -m "Initial commit"
```

---

## 4. Committing and Branching

- Commit often, with messages:
  - `"Added touch driver"`
  - `"Fixed envelope bug"`
- Use branches for features:
  - `git checkout -b feature-ui`
  - `git merge feature-ui`

---

## 5. GitHub/GitLab: Online Collaboration

- Create a repo, push your code.
- Invite collaborators.
- Use pull requests for review.

---

## 6. Writing a README

- What is this?
- How to build and run?
- Features and credits.

---

## 7. Issue Tracking and Planning

- Use GitHub Issues for bugs, feature requests, to-dos.
- Example:  
  - #1: "Implement sequencer grid"
  - #2: "Add MIDI learn mode"

---

## 8. Exercises

- Set up your directory layout.
- Push first code to GitHub.
- Write your project’s README.

---

**Next:**  
*workstation_05_digital_audio_principles_and_pc_testing.md* — The science and code behind sound.

---