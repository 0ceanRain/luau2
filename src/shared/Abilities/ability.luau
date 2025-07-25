local ability = {}
ability.windup = 0.6
ability.CD = 10

local CombatStateModule = require(game.ReplicatedStorage.Modules.CombatStateModule)
local AbilityRemote = game.ReplicatedStorage.remotes



function ability:CanActivate()
    if CombatStateModule then
        return false
    else
        return true
    end
end

function ability:Activate()
    task.delay(ability.windup, function()
        
    end)
end


return ability