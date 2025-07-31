local ability = {}
ability.windup = 0.6
ability.CD = 10

local CombatStateModule = require(game.ReplicatedStorage.Shared.Modules.StateModule)
local AbilityRemote = game.ReplicatedStorage.Shared.Remotes.AbilityRemote



function ability:CanActivate()
    if CombatStateModule:Stunned() or CombatStateModule:DoingAction() then
        return false
    else
        return true
    end
end

function ability:Activate()
    task.delay(ability.windup, function()
        print("Used")
    end)
end


return ability
