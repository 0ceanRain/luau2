local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    player.Character:SetAttribute("Parrying", false)
    player.Character:SetAttribute("Dashing", false)
    player.Character:SetAttribute("Blocking", false)
    player.Character:SetAttribute("DoingAction", false)
    player.Character:SetAttribute("Stunned", false)
end)
