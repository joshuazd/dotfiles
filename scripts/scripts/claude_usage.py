#!/usr/bin/env python3
"""Claude Code org usage analyzer.

Reads a monthly CSV export from platform.claude.com and prints a terminal
report covering distribution, leaderboard, efficiency outliers, team
breakdown, and dormant license signal.
"""

import argparse
import csv
import glob
import json
import os
import re
import statistics
import subprocess
import sys
from pathlib import Path

ORG = "huntresslabs"
TEAMS = [
    "api-experience",
    "architects",
    "business-platform",
    "core-experience",
    "core-platform",
    "detection-platform",
    "edr-backend",
    "email-security",
    "espm",
    "idex",
    "ispm",
    "itdr",
    "siem",
    "soc-platform",
]
ROSTER_CACHE = Path.home() / ".cache" / "claude_usage_rosters.json"
ALIASES_FILE = Path.home() / ".config" / "claude_usage_aliases.json"
DOWNLOADS_GLOB = str(Path.home() / "Downloads" / "claude_code_team*.csv")
EMAIL_DOMAIN = "@huntresslabs.com"


def parse_args():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--csv", help="Path to CSV (default: newest in ~/Downloads)")
    p.add_argument("--refresh", action="store_true", help="Force re-fetch team rosters")
    p.add_argument("--top", type=int, default=20, help="Leaderboard size (default 20)")
    p.add_argument(
        "--min-lines",
        type=int,
        default=500,
        help="Min lines for efficiency ranking (default 500)",
    )
    return p.parse_args()


def find_csv(explicit):
    if explicit:
        path = Path(explicit).expanduser()
        if not path.exists():
            sys.exit(f"CSV not found: {path}")
        return path
    matches = sorted(glob.glob(DOWNLOADS_GLOB), key=os.path.getmtime, reverse=True)
    if not matches:
        sys.exit(f"No CSV found matching {DOWNLOADS_GLOB}")
    return Path(matches[0])


def parse_date_range(filename):
    m = re.search(r"(\d{4}_\d{2}_\d{2})_to_(\d{4}_\d{2}_\d{2})", filename)
    if not m:
        return None
    start = m.group(1).replace("_", "-")
    end = m.group(2).replace("_", "-")
    return f"{start} → {end}"


