-- Rayfield_GrabGun_ESP_Final.local (LocalScript)
-- Place in StarterPlayerScripts (or Tool in StarterPack). Uses Rayfield loader you provided.
-- WARNING: This script does client-side teleport and highlighting for dev UX only.
-- It does NOT steal from other players or violate server authority.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ===== CONFIG =====
local TELEPORT_OFFSET_Y = 3            -- how high above the target to place you
local GUN_NAMES = {"Gun", "GunDrop", "Pistol", "Rifle"} -- keywords for searching guns/drops
local WEAPON_KEYWORDS = {"Gun", "Knife"} -- keywords used to determine who is "holding" a weapon
local HIGHLIGHT_REFRESH = 0.12         -- how often ESP checks players
local RAYFIELD_URL = "https://sirius.menu/rayfield" -- (you provided)
-- ===================

-- ===== Rayfield loader (user-provided) =====
local rayfield_ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet(RAYFIELD_URL))()
end)
if not rayfield_ok then
    Rayfield = nil
    warn("[GrabGun] Rayfield loader failed or blocked. Falling back to builtin UI.")
end

-- ===== Utilities (searching & matching) =====
local function lowerContains(str, sub)
    if not str or not sub then return false end
    return string.find(string.lower(str), string.lower(sub), 1, true) ~= nil
end

local function matchesGunName(name)
    if not name then return false end
    for _, key in ipairs(GUN_NAMES) do
        if lowerContains(name, key) then return true end
    end
    return false
end

local function findAllGunCandidates()
    local found = {}
    for _, inst in ipairs(workspace:GetDescendants()) do
        -- limit to instances that matter
        if inst:IsA("Tool") or inst:IsA("Model") or inst:IsA("BasePart") then
            -- Tool directly
            if inst:IsA("Tool") and matchesGunName(inst.Name) then
                table.insert(found, inst)
            elseif inst:IsA("Model") and matchesGunName(inst.Name) then
                table.insert(found, inst)
            elseif inst:IsA("Model") then
                -- model may contain a Tool descendant
                for _, d in ipairs(inst:GetDescendants()) do
                    if d:IsA("Tool") and matchesGunName(d.Name) then
                        table.insert(found, inst)
                        break
                    end
                end
            elseif inst:IsA("BasePart") and matchesGunName(inst.Name) then
                table.insert(found, inst)
            end
        end
    end
    return found
end

local function pickBestGun()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local cpos = hrp and hrp.Position or (LocalPlayer:GetMouse() and LocalPlayer:GetMouse().Hit.p) or Vector3.new()
    local choices = findAllGunCandidates()
    if #choices == 0 then return nil end

    local best, bestDist = nil, math.huge
    for _, inst in ipairs(choices) do
        local pos
        if inst:IsA("Tool") then
            local handle = inst:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then pos = handle.Position end
            if not pos and inst.Parent and inst.Parent:IsA("Model") and inst.Parent.PrimaryPart then
                pos = inst.Parent.PrimaryPart.Position
            end
        elseif inst:IsA("Model") and inst.PrimaryPart then
            pos = inst.PrimaryPart.Position
        elseif inst:IsA("BasePart") then
            pos = inst.Position
        end
        if pos then
            local d = (pos - cpos).Magnitude
            if d < bestDist then bestDist, best = d, inst end
        end
    end
    return best
end

local function teleportToInstance(inst)
    if not inst then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local targetPos
    if inst:IsA("Tool") then
        local handle = inst:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            targetPos = handle.Position
        elseif inst.Parent and inst.Parent:IsA("Model") and inst.Parent.PrimaryPart then
            targetPos = inst.Parent.PrimaryPart.Position
        end
    elseif inst:IsA("Model") and inst.PrimaryPart then
        targetPos = inst.PrimaryPart.Position
    elseif inst:IsA("BasePart") then
        targetPos = inst.Position
    end

    if not targetPos then return false end

    local newCFrame = CFrame.new(targetPos + Vector3.new(0, TELEPORT_OFFSET_Y, 0))
    -- best-effort local teleport
    pcall(function() hrp.CFrame = newCFrame end)
    return true
