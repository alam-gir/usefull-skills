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
3. Copy [`PROTOCOL.md`](PROTOCOL.md) and `savings-report.sh` (both beside this `SKILL.md`) to
   `.agent/project-map/README.md` and `.agent/project-map/savings-report.sh`; `chmod +x` the script.
4. Add these two lines to `.gitignore`:
   `.agent/project-map/savings-log.csv` and `.agent/project-map/savings.html`.
5. If `AGENTS.md` or `CLAUDE.md` exists and has no project-map line, add one:
   `Locate code via .agent/project-map/index-map.md before searching; keep it current (.agent/project-map/README.md).`

**Every build:** map only the area(s) the current task needs, per [`MAP-FORMAT.md`](MAP-FORMAT.md).
Extend an existing area before adding a thin new one.

## Map the whole project

Only when the user explicitly asks. Say it is a large one-time read, get a yes, then map every
area. Otherwise the map grows one area at a time as tasks reach them.

## Track savings

When the map saved you a search, append one line to `.agent/project-map/savings-log.csv`
(header `date,area,tokens_saved,map_cost,note` — create it if missing):

```
2026-09-01,auth,9000,1200,found login flow without searching
```

- `tokens_saved` — rough size of the files you would have opened to locate that code without
  the map.
- `map_cost` — what you actually spent this task reading `index-map.md` and the area file(s).
- Keep the estimates honest and `note` comma-free.

The user runs `.agent/project-map/savings-report.sh` (add `--html` for a visual dashboard) for
the totals — never maintain a running total yourself.
