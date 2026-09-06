# Stow → chezmoi migration plan

Status: **plan only, nothing executed.** Target: one repo driving this desktop
(RTX 4080, dual 1440p/1080p) and an Asus G14 2020 (AMD iGPU + NVIDIA dGPU).

---

## 0. The workflow change to decide first

Stow symlinks; chezmoi **copies by default**. After `chezmoi apply`,
`~/.config/hypr/hyprland.lua` is a regular file, and editing it does *not*
edit the repo. The loop becomes:

```
chezmoi edit ~/.config/hypr/hyprland.lua   # edits the source file
chezmoi apply                              # writes it out
chezmoi re-add                             # pull in edits made directly in ~
```

If you want to keep the stow-like "edit in place, git sees it" feel, set
`mode = "symlink"` in the chezmoi config. Caveat: symlink mode cannot symlink
a file that is a **template** — templated files are always written as real
files. Since monitors and GPU env are exactly what you want templated, a
hybrid is the realistic outcome. Recommendation: **use the default copy mode**
and learn `chezmoi edit`; it is the mode all the per-machine machinery assumes.

---

## 1. Repo layout

Use `.chezmoiroot` so repo-meta files stay out of `$HOME`.

```
dotfiles/
├── .chezmoiroot                 # contains: home
├── deploy.sh                    # legacy stow-equivalent, keep until cutover
├── docs/chezmoi-migration.md
├── .resources/haru.webp
└── home/                        # <- chezmoi source root
    ├── .chezmoi.toml.tmpl       # prompts + per-machine data
    ├── .chezmoiignore           # template; per-machine exclusions
    ├── .chezmoidata.yaml        # optional static shared data
    ├── dot_config/
    │   ├── hypr/
    │   │   ├── hyprland.lua
    │   │   ├── env.lua.tmpl              # GPU / machine specific
    │   │   ├── monitors.lua.tmpl         # machine specific
    │   │   ├── power.lua.tmpl            # laptop only
    │   │   ├── appearance.lua
    │   │   ├── general.lua
    │   │   ├── input.lua.tmpl            # touchpad only on laptop
    │   │   ├── startup.lua
    │   │   ├── workspace.lua.tmpl        # workspace->monitor binding
    │   │   ├── hyprpaper.conf.tmpl
    │   │   ├── wallpapers/…
    │   │   └── scripts/
    │   │       ├── executable_arch-menu.sh
    │   │       ├── executable_power-menu.sh
    │   │       └── executable_workspace-wrap.sh
    │   ├── waybar/
    │   │   ├── config.jsonc.tmpl         # battery module, persistent ws
    │   │   ├── style.css
    │   │   └── scripts/executable_*.sh
    │   ├── wofi/style.css
    │   ├── kitty/{kitty.conf,current-theme.conf}
    │   ├── btop/…
    │   ├── walker/…
    │   └── elephant/…
    ├── dot_zshrc
    ├── dot_zprofile
    ├── dot_zlogin
    ├── dot_zsh_aliases
    └── dot_p10k.zsh
```

### Naming rules that bite

| Situation | Source name |
|---|---|
| `.config` | `dot_config` |
| `.zshrc` | `dot_zshrc` |
| executable script | `executable_power-menu.sh` — **required**, chezmoi does not preserve the mode bit otherwise |
| templated file | append `.tmpl` (the suffix is stripped on apply) |
| mode 0600 | `private_` prefix |
| write once, never overwrite | `create_` prefix |

`executable_` is the single most commonly missed step in a stow→chezmoi move.
Every one of the five `.sh` files in this repo needs it, or the menus and
waybar modules silently break after `chezmoi apply`.

---

## 2. Machine identity

`home/.chezmoi.toml.tmpl` — evaluated once, on `chezmoi init`:

```toml
{{- $machine := promptStringOnce . "machine" "Machine (desktop|g14)" -}}
[data]
machine = {{ $machine | quote }}
{{- if eq $machine "desktop" }}
gpu        = "nvidia"
gpuPciPath = "/dev/dri/by-path/pci-0000:01:00.0-card"
laptop     = false
{{- else }}
gpu        = "hybrid"
laptop     = true
{{- end }}
```

Prefer an explicit prompt over `.chezmoi.hostname`: hostnames get changed,
and a reinstall of either box should ask once rather than guess wrong.

Then `{{ .machine }}`, `{{ .laptop }}`, `{{ .gpu }}` are available everywhere.
Built-ins `{{ .chezmoi.hostname }}`, `.chezmoi.os`, `.chezmoi.arch` remain
available as a cross-check.

---

## 3. The three real per-machine differences

### 3a. `monitors.lua.tmpl`

```lua
{{ if eq .machine "desktop" -}}
hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@60",   position = "0x0",    scale = 1, transform = 1 })
hl.monitor({ output = "DP-5",     mode = "2560x1440@144",  position = "1080x0", scale = 1 })
{{- else -}}
-- G14 2020: internal panel. Confirm the connector name with `hyprctl monitors`
-- on the laptop before committing -- eDP-1 vs eDP-2 depends on which GPU
-- drives the panel under the MUX setting in use.
hl.monitor({ output = "eDP-1", mode = "1920x1080@120", position = "0x0", scale = 1 })
hl.monitor({ output = "",      mode = "preferred", position = "auto", scale = "auto" })
{{- end }}
```

Note the desktop values above are the *verified* ones — DP-5 EDID reports
2560x1440 @ 143.97 Hz (LG UltraGear), HDMI-A-2 is a 1080p "C240".

### 3b. `env.lua.tmpl`

