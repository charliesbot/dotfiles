---
name: pr-description
description: Write and open a pull request for a solo personal project. Use whenever the user wants to ship the current branch ("open a pr", "create pr", "push and pr"). Produces a bracketed-type title (e.g. "[feat] ...") and a concise body, then runs gh pr create.
---

You write PR descriptions for the user's solo projects and open the PR with `gh pr create`. The audience is the user themselves, looking back at the PR a few weeks later. Optimize for a future self who wants to know _what_ this PR was about in 10 seconds.

## Core principles

- **Describe the PR, not the implementation.** Good: "Add a skill for drafting solo-project PRs." Bad: "Introduce SKILL.md with frontmatter and a workflow section." Avoid naming specific classes, files, or methods unless the name is load-bearing for understanding the change.

- **Plain punctuation, no AI-tell.** Use periods and commas. Do not use em-dashes (—) or semicolons (;). They make prose feel dense and AI-written. If you would reach for an em-dash, use a period and start a new sentence. If you would reach for a semicolon, the same.

- **Break ideas across sentences and paragraphs.** Short sentences beat long compound ones. Two distinct points means two sentences. When the topic shifts (for example from "what changed" to "known follow-up"), use a blank-line paragraph break. Spacing aids readability.

- **Concise, but not crammed.** Cut filler words. Do not pack three ideas into one sentence to save space. A two-paragraph body of short sentences reads better than one dense paragraph of the same length.

- **No reviewer filler.** No "please review", no "cc @anyone", no "let me know what you think". Solo PR, no audience to address.

- **No emojis. No badges. No decorative headers.** Plain markdown.

- **Default to prose, not bullets.** PR bodies read as paragraphs. If the items could be a comma-separated sentence, write the sentence. A three-item list almost always belongs as prose, not as a bullet list. Reach for bullets only when each item is long enough to need its own line, such as a multi-part PR where each piece has its own short description.

  Bad (three short verbs that should be a sentence):

  ```
  The reader now:
  - applies publisher-free legibility defaults
  - pins line length and indent at the reading-system level
  - ships bundled Inter and Noto Serif faces
  ```

  Good (same content, as prose):

  ```
  The reader now applies legibility defaults independent of the publisher, pins line length and indent at the reader level, and ships bundled Inter and Noto Serif faces.
  ```

- **No test plan section by default.** Strip it. The PR body answers "what is this about", not "how do I verify it". Claude Code's default `gh pr create` template includes a `## Test plan` block — remove it before running the command. Only include a test plan when this specific PR introduces a non-obvious manual verification step that a future-you wouldn't otherwise know about (a flaky test to re-run, a specific QA flow, an env var that needs setting before the change is observable). "Click around and see if it works" is implied for solo projects. Do not write that down. Do not write a stub.

## Title format

Format: `[<type>] <Imperative summary in sentence case>`

The type goes in square brackets at the front. The summary is imperative ("Add", "Fix") and uses sentence case (first word capitalized, rest lowercase unless they are proper nouns or identifiers).

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `style`.

Examples:

- `[feat] Add pr-description skill for solo projects`
- `[fix] Handle empty branch name in deploy script`
- `[chore] Bump dependencies and drop unused angular skills`

Keep titles under ~70 characters. No trailing period.

## Workflow

### 1. Gather context

Run these in parallel:

```bash
git status
git log main..HEAD --oneline
git diff main...HEAD
gh pr view --json url 2>/dev/null  # check if a PR already exists
```

Also draw from the current conversation. What the user just built is usually the clearest source for the "what is this about" framing.

Bail conditions to check before drafting:

- **On the base branch.** If `git status` shows the current branch is `main` (or the repo's default), stop and tell the user. PRs go from feature branches, not from `main` itself.
- **A PR already exists.** If `gh pr view` returns a URL, stop and surface it. Do not create a duplicate. Offer `gh pr edit` if they want to update it.
- **Uncommitted changes.** `git diff main...HEAD` only sees committed work. If `git status` shows modified or untracked files, surface them and ask whether to commit them into the PR or leave them aside. Do not silently ship a PR missing the user's latest changes.

### 2. Decide if the diff is clear

The diff is **clear** when:

- It's a focused change on a single concern.
- The conversation context or commit messages already name the intent plainly.
- The Conventional Commits type is obvious (one of feat/fix/chore fits cleanly).

The diff is **uncertain** when:

- It spans multiple unrelated concerns and you'd have to guess the framing.
- The intent isn't obvious from commits or the conversation (e.g. a refactor that could be described several ways).
- You're unsure whether something is `feat` vs `refactor`, or whether to mention something that may be incidental.

### 3. Draft

Write the title and body. The body answers one question: _what is this PR about?_

Shape:

- Most PRs: 2 to 4 short sentences of prose, split into 1 or 2 paragraphs.
- Multi-part PRs: a short framing paragraph followed by a tight bullet list of the distinct pieces.
- One-line trivia (rename, typo, dep bump): a single short sentence is fine.

Use blank-line paragraph breaks when the body shifts topic, for example moving from "what changed" to "known follow-up" or "context that won't be obvious later".

Re-read the draft and strip these before printing:

- Implementation details like class names, function names, or file names that a future self could rediscover from the diff
- File-by-file walkthroughs
- "Why" framing when the motivation is already obvious from the title
- Any `## Test plan` section. Strip it by default. The only reason to keep one is the narrow exception above (non-obvious manual verification that a future-you wouldn't otherwise know about).
- Any em-dash or semicolon that slipped in
- Any bullet list whose items could have been written as a single sentence

### 4. Confirm only if uncertain

- **Clear diff:** run `gh pr create` directly. After it returns, print the title, body, and PR URL so the user can see what shipped.
- **Uncertain diff:** show the draft, ask "ship it?", wait for explicit go, then create.

### 5. Push and create the PR

```bash
# Push if the branch has no upstream yet
git push -u origin HEAD

# Create the PR. Body via heredoc to preserve formatting.
gh pr create --title "[<type>] <Summary>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

Return the PR URL after creation.
