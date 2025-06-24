# Chapter 2: Project Management & Git/GitHub Basics

---

## 2.1 Introduction

Before you build your hybrid synthesizer—or any complex technical project—it's essential to learn the basics of project management and collaborative tools. This chapter will guide you, step-by-step, through setting up your project, using version control (Git), and collaborating via GitHub. We'll approach this with the mindset of a complete beginner, ensuring you build strong habits that will serve you through this synthesizer adventure and all future engineering work.

---

## 2.2 Why Project Management Matters

### 2.2.1 What is Project Management?

Project management means organizing your work to achieve specific goals within a set timeframe, using available resources efficiently. For engineering projects, this includes breaking down your project into manageable tasks, scheduling, tracking progress, and adapting as you go.

### 2.2.2 Why You Need It

- **Clarity:** Understand what to do next and why.
- **Efficiency:** Avoid wasted effort and repeated work.
- **Collaboration:** Work well with others and communicate clearly.
- **Documentation:** Keep a record of decisions, designs, and versions.

---

## 2.3 Planning Your Synthesizer Project

### 2.3.1 Breaking Down the Big Goal

Your overall goal: **Build a hybrid synthesizer.**

Break this down into smaller, actionable components. For example:
- Digital oscillators (C code)
- DAC interfacing (Pi hardware)
- Analog filters (electronics)
- Polyphony and voice management (C code)
- User interface and controls (electronics + C code)
- Enclosure and assembly

For each, you’ll plan, code, test, and integrate.

### 2.3.2 Task Lists and Milestones

**Task list example for the oscillator module:**
- Research digital oscillator theory
- Write basic oscillator code in C for PC (test with PortAudio)
- Port code to Raspberry Pi (bare metal)
- Interface with DAC; test output on oscilloscope
- Tune code for fidelity and performance
- Document design and code

**Milestones:**  
A milestone is a significant project event (e.g., "First sound output on Pi," "First analog filter working," "Full polyphony achieved").

### 2.3.3 Tools for Tracking Progress

- **Pen and paper:** Great for brainstorming and quick notes.
- **Spreadsheets:** Simple task lists and schedules.
- **Project management software:** Trello, Notion, GitHub Projects (built into GitHub repositories).

We’ll use **GitHub Projects** for this course, but feel free to adapt.

---

## 2.4 What is Git? Why Use It?

### 2.4.1 Version Control

**Version control** is a system that records changes to files over time. It allows you to:
- Track and revert changes
- Experiment safely (branches)
- Collaborate with others

### 2.4.2 What is Git?

**Git** is the most popular version control system, designed for speed, flexibility, and distributed teamwork. Every “commit” (save point) is stored with a full history, so you can always go back.

### 2.4.3 What is GitHub?

**GitHub** is a website that hosts Git repositories online. It provides collaboration tools, issue tracking, code review, and more.

---

## 2.5 Setting Up Git and GitHub

### 2.5.1 Installing Git

#### On Linux (Solus example):

```bash
sudo eopkg install git
```

#### On Raspberry Pi (Raspberry Pi OS):

```bash
sudo apt-get update
sudo apt-get install git
```

#### On Windows/Mac:

