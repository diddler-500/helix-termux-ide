# Helix cheat sheet (Termux + Python)

Keys checked against the [official Helix keymap](https://docs.helix-editor.com/keymap.html).

## Key notation

- `Ctrl-x` means hold Ctrl and press `x`. On Termux, tap **CTRL** on the extra keys row, then `x`. Volume Up also works as Ctrl.
- `Space k` means press `Space`, then `k`.
- `g d` means press `g`, then `d`.
- `Esc` is on the extra keys row.

## The one big idea

Helix works in the order **select, then act**. `x` selects the line, then `d` deletes it. `w` selects the next word, then `c` changes it. You always see what you're about to change.

## Modes

| Key | What happens |
|---|---|
| `Esc` | Back to Normal mode (where you start) |
| `i` / `a` | Insert before / after the selection |
| `I` / `A` | Insert at line start / line end |
| `o` / `O` | Open a new line below / above and insert |
| `v` | Select mode: movements extend the selection |
| `:` | Command mode |

## Move around

| Key | Moves |
|---|---|
| `h` `j` `k` `l` | Left, down, up, right |
| `w` / `b` / `e` | Next word start / previous word start / next word end |
| `f x` / `t x` | Find / go till the next `x` (`F`, `T` go backwards) |
| `g h` / `g l` | Line start / line end |
| `g s` | First non-blank character of the line |
| `g g` | Top of the file (`12 g g` goes to line 12) |
| `g e` | End of the file |
| `Ctrl-d` / `Ctrl-u` | Half page down / up |
| `Ctrl-f` / `Ctrl-b` | Page down / up |
| `Ctrl-o` / `Ctrl-i` | Jump back / forward through your jump history |
| `g w` | Show labels on words and jump to the one you pick |

## Select

| Key | Does |
|---|---|
| `x` | Select the line (press again to extend downward) |
| `%` | Select the whole file |
| `;` | Collapse the selection to the cursor |
| `,` | Keep only the main selection (drops the extra cursors) |
| `s` | Select every regex match inside the selection |
| `S` | Split the selection at every regex match |
| `C` | Add a cursor on the next line (multi-cursor) |
| `K` / `Alt-K` | Keep / remove selections matching a regex |

Multi-cursor rename by hand: `%` then `s`, type the name, `Enter`, then `c` and type the new one.

## Edit

| Key | Does |
|---|---|
| `d` | Delete the selection (`xd` deletes a line) |
| `c` | Delete the selection and start inserting |
| `y` | Yank (copy) |
| `p` / `P` | Paste after / before |
| `R` | Replace the selection with what you yanked |
| `r x` | Replace each selected character with `x` |
| `u` / `U` | Undo / redo |
| `.` | Repeat the last insert |
| `>` / `<` | Indent / unindent |
| `J` | Join lines |
| `~` | Switch case |
| `Ctrl-c` | Toggle a comment on the selected lines |
| `Ctrl-a` / `Ctrl-x` | Increase / decrease the number under the cursor |

## Select inside or around things (match mode)

Press `m`, then:

| Keys | Selects |
|---|---|
| `m i w` | Inside the word |
| `m a w` | Around the word |
| `m i (` | Inside the parentheses (also `[`, `{`, `"`, `'`) |
| `m i p` | Inside the paragraph |
| `m i f` | Inside the function |
| `m m` | Jump to the matching bracket |
| `m s (` | Surround the selection with `( )` |
| `m r ( [` | Replace the surrounding `( )` with `[ ]` |
| `m d (` | Delete the surrounding `( )` |

Example: put the cursor in a word, press `m i w`, then `c` to change that word.

## Search

| Key | Does |
|---|---|
| `/` | Search forward (regex) |
| `?` | Search backward |
| `n` / `N` | Next / previous match |
| `*` | Search for the selected text |
| `Space /` | Search the whole project |

## IDE features (language server)

These need `jedi-ls` running. Check with `hx --health python`.

| Key | Does | Jedi supports it? |
|---|---|---|
| `Ctrl-x` (in Insert mode) | Open the completion list | Yes |
| `Space k` | Hover docs | Yes |
| `g d` | Go to definition | Yes |
| `g r` | Go to references | Yes |
| `Space h` | Select all references to the symbol in this file | Yes |
| `Space r` | Rename the symbol | Yes |
| `Space s` | Symbols in this file | Yes |
| `Space S` | Symbols in the whole project | Yes |
| `Space d` | Errors in this file | Yes (syntax errors only) |
| `Space D` | Errors in the whole project | Yes (syntax errors only) |
| `] d` / `[ d` | Next / previous error | Yes |
| `Space a` | Code actions (extract or inline a variable) | Partly |
| `g y` / `g i` | Type definition / implementation | No |
| `=` | Format the selection | No |
| `Alt-p` / `Alt-n` | Previous / next signature while typing a call | Yes |

### The completion list

| Key | Does |
|---|---|
| `Ctrl-x` | Open it (in Insert mode) |
| `Tab` or `Ctrl-n` | Next entry |
| `Shift-Tab` or `Ctrl-p` | Previous entry |
| `Enter` | Accept the entry |
| `Ctrl-c` | Close it without accepting |

## Pickers and files (`Space` menu)

| Key | Does |
|---|---|
| `Space f` | Find a file (from the project root) |
| `Space F` | Find a file (from the current folder) |
| `Space b` | Switch between open buffers |
| `Space j` | Jump list |
| `Space /` | Search text in the project |
| `Space '` | Reopen the last picker |
| `Space ?` | Command palette: search every command |
| `Space y` / `Space p` | Copy to / paste from the system clipboard |

Inside a picker: `Tab` / `Shift-Tab` move, `Enter` opens, `Ctrl-s` opens in a horizontal split, `Ctrl-v` in a vertical split, `Esc` closes.

Switch buffers without a picker: `g n` next buffer, `g p` previous buffer.

## Windows

`Ctrl-w` and then:

| Key | Does |
|---|---|
| `v` / `s` | Split vertically / horizontally |
| `h` `j` `k` `l` | Move between splits |
| `q` | Close this split |
| `o` | Keep only this split |

## Commands (press `:`)

| Command | Does |
|---|---|
| `:w` | Save |
| `:q` | Close the view |
| `:wq` or `:x` | Save and close |
| `:q!` | Close without saving |
| `:wa` / `:qa` | Save all / close all |
| `:o file.py` | Open a file |
| `:bc` | Close the current buffer |
| `:rl` | Reload the file from disk |
| `:theme name` | Change the theme |
| `:config-open` | Open `config.toml` |
| `:config-reload` | Reload the config |
| `:lsp-restart` | Restart the language server |
| `:log-open` | Open Helix's log file (good for debugging) |
| `:sh python3 %{buffer_name}` | Run the current file (save it first, needs Helix 25.07 or newer) |

## Insert mode

| Key | Does |
|---|---|
| `Esc` | Back to Normal mode |
| `Ctrl-x` | Completion list |
| `Ctrl-w` | Delete the previous word |
| `Ctrl-u` | Delete to the start of the line |
| `Ctrl-k` | Delete to the end of the line |
| `Ctrl-s` | Save an undo checkpoint |

## Five-minute practice

1. `hx practice.py`, press `i`, and type a few lines, ending a line with a colon, then `Enter` (the next line indents for you).
2. `Esc`, then `x` `d` to delete a line, and `u` to undo it.
3. Type a dictionary name followed by `.` and press `Ctrl-x`.
4. Put the cursor on a function name and press `Space k`, then `g d`, then `Ctrl-o` to come back.
5. Press `Space f` and open another file, then `g p` to go back.
