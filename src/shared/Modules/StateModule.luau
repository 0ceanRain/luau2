local StateModule = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer

function StateModule:DoingAction()
    if player.Character:GetAttribute("DoingAction") then
        return true
    else
        return false
    end
end

function StateModule:Stunned()
    if player.Character:GetAttribute("Stunned") then
        return true
    else
        return false
    end
end

function StateModule:Parrying()
    if player.Character:GetAttribute("Parrying") then
        return true
    else
        return false
    end
end

function StateModule:Blocking()
    if player.Character:GetAttribute("Blocking") then
        return true
    else
        return false
    end
end

function StateModule:Dashing()
    if player.Character:GetAttribute("Dashing") then
        return true
    else
        return false
    end
end

return  StateModule