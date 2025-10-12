--// MM2 Script
---@diagnostic disable: undefined-global
local game, workspace, Players = game, workspace, game:GetService("Players")

--// Rayfield UI Setup
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/charzxx/MM2SCRIPT/refs/heads/main/MM2Script.lua"))()

local Window = Rayfield:CreateWindow({
	Name = "MM2 Script",
	LoadingTitle = "MM2 UI",
	LoadingSubtitle = "By Charz",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil,
		FileName = "MM2"
	},
	Discord = { Enabled = false }
})

local Tab = Window:CreateTab("Main", 4483362458)

--// Button: Steal Gun From SHERIFF (already exists)
Tab:CreateButton({
	Name = "Steal Gun From SHERIFF",
	Callback = function()
		local player = game.Players.LocalPlayer
		local sheriff = nil

		for _, plr in pairs(game.Players:GetPlayers()) do
			if plr.Backpack:FindFirstChildOfClass("Tool") and string.find(plr.Backpack:FindFirstChildOfClass("Tool").Name, "Gun") then
				sheriff = plr
				break
			end
			if plr.Character and plr.Character:FindFirstChildOfClass("Tool") and string.find(plr.Character:FindFirstChildOfClass("Tool").Name, "Gun") then
				sheriff = plr
				break
			end
		end

		if sheriff then
			local gun = sheriff.Backpack:FindFirstChildOfClass("Tool") or sheriff.Character:FindFirstChildOfClass("Tool")
			if gun then
				gun.Parent = player.Backpack
				Rayfield:Notify({ Title = "Success!", Content = "You stole the gun from " .. sheriff.Name, Duration = 4 })
			else
				Rayfield:Notify({ Title = "Error", Content = "No gun found on sheriff!", Duration = 3 })
			end
		else
			Rayfield:Notify({ Title = "Error", Content = "No sheriff found with a gun!", Duration = 3 })
		end
	end
})

--// New Button: Steal Knife from Murderer
Tab:CreateButton({
	Name = "Steal Knife From Murderer",
	Callback = function()
		local player = game.Players.LocalPlayer
		local murderer = nil

		for _, plr in pairs(game.Players:GetPlayers()) do
			if plr.Backpack:FindFirstChildOfClass("Tool") and string.find(plr.Backpack:FindFirstChildOfClass("Tool").Name, "Knife") then
				murderer = plr
				break
			end
			if plr.Character and plr.Character:FindFirstChildOfClass("Tool") and string.find(plr.Character:FindFirstChildOfClass("Tool").Name, "Knife") then
				murderer = plr
				break
			end
		end

		if murderer then
			local knife = murderer.Backpack:FindFirstChildOfClass("Tool") or murderer.Character:FindFirstChildOfClass("Tool")
			if knife then
				knife.Parent = player.Backpack
				Rayfield:Notify({ Title = "Success!", Content = "You stole the knife from " .. murderer.Name, Duration = 4 })
			else
				Rayfield:Notify({ Title = "Error", Content = "No knife found on murderer!", Duration = 3 })
			end
		else
			Rayfield:Notify({ Title = "Error", Content = "No murderer found with a knife!", Duration = 3 })
		end
	end
})

--// New Button: TP to Map (callback to be defined)
Tab:CreateButton({
	Name = "TP to Map",
	Callback = function()
		-- Callback details to be added later
	end
})
