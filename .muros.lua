-- build.bresilla.com builds this flake's checks on every push, sends each result to
-- its cache and pins it there, where machines look for kernels and firmware.
local muros = require("muros")

muros.cache = {
    default = "kernels",
    pin = true,
    pin_name = "{name}",
    no_pin = { "*-config", "driver-*" },
    rules = {
        { "*-firmware", "firmwares" },
        { "tb321fu-loader", "firmwares" },
        { "device-recipes", "firmwares" },
        { "driver-*", "firmwares" },
    },
}

muros.recipe { name = "checks", attribute = "checks" }
