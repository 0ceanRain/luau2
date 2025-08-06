-- src/shared/Modules/PostureSystem.luau
local PostureSystem = {}
PostureSystem.__index = PostureSystem

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local MAX_POSTURE = 100
local DECAY_RATE = 0.25 -- posture per second
local GUARD_BREAK_DURATION = 0.8
local PARRY_POSTURE_REDUCTION = 10

-- Static properties
PostureSystem._instances = {}
PostureSystem._connections = {}

function PostureSystem.new(player)
	local self = setmetatable({}, PostureSystem)

	self.player = player
	self.character = player.Character
	self.currentPosture = 0
	self.maxPosture = MAX_POSTURE
	self.isGuardBroken = false
	self.lastDamageTime = 0

	-- Events
	self.postureChanged = Instance.new("BindableEvent")
	self.guardBroken = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.guardBroken
	self.guardBreakRecovered = Instance.new("BindableEvent")

	-- Store instance
	PostureSystem._instances[player] = self

	-- Set up character attribute if it doesn't exist
	if self.character and not self.character:GetAttribute("CurrentPosture") then
		self.character:SetAttribute("CurrentPosture", 0)
	end

	-- Start decay loop
	self:_startDecayLoop()

	return self
end

function PostureSystem:GetCurrentPosture()
	return self.currentPosture
end

function PostureSystem:GetMaxPosture()
	return self.maxPosture
end

function PostureSystem:GetPosturePercentage()
	return self.currentPosture / self.maxPosture
end

function PostureSystem:IsGuardBroken()
	return self.isGuardBroken
end

function PostureSystem:AddPosture(amount)
	if self.isGuardBroken then return end
	if not self.character or not self.character:GetAttribute("Blocking") then return end

	self.lastDamageTime = tick()
	local oldPosture = self.currentPosture
	self.currentPosture = math.min(self.currentPosture + amount, self.maxPosture)

	-- Update character attribute
	if self.character then
		self.character:SetAttribute("CurrentPosture", self.currentPosture)
	end

	-- Fire posture changed event
	self.postureChanged:Fire(oldPosture, self.currentPosture)

	-- Check for guard break
	if self.currentPosture >= self.maxPosture and not self.isGuardBroken then
		self:_triggerGuardBreak()
	end

	print(self.player.Name .. " posture: " .. self.currentPosture .. "/" .. self.maxPosture)
end

function PostureSystem:ReducePosture(amount)
	local oldPosture = self.currentPosture
	self.currentPosture = math.max(self.currentPosture - amount, 0)

	-- Update character attribute
	if self.character then
		self.character:SetAttribute("CurrentPosture", self.currentPosture)
	end

	-- Fire posture changed event
	self.postureChanged:Fire(oldPosture, self.currentPosture)
end

function PostureSystem:ResetPosture()
	local oldPosture = self.currentPosture
	self.currentPosture = 0

	-- Update character attribute
	if self.character then
		self.character:SetAttribute("CurrentPosture", 0)
	end

	-- Fire posture changed event
	self.postureChanged:Fire(oldPosture, self.currentPosture)
end

function PostureSystem:OnSuccessfulParry()
	self:ReducePosture(PARRY_POSTURE_REDUCTION)
end

function PostureSystem:_triggerGuardBreak()
	if self.isGuardBroken then return end

	self.isGuardBroken = true

	-- Set stunned attribute
	if self.character then
		self.character:SetAttribute("Stunned", true)
	end

	-- Fire guard break event
	self.guardBroken:Fire()

	-- Reset posture
	self:ResetPosture()

	print(self.player.Name .. " has been guard broken!")

	-- Recover from guard break after duration
	task.delay(GUARD_BREAK_DURATION, function()
		self:_recoverFromGuardBreak()
	end)
end

function PostureSystem:_recoverFromGuardBreak()
	if not self.isGuardBroken then return end

	self.isGuardBroken = false

	-- Remove stunned attribute
	if self.character then
		self.character:SetAttribute("Stunned", false)
	end

	-- Fire recovery event
	self.guardBreakRecovered:Fire()

	print(self.player.Name .. " recovered from guard break")
end

function PostureSystem:_startDecayLoop()
	if PostureSystem._connections[self.player] then
		PostureSystem._connections[self.player]:Disconnect()
	end

	PostureSystem._connections[self.player] = RunService.Heartbeat:Connect(function(dt)
		-- Only decay if not guard broken and some time has passed since last damage
		if not self.isGuardBroken and self.currentPosture > 0 and (tick() - self.lastDamageTime) > 2 then
			local decayAmount = DECAY_RATE * dt
			local oldPosture = self.currentPosture
			self.currentPosture = math.max(self.currentPosture - decayAmount, 0)

			-- Update character attribute
			if self.character then
				self.character:SetAttribute("CurrentPosture", self.currentPosture)
			end

			-- Fire posture changed event if there was a meaningful change
			if math.abs(oldPosture - self.currentPosture) > 0.1 then
				self.postureChanged:Fire(oldPosture, self.currentPosture)
			end
		end
	end)
end

function PostureSystem:Destroy()
	-- Disconnect events
	if self.postureChanged then
		self.postureChanged:Destroy()
	end
	if self.guardBroken then
		self.guardBroken:Destroy()
	end
	if self.guardBreakRecovered then
		self.guardBreakRecovered:Destroy()
	end

	-- Disconnect decay loop
	if PostureSystem._connections[self.player] then
		PostureSystem._connections[self.player]:Disconnect()
		PostureSystem._connections[self.player] = nil
	end

	-- Remove from instances
	PostureSystem._instances[self.player] = nil
end

-- Static methods
function PostureSystem.GetInstance(player)
	return PostureSystem._instances[player]
end

function PostureSystem.GetOrCreateInstance(player)
	local instance = PostureSystem._instances[player]
	if not instance then
		instance = PostureSystem.new(player)
	end
	return instance
end

function PostureSystem.CleanupPlayer(player)
	local instance = PostureSystem._instances[player]
	if instance then
		instance:Destroy()
	end
end

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	PostureSystem.CleanupPlayer(player)
end)

-- Handle character respawning
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local instance = PostureSystem._instances[player]
		if instance then
			instance.character = character
			instance:ResetPosture()
			character:SetAttribute("CurrentPosture", 0)
		end
	end)
end)

return PostureSystem 
