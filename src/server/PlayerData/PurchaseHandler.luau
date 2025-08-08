
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


local characterCheckRemote = ReplicatedStorage.Shared.Remotes.utilityRemotes.CheckCharacterStatus


local function getOwnedCharacters(player)
	if _G.GetOwnedCharacters then
		return _G.GetOwnedCharacters(player)
	end
	return {"Ice"}
end


local function addOwnedCharacter(player, characterName)
	if _G.AddOwnedCharacter then
		return _G.AddOwnedCharacter(player, characterName)
	end
	return false 
end


characterCheckRemote.OnServerInvoke = function(player, characterName, price, attemptPurchase)

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		warn("No leaderstats found for player: " .. player.Name)
		return {owned = false, canAfford = false, error = "No leaderstats"}
	end

	local coinsValue = leaderstats:FindFirstChild("Coins")
	if not coinsValue then
		warn("No coins leaderstat found for player: " .. player.Name)
		return {owned = false, canAfford = false, error = "No coins stat"}
	end

	local currentCoins = coinsValue.Value


	local ownedCharacters = getOwnedCharacters(player)


	local isOwned = false
	for _, ownedChar in ipairs(ownedCharacters) do
		if ownedChar == characterName then
			isOwned = true
			break
		end
	end

	
	local canAfford = currentCoins >= price


	if attemptPurchase and not isOwned and canAfford then
	
		coinsValue.Value = coinsValue.Value - price

	
		local saveSuccess = addOwnedCharacter(player, characterName)

		if saveSuccess then
			print(player.Name .. " purchased " .. characterName .. " for " .. price .. " coins")
			return {owned = true, canAfford = true, purchased = true}
		else
		
			coinsValue.Value = coinsValue.Value + price
			return {owned = false, canAfford = true, purchased = false, error = "Save failed"}
		end
	end

	return {
		owned = isOwned,
		canAfford = canAfford,
		currentCoins = currentCoins,
		price = price
	}
end


Players.PlayerAdded:Connect(function(player)
	
	player.CharacterAdded:Wait()

	
	while not player:FindFirstChild("leaderstats") do
		wait(0.1)
	end


	print("Character purchase system ready for " .. player.Name)
end)
