local RS = game:GetService("ReplicatedStorage")
local ModuleServices = require(RS.Module.ServicesModule)
local ToolInfoModule = require(RS.Module.ToolsInfo)

local ToolsServerMain = {}

-- Data structures to manage player states
local DebounceCooldown = {}
local GuardBrokenPlayers = {} -- Tracks players who had their defense broken
local HitCounters = {} -- Tracks how many hits a blocking player has taken

-- Configuration Constants
local HITBOX_SIZE = Vector3.new(5, 5, 5)
local OFFSET_Z = -4 
local MAX_HIT_COUNT = 5 -- Hits required to break guard
local GUARD_BREAK_DURATION = 5 -- Seconds player stays stunned
local BLOCK_DAMAGE_REDUCTION = 0.2 -- Player takes 20% damage while blocking

--[[
    Handles the Defense/Blocking state for players.
    Listens to the DefenseEvent to toggle the "IsDefending" attribute.
]]--
RS.Events.DefenseEvent.OnServerEvent:Connect(function(player, isDefendingRequest)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    -- Prevent defending if the player is currently guard-broken
    if GuardBrokenPlayers[player.Name] then 
        character:SetAttribute("IsDefending", false)
        RS.Events.DefenseEvent:FireClient(player,false)
        return 
    end

    character:SetAttribute("IsDefending", isDefendingRequest)
    
    -- Reset hit counter when they stop defending
    if not isDefendingRequest then
        HitCounters[player.Name] = 0
    end
end)

--[[
    Main function to verify hits, calculate damage, and handle defense logic.
]]--
function ToolsServerMain.VerifiedPlayers(playerWhoPunched, damage, soundDestin, SoundHit, SoundSwoosh, SoundDied)
    local character = playerWhoPunched.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp or not soundDestin then return end

    -- Define the hitbox position in front of the player
    local hitboxCFrame = hrp.CFrame * CFrame.new(0, 0, OFFSET_Z)

    -- Filter potential targets (other players)
    local possibleTargets = {}
    for _, p in ipairs(ModuleServices.Players:GetPlayers()) do
        if p ~= playerWhoPunched and p.Character then
            table.insert(possibleTargets, p.Character)
        end
    end

    -- Play "Whoosh" sound on attack
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
        local enemyHumanoid = enemyCharacter and enemyCharacter:FindFirstChildOfClass("Humanoid")

        -- Ensure we only hit the enemy once per attack and they are alive
        if enemyHumanoid and enemyHumanoid.Health > 0 and not table.find(enemiesHit, enemyCharacter) then
            table.insert(enemiesHit, enemyCharacter)

            local isBlocking = enemyCharacter:GetAttribute("IsDefending")
            local finalDamage = damage

            -- Logic if the enemy is blocking
            if isBlocking then
                local currentHits = (HitCounters[enemyCharacter.Name] or 0) + 1
                HitCounters[enemyCharacter.Name] = currentHits

                if currentHits < MAX_HIT_COUNT then
                    -- Reduced damage while blocking
                    finalDamage = damage * BLOCK_DAMAGE_REDUCTION
                else
                    -- Guard Break logic
                    finalDamage = damage -- Take full damage on break
                    HitCounters[enemyCharacter.Name] = 0
                    enemyCharacter:SetAttribute("IsDefending", false)
                    
                    -- Apply Stun/Guard Break state
                    GuardBrokenPlayers[enemyCharacter.Name] = true
                    task.delay(GUARD_BREAK_DURATION, function()
                        GuardBrokenPlayers[enemyCharacter.Name] = nil
                    end)
                end
            end

            -- Apply the calculated damage
            enemyHumanoid:TakeDamage(finalDamage)

            -- Play hit impact sound
            if SoundHit then
                local cloneHit = SoundHit:Clone()
                cloneHit.Parent = enemyCharacter:FindFirstChild("HumanoidRootPart") or soundDestin
                cloneHit:Play()
                ModuleServices.Debris:AddItem(cloneHit, cloneHit.TimeLength + 0.1)
            end

            -- Handle death sound without creating leaking connections
            if enemyHumanoid.Health <= 0 and SoundDied then
                local cloneDied = SoundDied:Clone()
                cloneDied.Parent = enemyCharacter:FindFirstChild("HumanoidRootPart") or soundDestin
                cloneDied:Play()
                ModuleServices.Debris:AddItem(cloneDied, cloneDied.TimeLength + 0.1)
            end
        end
    end
end

--[[
    Handles the attack signal sent from the client.
]]--
RS.Events.SignalPunch.OnServerEvent:Connect(function(player, toolName, comboStep)
    local ChosenToolData = ToolInfoModule.Data[toolName]
    if not ChosenToolData then return end

    -- Rate limiting (Anti-spam)
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
        warn("Invalid attack or missing character: " .. tostring(toolName))
    end
end)

return ToolsServerMain