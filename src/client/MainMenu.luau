--[[ Made by coolcapidog
Channel ->> https://www.youtube.com/c/coolcapidog
You can change the settings but you shouldn't change anything except settings.
]]
------------------------------------ Settings
local SettingsEnabled = true
local CreditsEnabled = true
local DayClockTime = 14
local NightClockTime = 18
------------------------------------ Settings

local Player = game.Players.LocalPlayer
local tweenService = game:GetService("TweenService")
local Char = Player.Character
local Camera = game.Workspace.CurrentCamera
local MenuCam = game.Workspace:WaitForChild("MenuCam")
local Process = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local characterCheckRemote = ReplicatedStorage.Shared.Remotes.utilityRemotes.CheckCharacterStatus

local selectedCharacter = nil
local characterButtons = {}

wait(game:IsLoaded())
MenuCam.Transparency = 1
Camera.CameraType = Enum.CameraType.Scriptable
Camera.CFrame = MenuCam.CFrame
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = game.Lighting

local Black = tweenService:Create(script.Parent:WaitForChild("Black") ,TweenInfo.new(2, 
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out),
	{Transparency = 0})
local UnBlack = tweenService:Create(script.Parent:WaitForChild("Black") ,TweenInfo.new(2, 
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out),
	{Transparency = 1})
local Blur = tweenService:Create(BlurEffect ,TweenInfo.new(2, 
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out),
	{Size = 20})
local UnBlur = tweenService:Create(BlurEffect ,TweenInfo.new(1, 
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out),
	{Size = 0})

if SettingsEnabled == false then
	script.Parent.SettingsButton.Visible = false
end
if CreditsEnabled == false then
	script.Parent.CharacterButton.Visible = false
else
	if script.Parent:WaitForChild("CharacterFrame"):WaitForChild("Frame"):FindFirstChild("TextLabel") then
		if script.Parent:WaitForChild("CharacterFrame"):WaitForChild("Frame"):WaitForChild("TextLabel").Text == "Scripter -" then
			script.Parent.CharacterFrame.Frame.TextLabel.Text = "Scripter - "..Player.Name
		end
	end
end

script.Parent:WaitForChild("GameMusic").Playing = true

script.Parent.SettingsButton.MouseButton1Click:Connect(function()
	if Process == true then return end
	Process = true
	if script.Parent.SettingsFrame.Position == UDim2.new(0.5, 0,-0.4, 0) then
		script.Parent.SettingsFrame:TweenPosition(UDim2.new(0.5, 0,0.5, 0), "Out", "Quad", 1)
		script.Parent.PlayButton:TweenPosition(UDim2.new(-0.3, 0,0.353, 0), "Out", "Quad", 0.5)
		script.Parent.SettingsButton:TweenPosition(UDim2.new(-0.3, 0,0.508, 0), "Out", "Quad", 0.5)
		script.Parent.CharacterButton:TweenPosition(UDim2.new(-0.3, 0,0.636, 0), "Out", "Quad", 0.5)
		Blur:Play()
	else
		script.Parent.SettingsFrame:TweenPosition(UDim2.new(0.5, 0,-0.4, 0), "Out", "Quad", 1)
		script.Parent.PlayButton:TweenPosition(UDim2.new(0.005, 0,0.353, 0), "Out", "Quad", 0.5)
		script.Parent.SettingsButton:TweenPosition(UDim2.new(0.005, 0,0.508, 0), "Out", "Quad", 0.5)
		script.Parent.CharacterButton:TweenPosition(UDim2.new(0.005, 0,0.636, 0), "Out", "Quad", 0.5)
		UnBlur:Play()
	end
	wait(2)
	Process = false
end)




