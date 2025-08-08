
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local guardBreakRequestRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.guardBreakRequest
local guardBreakConfirmRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.guardBreakConfirm
local guardBreakVisualRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.guardBreakVisual


local GUARD_BREAK_DURATION = 0.8
local MAX_POSTURE = 100
local GUARD_BREAK_COOLDOWN = 0.5


local playerPostureData = {}
local guardBreakCooldowns = {}
local activeGuardBreaks = {}

local adminCommands = {
	forceGuardBreak = function(adminPlayer, targetPlayerName)
		local targetPlayer = Players:FindFirstChild(targetPlayerName)
		if targetPlayer and targetPlayer.Character then
			executeGuardBreak(targetPlayer, adminPlayer, MAX_POSTURE, "admin_force")
			return true
		end
		return false
	end,

	cancelGuardBreak = function(adminPlayer, targetPlayerName)
		local targetPlayer = Players:FindFirstChild(targetPlayerName)
		if targetPlayer and activeGuardBreaks[targetPlayer] then
			cancelGuardBreak(targetPlayer, "admin_cancel")
			return true
		end
		return false
	end,

	setGuardBreakDuration = function(adminPlayer, targetPlayerName, duration)
		local targetPlayer = Players:FindFirstChild(targetPlayerName)
		if targetPlayer and activeGuardBreaks[targetPlayer] then
			activeGuardBreaks[targetPlayer].customDuration = duration
			return true
		end
		return false
	end
}


local function initializePlayerData(player)
	playerPostureData[player] = {
		currentPosture = 0,
		lastUpdateTime = tick(),
		lastAttacker = nil
	}
	guardBreakCooldowns[player] = 0
end

local function validateGuardBreakRequest(player, attackerPlayer, reportedPosture)
	local currentTime = tick()


	if guardBreakCooldowns[player] and guardBreakCooldowns[player] > currentTime then
		return false, "Guard break on cooldown"
	end

	-- Check if player exists and has character
	if not player.Character or not player.Character:FindFirstChild("Humanoid") then
		return false, "Invalid player character"
	end

	-- Check if already guard broken
	if activeGuardBreaks[player] then
		return false, "Player already guard broken"
	end

	-- Validate posture value (basic range check)
	if not reportedPosture or reportedPosture < MAX_POSTURE * 0.9 then
		return false, "Insufficient posture for guard break"
	end

	-- Validate attacker exists if provided
	if attackerPlayer and (not attackerPlayer.Character or not Players:FindFirstChild(attackerPlayer.Name)) then
		return false, "Invalid attacker"
	end

	-- Update server tracking
	if not playerPostureData[player] then
		initializePlayerData(player)
	end

	playerPostureData[player].currentPosture = reportedPosture
	playerPostureData[player].lastAttacker = attackerPlayer
	playerPostureData[player].lastUpdateTime = currentTime

	return true, "Valid guard break request"
end

-- Execute guard break
function executeGuardBreak(player, attackerPlayer, posture, reason)
	if not player.Character then return end
	local character = player.Character
	local hum:Humanoid = character:FindFirstChild("Humanoid")
	local currentTime = tick()
	reason = reason or "posture_full"

	-- Set guard break data
	activeGuardBreaks[player] = {
		startTime = currentTime,
		duration = GUARD_BREAK_DURATION,
		attacker = attackerPlayer,
		reason = reason,
		customDuration = nil
	}

	-- Set server-side stunned attribute
	player.Character:SetAttribute("Stunned", true)
	player.Character:SetAttribute("GuardBroken", true)
	hum.WalkSpeed = 6

	-- Set cooldown
	guardBreakCooldowns[player] = currentTime + GUARD_BREAK_COOLDOWN

	-- Reset posture tracking
	if playerPostureData[player] then
		playerPostureData[player].currentPosture = 0
	end

	-- Send confirmation to the guard broken player
	guardBreakConfirmRemote:FireClient(player, {
		duration = GUARD_BREAK_DURATION,
		attacker = attackerPlayer and attackerPlayer.Name or "Unknown",
		reason = reason,
		timestamp = currentTime
	})

	-- Send visual effects to all clients
	guardBreakVisualRemote:FireAllClients({
		targetPlayer = player.Name,
		attacker = attackerPlayer and attackerPlayer.Name or "Unknown",
		position = player.Character.HumanoidRootPart.Position,
		reason = reason
	})

	print(string.format("Guard break executed: %s (by %s) - Reason: %s", 
		player.Name, 
		attackerPlayer and attackerPlayer.Name or "Unknown", 
		reason
		))

	-- Schedule recovery
	task.delay(GUARD_BREAK_DURATION, function()
		recoverFromGuardBreak(player)
	end)
