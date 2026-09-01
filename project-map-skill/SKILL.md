---
name: project-map-skill
description: Locate code through `.agent/project-map/` — a committed index of where each feature lives — instead of searching the whole repo, and keep it current after structural changes. Use before working in an unfamiliar area, when finding where something lives, or when asked to map or resync the project.
---

# Project map

`.agent/project-map/` is a committed set of Markdown files recording where each feature's code
lives, so an agent goes straight to the right files instead of re-exploring the repo. Every
agent reads and updates it the same way — [`PROTOCOL.md`](PROTOCOL.md) is that protocol and the
single source of truth for it. File structure is [`MAP-FORMAT.md`](MAP-FORMAT.md).

One rule governs the whole skill: **the map must cost less to maintain than it saves.** When
unsure, write less or skip it.

## Use the map

Consult the map when a task needs code you cannot already place; refresh it after a structural
change. Both are in [`PROTOCOL.md`](PROTOCOL.md) — follow it there.

Skip the map entirely — no read, no update — for typos, comments, formatting, copy tweaks, and
one-liners in code you already know.

## Build the map

Run when `.agent/project-map/index-map.md` is missing, or a task touches an area no file covers.

**First time — the folder doesn't exist yet:**

1. Glance at the directory tree (2 levels, skipping `node_modules`, `.git`, and build output)
   and the root manifest (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`,
   `Makefile`) for the project summary and any package roots.
2. Write `index-map.md` with that summary and no areas yet (see [`MAP-FORMAT.md`](MAP-FORMAT.md)).
3. Copy [`PROTOCOL.md`](PROTOCOL.md) to `.agent/project-map/README.md` and
   `savings-report.sh` to `.agent/project-map/savings-report.sh`.
4. Add `.agent/project-map/savings-log.csv` to `.gitignore`.
5. If `AGENTS.md` or `CLAUDE.md` exists and has no project-map line, add one:
   `Locate code via .agent/project-map/index-map.md before searching; keep it current (.agent/project-map/README.md).`

**Every build:** map only the area(s) the current task needs, per [`MAP-FORMAT.md`](MAP-FORMAT.md).
Extend an existing area before adding a thin new one.

## Map the whole project

Only when the user explicitly asks. Say it is a large one-time read, get a yes, then map every
area. Otherwise the map grows one area at a time as tasks reach them.

## Track savings

When the map saved you a search, append one line to `.agent/project-map/savings-log.csv`
(header `date,area,est_tokens_saved,note` — create it if missing):

```
2026-09-01,auth,8000,found login flow without searching
```

Estimate `est_tokens_saved` as the rough size of the files you would have had to open and read
to locate that code without the map. Keep it honest; it is a rough figure. The user runs
`.agent/project-map/savings-report.sh` for the running total — do not maintain a total yourself.