- Download from [git-scm.com](https://git-scm.com/)

### 2.5.2 Configuring Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

This sets your identity for all repositories on your machine.

### 2.5.3 Creating a GitHub Account

1. Visit [github.com](https://github.com/)
2. Register with your email and choose a username.
3. Verify your email.

---

## 2.6 Creating Your First Repository

A **repository** (repo) is a folder tracked by Git, containing your project files.

### 2.6.1 On GitHub

1. Click the "+" icon → "New repository"
2. Name your repo, e.g., `hybrid-synth`
3. Add a description.
4. (Optional) Initialize with a README.
5. Click "Create repository".

### 2.6.2 On Your Computer

```bash
# Clone your repo to your local machine
git clone https://github.com/YOUR_USERNAME/hybrid-synth.git
cd hybrid-synth

# Or, to start from scratch and add remote later:
mkdir hybrid-synth
cd hybrid-synth
git init
```

---

## 2.7 Basic Git Workflow

### 2.7.1 Adding and Committing Files

```bash
# Add a new file
echo "# Hybrid Synthesizer" > README.md
git add README.md

# Commit (save your changes)
git commit -m "Add README"
```

### 2.7.2 Pushing Changes to GitHub

```bash
git push origin main
```

### 2.7.3 Pulling Changes From GitHub

```bash
git pull origin main
```

---

## 2.8 Branches: Experiment Safely

A **branch** is a separate line of development. Use them for features or experiments.

```bash
git checkout -b feature/oscillator
# ...make changes...
git add .
git commit -m "Initial oscillator module"
git push origin feature/oscillator
```

On GitHub, you can open a **pull request** to merge your branch into `main` after review.

---

## 2.9 GitHub Issues and Project Boards

### 2.9.1 Issues

- Use **Issues** to track bugs, feature requests, and questions.
- Assign labels, milestones, and assignees.

### 2.9.2 Project Boards

- Go to the "Projects" tab of your repo.
- Create a board (Kanban style).
- Add columns: "To do," "In progress," "Done."
- Add issues/cards to each column for clear tracking.

---

## 2.10 Directory and File Organization

### 2.10.1 Example Structure for Synth Project

```
hybrid-synth/
├── README.md
├── docs/        # Documentation, schematics, notes
├── src/         # C source code (.c and .h files)
│   ├── main.c
│   ├── oscillator.c
│   ├── oscillator.h
│   ├── envelope.c
│   ├── envelope.h
│   └── ...
├── hardware/    # Analog schematics, PCB KiCAD files
├── test/        # Test programs, unit tests
└── Makefile     # For building the project
```

### 2.10.2 Modularity (Hardware-Inspired)

- Each board/module (oscillator, envelope, filter) = separate `.c` and `.h` files.
- Use folders for logical grouping: `src/oscillators/`, `src/filters/`, etc.

---

## 2.11 Collaboration and Best Practices

### 2.11.1 Commit Early, Commit Often

- Save your work regularly.
- Write clear commit messages:  
  `"Implement basic triangle oscillator"`  
  `"Fix bug in envelope generator"`

### 2.11.2 Document Everything

- Use `README.md` for project overview.
- Document each module in comments and `docs/` directory.

### 2.11.3 Back Up Your Work

- Push to GitHub regularly.
- Consider making releases (snapshots) for stable versions.

### 2.11.4 Review Code (Even Your Own)

- Use pull requests, even if working solo.
- Review diffs before merging.

---

## 2.12 Example: Setting Up Your First Module

Let’s walk through adding a simple module (oscillator):

1. Create `src/oscillator.c` and `src/oscillator.h`.
2. Write a basic function (details in later chapters).
3. Track with Git:

```bash
git add src/oscillator.c src/oscillator.h
git commit -m "Add oscillator module skeleton"
git push origin main
```

---

## 2.13 Troubleshooting Common Git Issues

### 2.13.1 Merge Conflicts

- Occur when two branches change the same lines.
- Git will mark the conflict in the file with `<<<<<<<` and `>>>>>>>`.
- Edit to resolve, then:

```bash
git add <filename>
git commit
git push
```

### 2.13.2 Untracked Files

- `git status` shows files not tracked by Git.
- Use `git add <filename>` to track.

### 2.13.3 Undo Changes

- Undo changes in a file:

```bash
git checkout -- filename
```

- Undo last commit (if not pushed):

```bash
git reset --soft HEAD~1
```

---

## 2.14 Using .gitignore

- Prevents Git from tracking files/folders (e.g., build artifacts, OS-generated files).
- Example `.gitignore`:

```
*.o
*.exe
build/
.DS_Store
```

Add and commit your `.gitignore`:

```bash
git add .gitignore
git commit -m "Add .gitignore"
git push
```

---

## 2.15 GitHub README Best Practices

- Introduce your project:  
  What is it? Why is it cool?
- List requirements and setup steps.
- Document basic usage.
- Link to documentation and schematics.

---

## 2.16 Summary

- Project management and version control are as critical as soldering or coding.
- Use Git and GitHub to track every step, from code to schematics.
- Keep your project modular, well-documented, and regularly committed.
- Use issues and project boards for clear progress.
- Structure your repo to mimic real hardware modules for future scalability.

---

## 2.17 Exercises

1. **Create a new GitHub repo for your synth project.**
2. **Clone it to your PC and Raspberry Pi.**
3. **Add a README and directory structure.**
4. **Commit and push your changes.**
5. **Create a basic project board and add your first milestones and tasks.**

---

*End of Chapter 2*

---