script.Parent.CharacterButton.MouseButton1Click:Connect(function()
	if Process == true then return end
	Process = true
	if script.Parent.CharacterFrame.Position == UDim2.new(0.5, 0,-0.4, 0) then
		script.Parent.CharacterFrame:TweenPosition(UDim2.new(0.5, 0,0.5, 0), "Out", "Quad", 1)
		script.Parent.PlayButton:TweenPosition(UDim2.new(-0.3, 0,0.353, 0), "Out", "Quad", 0.5)
		script.Parent.SettingsButton:TweenPosition(UDim2.new(-0.3, 0,0.508, 0), "Out", "Quad", 0.5)
		script.Parent.CharacterButton:TweenPosition(UDim2.new(-0.3, 0,0.636, 0), "Out", "Quad", 0.5)
		Blur:Play()
	else
		script.Parent.CharacterFrame:TweenPosition(UDim2.new(0.5, 0,-0.4, 0), "Out", "Quad", 1)
		script.Parent.PlayButton:TweenPosition(UDim2.new(0.005, 0,0.353, 0), "Out", "Quad", 0.5)
		script.Parent.SettingsButton:TweenPosition(UDim2.new(0.005, 0,0.508, 0), "Out", "Quad", 0.5)
		script.Parent.CharacterButton:TweenPosition(UDim2.new(0.005, 0,0.636, 0), "Out", "Quad", 0.5)
		UnBlur:Play()
	end
	wait(2)
	Process = false
end)

script.Parent.CharacterFrame.ExitButton.MouseButton1Click:Connect(function()
	if Process == true then return end
	Process = true
	script.Parent.CharacterFrame:TweenPosition(UDim2.new(0.5, 0,-0.4, 0), "Out", "Quad", 1)
	script.Parent.PlayButton:TweenPosition(UDim2.new(0.005, 0,0.353, 0), "Out", "Quad", 0.5)
	script.Parent.SettingsButton:TweenPosition(UDim2.new(0.005, 0,0.508, 0), "Out", "Quad", 0.5)
	script.Parent.CharacterButton:TweenPosition(UDim2.new(0.005, 0,0.636, 0), "Out", "Quad", 0.5)
	UnBlur:Play()
	wait(2)
	Process = false
end)

script.Parent.SettingsFrame.ExitButton.MouseButton1Click:Connect(function()
	if Process == true then return end
	Process = true
	script.Parent.SettingsFrame:TweenPosition(UDim2.new(0.5, 0,-0.4, 0), "Out", "Quad", 1)
	script.Parent.PlayButton:TweenPosition(UDim2.new(0.005, 0,0.353, 0), "Out", "Quad", 0.5)
	script.Parent.SettingsButton:TweenPosition(UDim2.new(0.005, 0,0.508, 0), "Out", "Quad", 0.5)
	script.Parent.CharacterButton:TweenPosition(UDim2.new(0.005, 0,0.636, 0), "Out", "Quad", 0.5)
	UnBlur:Play()
	wait(2)
	Process = false
end)

if script.Parent.SettingsFrame.Frame:FindFirstChild("Shadows") then
	script.Parent.SettingsFrame.Frame.Shadows.MouseButton1Click:Connect(function()
		if script.Parent.SettingsFrame.Frame.Shadows.Text == "X" then
			script.Parent.SettingsFrame.Frame.Shadows.Text = ""
			game.Lighting.GlobalShadows = false
		else
			script.Parent.SettingsFrame.Frame.Shadows.Text = "X"
			game.Lighting.GlobalShadows = true
		end
	end)
end
if script.Parent.SettingsFrame.Frame:FindFirstChild("Time") then
	script.Parent.SettingsFrame.Frame.Time.MouseButton1Click:Connect(function()
		if script.Parent.SettingsFrame.Frame.Time.Text == "DAY" then
			script.Parent.SettingsFrame.Frame.Time.Text = "NIGHT"
			game.Lighting.ClockTime = NightClockTime
		else
			script.Parent.SettingsFrame.Frame.Time.Text = "DAY"
			game.Lighting.ClockTime = DayClockTime
		end
	end)
end
if script.Parent.SettingsFrame.Frame:FindFirstChild("Music") then
	script.Parent.SettingsFrame.Frame.Music.MouseButton1Click:Connect(function()
		if script.Parent.SettingsFrame.Frame.Music.Text == "X" then
			script.Parent.SettingsFrame.Frame.Music.Text = ""
			script.Parent.GameMusic.Playing = false
		else
			script.Parent.SettingsFrame.Frame.Music.Text = "X"
			script.Parent.GameMusic.Playing = true
		end
	end)