def fetch_rosters(refresh):
    if not refresh and ROSTER_CACHE.exists():
        with open(ROSTER_CACHE) as f:
            return json.load(f)
    print("Fetching team rosters from GitHub...", file=sys.stderr)
    rosters = {}
    for team in TEAMS:
        result = subprocess.run(
            [
                "gh",
                "api",
                f"orgs/{ORG}/teams/{team}/members",
                "--paginate",
                "--jq",
                ".[].login",
            ],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            sys.exit(f"gh api failed for team {team}: {result.stderr}")
        rosters[team] = [line.strip() for line in result.stdout.splitlines() if line.strip()]
    ROSTER_CACHE.parent.mkdir(parents=True, exist_ok=True)
    with open(ROSTER_CACHE, "w") as f:
        json.dump(rosters, f, indent=2)
    return rosters


def normalize(s):
    return re.sub(r"[._\-]", "", s.lower())


SUFFIX_PATTERNS = [
    r"-huntress$", r"huntress$", r"-hs$", r"-hunt$",
    r"-labs$", r"-gh$", r"\d+$",
]


def canonical_login(login):
    """Strip decorative org-affiliation suffixes from a GitHub login.

    Iteratively peels off patterns like `-huntress`, `-hs`, trailing digits, etc.
    so `dereklohnes-huntress`, `brentmiller-42`, `chrisbloom7` all reduce to a
    bare normalized handle. The `len(new) >= 3` guard prevents over-stripping
    short logins down to nothing.
    """
    s = login.lower()
    changed = True
    while changed:
        changed = False
        for pat in SUFFIX_PATTERNS:
            new = re.sub(pat, "", s)
            if new != s and len(new) >= 3:
                s = new
                changed = True
    return normalize(s)


def email_candidates(local):
    """Generate normalized candidate login forms for an email local-part.

    Handles `first.last` → `firstlast`, `joshua.zink-duda` → `joshuazd`,
    `chris.gratigny` → `cgratigny`, etc. Ordered most-specific first.
    """
    parts = [p for p in re.split(r"[.\-_]", local.lower()) if p]
    if not parts:
        return []
    cands = []
    cands.append("".join(parts))                              # firstlast
    if len(parts) >= 2:
        cands.append(parts[0] + "".join(p[0] for p in parts[1:]))  # joshuazd
        cands.append(parts[0][0] + "".join(parts[1:]))             # cgratigny
        cands.append("".join(p[0] for p in parts))                 # jzd
        cands.append("".join(reversed(parts)))                     # woodbyjacob
    seen = set()
    return [c for c in cands if not (c in seen or seen.add(c))]


def build_login_to_team(rosters):
    mapping = {}
    for team, logins in rosters.items():
        for login in logins:
            for key in (normalize(login), canonical_login(login)):
                mapping.setdefault(key, []).append(team)
    return mapping


def load_aliases():
    if not ALIASES_FILE.exists():
        return {}
    raw = json.loads(ALIASES_FILE.read_text())
    return {k.lower(): v for k, v in raw.items() if not k.startswith("_")}


def lookup_team(local, login_to_team, aliases):
    for cand in email_candidates(local):
        teams = login_to_team.get(cand)
        if teams:
            return teams[0]
    alias_login = aliases.get(local.lower())
    if alias_login:
        teams = login_to_team.get(normalize(alias_login))
        if teams:
            return teams[0]
    return None


def parse_spend(s):
    return float(s.replace("$", "").replace(",", "").strip())


def parse_lines(s):
    return int(s.replace(",", "").replace('"', "").strip())


def classify_user(user, login_to_team, aliases):
    if "[API key]" in user:
        return {"kind": "api_key", "team": "API keys", "display": user.replace(" [API key]", "")}
    if EMAIL_DOMAIN in user.lower():
        local = user.lower().split("@", 1)[0]
        team = lookup_team(local, login_to_team, aliases) or "Unaffiliated"
        display = local.replace(".", " ").replace("-", " ").title()
        return {"kind": "human", "team": team, "display": display}
    return {"kind": "other", "team": "Other", "display": user}


def load_rows(csv_path, login_to_team, aliases):
    rows = []
    with open(csv_path, newline="") as f:
        reader = csv.reader(f)
        next(reader)  # header
        for raw in reader:
            if len(raw) < 3 or not raw[0]:
                continue
            user, spend_s, lines_s = raw[0], raw[1], raw[2]
            spend = parse_spend(spend_s)
            lines = parse_lines(lines_s)
            info = classify_user(user, login_to_team, aliases)
            rows.append(
                {
                    "user": user,
                    "spend": spend,
                    "lines": lines,
                    **info,
                }
            )
    return rows


def percentile(values, pct):
    if not values:
        return 0.0
    sorted_values = sorted(values)
    k = (len(sorted_values) - 1) * (pct / 100)
    f = int(k)
    c = min(f + 1, len(sorted_values) - 1)
    if f == c:
        return sorted_values[f]
    return sorted_values[f] + (sorted_values[c] - sorted_values[f]) * (k - f)


def dollars(v):
    return f"${v:,.2f}"


def humanint(v):
    return f"{v:,}"


def cost_per_kloc(row):
    if row["lines"] <= 0:
        return None
    return row["spend"] / row["lines"] * 1000


def section(title):
    return f"\n{title}\n{'=' * len(title)}"


def render_header(csv_path, rows, date_range):
    print(section("Claude Code Org Usage"))
    print(f"File:  {csv_path.name}")
    if date_range:
        print(f"Range: {date_range}")
    print(f"Rows:  {len(rows)}")


def render_overall(rows):
    humans = [r for r in rows if r["kind"] == "human"]
    api_keys = [r for r in rows if r["kind"] == "api_key"]
    total_spend = sum(r["spend"] for r in rows)
    api_spend = sum(r["spend"] for r in api_keys)
    total_lines = sum(r["lines"] for r in rows)
    print(section("Overall"))
    print(f"Total spend:   {dollars(total_spend)}")
    print(f"Total lines:   {humanint(total_lines)}")
    print(f"Humans:        {len(humans)}")
    print(f"API keys:      {len(api_keys)}")
    api_pct = (api_spend / total_spend * 100) if total_spend else 0
    print(f"API key spend: {dollars(api_spend)} ({api_pct:.1f}% of total)")


def render_distribution(rows):
    humans = [r for r in rows if r["kind"] == "human"]
    spends = [r["spend"] for r in humans]
    if not spends:
        return
    p50 = percentile(spends, 50)
    p75 = percentile(spends, 75)
    p90 = percentile(spends, 90)
    p99 = percentile(spends, 99)
    mean = statistics.mean(spends)
    skew = mean / p50 if p50 else float("inf")
    print(section("Distribution (humans)"))
    print(f"p50: {dollars(p50)}")
    print(f"p75: {dollars(p75)}")
    print(f"p90: {dollars(p90)}")
    print(f"p99: {dollars(p99)}")
    print(f"mean: {dollars(mean)}  (mean/median = {skew:.2f}x → {'right-skewed' if skew > 1.5 else 'roughly balanced'})")


def render_pareto(rows):
    humans = sorted(
        [r for r in rows if r["kind"] == "human"], key=lambda r: r["spend"], reverse=True
    )
    total = sum(r["spend"] for r in humans)
    if not total:
        return
    print(section("Pareto (human spend share)"))
    for n in (1, 5, 10, 20):
        share = sum(r["spend"] for r in humans[:n]) / total * 100
        print(f"Top {n:>2}: {share:5.1f}%")
    median_spend = percentile([r["spend"] for r in humans], 50)
    print(f"Median human spends {dollars(median_spend)}")


def compute_tiers(rows):
    """Dynamic tiers from non-dormant human spend percentiles."""
    spenders = [r["spend"] for r in rows if r["kind"] == "human" and r["spend"] > 0]
    if not spenders:
        return None
    return {
        "whale": percentile(spenders, 90),
        "heavy": percentile(spenders, 75),
        "regular": percentile(spenders, 50),
    }


def tier_for(spend, tiers):
    if spend == 0:
        return "Dormant"
    if spend >= tiers["whale"]:
        return "Whale"
    if spend >= tiers["heavy"]:
        return "Heavy"
    if spend >= tiers["regular"]:
        return "Regular"
    return "Dabbler"


def render_tiers(rows, tiers):
    print(section("Spend tiers (dynamic — humans only)"))
    if not tiers:
        print("(no non-dormant spenders)")
        return
    print(f"Cutoffs derived from non-dormant percentiles:")
    print(f"  Whale   ≥ p90  ({dollars(tiers['whale'])})")
    print(f"  Heavy   ≥ p75  ({dollars(tiers['heavy'])})")
    print(f"  Regular ≥ p50  ({dollars(tiers['regular'])})")
    print(f"  Dabbler > $0")
    print(f"  Dormant = $0")
    print()
    buckets = {"Whale": [], "Heavy": [], "Regular": [], "Dabbler": [], "Dormant": []}
    for r in rows:
        if r["kind"] != "human":
            continue
        buckets[tier_for(r["spend"], tiers)].append(r)
    print(f"{'Tier':<8} {'Count':>6} {'Total':>14} {'Avg':>12}")
    for name in ("Whale", "Heavy", "Regular", "Dabbler", "Dormant"):
        members = buckets[name]
        count = len(members)
        total = sum(m["spend"] for m in members)
        avg = total / count if count else 0
        print(f"{name:<8} {count:>6} {dollars(total):>14} {dollars(avg):>12}")


def render_leaderboard(rows, top_n):
    humans = sorted(
        [r for r in rows if r["kind"] == "human"], key=lambda r: r["spend"], reverse=True
    )[:top_n]
    print(section(f"Top {top_n} spenders (humans)"))
    print(f"{'#':>3}  {'Name':<28} {'Spend':>11} {'Lines':>10} {'$/1k ln':>10}  Team")
    for i, r in enumerate(humans, 1):
        ckl = cost_per_kloc(r)
        ckl_s = f"${ckl:.2f}" if ckl is not None else "—"
        print(
            f"{i:>3}  {r['display']:<28} {dollars(r['spend']):>11} "
            f"{humanint(r['lines']):>10} {ckl_s:>10}  {r['team']}"
        )


def render_efficiency(rows, min_lines):
    eligible = [
        r for r in rows if r["kind"] == "human" and r["lines"] >= min_lines and r["spend"] > 0
    ]
    if not eligible:
        return
    ranked = sorted(eligible, key=cost_per_kloc, reverse=True)
    print(section(f"Efficiency outliers (≥ {min_lines} lines)"))
    print("Heavy thinkers — highest $/1k lines (likely Opus/agentic):")
    for r in ranked[:5]:
        print(
            f"  ${cost_per_kloc(r):>6.2f}/1k  {r['display']:<28} "
            f"{dollars(r['spend']):>10}  {humanint(r['lines']):>8} ln  {r['team']}"
        )
    print()
    print("Light/efficient — lowest $/1k lines (likely Haiku/simple edits):")
    for r in ranked[-5:][::-1]:
        print(
            f"  ${cost_per_kloc(r):>6.2f}/1k  {r['display']:<28} "
            f"{dollars(r['spend']):>10}  {humanint(r['lines']):>8} ln  {r['team']}"
        )


def render_teams(rows):
    by_team = {}
    for r in rows:
        by_team.setdefault(r["team"], []).append(r)
    summaries = []
    for team, members in by_team.items():
        active = [m for m in members if m["spend"] > 0]
        total_spend = sum(m["spend"] for m in members)
        total_lines = sum(m["lines"] for m in members)
        top = max(members, key=lambda m: m["spend"]) if members else None
        summaries.append(
            {
                "team": team,
                "active": len(active),
                "total_members": len(members),
                "spend": total_spend,
                "lines": total_lines,
                "avg": total_spend / len(active) if active else 0,
                "top_name": top["display"] if top else "—",
                "top_spend": top["spend"] if top else 0,
            }
        )
    summaries.sort(key=lambda s: s["spend"], reverse=True)
    print(section("Team breakdown (sorted by total spend)"))
    print(
        f"{'Team':<22} {'Active':>7} {'Spend':>12} {'Lines':>10} "
        f"{'Avg':>10}  Top contributor"
    )
    for s in summaries:
        active_s = f"{s['active']}/{s['total_members']}"
        top_s = f"{s['top_name']} ({dollars(s['top_spend'])})" if s["top_spend"] else "—"
        print(
            f"{s['team']:<22} {active_s:>7} {dollars(s['spend']):>12} "
            f"{humanint(s['lines']):>10} {dollars(s['avg']):>10}  {top_s}"
        )


def render_dormant(rows):
    dormant = [r for r in rows if r["kind"] == "human" and r["spend"] == 0]
    print(section(f"Dormant access — {len(dormant)} humans at $0 (license waste signal)"))
    for r in sorted(dormant, key=lambda x: x["display"]):
        print(f"  {r['display']:<28}  {r['team']}")


def main():
    args = parse_args()
    csv_path = find_csv(args.csv)
    date_range = parse_date_range(csv_path.name)
    rosters = fetch_rosters(args.refresh)
    login_to_team = build_login_to_team(rosters)
    aliases = load_aliases()
    rows = load_rows(csv_path, login_to_team, aliases)

    render_header(csv_path, rows, date_range)
    render_overall(rows)
    render_distribution(rows)
    render_pareto(rows)
    tiers = compute_tiers(rows)
    render_tiers(rows, tiers)
    render_leaderboard(rows, args.top)
    render_efficiency(rows, args.min_lines)
    render_teams(rows)
    render_dormant(rows)


if __name__ == "__main__":
    main()
