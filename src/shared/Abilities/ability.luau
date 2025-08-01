local ability = {}
ability.windup = 0.6
ability.CD = 10
ability.Name = "TestAbility"
ability.Damage = 10
ability.PostureDamage = 5
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
    AbilityRemote:FireClient({
        Name = ability.Name,
        Damage = ability.Damage,
        PostureDamage = ability.PostureDamage
    })
    end)
end


return ability