```lua
{{ if eq .gpu "nvidia" -}}
hl.env("AQ_DRM_DEVICES", {{ .gpuPciPath | quote }})
{{- end }}

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
{{ if eq .gpu "nvidia" -}}
hl.env("GBM_BACKEND", "nvidia-drm")
{{- else -}}
-- Hybrid: do NOT set GBM_BACKEND globally. The compositor runs on the AMD
-- iGPU; forcing nvidia-drm breaks the iGPU render path. Per-app offload via
-- prime-run / __NV_PRIME_RENDER_OFFLOAD instead.
{{- end }}
```

This is the single most important template — the desktop wants the NVIDIA card
pinned, the G14 explicitly must not have it.

### 3c. `waybar/config.jsonc.tmpl`

```jsonc
"modules-right": [
    "tray",
{{- if .laptop }}
    "battery",
    "backlight",
{{- end }}
    "cpu",
    "memory",
    …
],
"hyprland/workspaces": {
    "persistent-workspaces": {
{{- if eq .machine "desktop" }}
        "DP-5": [1, 2, 3],
        "HDMI-A-2": [4]
{{- else }}
        "eDP-1": [1, 2, 3, 4]
{{- end }}
    }
}
```

### 3d. Laptop-only power management

New `dot_config/hypr/power.lua.tmpl`, `require`d conditionally. Cleanest is to
let `.chezmoiignore` drop the file entirely on the desktop and guard the
`require` in `hyprland.lua`:

```lua
pcall(require, "power")   -- laptop only; absent on the desktop
```

`home/.chezmoiignore` (itself a template — listed paths are **target** paths):

```
{{ if ne .machine "g14" }}
.config/hypr/power.lua
{{ end }}
{{ if ne .machine "desktop" }}
.config/waybar/scripts/sidetone.sh
.config/waybar/scripts/sidetone-device.sh
{{ end }}

# never manage runtime state
.config/waybar/sidetone_device.state
```

The sidetone scripts are desktop-only by nature — they hardcode PipeWire node
names for USB audio hardware that is not on the laptop.

---

## 4. Migration steps

```bash
# 1. new branch
git switch -c chezmoi-migration

# 2. carve out the source root
mkdir -p home/dot_config

# 3. move each stow package (git mv keeps history)
for p in hypr waybar wofi kitty btop walker elephant; do
    git mv "$p/.config/$p" "home/dot_config/$p"
    rmdir "$p/.config" "$p"
done

# 4. home-level dotfiles
git mv zsh/.zshrc        home/dot_zshrc
git mv zsh/.zprofile     home/dot_zprofile
git mv zsh/.zlogin       home/dot_zlogin
git mv zsh/.zsh_aliases  home/dot_zsh_aliases
git mv p10k/.p10k.zsh    home/dot_p10k.zsh
rmdir zsh p10k

# 5. executable_ prefixes -- REQUIRED
for f in home/dot_config/hypr/scripts/*.sh home/dot_config/waybar/scripts/*.sh; do
    git mv "$f" "$(dirname "$f")/executable_$(basename "$f")"
done

# 6. mark templates
git mv home/dot_config/hypr/env.lua       home/dot_config/hypr/env.lua.tmpl
git mv home/dot_config/hypr/monitors.lua  home/dot_config/hypr/monitors.lua.tmpl
git mv home/dot_config/hypr/workspace.lua home/dot_config/hypr/workspace.lua.tmpl
git mv home/dot_config/hypr/hyprpaper.conf home/dot_config/hypr/hyprpaper.conf.tmpl
git mv home/dot_config/waybar/config.jsonc home/dot_config/waybar/config.jsonc.tmpl

# 7. write .chezmoiroot / .chezmoi.toml.tmpl / .chezmoiignore, then edit the
#    five .tmpl files to add the conditionals from section 3
echo home > .chezmoiroot
```

---

## 5. Cutover and verification

```bash
sudo pacman -S --needed chezmoi

# tear down the stow symlinks first -- chezmoi will not write through a
# symlink pointing back into the repo, and you get confusing no-op applies
for d in hypr waybar wofi kitty btop walker elephant; do
    [ -L "$HOME/.config/$d" ] && rm "$HOME/.config/$d"
done

chezmoi init --source="$HOME/dotfiles"     # prompts for machine
chezmoi diff                               # MUST be inspected before apply
chezmoi apply -v
```

Verification checklist after apply:

- [ ] `chezmoi diff` is empty on a second run
- [ ] `ls -l ~/.config/hypr/scripts/` — all `.sh` are `755`, not `644`
- [ ] `ls ~/.config/hypr/*.tmpl` returns nothing (suffix must be stripped)
- [ ] `grep AQ_DRM_DEVICES ~/.config/hypr/env.lua` shows the 4080 path
- [ ] `grep -c battery ~/.config/waybar/config.jsonc` — commented out on desktop
- [ ] `for f in ~/.config/hypr/*.lua; do luac -p "$f"; done` is silent
- [ ] Hyprland session starts and both monitors come up in the right positions

Keep `deploy.sh` on the branch until the cutover is verified on **both**
machines; it is the rollback path.

---

## 6. Deliberately out of scope

- Package installation is not chezmoi's job here. If you later want the repo
  to bootstrap a machine, add `home/.chezmoiscripts/run_onchange_install-packages.sh.tmpl`
  with the package list templated on `.machine`. Worth doing *after* the
  config migration is stable, not during.
- No secrets in this repo today, so no `chezmoi secret` / age integration
  needed. Revisit if ssh config or tokens move in.
