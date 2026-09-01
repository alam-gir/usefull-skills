# Map format

Files under `.agent/project-map/`. Commit `index-map.md` and the `<area>-map.md` files so every
teammate's agent shares one map. `savings-log.csv` is personal and gitignored.

## `index-map.md`

Read on every task, so keep it lean — two lines per area, however large the project grows.

````markdown
---
kind: project-map-index
last-synced: <short SHA>
---

# Project Map — Index

<1–2 sentences: what this project is, its layout, and package roots if a monorepo.>

## Areas

### <area name>
- <one-line purpose> · [`<area>-map.md`](./<area>-map.md) · synced <short SHA>
- Triggers: <keywords a task would mention — auth, login, JWT, session, logout>
````

## `<area>-map.md`

One file per feature area; the filename is the area name kebab-cased.

````markdown
---
kind: project-map-area
area: <name>
last-synced: <short SHA>
---

# <Area> Map

## Responsibility
<2–4 sentences: what this area does and where its edge is.>

## Entry points
- `<anchor>` — <path> ~L<n> — <what runs when execution enters here>

## Key files
| Path | Role |
|------|------|
| <path> | <one line — load-bearing files only> |

## Flow
1. <step> → `<anchor>` (<path> ~L<n>)
2. <step> → `<anchor>` (<path> ~L<n>)

## Cross-area edges
- Calls into: [`<area>`](./<area>-map.md) — <why>
- Called by: [`<area>`](./<area>-map.md) — <why>

## Gotchas
- <a constraint or the reason behind a choice that the code does not show on its face>
````

## `savings-log.csv`

Personal and gitignored. One row per task the map assisted.

```
date,area,tokens_saved,map_cost,note
2026-09-01,auth,9000,1200,found login flow without searching
```

- `tokens_saved` — rough size of the search the map let the agent skip.
- `map_cost` — tokens the agent spent reading the index and area file(s) this task.
- Keep `note` short and comma-free.

`savings-report.sh` reads this file:

```sh
.agent/project-map/savings-report.sh            # terminal report with bar chart
.agent/project-map/savings-report.sh --html     # writes .agent/project-map/savings.html
```

## Rules

- **Anchors locate; line numbers hint.** Every locator is a symbol name or unique grep-able
  string. A `~L<n>` may drift and is never the only locator.
- **Verify every anchor** with `grep` before writing it.
- **Load-bearing only.** The files and symbols a task must touch — not an inventory. `glob`
  already lists everything for free.
- **Do not cache the environment.** No build or test commands, no framework conventions. Cache
  what an agent cannot cheaply look up: flow, cross-area edges, gotchas.
- **~200 lines per area file.** Outgrown → split into sub-areas and add their index entries.
- **Coarse beats fine.** Fewer, broader areas mean a shorter index and fewer files opened per
  task. Add an area only for a distinct capability; name it in domain terms, never by folder
  or layer.
- **`last-synced`** is `git rev-parse --short HEAD` at the moment the file was last made
  accurate. Outside a git repo, use the date.

## Optional — pre-commit warning

Warns when a commit changes code but no map file. Never blocks. A no-op where hooks do not run,
so step 5 of the protocol still matters.

```sh
#!/bin/sh
# .git/hooks/pre-commit   (chmod +x)
c=$(git diff --cached --name-only)
code=$(printf '%s\n' "$c" | grep -vE '^\.agent/project-map/' | grep .)
maps=$(printf '%s\n' "$c" | grep -E '^\.agent/project-map/.*-map\.md$')
if [ -n "$code" ] && [ -z "$maps" ]; then
  echo "note: code changed, project map did not — refresh it if this moved a symbol or changed a flow (.agent/project-map/README.md)" >&2
fi
exit 0
```
