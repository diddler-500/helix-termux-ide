#!/usr/bin/env bash
# check-sync.sh - make sure the files embedded in install.sh match the copies in config/ and bin/.
#
# install.sh carries its own copy of each file so it works as a single download.
# If you edit config/config.toml, config/languages.toml or bin/jedi-ls-fast,
# update the matching block in install.sh and run this script to confirm.
#
# Usage:  bash tools/check-sync.sh

set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

# extract <heredoc-marker>: print what install.sh writes between the marker lines
extract() {
  sed -n "/<<'$1'/,/^$1\$/p" install.sh | sed '1d;$d'
}

status=0
check() { # <label> <marker> <file> [sed-expression]
  local label="$1" marker="$2" file="$3" expr="${4:-}"
  if [ -n "$expr" ]; then
    diff <(extract "$marker" | sed "$expr") "$file" >/dev/null
  else
    diff <(extract "$marker") "$file" >/dev/null
  fi
  if [ $? -eq 0 ]; then
    echo "[ok]   $label matches $file"
  else
    echo "[DIFF] $label differs from $file"
    status=1
  fi
}

check "config.toml"    HELIX_CONFIG_TOML_EOF    config/config.toml
check "languages.toml" HELIX_LANGUAGES_TOML_EOF config/languages.toml 's|@HOME@|/data/data/com.termux/files/home|g'
check "jedi-ls-fast"   JEDI_LS_FAST_EOF         bin/jedi-ls-fast

exit "$status"
