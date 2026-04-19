local RS = game:GetService("ReplicatedStorage")

local ToolsInfo = {}

--[[

This is where the information is according to the Tool that is loaded in the modules,
including the combo in numerical sequence.

]]--
ToolsInfo.Data = {
    ["Default"] = {
        SoundHit = RS:WaitForChild("Sounds"):WaitForChild("Default"):WaitForChild("Punch"), --Punch sound
        SoundSwoosh = RS:WaitForChild("Sounds"):WaitForChild("Default"):WaitForChild("Swoosh"), --Swoosh effect sound
        SoundDied = RS:WaitForChild("Sounds"):WaitForChild("Default"):WaitForChild("Died"), --Target 0 Health play this sound
		Combo = {
        [1] = {
			Damage = 10, --Damage
			Cooldown = 0.4, --cooldown every attack
			Animation = RS:WaitForChild("Animations"):WaitForChild("Default"):WaitForChild("Punch1"), --Base animation 1
			ResetTime = 1.2 --it's the time that will reset to go back to 1 again from the table
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