local ability = {}
ability.windup = 0.5
ability.CD = 7
ability.Damage = 15
ability.PostureDamage = 50
local CombatStateModule = require(game.ReplicatedStorage.Shared.Modules.StateModule)
local AbilityRemote = game.ReplicatedStorage.Shared.Remotes.AbilityRemote
local cd = false
local debris = game:GetService("Debris")
function Dash()
	local character = game.Players.LocalPlayer.Character
	local RunService = game:GetService("RunService")
	local camera = workspace.CurrentCamera
	local DashDuration = 0.3
	local DashSpeed = 100
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
			-- Clean up
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
	
end

function slash2()
	
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
	local stats = {
		windup = self.windup,
		cooldown = self.CD,
		damage = self.Damage,
		postureDamage = self.PostureDamage,
	}
    task.delay(ability.windup, function()
		print("Used")
		AbilityRemote:FireServer(stats)
    end)
end


return ability
