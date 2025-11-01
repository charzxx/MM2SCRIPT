--// Brookhaven M2 Script by Charz 😎
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Brookhaven M2 Script by Charz",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "By Charz 😎",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BrookhavenConfigs",
        FileName = "BrookhavenSettings"
    }
})

-- Main Tab
local Tab = Window:CreateTab("Main", 4483362458)

-- Variables
local ESPEnabled = false
local Connections = {}

-- Function to clear highlights
local function clearHighlight(character)
    if character and character:FindFirstChild("RoleHighlight") then
        character.RoleHighlight:Destroy()
    end
end

-- Function to highlight players with Gun/Knife
local function highlightPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local backpack = player:FindFirstChild("Backpack")
            local hasGun = false
            local hasKnife = false

            -- Check backpack
            if backpack then
                hasGun = backpack:FindFirstChild("Gun") ~= nil
                hasKnife = backpack:FindFirstChild("Knife") ~= nil
            end

            -- Check character
            if char then
                hasGun = hasGun or char:FindFirstChild("Gun") ~= nil
                hasKnife = hasKnife or char:FindFirstChild("Knife") ~= nil
            end

            -- Clear old highlight
            clearHighlight(char)

            -- Apply new highlight
            if char and (hasGun or hasKnife) then
                local highlight = Instance.new("Highlight")
                highlight.Name = "RoleHighlight"
                highlight.Parent = char
                highlight.Adornee = char
                highlight.FillTransparency = 0.6
                highlight.OutlineTransparency = 0.1
                highlight.FillColor = hasGun and Color3.fromRGB(0,0,255) or Color3.fromRGB(255,0,0)
            end
        end
    end
end

-- Toggle ESP Button
Tab:CreateToggle({
    Name = "ESP Sheriff & Murderer",
    CurrentValue = false,
    Callback = function(state)
        ESPEnabled = state
        if ESPEnabled then
            Connections.ESP = RunService.RenderStepped:Connect(function()
                highlightPlayers()
            end)
            Rayfield:Notify({
                Title = "ESP Enabled",
                Content = "Blue = Gun / Red = Knife",
                Duration = 3
            })
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    clearHighlight(player.Character)
                end
            end
            if Connections.ESP then Connections.ESP:Disconnect() end
            Rayfield:Notify({
                Title = "ESP Disabled",
                Content = "ESP turned off",
                Duration = 3
            })
        end
    end
})

-- Button: Grab Gun from GunDrop
Tab:CreateButton({
    Name = "Grab Gun",
    Callback = function()
        local gunDrop = Workspace:FindFirstChild("GunDrop")
        if gunDrop and gunDrop:IsA("BasePart") then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = gunDrop.CFrame + Vector3.new(0, 3, 0)
                Rayfield:Notify({Title="Success", Content="You grabbed the Gun!", Duration=3})
            end
        else
            Rayfield:Notify({Title="Error", Content="No GunDrop found!", Duration=3})
        end
    end
})

-- Button: Steal Gun
Tab:CreateButton({
    Name = "Steal Gun",
    Callback = function()
        local backpack = LocalPlayer:WaitForChild("Backpack",5)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local gun = (player.Backpack and player.Backpack:FindFirstChild("Gun")) or (player.Character and player.Character:FindFirstChild("Gun"))
                if gun then
                    gun.Parent = backpack
                    Rayfield:Notify({Title="Success", Content="Stole Gun from "..player.Name, Duration=3})
                end
            end
        end
    end
})

-- Button: Steal Knife
Tab:CreateButton({
    Name = "Steal Knife",
    Callback = function()
        local backpack = LocalPlayer:WaitForChild("Backpack",5)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local knife = (player.Backpack and player.Backpack:FindFirstChild("Knife")) or (player.Character and player.Character:FindFirstChild("Knife"))
                if knife then
                    knife.Parent = backpack
                    Rayfield:Notify({Title="Success", Content="Stole Knife from "..player.Name, Duration=3})
                end
            end
        end
    end
})

-- TextBox: Bring Player
Tab:CreateTextBox({
    Name = "Bring Player",
    PlaceholderText = "Enter player name",
    TextDisappear = true,
    Callback = function(playerName)
        local target = Players:FindFirstChild(playerName)
        if target and target.Character then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                target.Character:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0,0,3))
                Rayfield:Notify({Title="Success", Content=playerName.." brought to you!", Duration=3})
            end
        end
    end
})
