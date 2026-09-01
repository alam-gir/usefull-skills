# Project map protocol

`.agent/project-map/` records where each feature's code lives so an AI agent goes straight to
the right files instead of re-exploring the repo. It works with any agent. This file is the
whole protocol.

## Locate code

1. Read `index-map.md`. Match the task to one or more areas by their trigger keywords.
2. Open **only** those `<area>-map.md` files.
3. Navigate by anchors — the backticked symbol names and unique strings. A `~L<n>` beside an
   anchor is a hint only; `grep` the anchor to land on it. Read just the regions the map cites.
4. Trust the map by default. Before relying on it for a high-stakes change you may confirm an
   area is current:

   ```
   git diff --stat <that area's last-synced>..HEAD -- <its key file paths>
   ```

   Empty output means nothing moved since the map was synced.
5. If an anchor is missing, a file has moved, or a flow no longer matches, that area is stale.
   Finish the task by searching manually, then repair the area file and set its `last-synced`
   to `git rev-parse --short HEAD`.

## Refresh after a change

Refresh the map when your change **either** makes an existing area file wrong **or** adds
something a future task will need to find. Concretely: a moved or renamed symbol other code
references, a new entry point, an altered flow, a new gotcha, or a new capability.

- Update every affected `<area>-map.md` and its matching index entry.
- `grep`-verify every anchor you write.
- Set each touched file's `last-synced` to `git rev-parse --short HEAD`.
- A new capability with no area → add a `<area>-map.md` and an index entry, but only if
  building it meant tracing through existing code to find where it plugs in. A self-contained
  addition can wait until a task actually needs to locate it.
- While you are in an area file, delete anything that is now noise. Keep it under ~200 lines.

Skip the refresh for internal edits the map does not cite, typos, comments, formatting, copy
tweaks, and one-liners in familiar code.
