local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local localPlayer = Players.LocalPlayer

local supportedGames = {
    [13924946576] = "Dingus",
    [18687417158] = "Forsaken"
}

local currentGameId = game.PlaceId
local isSupported = supportedGames[currentGameId] ~= nil
local gameName = supportedGames[currentGameId] or "Unknown Game"

local chamsOn = false
local pathOn = false
local forceHunter = false

--========================================
--DINGUS GAME FUNCTIONS
--========================================

local HUNTER_COLOR = Color3.fromRGB(255, 80, 80)
local HIDER_COLOR  = Color3.fromRGB(80, 255, 80)

local function isHunterDingus(char)
    return char:FindFirstChild("Revolver", true) ~= nil
end

local function removeChamsDingus(char)
    for _, v in char:GetDescendants() do
        if v:IsA("BasePart") and v:FindFirstChild("NX") then 
            v.NX:Destroy() 
        end
    end
end

local function applyChamsDingus(char)
    removeChamsDingus(char)
    if not chamsOn then return end
    local col = isHunterDingus(char) and HUNTER_COLOR or HIDER_COLOR
    for _, part in char:GetDescendants() do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local h = Instance.new("Highlight")
            h.Name = "NX"
            h.FillColor = col
            h.FillTransparency = 0.35
            h.OutlineTransparency = 1
            h.Parent = part
        end
    end
end

local function refreshDingus()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then 
            if chamsOn then
                applyChamsDingus(p.Character)
            else
                removeChamsDingus(p.Character)
            end
        end
    end
end

local currentKeys = {}
local stopDuration = 0
local isStopped = false
local followingNPC = nil
local switchNPCTimer = 0

local function pressKey(key)
    if currentKeys[key] then return end
    currentKeys[key] = true
    VirtualInputManager:SendKeyEvent(true, key, false, game)
end

local function releaseKey(key)
    if not currentKeys[key] then return end
    currentKeys[key] = nil
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function releaseAllKeys()
    for key, _ in pairs(currentKeys) do
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end
    currentKeys = {}
end

local function isNPC(model)
    if not model or not model:IsA("Model") then return false end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then return false end
    end
    
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    if isHunterDingus(model) then return false end
    
    return true
end

local function findNearbyNPCs(root)
    local npcs = {}
    
    for _, model in ipairs(workspace:GetDescendants()) do
        if isNPC(model) then
            local npcRoot = model:FindFirstChild("HumanoidRootPart")
            if npcRoot then
                local dist = (npcRoot.Position - root.Position).Magnitude
                if dist < 60 and dist > 5 then
                    table.insert(npcs, {
                        model = model,
                        root = npcRoot,
                        distance = dist
                    })
                end
            end
        end
    end
    
    table.sort(npcs, function(a, b) return a.distance < b.distance end)
    
    return npcs
end

local function moveTowardsPoint(root, targetPos)
    local direction = (targetPos - root.Position)
    local distance = direction.Magnitude
    
    if distance < 3 then
        releaseAllKeys()
        return
    end
    
    local flatDir = Vector3.new(direction.X, 0, direction.Z).Unit
    
    releaseAllKeys()
    
    if math.abs(flatDir.X) > math.abs(flatDir.Z) then
        if flatDir.X > 0 then
            pressKey(Enum.KeyCode.D)
        else
            pressKey(Enum.KeyCode.A)
        end
    else
        if flatDir.Z > 0 then
            pressKey(Enum.KeyCode.S)
        else
            pressKey(Enum.KeyCode.W)
        end
    end
end

--========================================
--FORSAKEN GAME FUNCTIONS
--========================================

local PLAYER_COLOR = Color3.fromRGB(80, 255, 80)
local KILLER_COLOR = Color3.fromRGB(255, 80, 80)
local ITEM_COLOR = Color3.fromRGB(80, 255, 255)
local GENERATOR_COLOR = Color3.fromRGB(255, 165, 0)

local trackedObjects = {}

local function removeChamsForsaken(obj)
    for _, v in obj:GetDescendants() do
        if v:IsA("BasePart") and v:FindFirstChild("NX_Highlight") then 
            v.NX_Highlight:Destroy() 
        end
    end
    
    if obj:FindFirstChild("NX_BillboardGui") then
        obj.NX_BillboardGui:Destroy()
    end
end

local function createBillboard(obj, text, color)
    if obj:FindFirstChild("NX_BillboardGui") then
        obj.NX_BillboardGui:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NX_BillboardGui"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = obj
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    
    return billboard
end

