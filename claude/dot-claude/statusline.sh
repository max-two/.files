#!/bin/bash

# Status line script for Claude Code
# Line 1:  project_dir • worktree •  branch (color = git state) • PR↗
# Line 2: model [effort] • progress_bar pct% •  tokens • cost • [agent]
# Caches git status and PR link (5s)

CACHE_DIR="/tmp/claude-statusline"
CACHE_TTL=5

mkdir -p "$CACHE_DIR"

input=$(cat)

# --- Extract fields from JSON ---
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir')
MODEL=$(echo "$input" | jq -r '.model.display_name')
AGENT_NAME=$(echo "$input" | jq -r '.agent.name // empty')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
TOTAL_INPUT=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
TOTAL_OUTPUT=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# --- Write metrics snapshot for stats tracking (atomic write) ---
METRICS_TMP="/tmp/claude-stats-latest.json.tmp.$$"
if echo "$input" | jq -c '{input_tokens: (.context_window.total_input_tokens // 0), output_tokens: (.context_window.total_output_tokens // 0), cost_usd: (.cost.total_cost_usd // 0), session_id: (.session_id // "")}' > "$METRICS_TMP" 2>/dev/null; then
  mv "$METRICS_TMP" /tmp/claude-stats-latest.json
else
  rm -f "$METRICS_TMP"
fi

# --- Colors ---
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
CYAN='\033[36m'
BLUE='\033[34m'
MAGENTA='\033[35m'
DIM='\033[90m'
RESET='\033[0m'

# Branch-state colors (256-color, matched to the p10k prompt).
GIT_CLEAN='\033[38;5;76m'      # green  — clean and in sync with origin
GIT_UNPUSHED='\033[38;5;220m'  # yellow — commits not pushed to origin
GIT_LOCAL='\033[38;5;208m'     # orange — uncommitted local changes

SEP="${DIM} ◆ ${RESET}"

# --- Icons (Nerd Font v3, built from octal UTF-8 so no multibyte literals) ---
FOLDER_ICON=$(printf '\357\201\273')  # nf-fa-folder       U+F07B
GIT_ICON=$(printf '\356\234\245')     # nf-dev-git-branch  U+E725
TOKEN_ICON=$(printf '\357\224\236')   # nf-fa-coins        U+F51E

# --- Cache helper ---
cache_is_stale() {
    local file="$1"
    [ ! -f "$file" ] || \
    [ $(($(date +%s) - $(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null || echo 0))) -gt "$CACHE_TTL" ]
}

CACHE_KEY=$(echo "$PROJECT_DIR" | sed 's/[^a-zA-Z0-9]/_/g')

# --- Git info (cached) ---
GIT_CACHE="$CACHE_DIR/git_${CACHE_KEY}"

