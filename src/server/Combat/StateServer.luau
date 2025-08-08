




local players = game:GetService("Players")
players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)

		char:SetAttribute("Parrying", false)
		char:SetAttribute("Swinging", false)
		char:SetAttribute("Stunned", false)
		char:SetAttribute("Dashing", false)
		char:SetAttribute("Blocking", false)
		char:SetAttribute("doingAction", false)
		char:SetAttribute("UsingAbility", false)
		char:SetAttribute("Iframes", false)
	end)
end)
