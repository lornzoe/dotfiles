------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({ -- Side monitor
    output      = "HDMI-A-2",
    mode        = "1920x1080@60",
    position    = "0x0",
    scale       = 1,
    transform   = 1
})

hl.monitor({ -- Main monitor
    output      = "DP-5",
    mode        = "2560x1440@144",
    position    = "1080x0",
    scale       = 1

})

-- hl.monitor({ -- Main monitor
--     output      = "DP-5",
--     mode        = "2560x1440@144",
--     position    = "0x0",
--     scale       = 1

-- })