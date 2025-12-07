local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local HUNTER_COLOR = Color3.fromRGB(255, 80, 80)
local HIDER_COLOR  = Color3.fromRGB(80, 255, 80)
local chamsOn = false
local pathOn = false
local localPlayer = Players.LocalPlayer

local supportedGames = {
    [13924946576] = "Dingus"
}

local currentGameId = game.PlaceId
local isSupported = supportedGames[currentGameId] ~= nil
local gameName = supportedGames[currentGameId] or "Unknown Game"

local function isHunter(char)
    return char:FindFirstChild("Revolver", true) ~= nil
end

local function removeChams(char)
    for _, v in char:GetDescendants() do
        if v:IsA("BasePart") and v:FindFirstChild("NX") then 
            v.NX:Destroy() 
        end
    end
end

local function applyChams(char)
    removeChams(char)
    if not chamsOn then return end
    local col = isHunter(char) and HUNTER_COLOR or HIDER_COLOR
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

local function refresh()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then 
            if chamsOn then
                applyChams(p.Character)
            else
                removeChams(p.Character)
            end
        end
    end
end

if isSupported then
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(applyChams)
        if p.Character then applyChams(p.Character) end
    end)

    task.spawn(function()
        while task.wait(5) do
            if chamsOn then
                refresh()
            end
        end
    end)
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
    if model.Name == localPlayer.Name then return false end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if model.Name == player.Name then return false end
    end
    
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    if isHunter(model) then return false end
    
    return true
end

local function findNearbyNPCs(root)
    local npcs = {}
    
    for _, model in ipairs(workspace:GetChildren()) do
        if isNPC(model) then
            local npcRoot = model:FindFirstChild("HumanoidRootPart")
            if npcRoot then
                local dist = (npcRoot.Position - root.Position).Magnitude
                if dist < 50 and dist > 5 then
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
    local direction = (targetPos - root.Position).Unit
    local flatDir = Vector3.new(direction.X, 0, direction.Z).Unit
    
    releaseAllKeys()
    
    if math.abs(flatDir.X) > 0.4 then
        if flatDir.X > 0 then
            pressKey(Enum.KeyCode.D)
        else
            pressKey(Enum.KeyCode.A)
        end
    end
    
    if math.abs(flatDir.Z) > 0.4 then
        if flatDir.Z > 0 then
            pressKey(Enum.KeyCode.S)
        else
            pressKey(Enum.KeyCode.W)
        end
    end
end

if isSupported then
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
        
        if math.random(1, 900) == 1 then
            isStopped = true
            stopDuration = 0
            return
        end
        
        local shouldRunAway = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local theirRoot = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
                if theirRoot then
                    local dist = (theirRoot.Position - root.Position).Magnitude
                    if dist < 20 then
                        local awayDir = (root.Position - theirRoot.Position).Unit
                        local escapePoint = root.Position + (awayDir * 15)
                        moveTowardsPoint(root, escapePoint)
                        shouldRunAway = true
                        followingNPC = nil
                        switchNPCTimer = 0
                        break
                    end
                end
            end
        end
        
        if shouldRunAway then return end
        
        if not followingNPC or switchNPCTimer >= math.random(10, 20) then
            local nearbyNPCs = findNearbyNPCs(root)
            if #nearbyNPCs > 0 then
                followingNPC = nearbyNPCs[math.random(1, math.min(3, #nearbyNPCs))]
                switchNPCTimer = 0
            else
                followingNPC = nil
            end
        end
        
        if followingNPC and followingNPC.root and followingNPC.root.Parent then
            local dist = (followingNPC.root.Position - root.Position).Magnitude
            
            if dist < 8 then
                releaseAllKeys()
            elseif dist > 30 then
                followingNPC = nil
            else
                moveTowardsPoint(root, followingNPC.root.Position)
            end
        else
            followingNPC = nil
            releaseAllKeys()
        end
    end)
end

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
    Content = "Game ID: 13924946576 - Full support with Chams and Path Finder"
})

if isSupported then
    local MainTab = Window:CreateTab("Main", 4483362458)
    
    local ChamsSection = MainTab:CreateSection("Visual")
    
    MainTab:CreateToggle({
        Name = "Chams",
        CurrentValue = false,
        Flag = "ChamsToggle",
        Callback = function(Value)
            chamsOn = Value
            refresh()
        end
    })
    
    MainTab:CreateParagraph({
        Title = "About Chams",
        Content = "Highlights all players through walls. Hunters glow RED, Hiders glow GREEN. Auto-refreshes every 5 seconds."
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
        Content = "Detects and mimics real AI NPCs! Finds nearby NPCs, follows them naturally (staying 8-30 studs away), switches NPCs every 10-20 seconds, and runs from nearby players. Perfect blending!"
    })
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