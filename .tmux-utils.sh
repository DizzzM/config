# --- tmux helpers -------------------------------------------------------------

# tmux_new <session-name>
# Create or attach to a tmux session with:
#   - window 0: "monitor" running btop/htop/top
#   - window 1: "shell"
tmux_new() {
  local name="$1"
  if [ -z "$name" ]; then
    echo "Usage: tmux_new <session-name>" >&2
    return 1
  fi

  if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux not found." >&2
    return 1
  fi

  local attach_cmd="attach-session -t"
  [ -n "$TMUX" ] && attach_cmd="switch-client -t"

  # attach if exists
  if tmux has-session -t "$name" 2>/dev/null; then
    tmux $attach_cmd "$name"
    return 0
  fi

  # create detached session
  tmux new-session -d -s "$name" -n monitor

  # start monitor program
  if command -v btop >/dev/null 2>&1; then
    tmux send-keys -t "$name":0 'btop' C-m
  elif command -v htop >/dev/null 2>&1; then
    tmux send-keys -t "$name":0 'htop' C-m
  else
    tmux send-keys -t "$name":0 'top' C-m
  fi

  # second window: shell
  tmux new-window -t "$name":1 -n shell
  tmux select-window -t "$name":1
  tmux $attach_cmd "$name"
}

# tmux_pick
# Full-screen selector (list at bottom) with "Create new session…" option.
tmux_pick() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux not found." >&2
    return 1
  fi
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found." >&2
    return 1
  fi

  local attach_cmd="attach-session -t"
  [ -n "$TMUX" ] && attach_cmd="switch-client -t"

  # Gather sessions (names only)
  local sessions
  sessions=$(tmux list-sessions -F '#S' 2>/dev/null || true)

  # If no sessions, jump straight to creation
  if [ -z "$sessions" ]; then
    read -rp "No sessions. New session name: " name
    [ -z "$name" ] && return 0
    tmux_new "$name"
    return $?
  fi

  # Build menu with a "Create new…" entry
  local choice
  choice=$(
    { printf '%s\n' "+ Create new session…"; printf '%s\n' "$sessions"; } |
    fzf --height=100% --layout=default --border=none --no-info \
        --prompt='Select session to attach ' --exit-0 --color=bg:-1,bg+:-1,preview-bg:-1,gutter:-1,border:-1
  )

  # If user cancelled
  [ -z "$choice" ] && return 0

  if [ "$choice" = "+ Create new session…" ]; then
    local name
    read -rp "New session name: " name
    [ -z "$name" ] && return 0
    tmux_new "$name"
  else
    tmux $attach_cmd "$choice"
  fi
}

# Optional convenience aliases:
alias tmux-new='tmux_new'
alias tmux-pick='tmux_pick'