local function applyChamsForsaken(obj, color, text)
    removeChamsForsaken(obj)
    if not chamsOn then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "NX_Highlight"
    highlight.Parent = obj
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = color
    highlight.FillTransparency = 0.35
    highlight.OutlineTransparency = 1
    
    if text then
        local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if primaryPart then
            createBillboard(primaryPart, text, color)
        end
    end
end

local function findItems()
    local items = {}
    
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return items end
    
    local ingameFolder = mapFolder:FindFirstChild("Ingame")
    if not ingameFolder then return items end
    
    for _, obj in ingameFolder:GetChildren() do
        if obj:IsA("Tool") then
            local name = obj.Name
            if name == "Medkit" then
                table.insert(items, {obj = obj, name = "Medkit"})
            elseif name == "BloxyCola" or name:find("Cola") then
                table.insert(items, {obj = obj, name = "Bloxy Cola"})
            end
        end
    end
    
    return items
end

local function findGenerators()
    local generators = {}
    
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return generators end
    
    local ingameFolder = mapFolder:FindFirstChild("Ingame")
    if not ingameFolder then return generators end
    
    local mapSubFolder = ingameFolder:FindFirstChild("Map")
    if not mapSubFolder then return generators end
    
    for _, obj in mapSubFolder:GetChildren() do
        if obj:IsA("Model") and obj.Name == "Generator" then
            table.insert(generators, obj)
        end
    end
    
    return generators
end

local function getGeneratorProgress(gen)
    local progressValue = gen:FindFirstChild("Completed") or gen:FindFirstChild("Progress") or gen:FindFirstChild("Percentage")
    
    if progressValue then
        if progressValue:IsA("BoolValue") then
            return progressValue.Value and "100%" or "0%"
        elseif progressValue:IsA("NumberValue") or progressValue:IsA("IntValue") then
            return math.floor(progressValue.Value) .. "%"
        end
    end
    
    for _, child in gen:GetDescendants() do
        if child:IsA("NumberValue") or child:IsA("IntValue") then
            local childName = child.Name:lower()
            if childName:find("progress") or childName:find("percent") or childName:find("complete") then
                return math.floor(child.Value) .. "%"
            end
        elseif child:IsA("BoolValue") then
            local childName = child.Name:lower()
            if childName:find("complete") or childName:find("done") or childName:find("finish") then
                return child.Value and "100%" or "0%"
            end
        end
    end
    
    return "0%"
end

local function findPlayers()
    local players = {}
    
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return players end
    
    local survivors = playersFolder:FindFirstChild("Survivors")
    if survivors then
        for _, survivor in survivors:GetChildren() do
            if survivor:IsA("Model") then
                table.insert(players, {char = survivor, isKiller = false})
            end
        end
    end
    
    local killers = playersFolder:FindFirstChild("Killers")
    if killers then
        for _, killer in killers:GetChildren() do
            if killer:IsA("Model") then
                table.insert(players, {char = killer, isKiller = true})
            end
        end
    end
    
    return players
end

local function refreshForsaken()
    if not chamsOn then
        for obj, _ in pairs(trackedObjects) do
            if obj and obj.Parent then
                removeChamsForsaken(obj)
            end
        end
        trackedObjects = {}
        return
    end
    
    for _, playerData in findPlayers() do
        if playerData.char and playerData.char.Parent then
            local color = playerData.isKiller and KILLER_COLOR or PLAYER_COLOR
            applyChamsForsaken(playerData.char, color, nil)
            trackedObjects[playerData.char] = true
        end
    end
    
    for _, item in findItems() do
        if item.obj and item.obj.Parent then
            applyChamsForsaken(item.obj, ITEM_COLOR, item.name)
            trackedObjects[item.obj] = true
        end
    end
    
    for _, gen in findGenerators() do
        if gen and gen.Parent then
            local progress = getGeneratorProgress(gen)
            applyChamsForsaken(gen, GENERATOR_COLOR, progress)
            trackedObjects[gen] = true
        end
    end
end

--========================================
--GAME INITIALIZATION
--========================================

