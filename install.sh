#!/usr/bin/env bash
# install.sh - one-command Helix + Python IDE setup for Termux (Android)
#
# This script is fully self-contained: the Helix config files and the fast
# Jedi wrapper are embedded below, so there is nothing else to download.
# (The same files live in config/ and bin/ so you can read or copy them by hand.
#  Run tools/check-sync.sh after editing either place.)
#
# What it does:
#   1. Updates Termux packages (skip with --skip-upgrade)
#   2. Installs anything that is missing: helix, python, git, clang (and tmux, optional)
#   3. Installs jedi-language-server (the Python language server) with pip
#   4. Backs up any existing Helix config, then writes:
#        ~/.config/helix/config.toml
#        ~/.config/helix/languages.toml
#        ~/bin/jedi-ls-fast   (Jedi wrapper with the slow analysis features off)
#   5. Fetches and builds the Helix syntax grammars (python, bash, toml, markdown)
#   6. Runs "hx --health python" so you can see that everything is wired up
#
# Usage:
#   bash install.sh
#   bash install.sh --skip-upgrade
#   curl -fsSL <raw-url-of-this-file> | bash -s -- --skip-upgrade

set -u

CONFIG_DST="${XDG_CONFIG_HOME:-$HOME/.config}/helix"
GRAMMARS=(python bash toml markdown)

# ---------- pretty output ----------
if [ -t 1 ]; then
  BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'
else
  BOLD=""; GREEN=""; YELLOW=""; RED=""; RESET=""
fi

