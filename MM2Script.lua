local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Charz Admin Panel",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Charz Hub",
})

local MainTab = Window:CreateTab("Main", 4483362458)

-- remove old ESPs
local function clearESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local h = plr.Character:FindFirstChild("CharzHighlight")
            if h then h:Destroy() end
        end
    end
end

-- add highlight w/ color
local function setESP(plr, color)
    if plr == LocalPlayer then return end
    if not plr.Character then return end

    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- remove old one if exists
    local old = plr.Character:FindFirstChild("CharzHighlight")
    if old then old:Destroy() end

    local h = Instance.new("Highlight")
    h.Name = "CharzHighlight"
    h.FillTransparency = 0.4
    h.FillColor = color
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.Parent = plr.Character
end

-- find tool in backpack/character
local function hasTool(plr, toolName)
    if plr.Backpack and plr.Backpack:FindFirstChild(toolName) then return true end
    if plr.Character and plr.Character:FindFirstChild(toolName) then return true end
    return false
end

-- ESP button
MainTab:CreateButton({
    Name = "ESP Murderer (Red) / Sheriff (Blue)",
    Callback = function()
        clearESP()

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if hasTool(plr, "Gun") then
                    setESP(plr, Color3.fromRGB(0, 0, 255)) -- BLUE sheriff
                elseif hasTool(plr, "Knife") then
                    setESP(plr, Color3.fromRGB(255, 0, 0)) -- RED murderer
                end
            end
        end
    end
})

-- GRAB GUN (Teleport to GunDrop)
MainTab:CreateButton({
    Name = "Grab Gun",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- find GunDrop anywhere
        local gun = workspace:FindFirstChild("GunDrop", true)

        if gun then
            root.CFrame = gun.CFrame + Vector3.new(0, 3, 0)
        else
            warn("GunDrop not found")
        end
    end
})
