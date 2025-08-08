local player = game:GetService("Players").LocalPlayer
local Character = player.Character
local Humanoid:Humanoid = player.Character:FindFirstChild("Humanoid")
local playerName = player.Name
local uis = game:GetService("UserInputService")
local refreshAbilities = game.ReplicatedStorage.Shared.Remotes.utilityRemotes.refershAbilites
local parryRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.parryRemote
local blockRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.blockRemote
local abilityMap = {
	["E"] = Enum.KeyCode.E,
	["R"] = Enum.KeyCode.R,
	["v"] = Enum.KeyCode.V
}

local animator:Animator = Humanoid:FindFirstChild("Animator")
local parryS:Animation = animator:LoadAnimation(game.ReplicatedStorage.Shared.Animations.defaultAnims.parryS)
local parried:Animation = animator:LoadAnimation(game.ReplicatedStorage.Shared.Animations.defaultAnims.parried)
local parry:Animation = animator:LoadAnimation(game.ReplicatedStorage.Shared.Animations.defaultAnims.parry)
local blockAnim:Animation = animator:LoadAnimation(game.ReplicatedStorage.Shared.Animations.defaultAnims.blockAnim)
local orWalkSpeed = Humanoid.WalkSpeed
local loadedAbilities = {}
local states = require(game.ReplicatedStorage.Shared.UtilityModules.StateModule)

if states:Stunned() then
	Humanoid.WalkSpeed = 6
end

if not states:Stunned() then
	Humanoid.WalkSpeed = orWalkSpeed
end
local function loadAbilities()
	local abilitiesFolder = game.ReplicatedStorage:WaitForChild(playerName):FindFirstChild("AbilitiesFolder")

	if not abilitiesFolder then
		print("AbilitiesFolder not found for player: " .. playerName)
		return
	end                


	for abilityName, keyCode in pairs(abilityMap) do
		local abilityFolderName = abilityName .. "_Ability"
		local abilityFolder = abilitiesFolder:FindFirstChild(abilityFolderName)

		if abilityFolder then

			local abilityModule = abilityFolder:FindFirstChildOfClass("ModuleScript")
			if abilityModule then
				local success, ability = pcall(require, abilityModule)
				if success and ability then
					loadedAbilities[abilityName] = ability
					print("Loaded " .. abilityName .. " ability successfully")
				else
					print("Failed to require " .. abilityName .. " ability module")
				end
			else
				print("No ModuleScript found in " .. abilityFolderName)
			end
		else
			print("No " .. abilityFolderName .. " folder found - skipping keybind")
		end
	end
end


loadAbilities()


refreshAbilities.Event:Connect(function()
	loadAbilities()
end)


local inputConnection = uis.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	
	for abilityName, ability in pairs(loadedAbilities) do
		local keyCode = abilityMap[abilityName]

		if input.KeyCode == keyCode then
			
			loadAbilities()
			
			if ability:CanActivate() then
				ability:Activate()
				print("Activated " .. abilityName .. " ability")
			else
				print(abilityName .. " ability cannot be activated right now")
			end
			break 
		end
	end
end)
local isFDown = false
local parryDone = false
local parryCD = false
local blocking = false
local blockingDone = false
local parrySuccessful = false
uis.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.F and not parryCD then
		--isFDown = true
		parryDone = false
		parryCD = true
		
		parry:play()
		parryRemote:FireServer(1) 

		local parryWait = task.delay(0.4, function()
			parryRemote:FireServer(2)
		
			parryDone = true
			blocking = true
			
			blockRemote:FireServer(1)
			local stopBlock1 = task.delay(0.15, function()
				if blocking then
					blocking = false
					blockRemote:FireServer(2)
				end
			end)
			task.delay(0.05, function()
				if uis:IsKeyDown(Enum.KeyCode.F) then
					task.cancel(stopBlock1)
					blocking = true
					
					blockingDone = false
				end
				
			end)	


			task.delay(1.5, function()
				parryCD = false
			end)
		end)


		if parrySuccessful then
			task.cancel(parryWait)
			print("task canceld")
		end

	end
end)


uis.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		isFDown = false
		if blocking then
			blocking = false
			blockingDone = true
			
			blockAnim:stop()
			blockRemote:FireServer(2)
		end
	end
end)



parryRemote.OnClientEvent:Connect(function(string)
	if string == "Parried" then
		

		parryCD = false
		print("parry")
		parrySuccessful = true
		parryDone = true
		parryRemote:FireServer(1)
				
		parryS:Play()
		task.delay(0.2, function()

			parrySuccessful = false
		end)
	end
	if string == "Parry" then
		--parryStun = true

		for i,v in pairs(player.Character.Humanoid:GetPlayingAnimationTracks()) do
			v:Stop()
		end

		parried:play()
		
		--task.wait(0.2)
		--idleAnim:play()
	end




end)

if blocking then
	blockAnim:play()
	blockRemote:FireServer(1)

end
