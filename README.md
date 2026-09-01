# usefull-skills

Small, self-contained skills for AI coding agents, distributed as a
[Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces).
Install once — every skill added here later arrives with a single update command.

## Skills

| Skill | What it does |
|-------|--------------|
| **project-map-skill** | Maintains `.agent/project-map/`, a committed index of where each feature's code lives, so agents jump to the right files instead of searching the whole repo every task. Catches its own stale entries and tracks the tokens it saves. |

## Install

In Claude Code:

```
/plugin marketplace add alam-gir/usefull-skills
/plugin install project-map-skill@usefull-skills
```

- **Update** (also picks up newly added skills) — `/plugin marketplace update`
- **Uninstall** — `/plugin uninstall project-map-skill@usefull-skills`
- **Team-wide** — commit `.claude/settings.json` with the marketplace and plugin listed under
  `extraKnownMarketplaces` / `enabledPlugins` so every clone gets it automatically.

Other agents (Cursor, etc.): they can't use the plugin, but the map itself is plain Markdown.
Let a Claude session build it once, or point your agent at
`plugins/project-map-skill/PROTOCOL.md`.

## How project-map-skill works

1. **First run in a repo** — a quick look at the layout writes `.agent/project-map/index-map.md`.
2. **Each task** — the agent reads the small index, opens only the area file it needs, and
   navigates by symbol anchors. No repo-wide search.
3. **After a structural change** — it updates the area files it touched. Stale entries are
   caught when used and repaired on the spot.
4. The map is committed, so a fresh clone is already navigable. `savings-log.csv` stays local;
   run `.agent/project-map/savings-report.sh` (or `--html`) to see what it saved.

## Repository layout

```
.claude-plugin/marketplace.json     catalog of the skills below
plugins/<skill>/                     one folder per skill
  .claude-plugin/plugin.json
  SKILL.md                           + any support files
```

### Adding a skill

1. `mkdir -p plugins/<name>/.claude-plugin`
2. Write `plugins/<name>/SKILL.md` and `plugins/<name>/.claude-plugin/plugin.json`
   (copy an existing one; start at `"version": "0.1.0"`).
3. Add one entry to the `plugins` array in `.claude-plugin/marketplace.json`.
4. Add a row to the table above, commit, push.

Users run `/plugin marketplace update`, then `/plugin install <name>@usefull-skills`.
To ship a fix to an installed skill, bump its `version` in `plugin.json`.

## License

MIT — see [LICENSE](./LICENSE).