end

-- ===== ESP helpers =====
local espEnabled = false
local highlightMap = {} -- [player] = Highlight instance

local function isPlayerHoldingWeapon(player)
    local ch = player.Character
    if not ch then return false, nil end
    for _, child in ipairs(ch:GetChildren()) do
        if child:IsA("Tool") then
            for _, key in ipairs(WEAPON_KEYWORDS) do
                if lowerContains(child.Name, key) then
                    return true, child.Name
                end
            end
        end
    end
    return false, nil
end

local function ensureHighlightForPlayer(player, color3)
    local existing = highlightMap[player]
    if existing and existing.Parent then return existing end
    local adornee = player.Character
    if not adornee then return end
    local h = Instance.new("Highlight")
    h.Name = "DevESPHighlight"
    h.Adornee = adornee
    h.FillTransparency = 0.6
    h.OutlineTransparency = 0.5
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = workspace
    if color3 then
        h.FillColor = color3
        h.OutlineColor = color3
    end
    highlightMap[player] = h
    return h
end

local function removeHighlightForPlayer(player)
    local h = highlightMap[player]
    if h and h.Parent then h:Destroy() end
    highlightMap[player] = nil
end

-- ESP update loop
spawn(function()
    while true do
        if espEnabled then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer then
                    local holding, toolName = isPlayerHoldingWeapon(pl)
                    if holding then
                        local color = Color3.fromRGB(255, 100, 100) -- default gun color
                        if lowerContains(toolName or "", "knife") then
                            color = Color3.fromRGB(255, 210, 80)
                        end
                        ensureHighlightForPlayer(pl, color)
                    else
                        removeHighlightForPlayer(pl)
                    end
                end
            end
        else
            -- remove all
            for p,_ in pairs(highlightMap) do removeHighlightForPlayer(p) end
        end
        wait(HIGHLIGHT_REFRESH)
    end
end)

-- ===== UI: Rayfield or fallback =====
local uiObject = {}

