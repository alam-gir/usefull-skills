#!/bin/sh
# Report token savings recorded by the project-map skill.
#
#   savings-report.sh [--html [outfile]] [path-to-savings-log.csv]
#
# Default: prints a terminal report.
# --html:  writes a standalone HTML dashboard (default .agent/project-map/savings.html)
#          and prints its path.
#
# CSV columns: date,area,tokens_saved,map_cost,note

mode=text
html_out=""
log=""

while [ $# -gt 0 ]; do
  case "$1" in
    --html)
      mode=html
      case "$2" in
        ""|--*) : ;;
        *.html) html_out="$2"; shift ;;
      esac
      ;;
    -h|--help)
      sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) log="$1" ;;
  esac
  shift
done

[ -n "$log" ] || log=".agent/project-map/savings-log.csv"
[ -n "$html_out" ] || html_out="$(dirname "$log")/savings.html"

if [ ! -f "$log" ]; then
  echo "No savings log at: $log" >&2
  exit 1
fi

awk -F',' -v mode="$mode" -v out="$html_out" -v today="$(date +%Y-%m-%d)" '
function commafy(n,   s, neg) {
  n = int(n); if (n < 0) { neg = 1; n = -n }
  s = ""
  while (n >= 1000) { s = sprintf(",%03d", n % 1000) s; n = int(n / 1000) }
  return (neg ? "-" : "") n s
}
function esc(x) { gsub(/&/, "\\&amp;", x); gsub(/</, "\\&lt;", x); gsub(/>/, "\\&gt;", x); return x }

