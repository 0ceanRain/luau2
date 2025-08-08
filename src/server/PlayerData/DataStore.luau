-- Server Script: Place this in ServerScriptService
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")


local playerDataStore = DataStoreService:GetDataStore("PlayerData")
local characterDataStore = DataStoreService:GetDataStore("PlayerCharacters")


local function getDefaultData()
	return {
		coins = 0,
		kills = 0,
		ownedCharacters = {"Ice"}
	}
end


local function loadPlayerData(player)
	local success, data = pcall(function()
		return playerDataStore:GetAsync(player.UserId)
	end)

	if success then
		return data or getDefaultData()
	else
		warn("Failed to load data for " .. player.Name .. ": " .. tostring(data))
		return getDefaultData()
	end
end


local playerDataCache = {}


local function savePlayerData(player)
	if not player.Parent then return end 

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local coins = leaderstats:FindFirstChild("Coins")
	local kills = leaderstats:FindFirstChild("Kills")

	if not coins or not kills then return end

	
	local ownedCharacters = playerDataCache[player.UserId] and playerDataCache[player.UserId].ownedCharacters or {"Ice"}

	local dataToSave = {
		coins = coins.Value,
		kills = kills.Value,
		ownedCharacters = ownedCharacters
	}

	local success, error = pcall(function()
		playerDataStore:SetAsync(player.UserId, dataToSave)
	end)

	if not success then
		warn("Failed to save data for " .. player.Name .. ": " .. tostring(error))
	else
		print("Saved data for " .. player.Name)
	end
end


local function createLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = leaderstats

	local kills = Instance.new("IntValue")
	kills.Name = "Kills"
	kills.Parent = leaderstats


	local data = loadPlayerData(player)
	coins.Value = data.coins
	kills.Value = data.kills


	playerDataCache[player.UserId] = {
		ownedCharacters = data.ownedCharacters
	}

	return leaderstats
end


Players.PlayerAdded:Connect(function(player)
	createLeaderstats(player)


	spawn(function()
		while player.Parent do
			wait(30)
			savePlayerData(player)
		end
	end)
end)


Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
	
	playerDataCache[player.UserId] = nil
end)


game:BindToClose(function()
	print("Server shutting down, saving all player data...")

	for _, player in pairs(Players:GetPlayers()) do
		savePlayerData(player)
	end

	wait(2) 
end)


local function awardKill(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		local kills = leaderstats:FindFirstChild("Kills")

		if coins and kills then
			coins.Value = coins.Value + 50 
			kills.Value = kills.Value + 1

			print(player.Name .. " got a kill! New stats - Coins: " .. coins.Value .. ", Kills: " .. kills.Value)
		end
	end
end


_G.AwardKill = awardKill
_G.GetOwnedCharacters = function(player)
	return playerDataCache[player.UserId] and playerDataCache[player.UserId].ownedCharacters or {"Ice"}
end
_G.AddOwnedCharacter = function(player, characterName)
	if not playerDataCache[player.UserId] then
		playerDataCache[player.UserId] = {ownedCharacters = {"Ice"}}
	end

	
	local ownedCharacters = playerDataCache[player.UserId].ownedCharacters
	for _, char in ipairs(ownedCharacters) do
		if char == characterName then
			return false 
		end
	end


	table.insert(ownedCharacters, characterName)
	return true 
end
