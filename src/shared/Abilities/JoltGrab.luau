local JoltGrab = {}
JoltGrab.__index = JoltGrab
JoltGrab.windup = 0.5
JoltGrab.windup2 = 0.15
JoltGrab.CD = 1
JoltGrab.Damage = 15
JoltGrab.PostureDamage = 50
JoltGrab.Parryable = true 
JoltGrab.Blockable = true 
JoltGrab.CanBeDodged = true 
JoltGrab.CanBeCancelled = true
JoltGrab.Hitbox = game.ReplicatedStorage.Shared.Hitboxes.Weapons.MediumWeapons.TestWeaponHitbox
JoltGrab.SFX = game.ReplicatedStorage.Shared.SFX.Abilities.Lighting["Thunder sound 2"]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CombatStateModule = require(game.ReplicatedStorage.Shared.UtilityModules.StateModule)
local AbilityRemote = game.ReplicatedStorage.Shared.Remotes.AbilityRemote
local SFXRemote = game.ReplicatedStorage.Shared.Remotes.utilityRemotes.SFXRemote
local RANGE = 50
local WINDUP_TIME = 0.55
local TELEPORT_DISTANCE = 2
local WINDUP_WALKSPEED = 9
local ORIGINAL_WALKSPEED = 16
local Anim = game.ReplicatedStorage.Shared.Animations.Abilities.Lighting.JoltGrabAnim
local animator:Animator = Players.LocalPlayer.Character.Humanoid.Animator
local cd = false
local anim1 = animator:LoadAnimation(Anim)
local stats = {
	windup = JoltGrab.windup,
	cooldown = JoltGrab.CD,
	damage = JoltGrab.Damage,
	postureDamage = JoltGrab.PostureDamage,
	hitbox = JoltGrab.Hitbox,
	Parryable = JoltGrab.Parryable,
	Blockable = JoltGrab.Blockable,
	CanBeDodged = JoltGrab.CanBeDodged,
	CanBeCancelled = JoltGrab.CanBeCancelled,
	SFX = JoltGrab.SFX
}

function JoltGrab.new()
	local self = setmetatable({}, JoltGrab)

	self.windup = WINDUP_TIME
	self.CD = 7
	self.Damage = 12.75
	self.PostureDamage = 60
	self.Parryable = true
	self.Blockable = true
	self.CanBeDodged = true
	self.CanBeCancelled = true
	self.Character = Players.LocalPlayer.Character
	self.Hitbox = game.ReplicatedStorage.Shared.Hitboxes.Weapons.MediumWeapons.TestWeaponHitbox

	self.cooldownActive = false
	self.isWindingUp = false

	--self.stats = {
	--	Character = self.Character,
	--	windup = self.windup,
	--	cooldown = self.CD,
	--	damage = self.Damage,
	--	postureDamage = self.PostureDamage,
	--	hitbox = self.Hitbox,
	--	Parryable = self.Parryable,
	--	Blockable = self.Blockable,
	--	CanBeDodged = self.CanBeDodged,
	--	CanBeCancelled = self.CanBeCancelled
	--}

	return self
end

function JoltGrab:FindClosestPlayer()
	local player = Players.LocalPlayer
	local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil end

	local closestPlayer = nil
	local closestDistance = RANGE

	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			local otherRootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			if otherRootPart then
				local distance = (rootPart.Position - otherRootPart.Position).Magnitude
				if distance < closestDistance then
					closestPlayer = otherPlayer
					closestDistance = distance
				end
			end
		end
	end

	return closestPlayer
end

function JoltGrab:TeleportToTarget(target)
	if not target or not target.Character then return end

	local player = Players.LocalPlayer
	local targetRootPart = target.Character:FindFirstChild("HumanoidRootPart")
	local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not targetRootPart or not rootPart then return end

	local targetPosition = targetRootPart.Position
	local targetLookVector = targetRootPart.CFrame.LookVector
	local teleportPosition = targetPosition + (targetLookVector * TELEPORT_DISTANCE)

	rootPart.CFrame = CFrame.new(teleportPosition, targetPosition)
end

function JoltGrab:PlayWindupAnimation()
	-- Animation hook - implement your animation here
	print("Playing JoltGrab windup animation")
	local Anim = game.ReplicatedStorage.Shared.Animations.Abilities.Lighting.JoltGrabAnim
	local animator:Animator = Players.LocalPlayer.Character.Humanoid.Animator
	local anim1 = animator:LoadAnimation(Anim)
	anim1:Play()
	
end

function JoltGrab:PlayTeleportEffect()
	-- Visual/Audio effect hook - implement your effects here
	print("Playing teleport effects")
	
end

function JoltGrab:CanActivate()
	if CombatStateModule:Stunned() or CombatStateModule:DoingAction() or cd then
		return false
		
	else
		return true
	end
end

function JoltGrab:Activate()
	if not self:CanActivate() then return end
	SFXRemote:FireServer(stats)
	local player = Players.LocalPlayer
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
	if not humanoid then return end

	self.cooldownActive = true
	self.isWindingUp = true
	cd = true
	task.delay(7, function()
		cd = false
	end)

	local originalWalkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = WINDUP_WALKSPEED

	self:PlayWindupAnimation()

	local target = self:FindClosestPlayer()

	task.delay(0.55, function()

		local currentPlayer = Players.LocalPlayer
		local currentHumanoid = currentPlayer.Character and currentPlayer.Character:FindFirstChild("Humanoid")
		if currentHumanoid then
			currentHumanoid.WalkSpeed = originalWalkSpeed
		end

		self.isWindingUp = false

		if target and target.Character then
			self:TeleportToTarget(target)
			self:PlayTeleportEffect()

			task.delay(0.15, function()
				AbilityRemote:FireServer(stats)
			end)
		end
	end)
end

function JoltGrab:Cancel()
	if not self.isWindingUp then return end

	self.isWindingUp = false
	local player = Players.LocalPlayer
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = ORIGINAL_WALKSPEED
	end
end

return JoltGrab
