k.printk(k.L_INFO, " - 10_libraries")


k.package = k.system.executeFile("/system/lib/package.lua")
k.package.addLibraryPath("/system/lib/?.lua")
k.package.addLibraryPath("/system/lib/?/init.lua")
_G.require = k.package.require
k.threading = k.system.executeFile("/system/kernel/threading.lua")

k.event = require("event")
