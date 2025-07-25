local Players = game:GetService("Players")


Players.PlayerAdded:Connect(function(player)
   local DataFolder = Instance.new("Folder")
   DataFolder.Name = player.Name
   DataFolder.Parent = game.ReplicatedStorage.player.Data
end)