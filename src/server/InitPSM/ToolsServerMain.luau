local RS = game:GetService("ReplicatedStorage")
local ModuleServices = require(RS.Module.ServicesModule)
local ToolInfoModule = require(RS.Module.ToolsInfo)

local ToolsServerMain = {}
local DebounceCooldown = {}

local HITBOX_SIZE = Vector3.new(5, 5, 5)
local OFFSET_Z = -4 

function ToolsServerMain.VerifiedPlayers(playerQueSocou, damage, soundDestin, SoundHit, SoundSwoosh, SoundDied)
    local character = playerQueSocou.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp or not soundDestin then return end

    local hitboxCFrame = hrp.CFrame * CFrame.new(0, 0, OFFSET_Z)

    local possibleTargets = {}
    for _, p in ipairs(ModuleServices.Players:GetPlayers()) do
        if p ~= playerQueSocou and p.Character then
            table.insert(possibleTargets, p.Character)
        end
    end

    if SoundSwoosh then
        local cloneSwoosh = SoundSwoosh:Clone()
        cloneSwoosh.Parent = soundDestin
        cloneSwoosh:Play()
        ModuleServices.Debris:AddItem(cloneSwoosh, cloneSwoosh.TimeLength + 0.1)
    end

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = possibleTargets

    local results = workspace:GetPartBoundsInBox(hitboxCFrame, HITBOX_SIZE, params)
    local enemiesHit = {}

    for _, part in ipairs(results) do
        local enemyCharacter = part:FindFirstAncestorOfClass("Model")
        local humanoid = enemyCharacter and enemyCharacter:FindFirstChildOfClass("Humanoid")

        if humanoid and humanoid.Health > 0 and not table.find(enemiesHit, enemyCharacter) then
            table.insert(enemiesHit, enemyCharacter)

            if SoundHit then
                local cloneHit = SoundHit:Clone()
                cloneHit.Parent = enemyCharacter:FindFirstChild("HumanoidRootPart") or soundDestin
                cloneHit:Play()
                ModuleServices.Debris:AddItem(cloneHit, cloneHit.TimeLength + 0.1)
            end

            humanoid:TakeDamage(damage)

            humanoid.Died:Connect(function()
                if SoundDied then
                    local cloneSoundDied = SoundDied:Clone()
                    cloneSoundDied.Parent = enemyCharacter:FindFirstChild("HumanoidRootPart") or soundDestin
                    cloneSoundDied:Play()
                    ModuleServices.Debris:AddItem(cloneSoundDied, cloneSoundDied.TimeLength + 0.1)
                end
            end)

            print("Dano de " .. damage .. " em: " .. enemyCharacter.Name)
        end
    end
end

RS.Events.SignalPunch.OnServerEvent:Connect(function(player, toolName, comboStep)
    local ChosenToolData = ToolInfoModule.Data[toolName]
    if not ChosenToolData then return end

    if DebounceCooldown[player] then return end

    local attackInfo = ChosenToolData.Combo[comboStep]
    
    if attackInfo and player.Character then
        DebounceCooldown[player] = true
        
        local soundRoot = player.Character:FindFirstChild("HumanoidRootPart")
        
        ToolsServerMain.VerifiedPlayers(
            player, 
            attackInfo.Damage, 
            soundRoot, 
            ChosenToolData.SoundHit, 
            ChosenToolData.SoundSwoosh,
            ChosenToolData.SoundDied
        )

        task.wait(attackInfo.Cooldown)
        DebounceCooldown[player] = nil
    else
        warn("Ataque não definido ou personagem ausente para: " .. toolName)
    end
end)

return ToolsServerMain