if currentGameId == 13924946576 then
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(applyChamsDingus)
        if p.Character then applyChamsDingus(p.Character) end
    end)

    task.spawn(function()
        while task.wait(5) do
            if chamsOn then
                refreshDingus()
            end
        end
    end)
    
    task.spawn(function()
        while task.wait(0.1) do
            if forceHunter and localPlayer.Character then
                if not isHunterDingus(localPlayer.Character) then
                    local revolver = game:GetService("ReplicatedStorage"):FindFirstChild("Revolver")
                    if revolver then
                        local clonedRevolver = revolver:Clone()
                        clonedRevolver.Parent = localPlayer.Character
                    end
                    
                    for _, v in pairs(localPlayer.Character:GetChildren()) do
                        if v:IsA("Shirt") then
                            v.ShirtTemplate = "rbxassetid://0"
                        end
                    end
                    
                    local roundStatus = game:GetService("ReplicatedStorage"):FindFirstChild("RoundStatus")
                    if roundStatus then
                        game:GetService("ReplicatedStorage").RE:FireServer("SetRole", "Hunter")
                    end
                end
            end
        end
    end)
    
    RunService.RenderStepped:Connect(function(dt)
        if not pathOn then 
            releaseAllKeys()
            return 
        end
        
        if not localPlayer.Character then return end
        
        local root = localPlayer.Character:FindFirstChild("HumanoidRootPart") or localPlayer.Character.PrimaryPart
        if not root then return end
        
        switchNPCTimer = switchNPCTimer + dt
        
        if isStopped then
            releaseAllKeys()
            stopDuration = stopDuration + dt
            if stopDuration >= math.random(1, 2) then
                isStopped = false
                stopDuration = 0
                followingNPC = nil
            end
            return
        end
        
        if math.random(1, 1200) == 1 then
            isStopped = true
            stopDuration = 0
            return
        end
        
        local shouldRunAway = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local theirRoot = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
                if theirRoot and isHunterDingus(player.Character) then
                    local dist = (theirRoot.Position - root.Position).Magnitude
                    if dist < 20 then
                        local awayDir = (root.Position - theirRoot.Position).Unit
                        local escapePoint = root.Position + (awayDir * 15)
                        moveTowardsPoint(root, escapePoint)
                        shouldRunAway = true
                        followingNPC = nil
                        switchNPCTimer = 999
                        break
                    end
                end
            end
        end
        
        if shouldRunAway then return end
        
        if not followingNPC or not followingNPC.root or not followingNPC.root.Parent or switchNPCTimer >= math.random(15, 30) then
            local nearbyNPCs = findNearbyNPCs(root)
            if #nearbyNPCs > 0 then
                followingNPC = nearbyNPCs[1]
                switchNPCTimer = 0
            else
                followingNPC = nil
                releaseAllKeys()
            end
        end
        
        if followingNPC and followingNPC.root and followingNPC.root.Parent then
            local dist = (followingNPC.root.Position - root.Position).Magnitude
            
            if dist > 70 then
                followingNPC = nil
            else
                local npcLookVector = followingNPC.root.CFrame.LookVector
                local trailPos = followingNPC.root.Position - (npcLookVector * 10)
                
                moveTowardsPoint(root, trailPos)
            end
        else
            releaseAllKeys()
        end
    end)
elseif currentGameId == 18687417158 then
    task.spawn(function()
        while task.wait(2) do
            if chamsOn then
                refreshForsaken()
            end
        end
    end)
    
    local mapFolder = Workspace:WaitForChild("Map", 10)
    if mapFolder then
        local ingameFolder = mapFolder:WaitForChild("Ingame", 10)
        if ingameFolder then
            ingameFolder.ChildAdded:Connect(function(obj)
                if not chamsOn then return end
                task.wait(0.1)
                
                if obj:IsA("Tool") then
                    local name = obj.Name
                    if name == "Medkit" then
                        applyChamsForsaken(obj, ITEM_COLOR, "Medkit")
                        trackedObjects[obj] = true
                    elseif name == "BloxyCola" or name:find("Cola") then
                        applyChamsForsaken(obj, ITEM_COLOR, "Bloxy Cola")
                        trackedObjects[obj] = true
                    end
                end
            end)
            
            local mapSubFolder = ingameFolder:FindFirstChild("Map")
            if mapSubFolder then
                mapSubFolder.ChildAdded:Connect(function(obj)
                    if not chamsOn then return end
                    task.wait(0.1)
                    
                    if obj:IsA("Model") and obj.Name == "Generator" then
                        local progress = getGeneratorProgress(obj)
                        applyChamsForsaken(obj, GENERATOR_COLOR, progress)
                        trackedObjects[obj] = true
                    end
                end)
            end
        end
    end
    
    local playersFolder = Workspace:FindFirstChild("Players")
    if playersFolder then
        local survivors = playersFolder:FindFirstChild("Survivors")
        if survivors then
            survivors.ChildAdded:Connect(function(char)
                if not chamsOn then return end
                task.wait(0.1)
                applyChamsForsaken(char, PLAYER_COLOR, nil)
                trackedObjects[char] = true
            end)
        end
        
        local killers = playersFolder:FindFirstChild("Killers")
        if killers then
            killers.ChildAdded:Connect(function(char)
                if not chamsOn then return end
                task.wait(0.1)
                applyChamsForsaken(char, KILLER_COLOR, nil)
                trackedObjects[char] = true
            end)
        end
    end
