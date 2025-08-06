-- src/client/PostureUI.luau
local PostureUI = {}
PostureUI.__index = PostureUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PostureSystem = require(game.ReplicatedStorage.Shared.UtilityModules.PostureSystem)

local player = Players.LocalPlayer

-- UI Constants
local BAR_WIDTH = 400
local BAR_HEIGHT = 12
local BAR_POSITION = UDim2.new(0.5, -BAR_WIDTH/2, 1, -68) -- Bottom bar (50 + 18 padding)
local BACKGROUND_COLOR = Color3.fromRGB(20, 20, 20)
local FILL_COLOR = Color3.fromRGB(255, 215, 0) -- Golden yellow like Sekiro
local BORDER_COLOR = Color3.fromRGB(100, 100, 100)
local FLASH_COLOR = Color3.fromRGB(255, 100, 100) -- Red flash for guard break

function PostureUI.new()
	local self = setmetatable({}, PostureUI)

	self.gui = nil
	self.backgroundFrame = nil
	self.fillFrame = nil
	self.borderFrame = nil
	self.tooltipLabel = nil
	self.postureSystem = nil
	self.connections = {}

	-- Initialize immediately and on character respawn
	self:_initialize()

	-- Reconnect when character respawns
	player.CharacterAdded:Connect(function()
		task.wait(1) -- Wait a moment for character to fully load
		self:_initialize()
	end)

	return self
end

function PostureUI:_initialize()
	print("PostureUI: Initializing...")
	self:_createUI()
	self:_connectToPostureSystem()
	print("PostureUI: Initialization complete")
end

function PostureUI:_createUI()
	-- Clean up existing UI
	if self.gui then
		self.gui:Destroy()
	end

	-- Create ScreenGui
	self.gui = Instance.new("ScreenGui")
	self.gui.Name = "PostureUI"
	self.gui.ResetOnSpawn = false
	self.gui.Parent = player:WaitForChild("PlayerGui")

	-- Create main container frame
	local container = Instance.new("Frame")
	container.Name = "PostureContainer"
	container.Size = UDim2.new(0, BAR_WIDTH + 4, 0, BAR_HEIGHT + 4)
	container.Position = BAR_POSITION
	container.BackgroundTransparency = 1
	container.Parent = self.gui

	-- Create border frame
	self.borderFrame = Instance.new("Frame")
	self.borderFrame.Name = "Border"
	self.borderFrame.Size = UDim2.new(1, 0, 1, 0)
	self.borderFrame.Position = UDim2.new(0, 0, 0, 0)
	self.borderFrame.BackgroundColor3 = BORDER_COLOR
	self.borderFrame.BorderSizePixel = 0
	self.borderFrame.Parent = container

	-- Add border corner rounding
	local borderCorner = Instance.new("UICorner")
	borderCorner.CornerRadius = UDim.new(0, 2)
	borderCorner.Parent = self.borderFrame

	-- Create background frame
	self.backgroundFrame = Instance.new("Frame")
	self.backgroundFrame.Name = "Background"
	self.backgroundFrame.Size = UDim2.new(1, -2, 1, -2)
	self.backgroundFrame.Position = UDim2.new(0, 1, 0, 1)
	self.backgroundFrame.BackgroundColor3 = BACKGROUND_COLOR
	self.backgroundFrame.BorderSizePixel = 0
	self.backgroundFrame.Parent = self.borderFrame

	-- Add background corner rounding
	local backgroundCorner = Instance.new("UICorner")
	backgroundCorner.CornerRadius = UDim.new(0, 1)
	backgroundCorner.Parent = self.backgroundFrame

	-- Create fill frame
	self.fillFrame = Instance.new("Frame")
	self.fillFrame.Name = "Fill"
	self.fillFrame.Size = UDim2.new(0, 0, 1, 0)
	self.fillFrame.Position = UDim2.new(0, 0, 0, 0)
	self.fillFrame.BackgroundColor3 = FILL_COLOR
	self.fillFrame.BorderSizePixel = 0
	self.fillFrame.Parent = self.backgroundFrame

	-- Add fill corner rounding
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 1)
	fillCorner.Parent = self.fillFrame

	-- Create tooltip label (hidden by default)
	self.tooltipLabel = Instance.new("TextLabel")
	self.tooltipLabel.Name = "PostureTooltip"
	self.tooltipLabel.Size = UDim2.new(1, 0, 1, 0)
	self.tooltipLabel.Position = UDim2.new(0, 0, 0, 0)
	self.tooltipLabel.BackgroundTransparency = 1
	self.tooltipLabel.Text = ""
	self.tooltipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.tooltipLabel.TextScaled = true
	self.tooltipLabel.Font = Enum.Font.GothamBold
	self.tooltipLabel.Visible = false
	self.tooltipLabel.Parent = self.backgroundFrame

	-- Add hover detection
	self:_setupHoverDetection(container)

	print("PostureUI: UI Created successfully")