NR == 1 && $1 == "date" { next }
{
  if ($3 !~ /^-?[0-9]+$/) next
  saved = $3 + 0
  if ($4 ~ /^-?[0-9]+$/) { cost = $4 + 0; ni = 5 } else { cost = 0; ni = 4 }
  note = $ni
  for (i = ni + 1; i <= NF; i++) note = note "," $i
  net = saved - cost

  gross += saved; overhead += cost; total += net; n++
  anet[$2] += net; acnt[$2]++
  if (first == "" || $1 < first) first = $1
  k++; d[k] = $1; a[k] = $2; v[k] = net; t[k] = note
}
END {
  if (n == 0) {
    if (mode == "html") { print "no entries yet" > out; close(out); print out }
    else print "  No entries yet."
    exit 0
  }

  # order areas by net desc (simple insertion sort over keys)
  na = 0
  for (x in anet) { na++; ord[na] = x }
  for (i = 2; i <= na; i++) { key = ord[i]; j = i - 1
    while (j >= 1 && anet[ord[j]] < anet[key]) { ord[j+1] = ord[j]; j-- }
    ord[j+1] = key }
  maxnet = (na > 0) ? anet[ord[1]] : 1
  if (maxnet < 1) maxnet = 1
  avg = int(total / n)
  lo = (k > 5) ? k - 4 : 1

  if (mode == "text") {
    printf "\n  Project Map \xE2\x80\x94 token savings\n"
    printf "  ===============================================\n\n"
    printf "  Saved (gross)   ~%s\n", commafy(gross)
    printf "  Map overhead    ~%s\n", commafy(overhead)
    printf "  Net saved       ~%s tokens\n", commafy(total)
    printf "  Tasks assisted  %d   (~%s net/task)\n", n, commafy(avg)
    printf "  Since           %s\n\n", first
    printf "  By area (net saved)\n"
    for (i = 1; i <= na; i++) {
      x = ord[i]; w = int(anet[x] / maxnet * 24); if (w < 1 && anet[x] > 0) w = 1
      bar = ""; for (b = 0; b < w; b++) bar = bar "\xE2\x96\x88"
      printf "    %-12s %9s  %3d\xC3\x97  %s\n", substr(x,1,12), commafy(anet[x]), acnt[x], bar
    }
    printf "\n  Recent\n"
    for (i = lo; i <= k; i++)
      printf "    %s  %-12s +%-8s %s\n", d[i], substr(a[i],1,12), commafy(v[i]), t[i]
    print ""
    exit 0
  }

  # ---- HTML ----
  print "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">" > out
  print "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">" > out
  print "<title>Project Map \xE2\x80\x94 token savings</title><style>" > out
  print ":root{color-scheme:light dark}" > out
  print "body{margin:0;font:15px/1.5 ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,sans-serif;background:#fbfbfa;color:#1a1a1a}" > out
  print "@media(prefers-color-scheme:dark){body{background:#16161a;color:#e8e8ea}.card{background:#202027!important;border-color:#2f2f38!important}.bar{background:#2f2f38!important}}" > out
  print "main{max-width:760px;margin:0 auto;padding:40px 24px}" > out
  print "h1{font-size:20px;margin:0 0 4px}.sub{color:#888;font-size:13px;margin:0 0 28px}" > out
  print "h2{font-size:13px;text-transform:uppercase;letter-spacing:.06em;color:#888;margin:32px 0 12px}" > out
  print ".stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px}" > out
  print ".card{background:#fff;border:1px solid #ececec;border-radius:10px;padding:14px 16px}" > out
  print ".card .k{display:block;font-size:12px;color:#888}.card .v{font-size:20px;font-weight:600}" > out
  print ".row{display:grid;grid-template-columns:110px 1fr 90px;align-items:center;gap:10px;margin:6px 0;font-size:14px}" > out
  print ".track{background:transparent}.bar{background:#e8e8e8;height:22px;border-radius:5px}" > out
  print ".fill{background:linear-gradient(90deg,#4f7cff,#7a5cff);height:22px;border-radius:5px}" > out
  print ".num{text-align:right;font-variant-numeric:tabular-nums;color:#555}" > out
  print "table{width:100%;border-collapse:collapse;font-size:13px}td{padding:7px 8px;border-top:1px solid #ececec}" > out
  print "td.n{text-align:right;font-variant-numeric:tabular-nums;color:#2c8a3d;white-space:nowrap}" > out
  print "footer{margin-top:36px;color:#aaa;font-size:12px}" > out
  print "</style></head><body><main>" > out
  print "<h1>Project Map \xE2\x80\x94 token savings</h1>" > out
  printf "<p class=\"sub\">%d tasks assisted since %s \xC2\xB7 rough estimates</p>\n", n, first > out
  print "<div class=\"stats\">" > out
  printf "<div class=\"card\"><span class=\"k\">Net saved</span><span class=\"v\">~%s</span></div>\n", commafy(total) > out
  printf "<div class=\"card\"><span class=\"k\">Gross saved</span><span class=\"v\">~%s</span></div>\n", commafy(gross) > out
  printf "<div class=\"card\"><span class=\"k\">Map overhead</span><span class=\"v\">~%s</span></div>\n", commafy(overhead) > out
  printf "<div class=\"card\"><span class=\"k\">Net / task</span><span class=\"v\">~%s</span></div>\n", commafy(avg) > out
  print "</div>" > out
  print "<h2>By area (net saved)</h2>" > out
  for (i = 1; i <= na; i++) {
    x = ord[i]; pct = int(anet[x] / maxnet * 100); if (pct < 2 && anet[x] > 0) pct = 2
    printf "<div class=\"row\"><span>%s</span><span class=\"bar\"><span class=\"fill\" style=\"width:%d%%\"></span></span><span class=\"num\">%s &nbsp; %d\xC3\x97</span></div>\n", esc(x), pct, commafy(anet[x]), acnt[x] > out
  }
  print "<h2>Recent</h2><table>" > out
  for (i = k; i >= lo; i--)
    printf "<tr><td>%s</td><td>%s</td><td class=\"n\">+%s</td><td>%s</td></tr>\n", d[i], esc(a[i]), commafy(v[i]), esc(t[i]) > out
  print "</table>" > out
  printf "<footer>Generated %s by savings-report.sh</footer>\n", today > out
  print "</main></body></html>" > out
  close(out)
  print out
}
' "$log"
