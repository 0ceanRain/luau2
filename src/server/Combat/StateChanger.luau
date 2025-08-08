local parryRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.parryRemote
local blockRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.blockRemote
parryRemote.OnServerEvent:Connect(function(player, num)
	if num == 1 then
		player.Character:SetAttribute("Parrying", true)
	else
		player.Character:SetAttribute("Parrying", false)
	end

end)
 

blockRemote.OnServerEvent:Connect(function(player, num)
	if num == 1 then
		player.Character:SetAttribute("Blocking", true)
	else
		player.Character:SetAttribute("Blocking", false)
	end

end)