end

-- Recover from guard break
function recoverFromGuardBreak(player)
	if not activeGuardBreaks[player] then return end
	local character = player.Character
	local hum:Humanoid = character:FindFirstChild("Humanoid")
	local guardBreakData = activeGuardBreaks[player]
	local actualDuration = guardBreakData.customDuration or guardBreakData.duration

	-- Check if custom duration was set
	if guardBreakData.customDuration then
		local elapsed = tick() - guardBreakData.startTime
		if elapsed < guardBreakData.customDuration then
			-- Reschedule with remaining time
			task.delay(guardBreakData.customDuration - elapsed, function()
				recoverFromGuardBreak(player)
			end)
			return
		end
	end

	-- Remove guard break
	activeGuardBreaks[player] = nil

	-- Remove server-side attributes
	if player.Character then
		player.Character:SetAttribute("Stunned", false)
		player.Character:SetAttribute("GuardBroken", false)
		hum.WalkSpeed = 16
	end

	-- Notify client of recovery
	guardBreakConfirmRemote:FireClient(player, {
		recovered = true,
		timestamp = tick()
	})

	print(string.format("Guard break recovery: %s", player.Name))
end

-- Cancel guard break (for admin use)
function cancelGuardBreak(player, reason)
	if not activeGuardBreaks[player] then return false end

	-- Remove guard break immediately
	activeGuardBreaks[player] = nil

	-- Remove server-side attributes
	if player.Character then
		player.Character:SetAttribute("Stunned", false)
		player.Character:SetAttribute("GuardBroken", false)
	end

	-- Notify client
	guardBreakConfirmRemote:FireClient(player, {
		cancelled = true,
		reason = reason or "admin_cancel",
		timestamp = tick()
	})

	print(string.format("Guard break cancelled: %s - Reason: %s", player.Name, reason or "Unknown"))
	return true
end

-- Handle guard break requests from clients
guardBreakRequestRemote.OnServerEvent:Connect(function(player, data)
	if not data then return end

	local attackerPlayer = data.attacker and Players:FindFirstChild(data.attacker)
	local reportedPosture = data.posture

	-- Validate request
	local isValid, reason = validateGuardBreakRequest(player, attackerPlayer, reportedPosture)

	if isValid then
		executeGuardBreak(player, attackerPlayer, reportedPosture, "client_request")
	else
		print(string.format("Guard break request denied for %s: %s", player.Name, reason))

		-- Optional: Send denial to client
		guardBreakConfirmRemote:FireClient(player, {
			denied = true,
			reason = reason,
			timestamp = tick()
		})
	end
end)

-- Handle player cleanup
Players.PlayerRemoving:Connect(function(player)
	playerPostureData[player] = nil
	guardBreakCooldowns[player] = nil
	activeGuardBreaks[player] = nil
end)

-- Initialize existing players
for _, player in pairs(Players:GetPlayers()) do
	initializePlayerData(player)
end

-- Initialize new players
Players.PlayerAdded:Connect(function(player)
	initializePlayerData(player)

	player.CharacterAdded:Connect(function(character)
		-- Reset guard break state on respawn
		activeGuardBreaks[player] = nil
		if playerPostureData[player] then
			playerPostureData[player].currentPosture = 0
		end

		-- Ensure attributes are set
		character:SetAttribute("Stunned", false)
		character:SetAttribute("GuardBroken", false)
	end)
end)

-- Heartbeat check for guard breaks (cleanup and validation)
RunService.Heartbeat:Connect(function()
	local currentTime = tick()

	for player, guardBreakData in pairs(activeGuardBreaks) do
		if not player.Parent or not player.Character then
			-- Player left or character destroyed
			activeGuardBreaks[player] = nil
		else
			-- Ensure stunned attribute is maintained
			if not player.Character:GetAttribute("Stunned") then
				player.Character:SetAttribute("Stunned", true)
				player.Character:SetAttribute("GuardBroken", true)
			end
		end
	end
end)

-- Export admin functions for other scripts
_G.GuardBreakAdmin = adminCommands

return {
	executeGuardBreak = executeGuardBreak,
	cancelGuardBreak = cancelGuardBreak,
	recoverFromGuardBreak = recoverFromGuardBreak,
	getActiveGuardBreaks = function() return activeGuardBreaks end,
	getPlayerPostureData = function() return playerPostureData end
}