end

function PostureUI:_setupHoverDetection(container)
	-- Mouse enter event
	container.MouseEnter:Connect(function()
		if self.postureSystem then
			local currentPosture = math.floor(self.postureSystem:GetCurrentPosture())
			local maxPosture = math.floor(self.postureSystem:GetMaxPosture())
			local percentage = math.floor((currentPosture / maxPosture) * 100)
			self.tooltipLabel.Text = string.format("Posture: %d/%d (%d%%)", currentPosture, maxPosture, percentage)
			self.tooltipLabel.Visible = true
		end
	end)

	-- Mouse leave event
	container.MouseLeave:Connect(function()
		self.tooltipLabel.Visible = false
	end)
end

function PostureUI:_connectToPostureSystem()
	-- Get or create posture system instance
	self.postureSystem = PostureSystem.GetOrCreateInstance(player)
	print("PostureUI: Connected to posture system, current posture:", self.postureSystem:GetCurrentPosture())

	-- Disconnect existing connections
	for _, connection in pairs(self.connections) do
		connection:Disconnect()
	end
	self.connections = {}

	-- Connect to posture events
	table.insert(self.connections, self.postureSystem.postureChanged.Event:Connect(function(oldPosture, newPosture)
		print("PostureUI: Posture changed from", oldPosture, "to", newPosture)
		self:_updateUI(newPosture)
	end))

	table.insert(self.connections, self.postureSystem.guardBroken.Event:Connect(function()
		print("PostureUI: Guard broken!")
		self:_playGuardBreakAnimation()
	end))

	table.insert(self.connections, self.postureSystem.guardBreakRecovered.Event:Connect(function()
		print("PostureUI: Guard break recovered!")
		self:_playRecoveryAnimation()
	end))

	-- Initial update
	self:_updateUI(self.postureSystem:GetCurrentPosture())
end

function PostureUI:_updateUI(currentPosture)
	if not self.fillFrame then 
		print("PostureUI: _updateUI called but fillFrame is nil!")
		return 
	end

	print("PostureUI: Updating UI with posture:", currentPosture)

	local percentage = currentPosture / self.postureSystem:GetMaxPosture()

	-- Always keep UI visible - just update the fill
	-- Animate fill bar
	local targetSize = UDim2.new(percentage, 0, 1, 0)
	local tween = TweenService:Create(
		self.fillFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = targetSize}
	)
	tween:Play()

	-- Change color based on posture level
	local fillColor = FILL_COLOR
	if percentage > 0.8 then
		-- Near guard break - more red
		fillColor = Color3.fromRGB(255, 165, 0) -- Orange-red
	elseif percentage > 0.6 then
		-- High posture - darker yellow
		fillColor = Color3.fromRGB(255, 200, 0)
	end

	local colorTween = TweenService:Create(
		self.fillFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundColor3 = fillColor}
	)
	colorTween:Play()
end

function PostureUI:_playGuardBreakAnimation()
	if not self.fillFrame or not self.borderFrame then return end

	-- Flash animation
	local flashTween = TweenService:Create(
		self.fillFrame,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
		{BackgroundColor3 = FLASH_COLOR}
	)
	flashTween:Play()

	-- Border flash
	local borderFlash = TweenService:Create(
		self.borderFrame,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
		{BackgroundColor3 = FLASH_COLOR}
	)
	borderFlash:Play()

	-- Shake animation
	local originalPosition = self.gui.PostureContainer.Position
	for i = 1, 5 do
		local shakeOffset = UDim2.new(0, math.random(-5, 5), 0, math.random(-2, 2))
		local shakeTween = TweenService:Create(
			self.gui.PostureContainer,
			TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = originalPosition + shakeOffset}
		)
		shakeTween:Play()

		shakeTween.Completed:Connect(function()
			if i == 5 then
				-- Return to original position
				local returnTween = TweenService:Create(
					self.gui.PostureContainer,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{Position = originalPosition}
				)
				returnTween:Play()
			end
		end)

		task.wait(0.05)
	end
end

function PostureUI:_playRecoveryAnimation()
	if not self.fillFrame then return end

	-- Gentle glow animation
	local glowTween = TweenService:Create(
		self.fillFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{BackgroundColor3 = Color3.fromRGB(100, 255, 100)} -- Green recovery
	)
	glowTween:Play()

	glowTween.Completed:Connect(function()
		-- Return to normal color
		local normalTween = TweenService:Create(
			self.fillFrame,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{BackgroundColor3 = FILL_COLOR}
		)
		normalTween:Play()
	end)
end

function PostureUI:Destroy()
	-- Disconnect all connections
	for _, connection in pairs(self.connections) do
		connection:Disconnect()
	end
	self.connections = {}

	-- Destroy GUI
	if self.gui then
		self.gui:Destroy()
	end
end

return PostureUI
