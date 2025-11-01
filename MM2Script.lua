local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Charz Admin Panel",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Charz Hub",
})

local MainTab = Window:CreateTab("Main", 4483362458)

-- // ESP Function
local function highlightPlayer(plr)
    if plr == LocalPlayer then return end

    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        if not plr.Character:FindFirstChild("CharzHighlight") then
            local h = Instance.new("Highlight")
            h.Name = "CharzHighlight"
            h.FillTransparency = 0.5
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.Parent = plr.Character
        end
    end
end

local function removeHighlights()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local h = plr.Character:FindFirstChild("CharzHighlight")
            if h then h:Destroy() end
        end
    end
end

-- // Button: ESP Murder / Sheriff (tools named "Knife" or "Gun")
MainTab:CreateButton({
    Name = "ESP Knife / Gun Players",
    Callback = function()
        removeHighlights()

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Backpack:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Gun") then
                highlightPlayer(plr)
            elseif plr.Character then
                if plr.Character:FindFirstChild("Knife") or plr.Character:FindFirstChild("Gun") then
                    highlightPlayer(plr)
                end
            end
        end
    end
})

-- // Button: Grab GunDrop (teleport to it)
MainTab:CreateButton({
    Name = "Grab Gun",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local gun = workspace:FindFirstChild("GunDrop", true) -- search whole workspace

        if gun then
            root.CFrame = gun.CFrame + Vector3.new(0, 3, 0) -- TP slightly above it
        else
            warn("No GunDrop found")
        end
    end
})
