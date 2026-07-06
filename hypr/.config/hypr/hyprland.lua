-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")

require("env")
require("monitors")
require("input")
require("appearance")
require("startup")
require("general")
require("workspace")
---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "walker"


---------------------
----   SCRIPTS   ----
---------------------
local workspaceWrap    = "~/.config/hypr/scripts/workspace-wrap.sh"
local powerMenu        = "~/.config/hypr/scripts/power-menu.sh"
local walkerMenu       = "~/.config/hypr/scripts/arch-menu.sh"



-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty --title fly_is_kitty"))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(walkerMenu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind("ALT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind("ALT" .. "+ Q", hl.dsp.window.move({ workspace = "special:magic" }))

-- Logic to stay within workspaces 1-3
local function get_target_ws(step)
    local current = hl.get_active_workspace().id
    local target = current + step

    if target > 3 or current == 4 then
        target = 1
    elseif target < 1 then
        target = 3
    end
    return tostring(target)
end

-- Right Binding
hl.bind("CTRL + ALT + RIGHT", function()
    local target = get_target_ws(1)
    -- hl.notification.create({ text = "Moving to Workspace " .. target, duration = 2000 })
    return hl.dispatch(hl.dsp.focus({ workspace = target }))
end)

-- Left Binding
hl.bind("CTRL + ALT + LEFT", function()
    local target = get_target_ws(-1)
    -- hl.notification.create({ text = "Moving to Workspace " .. target, duration = 2 })
    return hl.dispatch(hl.dsp.focus({ workspace = target }))
end)


-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    no_focus = true,
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false
    }
})

hl.window_rule({
    monitor = 1,
    min_size = {1152, 648},
    max_size = {1152, 648},
    size = {1152, 648},
    float = true,
    match = { class = "^(The Honkers Railway Launcher)$" }
})

hl.window_rule({
    monitor = 1,
    min_size = {1152, 648},
    max_size = {1152, 648},
    size = {1152, 648},
    float = true,
    match = { class = "^(Sleepy Launcher)$" }
})

hl.window_rule({
    center = true,
    float = true,
    match = { class = "^(*.exe)$" }
})

hl.window_rule({
    content = "game",
    monitor = 1,
    float = true,
    match = { initial_class= "^steam_app_.*$"}
})

hl.window_rule({
    size = {1280, 720},
    float = true,
    fullscreen = false,
    monitor = 1,

    idle_inhibit = "always",
    render_unfocused = true,
    match = { class = "^(steam_app_3224770)$" }
})

hl.window_rule({
    float = true,
    match = { class = "steam$" }
})

hl.window_rule({
    float = true,
    match = {
        class = "kitty",
        title = "^(.*steamapps/common.*)$"
    }
})

hl.window_rule({
    monitor = 1,
    match = { class = "^(steam_app_%d)$" }
})

hl.window_rule({
    opacity = 0.92,
    match = { class = "code-oss$" }
})

hl.window_rule({
    opacity = 0.8,
    match = { class = "org.kde.dolphin$" }
})

hl.window_rule({
    size = {800, 500},
    center = true,
    float = true,
    match = { title = "^(fly_is_kitty)$" }
})

hl.window_rule({
    animation = "slide",
    float = true,
    match = { title = "^(all_is_kitty)$" }
})

hl.window_rule({
    tile = true,
    match = { title = "^(kitty)$" }
})

hl.window_rule({
    workspace = "1",
    float = true,
    size = {542, 271},
    match = { title = "^(clock_is_kitty)$" }
})

hl.window_rule({
    workspace = 4,
    no_initial_focus = true,
    float = false,
    match = {
        initial_class = "spotify"
    }
})

hl.window_rule({
    content = "game",
    monitor = 1,
    float = true,
    no_screen_share = true,
    match = { initial_class= "steam_app_1590600"}
})