if cache_is_stale "$GIT_CACHE"; then
    if git -C "$PROJECT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
        BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null)
        STAGED=$(git -C "$PROJECT_DIR" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        MODIFIED=$(git -C "$PROJECT_DIR" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        UNTRACKED=$(git -C "$PROJECT_DIR" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

        GIT_COMMON=$(git -C "$PROJECT_DIR" rev-parse --git-common-dir 2>/dev/null)
        GIT_DIR=$(git -C "$PROJECT_DIR" rev-parse --git-dir 2>/dev/null)
        if [ "$GIT_COMMON" != "$GIT_DIR" ] && [ -n "$GIT_COMMON" ]; then
            WORKTREE=$(basename "$PROJECT_DIR")
        else
            WORKTREE=""
        fi

        CLEAN=0
        [ "$STAGED" -eq 0 ] && [ "$MODIFIED" -eq 0 ] && [ "$UNTRACKED" -eq 0 ] && CLEAN=1

        # Commits on the local branch not yet pushed to its upstream (0 when
        # there is no upstream, e.g. a branch never pushed to origin).
        AHEAD=$(git -C "$PROJECT_DIR" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
        [ -z "$AHEAD" ] && AHEAD=0

        echo "${BRANCH}|${STAGED}|${MODIFIED}|${UNTRACKED}|${CLEAN}|${WORKTREE}|${AHEAD}" > "$GIT_CACHE"
    else
        echo "||||||" > "$GIT_CACHE"
    fi
fi

IFS='|' read -r BRANCH STAGED MODIFIED UNTRACKED CLEAN WORKTREE AHEAD < "$GIT_CACHE"

# --- PR link (cached) ---
PR_CACHE="$CACHE_DIR/pr_${CACHE_KEY}"

if cache_is_stale "$PR_CACHE"; then
    PR_LINK=""
    if [ -n "$BRANCH" ] && [ "$BRANCH" != "master" ] && [ "$BRANCH" != "main" ]; then
        PR_URL=$(gh pr view "$BRANCH" --repo "$(git -C "$PROJECT_DIR" remote get-url origin 2>/dev/null)" --json url -q .url 2>/dev/null || echo "")
        if [ -n "$PR_URL" ]; then
            PR_LINK="\033]8;;${PR_URL}\033\\PR↗\033]8;;\033\\"
        fi
    fi
    echo "$PR_LINK" > "$PR_CACHE"
fi

PR_LINK=$(cat "$PR_CACHE")

# --- Helper: join array elements with separator ---
join_parts() {
    local result=""
    for part in "$@"; do
        if [ -n "$result" ]; then
            result+="$SEP"
        fi
        result+="$part"
    done
    echo "$result"
}

# ============================================================
# LINE 1: [project_dir] • worktree •  branch status • PR↗
# ============================================================
L1_PARTS=()

L1_PARTS+=("${BLUE}${FOLDER_ICON} ${PROJECT_DIR##*/}${RESET}")

if [ -n "$WORKTREE" ]; then
    L1_PARTS+=("${MAGENTA}${WORKTREE}${RESET}")
fi

if [ -n "$BRANCH" ]; then
    # Branch icon + name colored by state: orange = local changes,
    # yellow = unpushed commits, green = clean & in sync (orange > yellow > green).
    if [ "$CLEAN" != "1" ]; then
        GIT_COLOR="$GIT_LOCAL"
    elif [ "${AHEAD:-0}" -gt 0 ]; then
        GIT_COLOR="$GIT_UNPUSHED"
    else
        GIT_COLOR="$GIT_CLEAN"
    fi
    L1_PARTS+=("${GIT_COLOR}${GIT_ICON} ${BRANCH}${RESET}")
fi

if [ -n "$PR_LINK" ]; then
    L1_PARTS+=("$PR_LINK")
fi

LINE1=$(join_parts "${L1_PARTS[@]}")

# ============================================================
# LINE 2: model • progress_bar pct% • tokens • cost • [agent]
# ============================================================

# Progress bar (10 chars)
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))

if [ "$PCT" -ge 70 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 20 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"
fi

BAR=""
[ "$FILLED" -gt 0 ] && BAR=$(printf "%${FILLED}s" | tr ' ' '█')
[ "$EMPTY" -gt 0 ] && BAR="${BAR}$(printf "%${EMPTY}s" | tr ' ' '░')"

COST_FMT=$(printf '$%.2f' "$COST")

L2_PARTS=()
if [ -n "$EFFORT" ]; then
    L2_PARTS+=("${CYAN}${MODEL} [${EFFORT}]${RESET}")
else
    L2_PARTS+=("${CYAN}${MODEL}${RESET}")
fi

if [ -n "$AGENT_NAME" ]; then
    L2_PARTS+=("${MAGENTA}[${AGENT_NAME}]${RESET}")
fi

L2_PARTS+=("${BAR_COLOR}${BAR}${RESET} ${BAR_COLOR}${PCT}%${RESET}")
TOTAL_TOKENS=$((TOTAL_INPUT + TOTAL_OUTPUT))
TOKENS_FMT=$(printf "%'d" "$TOTAL_TOKENS")
L2_PARTS+=("${BAR_COLOR}${TOKEN_ICON} ${TOKENS_FMT}${RESET}")
L2_PARTS+=("${YELLOW}${COST_FMT}${RESET}")

LINE2=$(join_parts "${L2_PARTS[@]}")

# ============================================================
# Output
# ============================================================
printf '%b\n' "$LINE1"
printf '%b\n' "$LINE2"
