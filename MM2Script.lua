-- MM2 Script
---@diagnostic disable: undefined-global
local Players = game:GetService("Players")
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

-- Button: Steal Gun from SHERIFF
Tab:CreateButton({
    Name = "Steal Gun From SHERIFF",
    Callback = function()
        local sheriff = nil

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            -- Check backpack
            local tool = plr.Backpack:FindFirstChildOfClass("Tool")
            if tool and string.find(tool.Name, "Gun") then
                sheriff = plr
                break
            end
            -- Check character
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
                Rayfield:Notify({
                    Title = "Success!",
                    Content = "Stole gun from " .. sheriff.Name,
                    Duration = 4
                })
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "No gun found on sheriff!",
                    Duration = 3
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No sheriff found with a gun!",
                Duration = 3
            })
        end
    end
})

-- Button: Steal Knife from Murderer
Tab:CreateButton({
    Name = "Steal Knife From Murderer",
    Callback = function()
        local murderer = nil

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            -- Check backpack
            local tool = plr.Backpack:FindFirstChildOfClass("Tool")
            if tool and string.find(tool.Name, "Knife") then
                murderer = plr
                break
            end
            -- Check character
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
                Rayfield:Notify({
                    Title = "Success!",
                    Content = "Stole knife from " .. murderer.Name,
                    Duration = 4
                })
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "No knife found on murderer!",
                    Duration = 3
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No murderer found with a knife!",
                Duration = 3
            })
        end
    end
})

-- Button: TP to Map (placeholder)
Tab:CreateButton({
    Name = "TP to Map",
    Callback = function()
        -- TODO: Add teleport logic here
        Rayfield:Notify({
            Title = "Info",
            Content = "TP to Map button pressed. Add coordinates or logic here.",
            Duration = 3
        })
    end
})