info() { printf '%s==>%s %s\n' "$BOLD" "$RESET" "$*"; }
ok()   { printf '%s[ok]%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s[warn]%s %s\n' "$YELLOW" "$RESET" "$*"; }
fail() { printf '%s[error]%s %s\n' "$RED" "$RESET" "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

usage() {
  cat <<'EOF'
Usage: bash install.sh [options]

Options:
  --skip-upgrade   Do not run "pkg update && pkg upgrade" first
  -h, --help       Show this help
EOF
}

is_termux() {
  [ -n "${TERMUX_VERSION:-}" ] || [[ "${PREFIX:-}" == *com.termux* ]]
}

# install_pkg <command-to-check> <termux-package>
# (stdin is redirected so that pkg can never swallow the script when piped from curl)
install_pkg() {
  if have "$1"; then
    ok "$2 already installed"
  else
    info "Installing $2..."
    pkg install -y "$2" </dev/null || fail "Could not install $2"
    ok "$2 installed"
  fi
}

# True if the Helix config folder has anything in it besides the big runtime/ folder.
has_existing_config() {
  local f
  for f in "$CONFIG_DST"/* "$CONFIG_DST"/.[!.]*; do
    [ -e "$f" ] || continue
    [ "$(basename "$f")" = "runtime" ] || return 0
  done
  return 1
}

# backup_config <backup-dir>: copy everything except runtime/ (built grammars are large and re-creatable)
backup_config() {
  local dst="$1" f
  mkdir -p "$dst" || return 1
  for f in "$CONFIG_DST"/* "$CONFIG_DST"/.[!.]*; do
    [ -e "$f" ] || continue
    [ "$(basename "$f")" = "runtime" ] && continue
    cp -a "$f" "$dst"/ || return 1
  done
}

grammars_built() {
  local g
  for g in "${GRAMMARS[@]}"; do
    [ -e "$CONFIG_DST/runtime/grammars/$g.so" ] || return 1
  done
}

main() {
  local skip_upgrade=0 arg stamp wrapper

  for arg in "$@"; do
    case "$arg" in
      --skip-upgrade) skip_upgrade=1 ;;
      -h|--help) usage; exit 0 ;;
      *) usage; fail "Unknown option: $arg" ;;
    esac
  done

  stamp="$(date +%Y%m%d-%H%M%S)"

  # ---------- 0. environment check ----------
  if ! is_termux; then
    fail "This installer is made for Termux on Android. On other systems, follow the manual steps in the README."
  fi

  # ---------- 1. update packages ----------
  if [ "$skip_upgrade" -eq 0 ]; then
    info "Updating Termux packages (this can take a few minutes)..."
    if ! (pkg update -y && pkg upgrade -y) </dev/null; then
      warn "Package update had problems. Continuing anyway."
    fi
  else
    info "Skipping package upgrade."
  fi

  # ---------- 2. required packages ----------
  install_pkg hx helix
  install_pkg python python
  install_pkg git git
  install_pkg clang clang   # needed to build the syntax grammars

  # optional: tmux (editor + terminal split, used in the tutorial)
  if have tmux; then
    ok "tmux already installed"
  else
    info "Installing tmux (optional)..."
    if pkg install -y tmux </dev/null; then
      ok "tmux installed"
    else
      warn "Could not install tmux. You can skip it."
    fi
  fi

  # ---------- 3. Python language server ----------
  if have jedi-language-server; then
    ok "jedi-language-server already installed"
  else
    info "Installing jedi-language-server with pip..."
    if ! python -m pip install jedi-language-server </dev/null; then
      warn "First attempt failed. Retrying with --break-system-packages..."
      python -m pip install --break-system-packages jedi-language-server </dev/null \
        || fail "Could not install jedi-language-server. Check your internet connection and try again."
    fi
    hash -r
    have jedi-language-server \
      || fail "jedi-language-server was installed but is not on your PATH. Close and reopen Termux, then run this script again."
    ok "jedi-language-server installed"
  fi

  # ---------- 4. Helix configuration + Jedi wrapper (embedded) ----------
  mkdir -p "$CONFIG_DST" || fail "Could not create $CONFIG_DST"

  if has_existing_config; then
    info "Existing Helix config found. Backing it up to ${CONFIG_DST}.bak-$stamp"
    backup_config "${CONFIG_DST}.bak-$stamp" || fail "Backup failed. Nothing was changed."
    ok "Backup created"
  fi

  info "Writing Helix config files to $CONFIG_DST"

  cat > "$CONFIG_DST/config.toml" <<'HELIX_CONFIG_TOML_EOF' || fail "Could not write config.toml"
# Helix editor settings (Termux + Python IDE setup)
theme = "monokai_aqua"

[editor]
auto-pairs = true
auto-completion = true
completion-trigger-len = 1
# Delay in milliseconds before the completion popup shows up on its own.
# Ctrl-x always opens it instantly. Helix's default delay is 250.
completion-timeout = 10000
HELIX_CONFIG_TOML_EOF

  # @HOME@ is replaced with your real home folder right after writing the file
  cat > "$CONFIG_DST/languages.toml" <<'HELIX_LANGUAGES_TOML_EOF' || fail "Could not write languages.toml"
# Only fetch and build syntax grammars for these languages.
# This key must stay above the [[language]] sections.
use-grammars = { only = ["python", "bash", "toml", "markdown"] }

[language-server.jedi-ls]
command = "@HOME@/bin/jedi-ls-fast"
timeout = 15

[language-server.jedi-ls.config]
completion = { disableSnippets = true, resolveEagerly = false }
diagnostics = { enable = true }
jediSettings = { caseInsensitiveCompletion = true, autoImportModules = ["os", "re", "socket", "subprocess"] }

[[language]]
name = "python"
language-servers = ["jedi-ls"]
HELIX_LANGUAGES_TOML_EOF
  sed -i "s|@HOME@|$HOME|g" "$CONFIG_DST/languages.toml" || fail "Could not finish languages.toml"
  ok "Config installed"

  info "Installing the fast Jedi wrapper to ~/bin/jedi-ls-fast"
  wrapper="$HOME/bin/jedi-ls-fast"
  mkdir -p "$HOME/bin" || fail "Could not create $HOME/bin"
  if [ -e "$wrapper" ]; then
    cp -a "$wrapper" "$wrapper.bak-$stamp" || fail "Could not back up the existing $wrapper"
    ok "Existing wrapper backed up to $wrapper.bak-$stamp"
  fi
  cat > "$wrapper" <<'JEDI_LS_FAST_EOF' || fail "Could not write $wrapper"
#!/data/data/com.termux/files/usr/bin/python

import jedi

# Reduce expensive dynamic analysis
jedi.settings.dynamic_params = False
jedi.settings.dynamic_params_for_other_modules = False
jedi.settings.dynamic_array_additions = False

# Start Jedi Language Server
from jedi_language_server.cli import cli

cli()
JEDI_LS_FAST_EOF
  chmod +x "$wrapper" || fail "Could not make $wrapper executable"
  ok "Wrapper installed"

  # ---------- 5. syntax grammars ----------
  if grammars_built; then
    ok "Syntax grammars already built"
  else
    info "Fetching and building syntax grammars (python, bash, toml, markdown)..."
    if hx --grammar fetch </dev/null && hx --grammar build </dev/null; then
      ok "Syntax grammars built"
    else
      warn "Grammar build failed. Helix still works but without syntax colors. See docs/TROUBLESHOOTING.md in the repo."
    fi
  fi

  # ---------- 6. health check ----------
  echo
  info "Checking Helix setup for Python (hx --health python)"
  echo "------------------------------------------------------------"
  hx --health python || warn "hx --health reported a problem. See docs/TROUBLESHOOTING.md in the repo."
  echo "------------------------------------------------------------"

  echo
  ok "All done!"
  echo "Try it:  hx test.py"
  echo "  Ctrl-x  completion list     Space k  hover docs"
  echo "  g d     go to definition    Space d  diagnostics"
  echo "Full key list: docs/CHEATSHEET.md in the repo"
}

# Everything runs from this single call, so a half-downloaded script (curl | bash) does nothing.
main "$@"