end

--========================================
--UI CREATION
--========================================

local Window = Rayfield:CreateWindow({
    Name = "3NX Hub",
    LoadingTitle = "3NX Hub",
    LoadingSubtitle = "Multi-Game Hub",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local InfoTab = Window:CreateTab("Info", 4483362458)

InfoTab:CreateParagraph({
    Title = "Game Detection",
    Content = isSupported and "✅ Game Supported: " .. gameName or "❌ Game Not Supported"
})

InfoTab:CreateParagraph({
    Title = "Game ID",
    Content = "Current Game ID: " .. tostring(currentGameId)
})

InfoTab:CreateSection("Supported Games")

InfoTab:CreateParagraph({
    Title = "Dingus",
    Content = "Game ID: 13924946576 - Full support with Chams, Path Finder, and Force Hunter"
})

InfoTab:CreateParagraph({
    Title = "Forsaken",
    Content = "Game ID: 18687417158 - Full support with Player/Killer/Item/Generator ESP"
})

--========================================
--DINGUS UI
--========================================

if currentGameId == 13924946576 then
    local MainTab = Window:CreateTab("Dingus", 4483362458)
    
    local ChamsSection = MainTab:CreateSection("Visual")
    
    MainTab:CreateToggle({
        Name = "Chams",
        CurrentValue = false,
        Flag = "ChamsToggle",
        Callback = function(Value)
            chamsOn = Value
            refreshDingus()
        end
    })
    
    MainTab:CreateParagraph({
        Title = "About Chams",
        Content = "Highlights all players through walls. Hunters glow RED, Hiders glow GREEN. Auto-refreshes every 5 seconds."
    })
    
    local GameplaySection = MainTab:CreateSection("Gameplay")
    
    MainTab:CreateToggle({
        Name = "Force Hunter",
        CurrentValue = false,
        Flag = "ForceHunterToggle",
        Callback = function(Value)
            forceHunter = Value
        end
    })
    
    MainTab:CreateParagraph({
        Title = "About Force Hunter",
        Content = "Automatically makes you a hunter at the start of each round. Enable before the round starts for best results."
    })
    
    local MovementSection = MainTab:CreateSection("Movement")
    
    MainTab:CreateToggle({
        Name = "Path Finder",
        CurrentValue = false,
        Flag = "PathToggle",
        Callback = function(Value)
            pathOn = Value
            if not Value then
                releaseAllKeys()
                stopDuration = 0
                isStopped = false
                followingNPC = nil
            end
        end
    })
    
    MainTab:CreateParagraph({
        Title = "About Path Finder",
        Content = "Trails behind real AI NPCs (stays 10 studs behind them)! Searches all descendants for NPCs, switches every 15-30 seconds, runs from hunters, rarely stops."
    })

--========================================
--FORSAKEN UI
--========================================

elseif currentGameId == 18687417158 then
    local MainTab = Window:CreateTab("Forsaken", 4483362458)
    
    local ESPSection = MainTab:CreateSection("Visual ESP")
    
    MainTab:CreateToggle({
        Name = "Enable ESP",
        CurrentValue = false,
        Flag = "ESPToggle",
        Callback = function(Value)
            chamsOn = Value
            refreshForsaken()
        end
    })
    
    MainTab:CreateParagraph({
        Title = "About ESP",
        Content = "Players: GREEN | Killer: RED | Items (Bloxy Cola/Medkit): CYAN with labels | Generators: ORANGE with completion percentage. Auto-detects new spawns!"
    })

--========================================
--UNSUPPORTED GAME UI
--========================================

else
    local UnsupportedTab = Window:CreateTab("Unsupported", 4483362458)
    
    UnsupportedTab:CreateParagraph({
        Title = "Game Not Supported",
        Content = "This game is currently not supported by 3NX Hub. Please join one of our supported games to use the hub features."
    })
    
    UnsupportedTab:CreateSection("Want to request a game?")
    
    UnsupportedTab:CreateParagraph({
        Title = "Game Requests",
        Content = "Contact the developer to request support for this game. Make sure to include the Game ID: " .. tostring(currentGameId)
    })
end