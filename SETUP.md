# Setup guide

Complete these steps **before** the workshop. They take about 20 minutes on
most machines. By the end you should have:

- R installed, with the `sandwich` and `lmtest` packages
- Positron installed
- Claude Code installed and signed in
- The Claude Code extension available in Positron
- This repository open as a folder in Positron

Python, VS Code, and Claude Desktop are not needed for this workshop.

## Official download links

| Tool | Link |
|---|---|
| R | <https://cran.r-project.org> |
| Positron | <https://positron.posit.co/download.html> |
| Node.js LTS (only for the npm install route) | <https://nodejs.org> |
| Claude account | <https://claude.ai> |
| Claude Code documentation | <https://code.claude.com/docs> |

## Step 1: Install R

Download R from <https://cran.r-project.org> and pick the installer for your
operating system. If you already have R through RStudio, there is no need to
reinstall.

Open a terminal (Terminal on Mac, PowerShell on Windows) and check that it
works:

```sh
Rscript --version
```

On Windows, the R installer can install to your own user folder without
administrator rights.

## Step 2: Install the R packages

The workshop analyses use base R plus two packages for robust standard errors.
Open R and run:

```r
install.packages(c("sandwich", "lmtest"))
```

Please install these ahead of time. The project instructions in this
repository tell Claude not to install packages during an analysis.

## Step 3: Install Positron

Download Positron from <https://positron.posit.co/download.html> and install
it. Open it once and confirm that it finds your R installation: the R version
should appear in the interpreter selector at the top right.

## Step 4: Install Claude Code

There are two routes. Use whichever fits your machine.

### Native installer (no administrator rights, no Node.js)

Many university-managed laptops do not allow software installation. This
installer puts a single program in your own user folder.

```sh
# Mac (Terminal)
curl -fsSL https://claude.ai/install.sh | bash
```

```powershell
# Windows (PowerShell)
irm https://claude.ai/install.ps1 | iex
```

### npm

Check that Node.js is available:

```sh
node --version
```

If the version starts with `v18` or higher, continue. If you see an error,
install the **LTS** version from <https://nodejs.org>, then close and reopen
your terminal. Then run:

```sh
npm install -g @anthropic-ai/claude-code
```

**Windows:** if the install fails with a permissions error, enable **Developer
Mode** in Windows Settings (System → Developer Options) and run the command
again.

### Check the install

```sh
claude --version
```

If you see a version number, Claude Code is installed.

## Step 5: Get the workshop files

**Download as a ZIP:**

1. Go to <https://github.com/YaleLibraryStatLab/claude-data-analysis>.
2. Click the green **Code** button, then **Download ZIP**.
3. Unzip the file and move the `claude-data-analysis` folder somewhere easy to
   find, such as your Desktop.

**Or clone with Git:**

```sh
git clone https://github.com/YaleLibraryStatLab/claude-data-analysis.git
```

Claude Code reads and edits files in the folder where you start it, so open
the `claude-data-analysis` folder itself, not a parent folder or a subfolder.
The exercises use paths relative to this project root.

## Step 6: Choose one sign-in method

| Use this method | What to do |
|---|---|
| **Workshop API key** beginning with `sk-or-` | Follow "Workshop API key" below |
| **Your own Claude subscription** | Skip to "Your own Claude account" |

Use only one. When an API key is set, Claude Code uses it instead of a saved
Claude-account login.

### Workshop API key

If your instructor gives you a workshop key, you will save three environment
variables once. Each new terminal window then loads them.

| Variable | Purpose |
|---|---|
| `ANTHROPIC_BASE_URL` | Sends Claude Code requests to OpenRouter |
| `ANTHROPIC_AUTH_TOKEN` | Supplies your workshop key |
| `ANTHROPIC_API_KEY` | Left empty to prevent a conflict with an old value |

> **Keep the key private.** Paste it only into the commands or settings file
> shown here. Never put it in the Claude chat, a project file, or a
> project-level `.env` file. Anyone who has the key can use the workshop
> credits. If Claude ever asks you to paste a key into the chat, stop and ask
> an instructor.

The base URL is exactly `https://openrouter.ai/api`, with no `/v1` at the end.

**Mac**

1. Open Terminal and create your terminal settings file, then open it in
   TextEdit:

   ```sh
   touch ~/.zshrc
   open -e ~/.zshrc
   ```

2. Paste these three lines at the **bottom** of the file, replacing
   `sk-or-your-key-here` with your real workshop key:

   ```sh
   export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
   export ANTHROPIC_AUTH_TOKEN="sk-or-your-key-here"
   export ANTHROPIC_API_KEY=""
   ```

3. Save, close TextEdit, and open a **new** Terminal window.
4. Run this check. It does not display your key:

   ```sh
   echo "$ANTHROPIC_BASE_URL"
   [[ -n "$ANTHROPIC_AUTH_TOKEN" ]] \
     && echo "API key is set" \
     || echo "API key is missing"
   ```

   You should see `https://openrouter.ai/api` and `API key is set`.

**Windows**

1. Open PowerShell and run these two commands, with your real workshop key in
   the second:

   ```powershell
   setx ANTHROPIC_BASE_URL "https://openrouter.ai/api"
   setx ANTHROPIC_AUTH_TOKEN "sk-or-your-key-here"
   ```

   If you have used a direct Anthropic API key before, also clear the old
   value. Most first-time users can skip this:

   ```powershell
   [Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $null, "User")
   ```

