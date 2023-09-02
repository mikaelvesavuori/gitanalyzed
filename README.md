# GitAnalyzed 🧠 💻 💬 🔮

## Therapy for Your Code — Decode Your Repository's Mind!

GitAnalyzed is your passport to unlocking the psychology of your codebase. GitAnalyzed delivers comprehensive insights that go beyond commits and branches. Discover the dance of file churn, embrace the ebb and flow of line changes, and unravel the story of author contributions. Dive deep into code ownership dynamics, calculate the heartbeat of your development with churn rates, and uncover the pulse of bug fixes. GitAnalyzed isn't just about analytics; it's the therapy your code deserves. Let your repository share its mind, and GitAnalyzed will translate its language into actionable wisdom.

## What to know

GitAnalyzed wraps features readily available in Git, but which might be underutilized by many of us. Indeed there are good commercial tools out there - using GitAnalyzed, however, will provide you with important cornerstone features at no cost, no legacy or dependencies (as it's just plain Git), with very easy-to-inspect results.

**Results are output into a directory named `gitanalyzed` with `.txt` files for each feature.**

## Features

### File Churn

_Where are changes taking place?_

```text
 233 package.json
 142 package-lock.json
 115 README.md
  74 build/index.js
[...]
```

### Line Churn

_How much is added and removed?_

```text
Added lines: 738210
Removed lines: 671364
```

### Author Churn

_Who's doing the work?_

```text
 596 Sam Person
  81 Dat Person
  59 Hoo Person
   7 Bot Person
[...]
```

### Code Ownership

_Where are authors working?_

```text
10 Sam Person,Dat Person,Hoo Person, README.md
  7 Sam Person,Bot Person, package-lock.json
  3 Sam Person,Dat Person, bin/frameworks/errors/errors.ts
  1 Dat Person, bin/entities/BigThing/index.ts
[...]
```

### Churn Rate

_What's the average rate of change?_

```text
Churn rate: 4 changes per day
```

### Bug Fixes

_How many commits solve bugs, errors, or otherwise provide fixes for known problems?_

```text
Bug fixes/errors:       79 out of      817 commits (9%)
```

You will also get a full list of all detected commits:

```text
8e98265e Thu Sep 8 17:03:01 2022 +0200 fix(): add missing return to getEnvUrl() in configuration setup
003e3864 Fri Aug 19 20:53:48 2022 +0200 fix(): ensure there are clear error messages from the API call if an error occurs; remove unnecessary 'else'
fc236a47 Wed May 4 22:00:56 2022 +0200 fix(): issue 154, remove snyk, update dependencies
2ec88ec2 Sun Dec 26 15:08:39 2021 +0100 fix(imports-in-two-places): fix issue #152
4942a2ac Tue Nov 9 14:22:29 2021 +0100 fix(file-names): fix issue #149 and use PascalCase for file names
```

### Active Branches

_What are the live branches, right now?_

```text
  main
  long-living-branch-that-we-need-to-get-rid-of
  develop
  nasty-integration
```

### Days since last commit

_How long since the last change?_

```text
Days since the last commit: 6
```

## Installation

You can use it just as any old script in a project if you want...

_But the nicer option is to use the `install.sh` script._

It will:

- Make a root level directory named `.gitanalyzed`
- Copy `gitanalyzed.sh` to the new directory
- Add a line to your `.zshrc` with an alias (`gitanalyzed`) that runs the script

Feel free to modify the installation script or do it your way if this doesn't match how you'd like it to be set up.

You will need to source or reload your IDE for the changes to be activated.

## Usage

Easy, just run `gitanalyzed` in a Git repository.

## Contributing

There is a dedicated [CONTRIBUTING.md](CONTRIBUTING.md), but generally I'm happy to take suggestions and proposals for new features!
