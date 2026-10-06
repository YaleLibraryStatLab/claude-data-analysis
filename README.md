# Data Analysis with Claude Code

Materials for the Yale Library StatLab workshop on statistical analysis with
coding agents in R.

Coding agents are often effective at turning a well-specified statistical
decision into runnable R code. They are much less reliable at deciding what
should be estimated, which assumptions are defensible, or what a result means.
This workshop teaches a workflow for directing and inspecting agent-assisted
analysis without handing over those decisions.

By the end, you should be able to:

1. Explain what a coding agent does when it analyzes data with R.
2. Write an analysis brief that fixes the goal, target, task, and outputs.
3. Trace a claim back through its sample, estimator, code, and evidence.
4. Recognize a consequential choice that the agent supplied.
5. Decide when to proceed, revise, stop, or seek statistical expertise.

The workshop assumes some experience with R and with regression. It does not
assume prior experience with Claude Code.

## Before the workshop

Please set these up ahead of time. [SETUP.md](SETUP.md) has step-by-step
instructions for Mac and Windows, a readiness checklist, and fixes for common
problems.

1. **R**, with the `sandwich` and `lmtest` packages
2. **Positron**
3. **Claude Code**, signed in with a workshop API key or your own Claude
   subscription, plus the Claude Code extension for Positron

Claude Code can install software for you, but doing that during the session
spends time and credits on setup. The project instructions here also tell
Claude not to install packages during an analysis.

## Getting the files

**Download as a ZIP:** on the
[repository page](https://github.com/YaleLibraryStatLab/claude-data-analysis),
click the green **Code** button, then **Download ZIP**, and unzip it.

**Or clone with Git:**

```sh
git clone https://github.com/YaleLibraryStatLab/claude-data-analysis.git
```

Then, in Positron, choose **File > Open Folder** and select the
`claude-data-analysis` folder itself. Claude Code works in the folder you open,
and the exercises use paths relative to this project root.

## What is in this repository

| Item | What it is |
|---|---|
| [SETUP.md](SETUP.md) | Installation and sign-in instructions |
| [workshop/claude-data-analysis.pdf](workshop/claude-data-analysis.pdf) | Slide deck |
| [CLAUDE.md](CLAUDE.md) | Project instructions Claude Code reads automatically in this folder |
| [exercises/](exercises/) | Analysis briefs and worksheets for the three cases |
| [data/](data/) | Datasets and codebooks, treated as read-only |
| [scripts/](scripts/) | Output folders for each case, plus the We Do reference analysis |

`CLAUDE.md` sets the workflow the agent follows in every case: audit the data
and stop, write a plan and stop, and fit a model only after the researcher
approves the plan. It is worth reading before you start.

## The three cases

| Case | Data | You practice |
|---|---|---|
| **I Do** (instructor demonstration) | College attendance and political participation, 1965--1973 panel | Watching a full analysis in which the audit changes what can be claimed |
| **We Do** (groups) | Faculty salaries at one US college, 2008--09 | Choosing what "adjusted salary difference" means, then reading and verifying the agent's R |
| **They Do** (on your own, afterward) | New York air quality, summer 1973 | Writing your own brief and directing a bounded analysis with less scaffolding |

Each case starts from a brief in `exercises/` and writes its outputs under the
matching folder in `scripts/`. For We Do, each group works in
`scripts/we-do/<group-name>/`. For They Do, work in `scripts/they-do/<your-id>/`.

Each group picks a group name. Its analysis script also writes a
`submission.txt` file; on the class form the group enters its name and pastes
that file's contents. The facilitator then combines every group's results
into one table; the steps are in `instructor_files/`.

## Rebuilding the slides

The deck is a Quarto Beamer presentation. Rendering it requires
[Quarto](https://quarto.org) and a LaTeX distribution with XeLaTeX. The theme
and fonts are bundled under `workshop/assets/`.

```sh
cd workshop
quarto render claude-data-analysis.qmd
```

## Learn more

- [A Quick Tour of Positron](https://posit.co/blog/a-quick-tour-of-positron)
- [Claude Code 101](https://anthropic.skilljar.com/claude-code-101), Anthropic's introductory course
- [Claude Code documentation](https://code.claude.com/docs)

## Questions and help

- Haley Xiaohe Zhang: <haleyxiaohe.zhang@yale.edu>
- StatLab: <statlab@yale.edu>

See the
[StatLab page](https://library.yale.edu/help-and-research-support/research-support/statlab)
for free one-on-one consultations on research you are working on.

## License

Released under the [MIT License](LICENSE).
