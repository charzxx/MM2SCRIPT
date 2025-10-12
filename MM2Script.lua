-- MM2 Script with ESP
---@diagnostic disable: undefined-global
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Safe Rayfield loader
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield", true))()
end)
if not success then
    warn("Failed to load Rayfield:", Rayfield)
    return
end

-- Create main window
local Window = Rayfield:CreateWindow({
    Name = "MM2 Script",
    LoadingTitle = "Loading MM2 Script...",
    LoadingSubtitle = "By Charz 😎",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MM2Configs",
        FileName = "MM2Settings"
    }
})

-- Create Main Tab
local Tab = Window:CreateTab("Main", 4483362458)

--// ====== ESP Section ====== 
local ESPEnabled = false
local function clearHighlight(character)
    if character and character:FindFirstChild("RoleHighlight") then
        character.RoleHighlight:Destroy()
    end
end

local function highlightPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local backpack = player:FindFirstChild("Backpack")
            local isSheriff, isMurderer = false, false

            -- Check backpack for Gun/Knife
            if backpack then
                isSheriff = backpack:FindFirstChild("Gun") ~= nil
                isMurderer = backpack:FindFirstChild("Knife") ~= nil
            end

            -- Check character for Gun/Knife
            if char then
                isSheriff = isSheriff or char:FindFirstChild("Gun") ~= nil
                isMurderer = isMurderer or char:FindFirstChild("Knife") ~= nil
            end

            -- Remove old highlights
            clearHighlight(char)

            -- Apply new highlight
            if char and (isSheriff or isMurderer) then
                local highlight = Instance.new("Highlight")
                highlight.Name = "RoleHighlight"
                highlight.Parent = char
                highlight.Adornee = char
                highlight.FillTransparency = 0.6
                highlight.OutlineTransparency = 0.1
                highlight.FillColor = isSheriff and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(255, 0, 0)
            end
        end
    end
end

-- ESP Toggle Button
Tab:CreateToggle({
    Name = "ESP Sheriff & Murderer",
    CurrentValue = false,
    Callback = function(state)
        ESPEnabled = state
        if ESPEnabled then
            Rayfield:Notify({
                Title = "ESP Enabled",
                Content = "Sheriff (Blue) and Murderer (Red) ESP is now active.",
                Duration = 3
            })
            -- Start ESP loop
            RunService.RenderStepped:Connect(function()
                if ESPEnabled then
                    highlightPlayers()
                end
            end)
        else
            -- Clear highlights
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    clearHighlight(player.Character)
                end
            end
            Rayfield:Notify({
                Title = "ESP Disabled",
                Content = "ESP has been turned off.",
                Duration = 3
            })
        end
    end
})

--// ====== Steal Gun from Sheriff Button ======
Tab:CreateButton({
    Name = "Steal Gun From SHERIFF",
    Callback = function()
        local sheriff = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            local tool = plr.Backpack:FindFirstChildOfClass("Tool")
            if tool and string.find(tool.Name, "Gun") then
                sheriff = plr
                break
            end
            if plr.Character then
                local charTool = plr.Character:FindFirstChildOfClass("Tool")
                if charTool and string.find(charTool.Name, "Gun") then
                    sheriff = plr
                    break
                end
            end
        end
        if sheriff then
            local gun = sheriff.Backpack:FindFirstChildOfClass("Tool") or sheriff.Character:FindFirstChildOfClass("Tool")
            if gun then
                gun.Parent = LocalPlayer.Backpack
                Rayfield:Notify({Title = "Success!", Content = "Stole gun from " .. sheriff.Name, Duration = 4})
            else
                Rayfield:Notify({Title = "Error", Content = "No gun found on sheriff!", Duration = 3})
            end
        else
            Rayfield:Notify({Title = "Error", Content = "No sheriff found with a gun!", Duration = 3})
        end
    end
})

--// ====== Steal Knife from Murderer Button ======
Tab:CreateButton({
    Name = "Steal Knife From Murderer",
    Callback = function()
        local murderer = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            local tool = plr.Backpack:FindFirstChildOfClass("Tool")
            if tool and string.find(tool.Name, "Knife") then
                murderer = plr
                break
            end
            if plr.Character then
                local charTool = plr.Character:FindFirstChildOfClass("Tool")
                if charTool and string.find(charTool.Name, "Knife") then
                    murderer = plr
                    break
                end
            end
        end
        if murderer then
            local knife = murderer.Backpack:FindFirstChildOfClass("Tool") or murderer.Character:FindFirstChildOfClass("Tool")
            if knife then
                knife.Parent = LocalPlayer.Backpack
                Rayfield:Notify({Title = "Success!", Content = "Stole knife from " .. murderer.Name, Duration = 4})
            else
                Rayfield:Notify({Title = "Error", Content = "No knife found on murderer!", Duration = 3})
            end
        else
            Rayfield:Notify({Title = "Error", Content = "No murderer found with a knife!", Duration = 3})
        end
    end
})

--// ====== TP to Map Button (placeholder) ======
Tab:CreateButton({
    Name = "TP to Map",
    Callback = function()
        -- TODO: Add teleport logic here
        Rayfield:Notify({Title = "Info", Content = "TP to Map pressed. Add coordinates/logic here.", Duration = 3})
    end
})
