--[[
    Combat & Defense System (Client-Side)
    Developed for Open Source use.
    
    Features:
    - Input handling for blocking and attacking
    - Animation priority management
    - Automatic cleanup of defense tracks on Guard Break
]]

local ToolsLocalMain = {}

-- Services
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local ModuleServices = require(RS.Module.ServicesModule)
local ToolInfoModule = require(RS.Module.ToolsInfo)

-- Variables
local player = ModuleServices.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local isCooldown = false
local isDefending = false
local isGuardBroken = false
local currentToolData = nil
local blockTrack = nil -- Stores the active defense animation

local comboStep = 0
local lastAttackTime = 0
local toolConnections = {}

--[[ 
    CRITICAL: Guard Break Listener
    Force-stops the blocking animation when the server breaks the player's guard.
]]
RS.Events.DefenseEvent.OnClientEvent:Connect(function()
    isDefending = false
    isGuardBroken = true
    
    -- Force stop the defense animation immediately
    if blockTrack then
        blockTrack:Stop(0.1)
        blockTrack = nil
    end

    print("Defense broken by server!")
    task.wait(5) -- Stun duration
    isGuardBroken = false
end)

--[[ 
    Input handling for Blocking (F Key)
]]
UIS.InputBegan:Connect(function(input, processed)

    if processed or isGuardBroken or not currentToolData then return end

    if input.KeyCode == Enum.KeyCode.F then
        if isDefending then return end
        
        isDefending = true
        
        -- Load and play blocking animation
        blockTrack = animator:LoadAnimation(currentToolData.DefendingAnimation)
        blockTrack.Priority = Enum.AnimationPriority.Action
        blockTrack.Looped = true
        blockTrack:Play()

        RS.Events.DefenseEvent:FireServer(true)
    end
end)

UIS.InputEnded:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.F and isDefending then
        isDefending = false
        if blockTrack then
            blockTrack:Stop()
            blockTrack = nil
        end
        RS.Events.DefenseEvent:FireServer(false)
    end
end)

--[[ 
    Core tool logic: Attacks, Idles, and Setup.
]]
function ToolsLocalMain.LocalTool(tool)
    if toolConnections[tool] then return end
    toolConnections[tool] = true

    local toolData = ToolInfoModule.Data[tool.Name]
    if not toolData then return end

    -- Pre-load combo animations
    local loadedTracks = {}
    for i, attackData in ipairs(toolData.Combo) do
        if attackData.Animation then
            loadedTracks[i] = animator:LoadAnimation(attackData.Animation)
        end
    end

    -- Attack Activation
    tool.Activated:Connect(function()
        if isCooldown or isDefending or isGuardBroken then return end
        
        local currentTime = tick()
        local timeSinceLastAttack = currentTime - lastAttackTime
        
        -- Combo reset logic
        local prevIndex = (comboStep == 0) and #toolData.Combo or comboStep
        local resetTime = toolData.Combo[prevIndex].ResetTime or 1

        if timeSinceLastAttack > resetTime then
            comboStep = 1
        else
            comboStep = (comboStep % #toolData.Combo) + 1
        end

        local currentAttack = toolData.Combo[comboStep]
        local track = loadedTracks[comboStep]

        if track then
            isCooldown = true
            lastAttackTime = currentTime
            
            RS.Events.SignalPunch:FireServer(tool.Name, comboStep)
            track.Priority = Enum.AnimationPriority.Action2
            track:Play()

            task.wait(currentAttack.Cooldown)
            isCooldown = false
        end
    end)

    local idleTrack = nil

    tool.Equipped:Connect(function()
        currentToolData = toolData
        if toolData.AnimationIdle then
            idleTrack = animator:LoadAnimation(toolData.AnimationIdle)
            idleTrack:Play()
        end
    end)

    tool.Unequipped:Connect(function()
        currentToolData = nil
        isDefending = false
        if idleTrack then idleTrack:Stop() end
        if blockTrack then blockTrack:Stop() end
        RS.Events.DefenseEvent:FireServer(false)
        comboStep = 0
    end)
end

local function Setup(newChar)
    newChar.ChildAdded:Connect(function(child)
        if child:HasTag("Tool") then 
            ToolsLocalMain.LocalTool(child)
        end
    end)
end

-- Update character references on respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    animator = humanoid:WaitForChild("Animator")

    -- Initialize for tools tagged as "Tool"
    Setup(character)
end)

Setup(character)

return ToolsLocalMain