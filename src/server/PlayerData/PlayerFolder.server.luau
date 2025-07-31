local Players = game:GetService("Players")


Players.PlayerAdded:Connect(function(player)
   local DataFolder = Instance.new("Folder")
   DataFolder.Parent = game.ReplicatedStorage
   DataFolder.Name = player.Name
  
   
	local AbilitiesFolder = Instance.new("Folder")
	
	AbilitiesFolder.Name = 'AbilitiesFolder'
	AbilitiesFolder.Parent = DataFolder
	
	local R_Ability = Instance.new("Folder")
	
	R_Ability.Name = 'R_Ability'
	R_Ability.Parent = AbilitiesFolder
	
	local E_Ability = Instance.new("Folder")

	E_Ability.Name = 'E_Ability'
	E_Ability.Parent = AbilitiesFolder
   
end)