end
script.Parent.PlayButton.MouseButton1Click:Connect(function()
	if Process == true then return end
	Process = true
	Black:Play()
	wait(3)
	Camera.CameraType = Enum.CameraType.Custom
	script.Parent.PlayButton:Destroy()
	script.Parent.SettingsButton:Destroy()
	script.Parent.CharacterButton:Destroy()
	UnBlack:Play()
end)

local function giveCharacterAbility(characterName)
	local player = game.Players.LocalPlayer
	local refreshAbilities = game.ReplicatedStorage.Shared.Remotes.utilityRemotes.refershAbilites
	local playerName = player.Name


	local abilitiesFolder = game.ReplicatedStorage:FindFirstChild(playerName):FindFirstChild("AbilitiesFolder"):FindFirstChild("E_Ability")
	if abilitiesFolder then
		for _, ability in pairs(abilitiesFolder:GetChildren()) do
			if ability:IsA("ModuleScript") then
				ability:Destroy()
			end
		end
	end
	
	if characterName == "Ice" then
		local E_AbilityModule = game.ReplicatedStorage.Shared.Abilities.ability
		local E = E_AbilityModule:Clone()



		local abilityModule = game.ReplicatedStorage:FindFirstChild(playerName):FindFirstChild("AbilitiesFolder"):FindFirstChild("E_Ability"):FindFirstChildOfClass("ModuleScript")
		if abilityModule then
			print("ability already exists, cannot replicate")
		else
			E.Parent = game.ReplicatedStorage:WaitForChild(playerName):FindFirstChild("AbilitiesFolder"):FindFirstChild("E_Ability")
			refreshAbilities:Fire()
		end
	else
		print("no abilities made")
	end
	
	if characterName == "Lighting" then
		local E_AbilityModule = game.ReplicatedStorage.Shared.Abilities.Lighting.JoltGrab
		local E = E_AbilityModule:Clone()
		
		local abilityModule = game.ReplicatedStorage:FindFirstChild(playerName):FindFirstChild("AbilitiesFolder"):FindFirstChild("E_Ability"):FindFirstChildOfClass("ModuleScript")
		if abilityModule then
			print("ability already exists, cannot replicate")
		else
			E.Parent = game.ReplicatedStorage:WaitForChild(playerName):FindFirstChild("AbilitiesFolder"):FindFirstChild("E_Ability")
			refreshAbilities:Fire()
		end
	end
	
end

local function setupCharacterSelection()
	local CharacterFrame = script.Parent.CharacterFrame.Frame

	
	for _, child in pairs(CharacterFrame:GetChildren()) do
		if child:IsA("GuiObject") and child.Name ~= "ExitButton" then
			child:Destroy()
		end
	end


	local characterNames = {"Ice", "Lighting", "?"}
	local characterPrices = {0, 50, 999}

	for i, characterName in ipairs(characterNames) do
		local button = Instance.new("TextButton")
		button.Name = characterName
		button.Parent = CharacterFrame
		button.Size = UDim2.new(0.25, 0, 0.3, 0)
		button.Position = UDim2.new((i-1) * 0.3 + 0.1, 0, 0.4, 0)
		button.Text = characterName
		button.TextScaled = true
		button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
		button.TextColor3 = Color3.new(1, 1, 1)
		button.BorderSizePixel = 2
		button.BorderColor3 = Color3.new(0.5, 0.5, 0.5)

		characterButtons[characterName] = button

		button.MouseButton1Click:Connect(function()
			if selectedCharacter == characterName then
			
				selectedCharacter = nil
				button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
				button.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
			
			else
				
				if selectedCharacter then
					characterButtons[selectedCharacter].BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
					characterButtons[selectedCharacter].BorderColor3 = Color3.new(0.5, 0.5, 0.5)
				end

				
				selectedCharacter = characterName
				button.BackgroundColor3 = Color3.new(0, 0.5, 0)
				button.BorderColor3 = Color3.new(0, 1, 0)

				
				giveCharacterAbility(characterName)
			end
		end)
	end
end




setupCharacterSelection()
