# Troubleshooting

Start here, it answers most problems:

```bash
hx --health python
```

You want a check mark next to `jedi-ls`, and the `python` grammar listed as available. For anything else, `:log-open` inside Helix shows the log.

## `jedi-ls` isn't found, or has a cross instead of a check

1. Is the wrapper there and executable?
   ```bash
   ls -l ~/bin/jedi-ls-fast
   ```
   It should start with `-rwx`. If not, run `chmod +x ~/bin/jedi-ls-fast`, or run `bash install.sh` again.
2. Is Jedi installed?
   ```bash
   jedi-language-server --version
   ```
   If that says "command not found", run `pip install jedi-language-server` (add `--break-system-packages` if pip refuses), then close and reopen Termux.
3. Does `command` in `~/.config/helix/languages.toml` point at the wrapper? It should be `/data/data/com.termux/files/home/bin/jedi-ls-fast`.
4. Restart the server from inside Helix with `:lsp-restart`.

## The completion popup doesn't show up while I type

That's the setting `completion-timeout = 10000` in `config.toml`. The popup only appears on its own 10 seconds after you type. Press `Ctrl-x` in Insert mode to open it right away, or change the number to `250` (Helix's default) and run `:config-reload`.

## Helix lags or freezes

Phones are small machines, and language servers can be heavy. What this setup does, and what you can try:

- It runs **one** language server (Jedi) through `jedi-ls-fast`, which turns off Jedi's expensive dynamic analysis. Adding a second Python server next to it, such as `pylsp` with all its plugins, was slower in testing. Keep it to one.
- Completion is kept light with `disableSnippets` and `resolveEagerly = false` in `languages.toml`.
- Keep `autoImportModules` short. Every module in it is imported when the server starts.
- Open Helix in the folder of your project, not in `~` or `/`. Helix and the language server both scan the working folder.
- If it freezes, wait a few seconds. If it doesn't come back, run `:lsp-restart`.
- Close other heavy apps. Android can slow Termux down when memory is low.

## No syntax colors

The grammars aren't built. They need `clang`:

```bash
pkg install clang
hx --grammar fetch
hx --grammar build
```

Then check that these files exist:

```bash
ls ~/.config/helix/runtime/grammars/*.so
```

You should see `python.so`, `bash.so`, `toml.so` and `markdown.so`. Restart Helix after building.

## Helix shows a config error when it starts

Helix couldn't read one of the files. The most common causes:

- A typo in a TOML file. Open it with `hx ~/.config/helix/config.toml` and look at the line the error names.
- `use-grammars` in the wrong file. It belongs in `languages.toml` as a top-level key above the `[[language]]` sections, not in `config.toml`.
- A setting that doesn't exist in your Helix version. Run `hx --version` and compare with the [Helix docs](https://docs.helix-editor.com).

To go back to a working config, copy the repo files again (`bash install.sh`) or restore your backup (see below).

## `pip` says "externally-managed-environment"

The installer already retries with `--break-system-packages`. To do it by hand:

```bash
python -m pip install --break-system-packages jedi-language-server
```

## Error checking only finds syntax errors

That's how Jedi works. It reports syntax errors, such as a half-written `def`, and not lint warnings like unused variables. A separate linter would be needed for those.

## `=`, `:format`, `g y` or `g i` do nothing

Jedi doesn't support formatting, type definition or implementation lookups, so Helix has nothing to ask. Helix can run an external formatter instead, see the [Helix language docs](https://docs.helix-editor.com/languages.html).

## `:sh python3 %{buffer_name}` says something odd

The `%{buffer_name}` shortcut needs Helix 25.07 or newer. Check with `hx --version`, and update with `pkg upgrade`. Save the file first with `:w`.

## Restore my old config

The installer saved a copy of the old files:

```bash
ls -d ~/.config/helix.bak-*
cp ~/.config/helix.bak-<date>/* ~/.config/helix/
```

An older `~/bin/jedi-ls-fast` was saved as `~/bin/jedi-ls-fast.bak-<date>`.

## Still stuck?

Open an issue and include the output of `hx --version` and `hx --health python`, plus any error from `:log-open`.
