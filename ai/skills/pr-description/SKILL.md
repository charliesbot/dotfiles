---
name: pr-description
description: Write and open a pull request for a solo personal project. Use whenever the user wants to ship the current branch ("open a pr", "create pr", "push and pr"). Produces a Conventional Commits title and concise body, then runs gh pr create.
---

You write PR descriptions for the user's solo projects and open the PR with `gh pr create`. The audience is the user themselves, looking back at the PR a few weeks later. Optimize for: a future-self who wants to know *what* this PR was about in 10 seconds.

## Core principles

- **Describe the PR, not the implementation.** "Add a skill for drafting solo-project PRs." Not "introduce `SKILL.md` with frontmatter and a workflow section."
- **Concise beats comprehensive.** A tight one-paragraph PR is better than a structured-but-padded one. If you can say it in one sentence, say it in one sentence.
- **No reviewer filler.** No "please review", no "cc @anyone", no "let me know what you think". Solo PR — no audience to address.
- **No emojis. No badges. No decorative headers.** Plain markdown.
- **Bullets only when they earn their place.** Use prose by default. Use a bullet list only if there are 3+ genuinely distinct items that would read worse as a sentence.
- **No test plan if there are no tests** — or if the change is trivial enough that the test plan would be "click around and see if it works". Skip the section entirely; don't write a stub.

## Title — Conventional Commits

Format: `<type>: <imperative, lowercase summary>`

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `style`.

Use a scope only if the PR is strictly isolated to a single module (e.g. `feat(android-dev): …`). If the PR touches multiple modules or is generic, skip the scope.

Examples:
- `feat: add pr-description skill for solo projects`
- `fix: handle empty branch name in deploy script`
- `chore: bump dependencies and drop unused angular skills`

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

Also draw from the current conversation — what the user just built is usually the clearest source for the "what is this about" framing.

Bail conditions — check before drafting:

- **On the base branch.** If `git status` shows the current branch is `main` (or the repo's default), stop and tell the user. PRs go from feature branches; the skill doesn't make sense on `main` itself.
- **A PR already exists.** If `gh pr view` returns a URL, stop and surface it. Don't create a duplicate — offer `gh pr edit` if they want to update it.
- **Uncommitted changes.** `git diff main...HEAD` only sees committed work. If `git status` shows modified/untracked files, surface them and ask whether to commit them into the PR or leave them aside. Don't silently ship a PR missing the user's latest changes.

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

Write the title and body. The body should answer: *what is this PR about?*

A good body is usually 1–3 sentences of prose. For larger or multi-part PRs, allow up to a short paragraph plus an optional tight bullet list of the distinct pieces.

Do **not** include:
- Implementation details ("uses `useEffect` with a cleanup function")
- File-by-file walkthroughs
- "Why" sections unless the motivation is genuinely non-obvious from the title
- Test plan, unless the project has tests *and* this PR changes behavior worth a checklist

### 4. Confirm only if uncertain

- **Clear diff:** run `gh pr create` directly. After it returns, print the title, body, and PR URL so the user can see what shipped.
- **Uncertain diff:** show the draft, ask "ship it?", wait for explicit go, then create.

### 5. Push and create the PR

```bash
# Push if the branch has no upstream yet
git push -u origin HEAD

# Create the PR — body via heredoc to preserve formatting
gh pr create --title "<type>: <summary>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

Return the PR URL after creation.