-- Fallback builder
local function makeFallbackUI()
    local screen = Instance.new("ScreenGui")
    screen.Name = "GrabGunUI_Fallback"
    screen.ResetOnSpawn = false
    screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", screen)
    frame.Size = UDim2.new(0, 220, 0, 100)
    frame.Position = UDim2.new(0, 12, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0

    local function mkbtn(text, y)
        local b = Instance.new("TextButton", frame)
        b.Size = UDim2.new(0, 200, 0, 36)
        b.Position = UDim2.new(0, 10, 0, y)
        b.Text = text
        b.Font = Enum.Font.SourceSansBold
        b.TextScaled = true
        b.BackgroundColor3 = Color3.fromRGB(60,60,60)
        b.TextColor3 = Color3.fromRGB(255,255,255)
        return b
    end

    local grabBtn = mkbtn("Grab Gun", 8)
    local espBtn = mkbtn("ESP: OFF", 52)

    return {ScreenGui = screen, GrabBtn = grabBtn, EspBtn = espBtn}
end

-- Build UI using Rayfield if available
local function buildUI()
    if Rayfield and type(Rayfield) == "table" and Rayfield:CreateWindow then
        local ok, win = pcall(function()
            return Rayfield:CreateWindow({
                Name = "GrabGun & ESP",
                LoadingTitle = "Ready",
                LoadingSubtitle = "Dev Tools",
                ConfigurationSaving = {
                    Enabled = false,
                },
            })
        end)
        if ok and win then
            -- try common API names for Rayfield buttons/toggles
            local grabBt, espTog
            -- Button
            pcall(function()
                grabBt = win:CreateButton({
                    Name = "Grab Gun",
                    Callback = function() end
                })
            end)
            -- Toggle
            pcall(function()
                espTog = win:CreateToggle({
                    Name = "ESP",
                    CurrentValue = false,
                    Flag = "ESPFlag",
                    Callback = function() end
                })
            end)

            -- If CreateButton not present, try AddButton (other forks)
            if not grabBt and win.AddButton then
                pcall(function()
                    grabBt = win:AddButton("Grab Gun", function() end)
                end)
            end
            if not espTog and win.AddToggle then
                pcall(function()
                    espTog = win:AddToggle("ESP", false, function() end)
                end)
            end

            uiObject.Window = win
            uiObject.GrabBtn = grabBt
            uiObject.EspToggle = espTog
            return true
        end
    end

    -- fallback
    uiObject = makeFallbackUI()
    return false
end

buildUI()

-- ===== Wire UI logic =====
local function doGrabGun()
    local best = pickBestGun()
    if not best then
        -- try notify via Rayfield or print warn
        if uiObject.Window and uiObject.Window:Notification then
            pcall(function() uiObject.Window:Notification("Grab Gun", "No GunDrop found in workspace.", 3) end)
        else
            warn("[GrabGun] No GunDrop found in workspace.")
        end
        return
    end
    local ok = teleportToInstance(best)
    if ok then
        -- optional pulse marker on target
        local part = (best:IsA("Tool") and (best:FindFirstChild("Handle") or best)) or (best:IsA("Model") and best.PrimaryPart) or best
        if part and part:IsA("BasePart") then
            local pulse = Instance.new("Part")
            pulse.Name = "GrabPulseMarker"
            pulse.Size = Vector3.new(1,1,1)
            pulse.Anchored = true
            pulse.CanCollide = false
            pulse.Transparency = 0.4
            pulse.CFrame = part.CFrame
            pulse.Parent = workspace
            delay(1.0, function() if pulse and pulse.Parent then pulse:Destroy() end end)
        end
    else
        warn("[GrabGun] teleport failed.")
    end
end

local function setESPEnabled(val)
    espEnabled = val and true or false
end

-- attach callbacks depending on UI type
-- Rayfield path
if uiObject.Window and (uiObject.GrabBtn or uiObject.EspToggle) then
    -- Rayfield button callback wiring
    if uiObject.GrabBtn and type(uiObject.GrabBtn) == "table" and uiObject.GrabBtn.SetCallback then
        pcall(function() uiObject.GrabBtn:SetCallback(doGrabGun) end)
    elseif uiObject.GrabBtn and type(uiObject.GrabBtn) == "function" then
        -- some Rayfield returns function directly; attempt to override by replacing with a wrapper
        pcall(function() uiObject.GrabBtn = {Callback = doGrabGun} end)
    elseif uiObject.GrabBtn and uiObject.GrabBtn.Button then
        pcall(function() uiObject.GrabBtn.Button.MouseButton1Click:Connect(doGrabGun) end)
    end

    -- ESP toggle
    if uiObject.EspToggle and type(uiObject.EspToggle) == "table" and uiObject.EspToggle.SetCallback then
        pcall(function() uiObject.EspToggle:SetCallback(function(v) setESPEnabled(v) end) end)
    elseif uiObject.EspToggle and uiObject.EspToggle.Toggle then
        pcall(function()
            uiObject.EspToggle.Toggle:GetPropertyChangedSignal("Active"):Connect(function()
                setESPEnabled(uiObject.EspToggle.Toggle.Active)
            end)
        end)
    end
else
    -- fallback UI path: plain TextButtons
    local fb = uiObject
    if fb.GrabBtn and fb.GrabBtn:IsA("TextButton") then
        fb.GrabBtn.MouseButton1Click:Connect(function()
            doGrabGun()
        end)
    end
    if fb.EspBtn and fb.EspBtn:IsA("TextButton") then
        fb.EspBtn.MouseButton1Click:Connect(function()
            espEnabled = not espEnabled
            fb.EspBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
        end)
    end
end

-- Final: small console feedback
print("[GrabGun] UI ready. Grab Gun and ESP available. (Dev-only script)")

-- Cleanup highlights when player leaves or dies
Players.PlayerRemoving:Connect(function(pl)
    removeHighlightForPlayer(pl)
end)
LocalPlayer.CharacterRemoving:Connect(function()
    -- remove highlights to avoid orphaned adornee references
    for p,_ in pairs(highlightMap) do removeHighlightForPlayer(p) end
end)
