# helix-termux-ide

Turn [Helix](https://helix-editor.com) into a lightweight Python IDE on your Android phone, with one command. No laptop needed.

You get Python completion, hover docs, go to definition, rename, error checking and syntax colors, all inside [Termux](https://termux.dev).

<!-- Add a screenshot or GIF here, for example docs/img/demo.gif -->

## What you get

| Feature | Key |
|---|---|
| Completion list | `Ctrl-x` (it also pops up on its own after a delay, see [the config](#the-config-explained)) |
| Hover docs | `Space k` |
| Go to definition | `g d` |
| References | `g r` |
| Rename symbol | `Space r` |
| Error list | `Space d` |
| Symbols in the file | `Space s` |
| File picker | `Space f` |
| Search the project | `Space /` |

It also gives you auto-pairs, auto-indent, and syntax highlighting for Python, Bash, TOML and Markdown. The language server is [jedi-language-server](https://github.com/pappasam/jedi-language-server), started through a small wrapper that makes it faster on a phone.

The full key list is in [docs/CHEATSHEET.md](docs/CHEATSHEET.md).

## Requirements

- An Android phone with [Termux](https://termux.dev), installed from F-Droid or the Termux GitHub releases (the Play Store version is outdated)
- An internet connection and a few hundred MB of free space (the compiler and Python packages are the big parts)
- Helix 25.07 or newer if you want to use the `:sh python3 %{buffer_name}` tip below (`pkg install helix` gives you the latest one Termux has)

## Quick start

```bash
pkg install git
git clone https://github.com/<your-username>/helix-termux-ide
cd helix-termux-ide
bash install.sh
```

That's it. When it finishes, open a file:

```bash
hx test.py
```

If you've already upgraded Termux recently, `bash install.sh --skip-upgrade` skips the slow package upgrade.

### One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/<your-username>/helix-termux-ide/main/install.sh | bash -s -- --skip-upgrade
```

If `curl` is missing, run `pkg install curl` first. As with any script piped into a shell, read [install.sh](install.sh) before you run it. It's short and commented.

## What the installer does

1. Updates Termux packages (skipped with `--skip-upgrade`)
2. Installs whatever is missing: `helix`, `python`, `git`, `clang` (to build the syntax grammars), and `tmux` (optional)
3. Installs `jedi-language-server` with pip
4. **Backs up** any existing Helix config, then writes these files:

   | File | Purpose |
   |---|---|
   | `~/.config/helix/config.toml` | Editor settings and theme |
   | `~/.config/helix/languages.toml` | Python language server and grammar list |
   | `~/bin/jedi-ls-fast` | Wrapper that starts Jedi with its slowest analysis turned off |

5. Fetches and builds the syntax grammars
6. Runs `hx --health python` so you can see that the language server was found

It never overwrites without a backup. Your old config is copied to `~/.config/helix.bak-<date>` (without the large `runtime/` folder), and an existing `~/bin/jedi-ls-fast` is copied to `jedi-ls-fast.bak-<date>`. You can run the installer again safely. It skips what's already installed.

## Try it

Create a file and open it:

```bash
printf 'cows = {"a": 1}\n' > test.py
hx test.py
```

Then:

1. Press `g` then `e` to jump to the end of the file, press `o` to open a new line below, and type `cows.`
2. Press `Ctrl-x` to open the completion list. On Termux, tap **CTRL** on the extra keys row, then `x`.
3. Press `Esc`, move onto a name, and press `Space k` for hover docs.
4. Press `g d` on a name to jump to its definition, and `Ctrl-o` to jump back.
5. Write `def broken(` without finishing it, then press `Space d` to see the error.

## Manual setup

If you want to understand each step, or you don't want the script:

```bash
# 1. Packages
pkg update && pkg upgrade
pkg install helix python git clang

# 2. Language server (add --break-system-packages if pip refuses)
pip install jedi-language-server

# 3. Config files (run these from inside the cloned repo)
mkdir -p ~/.config/helix ~/bin
cp config/config.toml config/languages.toml ~/.config/helix/
cp bin/jedi-ls-fast ~/bin/ && chmod +x ~/bin/jedi-ls-fast

# 4. Syntax grammars
hx --grammar fetch && hx --grammar build

# 5. Check
hx --health python
```

`hx --health python` should show a check mark next to `jedi-ls`.

## The config explained

**`config/config.toml`**

| Setting | What it does |
|---|---|
| `theme = "monokai_aqua"` | A built-in Helix theme. Change it with `:theme <name>` |
| `auto-pairs = true` | Types the closing `)`, `]`, `"` for you |
| `auto-completion = true` | Lets the completion popup appear without pressing a key |
| `completion-trigger-len = 1` | Completion starts after one typed character (Helix's default is 2) |
| `completion-timeout = 10000` | The popup appears on its own 10 seconds after you type, so it stays out of your way. `Ctrl-x` always opens it instantly. Set it to `250` (Helix's default) or `5` if you want a popup as you type |

**`config/languages.toml`**

| Setting | What it does |
|---|---|
| `use-grammars = { only = [...] }` | Only builds syntax grammars for these four languages, which makes the install faster. It has to be a top-level key in this file, above the `[[language]]` sections |
| `command = ".../jedi-ls-fast"` | Starts Jedi through the wrapper instead of the plain `jedi-language-server` command |
| `timeout = 15` | Gives the server up to 15 seconds per request before Helix gives up |
| `disableSnippets`, `resolveEagerly = false` | Keeps completion lists light |
| `caseInsensitiveCompletion = true` | `pri` finds `print` and `Print` |
| `autoImportModules` | Modules Jedi imports directly for better completions on them. Importing them runs their code, so only list modules you trust and have installed. Add your own, for example `"requests"` |

**`bin/jedi-ls-fast`** turns off three of Jedi's "dynamic analysis" settings (`dynamic_params`, `dynamic_params_for_other_modules`, `dynamic_array_additions`). They guess types by scanning more of your code, and they're the expensive part on a phone.

## What it can't do

- **Error checking means syntax errors.** Jedi reports syntax errors, not lint warnings (unused variables, style, and so on).
- **No code formatting.** `=` and `:format` do nothing with Jedi. Helix can run an external formatter, see the [Helix language docs](https://docs.helix-editor.com/languages.html).
- **No type definition or implementation jumps.** `g y` and `g i` aren't supported by Jedi.

## Run your code

Save the file, then run it from inside Helix:

```
:w
:sh python3 %{buffer_name}
```

For longer output, use `tmux`: one pane for Helix and one for running your script.

## Troubleshooting

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for lag and freezes, a missing language server, no syntax colors, and how to restore your old config.

## Uninstall

```bash
rm ~/.config/helix/config.toml ~/.config/helix/languages.toml ~/bin/jedi-ls-fast
pip uninstall jedi-language-server
```

To get your old config back, copy files from `~/.config/helix.bak-<date>/` into `~/.config/helix/`.

## Changing the config

`install.sh` carries its own copy of each config file so it works as a single download. If you edit anything in `config/` or `bin/`, update the matching block in `install.sh` and run:

```bash
bash tools/check-sync.sh
```

It prints `[ok]` for each file when the two copies match.

## Credits

- [Helix](https://helix-editor.com) for the editor
- [jedi-language-server](https://github.com/pappasam/jedi-language-server) and [Jedi](https://github.com/davidhalter/jedi) for the Python intelligence
- [Termux](https://termux.dev) for a real Linux terminal on Android

## License

[MIT](LICENSE)
