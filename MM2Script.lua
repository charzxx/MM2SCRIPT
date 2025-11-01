---@diagnostic disable: undefined-global
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Load Rayfield safely
local ok, Rayfield = pcall(function()
	return loadstring(game:HttpGet("https://sirius.menu/rayfield", true))()
end)
if not ok or not Rayfield then
	warn("Failed to load Rayfield:", Rayfield)
	return
end

-- Create Window
local Window = Rayfield:CreateWindow({
	Name = "MM2 Script by Charz",
	LoadingTitle = "Loading MM2 Script...",
	LoadingSubtitle = "By Charz 😎",
	ConfigurationSaving = { Enabled = true, FolderName = "MM2Configs", FileName = "MM2Settings" }
})

local Tab = Window:CreateTab("Main", 4483362458)

-- ESP variables
local ESPEnabled = false
local Connections = {}

-- Function to clear highlight
local function clearHighlight(char)
	if char and char:FindFirstChild("RoleHighlight") then
		char.RoleHighlight:Destroy()
	end
end

-- Highlight players
local function highlightPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Players.LocalPlayer and player.Character then
			local char = player.Character
			local backpack = player:FindFirstChild("Backpack")
			local isSheriff = false
			local isMurderer = false

			-- Check backpack
			if backpack then
				isSheriff = backpack:FindFirstChild("Gun") ~= nil
				isMurderer = backpack:FindFirstChild("Knife") ~= nil
			end
			-- Check character
			isSheriff = isSheriff or (char:FindFirstChild("Gun") ~= nil)
			isMurderer = isMurderer or (char:FindFirstChild("Knife") ~= nil)

			clearHighlight(char)

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

-- Toggle ESP
local function toggleESP(state)
	ESPEnabled = state
	if ESPEnabled then
		Connections.ESP = RunService.RenderStepped:Connect(function()
			if not ESPEnabled then
				Connections.ESP:Disconnect()
				return
			end
			highlightPlayers()
		end)
		Rayfield:Notify({
			Title = "ESP Enabled",
			Content = "Sheriff (Blue) and Murderer (Red) ESP is now active.",
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
			Content = "ESP has been turned off.",
			Duration = 3
		})
	end
end

-- ESP toggle button
Tab:CreateToggle({
	Name = "ESP Sheriff & Murderer",
	CurrentValue = false,
	Callback = function(state)
		toggleESP(state)
	end
})

-- Handle respawns
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		if ESPEnabled then highlightPlayers() end
		char:WaitForChild("Humanoid").Died:Connect(function()
			clearHighlight(char)
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	if player.Character then clearHighlight(player.Character) end
end)

-- Steal Gun/Knife button
Tab:CreateButton({
	Name = "Steal Gun/Knife",
	Callback = function()
		local LocalPlayer = Players.LocalPlayer
		local backpack = LocalPlayer:WaitForChild("Backpack", 5)
		if not backpack then
			Rayfield:Notify({
				Title = "Error",
				Content = "Could not find your Backpack!",
				Duration = 3
			})
			return
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local char = player.Character
				local otherBackpack = player:FindFirstChild("Backpack")

				-- Gun
				local gun = char:FindFirstChild("Gun") or (otherBackpack and otherBackpack:FindFirstChild("Gun"))
				if gun then
					local success, clone = pcall(function() return gun:Clone() end)
					if success and clone then
						clone.Parent = backpack
						Rayfield:Notify({ Title = "Success", Content = "Stole Gun from "..player.Name, Duration = 3 })
					else
						Rayfield:Notify({ Title = "Error", Content = "Failed to clone Gun from "..player.Name, Duration = 3 })
					end
				end

				-- Knife
				local knife = char:FindFirstChild("Knife") or (otherBackpack and otherBackpack:FindFirstChild("Knife"))
				if knife then
					local success, clone = pcall(function() return knife:Clone() end)
					if success and clone then
						clone.Parent = backpack
						Rayfield:Notify({ Title = "Success", Content = "Stole Knife from "..player.Name, Duration = 3 })
					else
						Rayfield:Notify({ Title = "Error", Content = "Failed to clone Knife from "..player.Name, Duration = 3 })
					end
				end
			end
		end
	end
})

-- Grab Gun button
Tab:CreateButton({
	Name = "Grab Gun",
	Callback = function()
		local LocalPlayer = Players.LocalPlayer
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		-- Search for GunDrop in workspace
		local gunDrop = Workspace:FindFirstChild("GunDrop")
		if gunDrop and gunDrop:IsA("BasePart") then
			hrp.CFrame = gunDrop.CFrame + Vector3.new(0, 3, 0)
			Rayfield:Notify({Title="Success", Content="Moved to GunDrop!", Duration=3})
		else
			Rayfield:Notify({Title="Error", Content="No GunDrop found!", Duration=3})
		end
	end
})

-- Init highlights for existing players
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= Players.LocalPlayer and player.Character then
		player.CharacterAdded:Connect(function(char)
			if ESPEnabled then highlightPlayers() end
			char:WaitForChild("Humanoid").Died:Connect(function()
				clearHighlight(char)
			end)
		end)
	end
end
