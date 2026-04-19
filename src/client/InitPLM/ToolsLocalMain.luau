local ToolsLocalMain = {}

local RS = game:GetService("ReplicatedStorage")
local ModuleServices = require(RS.Module.ServicesModule)
local ToolInfoModule = require(RS.Module.ToolsInfo)
local player = ModuleServices.Players.LocalPlayer

local connection = {}
local Cooldown = false

local comboStep = 0
local lastAttackTime = 0

--[[

here we check what goes inside the player, if what enters has the tag 'Tool',
we apply the function for the tool to actually behave like one

]]--
player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(Child)
        if Child:HasTag("Tool") then 
            ToolsLocalMain.LocalTool(Child)
        end
    end)
end)


--[[

here we have the function in which we detect if the tool was activated 
by the player, if it was unequipped, equipped... Here we play the 
animation and send the signal to the server. ...

]]--
function ToolsLocalMain.LocalTool(tool)
    if connection[tool] then return end
    connection[tool] = true

    local ChosenToolData = ToolInfoModule.Data[tool.Name]
    
    if not ChosenToolData then 
        warn("A ferramenta " .. tool.Name .. " não tem dados no ToolInfoModule!")
        return 
    end

    local humanoid = player.Character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    local loadedTracks = {}
    
    for i, attackData in ipairs(ChosenToolData.Combo) do
        if attackData.Animation then
            loadedTracks[i] = animator:LoadAnimation(attackData.Animation)
        end
    end

    tool.Activated:Connect(function()
        if Cooldown then return end
        
        local currentTime = tick()
        local timeSinceLastAttack = currentTime - lastAttackTime
        
        if comboStep < 1 then comboStep = 1 end

        local currentAttack = ChosenToolData.Combo[comboStep]
        
        local previousAttack = ChosenToolData.Combo[comboStep - 1] or ChosenToolData.Combo[#ChosenToolData.Combo]
        local maxWait = previousAttack.ResetTime or 1

        if timeSinceLastAttack > maxWait then
            comboStep = 1
            currentAttack = ChosenToolData.Combo[comboStep]
        end

        local track = loadedTracks[comboStep]

        if not track then 
            warn("Erro: Animação não encontrada para o combo " .. comboStep)
            return 
        end

        Cooldown = true
        lastAttackTime = currentTime
        
        RS.Events.SignalPunch:FireServer(tool.Name, comboStep)

        track:Play()
        track.Priority = Enum.AnimationPriority.Action
        
        print("Atacou com " .. tool.Name .. " | Passo do Combo: " .. comboStep)

        if comboStep >= #ChosenToolData.Combo then
            comboStep = 1 
        else
            comboStep = comboStep + 1
        end

        task.wait(currentAttack.Cooldown)
        Cooldown = false
    end)

    tool.Unequipped:Connect(function()
        comboStep = 1
    end)

    tool.Destroying:Connect(function()
        connection[tool] = nil
    end)
end

return ToolsLocalMain