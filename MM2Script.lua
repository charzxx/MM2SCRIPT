--// Brookhaven M2 Script by Charz 😎
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

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

-- Create Main Tab
local Tab = Window:CreateTab("Main", 4483362458)

-- Button: Grab Gun
Tab:CreateButton({
    Name = "Grab Gun",
    Callback = function()
        local gunDrop = Workspace:FindFirstChild("GunDrop")
        if gunDrop and gunDrop:IsA("BasePart") then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = gunDrop.CFrame + Vector3.new(0, 3, 0)
                Rayfield:Notify({
                    Title = "Success",
                    Content = "You grabbed the Gun!",
                    Duration = 3
                })
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "HumanoidRootPart not found!",
                    Duration = 3
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No GunDrop found in workspace!",
                Duration = 3
            })
        end
    end
})

-- Button: Bring Player (example for “Example123”)
Tab:CreateTextBox({
    Name = "Bring Player",
    PlaceholderText = "Enter player name",
    TextDisappear = true,
    Callback = function(playerName)
        local target = Players:FindFirstChild(playerName)
        if target and target.Character then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                target.Character:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0, 0, 3))
                Rayfield:Notify({
                    Title = "Success",
                    Content = playerName .. " has been brought to you!",
                    Duration = 3
                })
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Your HumanoidRootPart not found!",
                    Duration = 3
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Player not found or has no character!",
                Duration = 3
            })
        end
    end
})
