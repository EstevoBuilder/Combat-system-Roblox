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
		AnimationIdle = RS:WaitForChild("Animations"):WaitForChild("Default"):WaitForChild("Idle"), --Idle Animation
		DefendingAnimation = RS:WaitForChild("Animations"):WaitForChild("Defending"), --Defending Animation
		Combo = {
        [1] = {
			Damage = 10, --Damage
			Cooldown = 0.4, --cooldown every attack
			Animation = RS:WaitForChild("Animations"):WaitForChild("Default"):WaitForChild("Punch1"), --Base animation 1
			ResetTime = 1.2 --it's the time that will reset to go back to 1 again from the table
		},
		[2] = {
			Damage = 15,
			Cooldown = 0.4,
			Animation = RS:WaitForChild("Animations"):WaitForChild("Default"):WaitForChild("Punch2"),
			ResetTime = 1.2
		},
		[3] = {
			Damage = 20,
			Cooldown = 0.4,
			Animation = RS:WaitForChild("Animations"):WaitForChild("Default"):WaitForChild("Punch3"),
			ResetTime = 1.5
		},
		[4] = {
			Damage = 25,
			Cooldown = 0.3,
			Animation = RS:WaitForChild("Animations"):WaitForChild("Default"):WaitForChild("HeavyPunch"),
			ResetTime = 1.5
		}
        },
	}
}

return ToolsInfo