local api = {}
local constants = require("VM/constants")

api.createBus = function()
    local memory = {}
    for i = 0, constants.MAX_ADDRESS do
        memory[i] = 0
    end
    return memory
end
return api