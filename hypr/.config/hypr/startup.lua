-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Every launch below is guarded with `command -v`, so a machine that is
-- missing an optional package just skips that line instead of leaving a
-- dead exec in the session. Keeps one config usable on desktop + laptop.
local function run_if(bin, cmd, opts)
    hl.exec_cmd("command -v " .. bin .. " >/dev/null 2>&1 && " .. (cmd or bin), opts)
end

hl.on("hyprland.start", function()
    ----------------------------------------------------------------
    -- Session plumbing
    ----------------------------------------------------------------
    -- NOTE: no `dbus-update-activation-environment` / portal restart dance
    -- here. This session is started through uwsm (hyprland-uwsm.desktop),
    -- which imports the environment and manages xdg-desktop-portal-hyprland
    -- as a systemd user unit. Doing it manually races the unit and was the
    -- likely reason the old config needed the `sleep 2 && hyprctl reload`
    -- band-aid. If you ever launch Hyprland bare from a TTY, re-add it.

    -- Polkit agent (hyprpolkitagent is not installed; KDE agent is)
    run_if("/usr/lib/polkit-kde-authentication-agent-1")

    -- Notifications
    run_if("dunst")

    -- Clipboard history
    run_if("cliphist", "wl-paste --type text --watch cliphist store")
    run_if("cliphist", "wl-paste --type image --watch cliphist store")

    ----------------------------------------------------------------
    -- Wallpaper
    ----------------------------------------------------------------
    -- swww was renamed upstream to `awww` (extra/awww). hyprpaper is what
    -- is actually installed right now, and reads ~/.config/hypr/hyprpaper.conf.
    hl.exec_cmd([[
        if command -v awww >/dev/null 2>&1; then
            awww-daemon & sleep 1
            awww img "$HOME/.config/hypr/wallpapers/my-neighbor-totoro-sunflowers.png"
        elif command -v hyprpaper >/dev/null 2>&1; then
            hyprpaper
        fi
    ]])

    ----------------------------------------------------------------
    -- Bar / launcher
    ----------------------------------------------------------------
    run_if("waybar")
    run_if("elephant")                                  -- walker's backend daemon
    run_if("walker", "walker --gapplication-service")
    run_if("hyprswitch", "hyprswitch init")

    ----------------------------------------------------------------
    -- Applications
    ----------------------------------------------------------------
    run_if("vesktop", nil, { workspace = "4" })
    run_if("steam", "steam -silent", { workspace = "2 silent" })

    run_if("zen-browser", nil, { workspace = "1" })
    run_if("code", nil, { workspace = "1" })
    run_if("kitty", "kitty --title fly_is_kitty", { workspace = "1" })

    hl.exec_cmd("hyprctl dispatch workspace 1")
end)
