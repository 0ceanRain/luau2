local ability = {}
ability.windup = 0.5
ability.windup2 = 0.15
ability.CD = 1
ability.Damage = 15
ability.PostureDamage = 50
ability.Parryable = true -- IGNORE
ability.Blockable = true -- IGNORE
ability.CanBeDodged = true -- IGNORE
ability.CanBeCancelled = true

ability.Hitbox = game.ReplicatedStorage.Shared.Hitboxes.Abilities.TestAbilities.TestHitbox -- IGNORE
local CombatStateModule = require(game.ReplicatedStorage.Shared.UtilityModules.StateModule)
local AbilityRemote = game.ReplicatedStorage.Shared.Remotes.AbilityRemote
local cd = false
local debris = game:GetService("Debris")
local stats = {
	windup = ability.windup,
	cooldown = ability.CD,
	damage = ability.Damage,
	postureDamage = ability.PostureDamage,
	hitbox = ability.Hitbox,
	Parryable = ability.Parryable,
	Blockable = ability.Blockable,
	CanBeDodged = ability.CanBeDodged,
	CanBeCancelled = ability.CanBeCancelled
}
function Dash()
	local character = game.Players.LocalPlayer.Character
	local RunService = game:GetService("RunService")
	local camera = workspace.CurrentCamera
	local DashDuration = 0.3
	local DashSpeed = 65
	local hrp = character.HumanoidRootPart

	
	local linearVel = Instance.new("LinearVelocity")
	linearVel.MaxForce = 100000
	linearVel.VectorVelocity = Vector3.new(0, 0, 0)
	linearVel.RelativeTo = Enum.ActuatorRelativeTo.World

	
	local attachment = Instance.new("Attachment")
	attachment.Parent = hrp
	linearVel.Attachment0 = attachment
	linearVel.Parent = hrp

	local elapsed = 0
	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		elapsed = elapsed + dt
		if elapsed >= DashDuration then
			conn:Disconnect()
			linearVel:Destroy()
			attachment:Destroy()
			return
		end

		local look = camera.CFrame.LookVector
		local dir = Vector3.new(look.X, 0, look.Z)
		if dir.Magnitude > 0 then
			linearVel.VectorVelocity = dir.Unit * DashSpeed
		end
	end)
end

function slash()
	
	--  anims play here then slash
	task.delay(0.1, function()
		AbilityRemote:FireServer(stats)
	end)
end

function slash2()
	-- anim play here, then 0,1 slash
	task.delay(0.1, function()
		AbilityRemote:FireServer(stats)
	end)
end

function ability:CanActivate()
    if CombatStateModule:Stunned() or CombatStateModule:DoingAction() or cd then
        return false
    else
        return true
    end
end

function ability:Activate()
	cd = true
	task.delay(ability.CD, function()
		cd = false
	end)
	Dash()
	
    task.delay(ability.windup, function()
		print("Used")
		slash()
		task.delay(ability.windup2, function()
			slash2()
		end)
    end)
end


return ability