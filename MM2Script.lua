-- MM2 Script (host-ready)
-- Put this file on GitHub/Paste.ee and load via loadstring(game:HttpGet("<raw_url>"))()

---@diagnostic disable: undefined-global
-- Local aliases so VS Code/Luau LSP stops complaining
local game = game
local workspace = workspace
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local loadstring = loadstring
local task = task
local warn = warn
local ipairs = ipairs
local pairs = pairs
local tostring = tostring

-- Safely load Rayfield (use the real URL; this tries and errors out cleanly if it fails)
local ok, Rayfield = pcall(function()
	return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not ok or not Rayfield then
	warn("Failed to load Rayfield:", Rayfield)
	-- Optionally notify the player (works in Studio/executor with StarterGui)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Rayfield Load Failed",
			Text = "Could not load Rayfield. Check URL or internet.",
			Duration = 4
		})
	end)
	return
end

-- UI setup
local Window = Rayfield:CreateWindow({
	Name = "MM2 Script",
	LoadingTitle = "MM2 Tools",
	LoadingSubtitle = "By Charz",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "RayfieldConfigs",
		FileName = "MM2ESPSettings"
	}
})

local Tab = Window:CreateTab("Main", 4483362458)

-- Utility: remove highlight named RoleHighlight from a character
local function clearHighlight(character)
	if character and character:FindFirstChild("RoleHighlight") then
		character.RoleHighlight:Destroy()
	end
end

-- Utility: apply RoleHighlight to a character with color
local function applyHighlight(character, color3)
	if not character then return end
	-- remove any old
	clearHighlight(character)
	-- create new
	local highlight = Instance.new("Highlight")
	highlight.Name = "RoleHighlight"
	highlight.Parent = character
	highlight.Adornee = character
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0.1
	highlight.FillColor = color3
end

-- Function: scan players and highlight Sheriff (gun) blue and Murderer (knife) red
local function highlightPlayers()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Players.LocalPlayer then
			local char = plr.Character
			local backpack = plr:FindFirstChild("Backpack")
			local isSheriff = false
			local isMurderer = false

			-- check backpack
			if backpack then
				if backpack:FindFirstChild("Gun") then isSheriff = true end
				if backpack:FindFirstChild("Knife") then isMurderer = true end
			end

			-- check character
			if char then
				if char:FindFirstChild("Gun") then isSheriff = true end
				if char:FindFirstChild("Knife") then isMurderer = true end
			end

			-- remove old highlight first
			clearHighlight(char)

			-- apply new highlight if needed
			if isSheriff then
				applyHighlight(char, Color3.fromRGB(0, 120, 255)) -- blue
			elseif isMurderer then
				applyHighlight(char, Color3.fromRGB(255, 50, 50)) -- red
			end
		end
	end
end

-- Button: ESP (manual refresh)
Tab:CreateButton({
	Name = "ESP Sheriff & Murderer",
	Callback = function()
		highlightPlayers()
		Rayfield:Notify({
			Title = "ESP Run",
			Content = "Scanned players for Gun/Knife and applied highlights.",
			Duration = 2
		})
	end
})

-- Button: Steal Gun From SHERIFF (reparents the first found Tool named or containing "Gun")
Tab:CreateButton({
	Name = "Steal Gun From SHERIFF",
	Callback = function()
		local localPlayer = Players.LocalPlayer
		if not localPlayer then
			Rayfield:Notify({Title = "Error", Content = "LocalPlayer not found", Duration = 3})
			return
		end
		local myBackpack = localPlayer:FindFirstChild("Backpack")
		if not myBackpack then
			Rayfield:Notify({Title = "Error", Content = "Your Backpack not found", Duration = 3})
			return
		end

		local found = false
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= localPlayer then
				-- search for a Tool that looks like a gun in backpack or character
				local otherBackpack = plr:FindFirstChild("Backpack")
				local tool = nil
				if otherBackpack then
					tool = otherBackpack:FindFirstChildOfClass("Tool")
					if tool and string.find(tool.Name:lower(), "gun") then
						-- ok it's likely the gun
					else
						tool = nil
					end
				end
				if not tool and plr.Character then
					local t = plr.Character:FindFirstChildOfClass("Tool")
					if t and string.find(t.Name:lower(), "gun") then
						tool = t
					end
				end

				if tool then
					-- attempt to reparent into your backpack
					local success, err = pcall(function()
						tool.Parent = myBackpack
					end)
					if success then
						Rayfield:Notify({
							Title = "Gun Stolen",
							Content = "Moved gun from " .. plr.Name .. " to your backpack.",
							Duration = 3
						})
					else
						Rayfield:Notify({
							Title = "Error",
							Content = "Failed to move gun: " .. tostring(err),
							Duration = 3
						})
					end
					found = true
					break
				end
			end
		end

		if not found then
			Rayfield:Notify({
				Title = "No Sheriff Found",
				Content = "No player with a gun detected in backpack/character.",
				Duration = 3
			})
		end
	end
})

-- Button: Teleport through Slaps (works if Slaps folder contains BaseParts)
Tab:CreateButton({
	Name = "Go Thru All Slaps",
	Callback = function()
		local player = Players.LocalPlayer
		if not player then
			Rayfield:Notify({Title = "Error", Content = "LocalPlayer not found", Duration = 3})
			return
		end
		local char = player.Character
		if not char then
			Rayfield:Notify({Title = "Error", Content = "Character not loaded", Duration = 3})
			return
		end
		local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Humanoid") and char:FindFirstChild("Humanoid").RootPart
		local slapsFolder = workspace:FindFirstChild("Slaps")
		if not slapsFolder then
			Rayfield:Notify({Title = "Error", Content = "No Slaps folder found", Duration = 3})
			return
		end

		Rayfield:Notify({Title = "Teleport", Content = "Starting teleport through slaps...", Duration = 2})
		for _, slap in pairs(slapsFolder:GetChildren()) do
			local part = nil
			if slap:IsA("BasePart") then
				part = slap
			elseif slap:IsA("Model") then
				part = slap.PrimaryPart or slap:FindFirstChildWhichIsA("BasePart")
			end
			if part and hrp then
				-- move character near the slap
				pcall(function()
					hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
				end)
				task.wait(1)
			end
		end
		Rayfield:Notify({Title = "Teleport", Content = "Finished teleporting through slaps.", Duration = 2})
	end
})
