local RS = game:GetService("ReplicatedStorage")

local ToolsInfo = {}

ToolsInfo.Data = {
    ["Default"] = {
        SoundHit = RS:WaitForChild("Sounds"):WaitForChild("Default"):WaitForChild("Punch"),
        SoundSwoosh = RS:WaitForChild("Sounds"):WaitForChild("Default"):WaitForChild("Swoosh"),
        SoundDied = RS:WaitForChild("Sounds"):WaitForChild("Default"):WaitForChild("Died"),
		Combo = {
        [1] = {
			Damage = 10,
			Cooldown = 0.4,
			Animation = RS:WaitForChild("Animations"):WaitForChild("Default"):WaitForChild("Punch1"),
			ResetTime = 1.2 
		},
		[2] = {
			Damage = 10,
			Cooldown = 0.4,
			Animation = RS:WaitForChild("Animations"):WaitForChild("Default"):WaitForChild("Punch2"),
			ResetTime = 1.2
		},
		[3] = {
			Damage = 20,
			Cooldown = 0.8,
			Animation = RS:WaitForChild("Animations"):WaitForChild("Default"):WaitForChild("Punch3"),
			ResetTime = 1.5
		},
		[4] = {
			Damage = 35,
			Cooldown = 1.5,
			Animation = RS:WaitForChild("Animations"):WaitForChild("Default"):WaitForChild("HeavyPunch"),
			ResetTime = 1
		}
        },
	}
}

return ToolsInfo