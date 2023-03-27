local cpu = {}

local function yieldSim(...) end
local function byte(a) return bit32.band(a, 0xFF) end
local function word(a) return bit32.band(a, 0xFFFF) end
 
cpu.create = function()
    threading:getCurrent():stop()
    print("test")
    coroutine.yield()
    local data = {
        pc = 0x8000,
        sp = 0x00,
        A = 0,
        X = 0,
        Y = 0,
        flags = {
            C = false,
            Z = false,
            G = false,
            E = false,
            I = false,
            B = false,
            O = false,
        }, 
        bus = require("VM/bus").createBus()
    }
    return setmetatable(data, {
        __index = cpu
    })
end

function cpu:fetchByte()
    local data = self:readByte(self.pc)
    self.pc = word(self.pc + 1)
    return data
end

function cpu:fetchWord()
    local data = self:fetchByte()
    data = bit32.bor(bit32.arshift(self:fetchByte(), 8), data)
    return data
end

function cpu:readByte(addr)
    return self.bus[word(addr)]
end

function cpu:loadRegister(id, v)
    if id == 1 then
        self.A = byte(v)
    elseif id == 2 then
        self.B = byte(v)
    elseif id == 3 then
        self.C = byte(v)
    elseif id == 4 then
        self.D = byte(v)
    else
        error("Invalid Register")
        threading:getCurrent():stop()
        coroutine.yield()
    end

    -- if value == 0 
end

function cpu:execute(useYield)
    
    checkArg(1, useYield, "boolean", "nil")
    local yield = yieldSim
    if useYield then yield = coroutine.yield end
        
    while true do
        local ins = self:fetchByte()
        if ins == 0x00 then
        elseif ins == 0x04 then
            local r = self:fetchByte()
            local value = self:fetchByte()
            self:loadRegister(r, value)
        elseif ins == 0x09 then
            local r = self:fetchByte()
            local addr = self:fetchWord()
            local value = self:readByte(addr)
            self:loadRegister(r, value)
        else
            error("Invalid Instruction " .. tostring(ins))
        end
    end
end

return cpu