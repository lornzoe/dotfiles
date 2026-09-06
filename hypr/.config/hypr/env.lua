-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

--------------------------------------------------------------------
-- PER-MACHINE: GPU
-- Desktop (this box): single RTX 4080, displays wired to the NVIDIA
-- card. An AMD Raphael iGPU is also present and enumerated by DRM,
-- so aquamarine is pinned to the NVIDIA node explicitly.
--   card1 = amdgpu  (0000:11:00.0)  <- iGPU, no displays attached
--   card2 = nvidia  (0000:01:00.0)  <- DP-5 + HDMI-A-2 live here
-- On the G14 this whole block becomes a template branch.
--------------------------------------------------------------------
hl.env("AQ_DRM_DEVICES", "/dev/dri/by-path/pci-0000:01:00.0-card")

-- NVIDIA + Wayland
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")           -- required by libva-nvidia-driver >= 0.0.10
hl.env("GBM_BACKEND", "nvidia-drm")       -- if Firefox/Chromium go soft-render, drop this one first

-- XDG_SESSION_TYPE is exported by uwsm/the session, not here. Setting it
-- from the compositor is too late for anything that reads it at startup.
-- Kept as a no-op-safe belt-and-braces value for nested/manual launches.
hl.env("XDG_SESSION_TYPE", "wayland")

-- Toolkit backends
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Cursor
-- Nordzy is AUR (nordzy-cursors / nordzy-hyprcursors) and is NOT installed
-- on this machine yet. Falling back to Adwaita so the cursor is not invisible.
-- Swap both back to Nordzy / Nordzy-hyprcursors once the AUR packages are in.
hl.env("XCURSOR_SIZE", "26")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "26")
hl.env("HYPRCURSOR_THEME", "Adwaita")
