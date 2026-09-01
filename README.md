# usefull-skills

Small, self-contained skills for AI coding agents. Each folder is one
[Claude Code skill](https://docs.claude.com/en/docs/claude-code/skills) — install it once and
it activates when it is relevant.

## Skills

| Skill | What it does |
|-------|--------------|
| [**project-map-skill**](./project-map-skill) | Maintains `.agent/project-map/`, a committed index of where each feature's code lives, so agents jump to the right files instead of searching the whole repo every task. Catches its own stale entries and logs the tokens it saves. |

## Install

```sh
git clone https://github.com/alam-gir/usefull-skills.git
ln -s "$(pwd)/usefull-skills/project-map-skill" ~/.claude/skills/project-map-skill
```

- **Update** — `git pull` in the clone.
- **Uninstall** — delete the symlink.
- **One project only** — symlink into that project's `.claude/skills/` instead of `~/.claude/skills/`.

Non-Claude agents: point them at a skill's `PROTOCOL.md`, or just let one build the map — any
agent can then read `.agent/project-map/README.md`.

## How project-map-skill works

1. **First run in a repo** — a quick look at the layout writes `.agent/project-map/index-map.md`.
2. **Each task** — the agent reads the small index, opens only the area file it needs, and
   navigates by symbol anchors. No repo-wide search.
3. **After a structural change** — it updates the area files it touched. Stale entries are
   caught when used and repaired on the spot.
4. The map is committed, so a fresh clone is already navigable and the whole team's agents
   benefit. `savings-log.csv` stays local to each developer.

## License

MIT — see [LICENSE](./LICENSE).
