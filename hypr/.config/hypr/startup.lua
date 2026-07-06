-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function () 
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)

hl.on("hyprland.start", function()
    -- Basic Background Processes
    hl.exec_cmd("sleep 2 && hyprctl reload")
    hl.exec_cmd("hyprctl setcursor Nordzy-hyprcursors 26")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("swww-daemon")
    hl.exec_cmd("sleep 1 && swww img dotfiles/hypr/.config/hypr/wallpapers/my-neighbor-totoro-sunflowers.png")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprswitch init &")
    hl.exec_cmd("elephant")
    hl.exec_cmd("walker --gapplication-service")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland")
    hl.exec_cmd("systemctl --user stop xdg-desktop-portal xdg-desktop-portal-hyprland")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")

    -- Workspace-Specific Autostart
    -- Lua allows passing a table to hl.exec_cmd for rules like workspace and silent
    hl.exec_cmd("discord", { workspace = "4" })
    hl.exec_cmd("steam -silent", { workspace = "2 silent" })
    
    -- Focused Startup
    hl.exec_cmd("hyprctl dispatch workspace 1")
    hl.exec_cmd("zen-browser", { workspace = "1" })
    hl.exec_cmd("code", { workspace = "1" })
    hl.exec_cmd("kitty --title fly_is_kitty", { workspace = "1" })
end)