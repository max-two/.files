# Dotfiles

Personal configuration for macOS and Coder Linux boxes, managed with [mise](https://mise.jdx.dev).
The repo root mirrors `~`; mise links the files into place, installs the tools, and clones
the zsh plugins. Terminal workspaces are [Herdr](https://herdr.dev).

## New machine

```sh
git clone git@github.com:max-two/.files.git ~/code/.files
~/code/.files/install.sh
```

`install.sh` installs mise if needed, trusts the config, and runs `mise bootstrap`. On a
Coder workspace the dotfiles module runs it automatically (`coder dotfiles <repo>`).

Then, once per machine:

- `~/.claude/settings.json`: set `statusLine.command` to `bash ~/scripts/claude/statusline.sh`.
- `herdr integration install claude` for Claude session restore across Herdr restarts.

## Using mise

Two config files: `mise.toml` at the repo root declares the machine setup (dotfile links, zsh
plugin clones, casks, a completions task); `.config/mise/config.toml` is the global config
(tools and settings) and is linked to `~/.config/mise/config.toml`, so editing either path edits
the repo. Tools are declared as `latest`; there is no lockfile, so each machine has whatever
`latest` was when it last installed or updated.

### Every day

| Task | Command |
|---|---|
| See what is linked, missing, or drifted | `mise dot status` |
| See the diff a link or copy would make | `mise dot diff` |
| Link newly added files | `git add <file>` then `mise dot apply` |
| Preview any change before applying | `mise bootstrap --dry-run` |
| Reapply everything | `mise bootstrap` |
| What is installed, and what a directory resolves to | `mise ls`, `mise ls --current` |
| What is newer, then update | `mise outdated`, `mise up` |
| Update one tool | `mise up <tool>` |
| Update the zsh plugins | `mise bootstrap repos update` |
| Update the casks and navi | `mise bootstrap packages upgrade` |
| Remove old tool versions | `mise prune` |
| Update mise itself | `mise self-update` |

After updating herdr: `herdr server stop`, then `herdr`, because the running server keeps the
old binary. Unattended runs take `--yes`. A fresh clone or a moved config needs `mise trust`
before anything else will read it.

### Adding things

- **Config file**: put it at its home-relative path under `.config/`, `git add` it, `mise dot apply`.
  Only git-tracked files get linked. A file that lives directly in `~` needs its own `symlink` entry
  in `mise.toml`.
- **CLI tool**: `mise use -g <name>`; `mise registry` shows what is installable and through which
  backend. If the registry has no macOS build, add `"brew:<formula>"` under `[bootstrap.packages]`
  instead; mise pours the bottle itself, no Homebrew needed.
- **Script**: `scripts/<tool>/<name>`, executable, `git add`, `mise dot apply`. `~/scripts/*` is on
  PATH for every shell.
- **zsh plugin**: a `[bootstrap.repos]` entry in `mise.toml` plus a `source` line in `.zshrc`.
- **GUI app**: `"brew-cask:<token>" = { os = "macos" }` under `[bootstrap.packages]`.

### When something is off

- `mise doctor` reports activation, shims, and which config files loaded.
- `mise config` lists the loaded config files in precedence order; `mise settings ls` shows every
  effective setting and where it came from.
- `mise dot apply` refuses to replace a real file with a link. Move the file aside, or use
  `--force` when you mean it.
- `MISE_DEBUG=1 mise <command>` or `--verbose` shows what mise is actually doing.
- `mise <command> --help` works for every subcommand. There is no man page. The docs at
  https://mise.jdx.dev are also plain markdown in the `docs/` directory of
  https://github.com/jdx/mise, which is handier to grep.

## Using Herdr

Config is `.config/herdr/config.toml`, defaults plus a few lines. `herdr --default-config` prints
every option with its default; `herdr server reload-config` applies edits to the running server.

- `herdr <group>` (for example `herdr worktree`, `herdr agent`, `herdr pane`) prints that group's
  usage. `herdr <subcommand> --help` only prints the top-level banner.
- `herdr status` shows client and server versions and whether a restart is needed.
- `herdr config check` validates the config file.
- `herdr agent explain <pane-id>` says why a pane shows the state it does.
- `herdr integration status` shows installed agent hooks; an "update" banner that survives a
  server restart usually means the Claude hook is outdated, not the binary.
- Logs: `~/.config/herdr/herdr-server.log` and `herdr-client.log`.
- Docs: https://herdr.dev/docs/. For an agent helping with Herdr: https://herdr.dev/agent-guide.md.

## Tool docs and help

mise and Herdr have their own sections above. For everything else, the official docs and the
commands that print help or state on this machine:

- **Ghostty**: https://ghostty.org/docs, config reference at
  https://ghostty.org/docs/config/reference. The same reference ships in the app as
  `/Applications/Ghostty.app/Contents/Resources/ghostty/doc/ghostty.5.md`.
  `ghostty +show-config --default --docs` prints every option with its default and its docs;
  `ghostty +list-keybinds`, `+list-themes`, and `+validate-config` do what they say; `ghostty +help`
  lists every action.
- **Helix**: https://docs.helix-editor.com/ (`keymap.html`, `configuration.html`, `commands.html`).
  `hx --health [language]` prints the config, log, and runtime paths and each language's LSP,
  formatter, and grammar status. `hx --tutor` (or `:tutor` inside Helix) opens the tutorial. There
  is no `:help` command; the keymap page is the reference.
- **yazi**: https://yazi-rs.github.io/docs/quick-start and
  https://yazi-rs.github.io/docs/configuration/overview (the bare `/docs/` URL is a 404). `ya env`
  prints versions, each config file's path and whether it exists, and the terminal probe; `ya pkg`
  manages plugins. Inside yazi, `F1` or `~` opens the help menu. `yazi --help` and `ya env` need a
  TTY, so they fail from an agent shell.
- **navi**: https://github.com/denisidoro/navi/tree/master/docs (cheat syntax under
  `cheatsheet/syntax/`, config under `configuration/`). `navi info config-example` prints an
  annotated example config, `navi info cheats-example` a sample cheat, and `navi info config-path`
  and `navi info cheats-path` the locations it reads. `navi fn welcome` opens navi's own cheatsheet.
- **revdiff**: README at https://github.com/umputun/revdiff (Config File, Themes, Key Bindings
  sections) and https://revdiff.com/docs.html. `revdiff --dump-config` prints the default config
  with every option commented, `--dump-keys` the effective keybindings, `--list-themes` the bundled
  themes. Inside revdiff, `?` toggles the help overlay and `T` picks a theme.
- **difftastic**: https://difftastic.wilfred.me.uk/ (git setup: `git.html`). `difft --help` lists
  the options with their `DFT_*` environment variables; `difft --list-languages` the languages and
  their globs.
- **OpenCode**: https://opencode.ai/docs/ and https://opencode.ai/docs/config/; the config schema is
  https://opencode.ai/config.json. `opencode debug config` prints the resolved configuration and
  `opencode debug paths` the directories it uses.
- **Powerlevel10k**: `p10k help` lists `configure`, `reload`, `segment`, and `display`;
  `p10k help <command>` explains each. README (Configuration, FAQ):
  https://github.com/romkatv/powerlevel10k, also in the clone.
- **zsh plugins**: each clone under `~/.local/share/zsh/plugins/<name>/` carries its README, which
  is the documentation. Upstream: https://github.com/Aloxaf/fzf-tab,
  https://github.com/zsh-users/zsh-autosuggestions,
  https://github.com/zsh-users/zsh-syntax-highlighting, and
  https://github.com/zsh-users/zsh-completions.

See `CLAUDE.md` for how the pieces fit together and the things that are easy to get wrong.
