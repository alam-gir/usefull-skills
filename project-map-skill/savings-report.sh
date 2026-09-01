#!/bin/sh
# Running total from a project-map savings log.
# Usage: savings-report.sh [path-to-savings-log.csv]

log="${1:-.agent/project-map/savings-log.csv}"

if [ ! -f "$log" ]; then
  echo "No savings log at: $log" >&2
  exit 1
fi

awk -F',' '
  NR == 1 { next }                                  # skip header
  $3 ~ /^[0-9]+$/ { total += $3; n += 1 }
  END {
    if (n == 0) { print "No entries yet."; exit 0 }
    printf "%d tasks logged  -  ~%d tokens saved (rough estimate)\n", n, total
  }
' "$log"
