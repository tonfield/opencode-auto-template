# opencode configuration

Personal opencode setup for `tonfield`.

This repository is intended to restore the opencode configuration on another Mac, Linux, or other Unix-like machine. It includes agents, commands, instructions, plugins, templates, helper tools, and core config files.

## Included

- `opencode.json` — main opencode configuration
- `AGENTS.md` — global workflow instructions
- `agents/` — primary agents and subagents
- `commands/` — custom slash commands
- `instructions/` — shared instruction files
- `plugins/` — local plugin code
- `templates/` — task/workbook/docs templates
- `tools/` — local helper scripts
- `custom-providers.json` and `opencode-auth-env.sh` — provider/env helper setup
- `package.json`, `package-lock.json`, and `bun.lock` — dependency lock/config files

## Not included

The repo intentionally excludes generated or machine-local files such as:

- `node_modules/`
- `.DS_Store`
- `opencode-notifier-state.json`
- `*.bak` backups
- `.env*`, private keys, and other secret material

API keys and auth state are expected to live outside the repo in environment variables, opencode auth storage, macOS Keychain, or local service config.

## Restore on macOS or Linux

Install prerequisites first:

- opencode
- git
- Node/npm
- Python 3
- `uv`/`uvx`, if using MCP tools that call it

If `~/.config/opencode` already exists on the target machine, back it up before cloning:

```sh
mkdir -p ~/.config
mv ~/.config/opencode ~/.config/opencode.backup.$(date +%Y%m%d-%H%M%S)
```

Then clone this repo into the global config location and install local dependencies:

```sh
git clone git@github.com:tonfield/opencode-config.git ~/.config/opencode
cd ~/.config/opencode
npm install
```

Then restore required credentials/env vars as needed:

- `KILOCODE_API_KEY`
- `DEEPSEEK_API_KEY`
- `OMLX_API_KEY`
- `CONTEXT7_API_KEY`
- `BRAVE_API_KEY`
- `EXA_API_KEY`
- `MORPH_API_KEY`, if using Morph tools

The helper script `opencode-auth-env.sh` can export provider keys from opencode's local auth store, oMLX local settings, and Morph from macOS Keychain when sourced from your shell startup file. Existing environment variables take precedence, so Linux machines can just export keys through the shell or secret manager.

### Machine-local notes

- macOS can keep `MORPH_API_KEY` in Keychain under service `morphllm-api-key` and account `$USER`.
- Linux should provide keys with environment variables or opencode's local auth store.
- Pushover notifications are optional. The helper checks `PUSHOVER_NOTIFY`, then `pushover-notify` in `PATH`, then `$HOME/bin/pushover-notify`, then the original `/Users/ton/bin/pushover-notify` path. If none exists, it exits successfully without breaking opencode.
- Local model providers such as `127.0.0.1:10000` or `127.0.0.1:8000` require equivalent local services on each machine.

Finally, restart opencode so it reloads the restored config.

## Syncing between machines

Before editing config on a machine, pull the latest backup first:

```sh
cd ~/.config/opencode
git pull --ff-only
```

After changing config, commit and push from that machine. On other machines, run `git pull --ff-only` to receive the same tracked setup. If `package.json`, `package-lock.json`, or `bun.lock` changed, run `npm install` after pulling.

## Updating the backup

From this directory:

```sh
git status
git add .
git commit -m "Update opencode config"
git push
```