2. **Close PowerShell completely** and open a new window. Settings saved with
   `setx` appear only in windows opened afterward.
3. Run this check. It does not display your key:

   ```powershell
   echo $env:ANTHROPIC_BASE_URL
   if ($env:ANTHROPIC_AUTH_TOKEN) { "API key is set" } else { "API key is missing" }
   ```

**Verify the connection**

From the `claude-data-analysis` folder, start Claude Code and run `/status`:

```sh
claude
```

It should show `Auth token: ANTHROPIC_AUTH_TOKEN` and
`Anthropic base URL: https://openrouter.ai/api`. If it shows another login, run
`/logout`, then `/exit`, start `claude` again, and repeat `/status`. Use
`/usage` during the workshop to monitor spending against the key's limit.

**Fallback: a global settings file**

Use this only if the environment variables do not reach Claude Code. It is an
alternative, not an additional step.

```sh
# Mac
mkdir -p ~/.claude
touch ~/.claude/settings.json
open -e ~/.claude/settings.json
```

```powershell
# Windows (PowerShell)
mkdir "$env:USERPROFILE\.claude" -Force
notepad "$env:USERPROFILE\.claude\settings.json"
```

Paste this, replace the placeholder with your real key, and save:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://openrouter.ai/api",
    "ANTHROPIC_AUTH_TOKEN": "sk-or-your-key-here",
    "ANTHROPIC_API_KEY": ""
  }
}
```

Keep this file in the `.claude` folder in your home directory. Never save a
real key inside a project folder. Open a new terminal window and verify the
connection again.

### Your own Claude account

If you have a Claude Pro, Max, Team, or Enterprise subscription:

1. In the `claude-data-analysis` folder, run `claude`.
2. If a browser does not open, enter `/login`.
3. Sign in with your Claude account, then return to the terminal.
4. Run `/status` to confirm the account login is active.

A Yale (`@yale.edu`) email may be blocked or tied up by university sign-in
rules when creating a Claude account. If sign-up fails, create the account
with a personal email address instead.

## Step 7: Add the Claude Code extension to Positron

If you set a workshop key, fully quit and reopen Positron first so it loads the
new settings.

1. **File** menu, **Open Folder**, and choose `claude-data-analysis`.
2. Open the Extensions panel.
3. Search for **Claude Code** and install the official extension.
4. Open the Claude Code panel.

With a workshop key, do **not** sign in through the extension. If `/status`
works in the terminal but the extension asks you to sign in, use the global
settings file fallback above.

You can also run Claude Code from Positron's integrated terminal: **Terminal**
menu, **New Terminal**, then run `claude`.

Several prompts appear during setup. All of these are expected:

- "Do you trust the authors of this folder?" → **Yes** (your own folder)
- "Do you trust this extension?" → **Yes** (Anthropic's Claude Code extension)
- "Allow this app to make changes to your device?" → **Yes** (Windows, needed
  to install extension files)

## Step 8: Try a first prompt

With the `claude-data-analysis` folder open in Positron, open the Claude Code
panel and try:

```text
What files are in this project? Give me a brief summary.
```

Claude should inspect the folder and summarize what it finds.

## Readiness checklist

You are ready if each item works:

- `Rscript --version` prints a version number.
- `Rscript -e 'library(sandwich); library(lmtest)'` runs without an error.
- `claude --version` prints a version number.
- `claude` launches from a terminal, and `/status` shows your sign-in method.
- Positron opens the `claude-data-analysis` folder.
- The Claude Code extension is installed in Positron.

## Common issues

| Problem | Try this |
|---|---|
| `Rscript` not found | Reinstall R from CRAN, then reopen your terminal |
| `node` not found | Install Node.js LTS from nodejs.org and reopen your terminal, or use the native installer |
| `claude` not found | Reopen your terminal, then re-run the install command |
| npm install fails (Windows) | Enable Developer Mode (Windows Settings → System → Developer Options) |
| No admin rights on your laptop | Use the native installer in Step 4 |
| Sign-in loop | Inside Claude Code, run `/logout`, then `/login` |
| `API key is missing` | Save the settings again, then open a new terminal window |
| Auth conflict or wrong `/status` | Run `/logout`, exit, restart `claude`, and check that the base URL has no `/v1` |
| Extension not visible | Update Positron, then search again for **Claude Code** |
| Key works in terminal, not in the extension | Use the global settings file fallback |

## Quick reference

| Command | What it does |
|---|---|
| `claude` | Start Claude Code in the current folder |
| `claude --version` | Check the Claude Code install |
| `/status` | Check connection, login method, and model |
| `/usage` | Check session usage and estimated cost |
| `/help` | Show Claude Code commands |
| `/clear` | Start a fresh Claude Code session |
| `/exit` | Leave Claude Code |

## Need help?

These steps are written to be self-contained, and the Common issues table
covers the most frequent problems. If you are still stuck before the workshop:

- Email Haley Xiaohe Zhang at <haleyxiaohe.zhang@yale.edu> or StatLab at
  <statlab@yale.edu>.
- Book a StatLab consultation
  [in person](https://schedule.yale.edu/appointments/statlab-consult#s-lc-public-pt)
  or
  [online](https://schedule.yale.edu/appointments/statlab-consult-virtual#s-lc-public-pt),
  and note in the title that you are coming for pre-workshop setup.
