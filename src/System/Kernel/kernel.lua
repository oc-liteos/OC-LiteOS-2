_G.VERSION_INFO = {}
_G.VERSION_INFO.major = 0
_G.VERSION_INFO.minor = 1
_G.VERSION_INFO.micro = 0
_G.VERSION_INFO.release = "dev"


k = {screen={}}

local files = component.invoke(computer.getBootAddress(), "list", "/system/kernel/modules")
table.sort(files)

for _,file in ipairs(files) do
    local module, err = _G.lib.loadfile("/system/kernel/modules/" .. file)
    if not module then
        error(file .. ": " .. err)
    end
    module()
end

k.printk(k.L_INFO, "Running CoreOS v" .. _G.VERSION_INFO.major .. "." .. _G.VERSION_INFO.minor .. "." .. _G.VERSION_INFO.micro .. "-".. _G.VERSION_INFO.release)

-- dofile("/system/bin/init.lua")

k.threading.createThread("init",  function()
    local sandbox = require("Sandbox")
    local env = sandbox.create_env()
    _G.syscall = env.syscall
    _G.ioctl = env.ioctl

    local shell = require("Shell")
    
    local sh, err
    _G.filesystem = env.filesystem
    local sh, err = shell.connect("tty0")
    if not sh then
        k.panic(err)
    end
    -- while true do
        sh:execute("/system/bin/vm.lua")
    -- end
    -- k.panic(result)


    _G.syscall, _G.ioctl = nil, nil
end, 1):start()
-- if not init then error("/system/bin/init.lua: " .. tostring(err)) end


-- thread management (look in /system/kernel/threading.lua)
while true do
    for thread, v in pairs(k.threading.threads) do
        if k.threading.threads[thread].stopped then goto continue end
        if coroutine.status(v.coro) == "dead" then
            k.threading.threads[thread]:stop()
            goto continue
        end
        result = table.pack(coroutine.resume(v.coro))
        -- k.write(dump(result))
        if not result[1] then
            k.panic(dump(result[2]))
        end
        if coroutine.status(v.coro) == "dead" then
            k.threading.threads[thread].result = result[2]
            k.threading.threads[thread]:stop()
            goto continue
        end
        
        -- coroutine.resume(v.coro, table.unpack({k.processSyscall(result)}))
        ::continue::
        local s = table.pack(computer.pullSignal(0.01))
        if s.n > 0 then
            computer.pushSignal(table.unpack(s))
        end
    end
end