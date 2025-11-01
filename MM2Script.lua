local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Charz Dev Panel",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Charz Hub",
})

local MainTab = Window:CreateTab("Main", 4483362458)

-- ======= Helper functions =======
local function clearESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local h = plr.Character:FindFirstChild("CharzHighlight")
            if h then h:Destroy() end
        end
    end
end

local function setESP(plr, color)
    if plr == LocalPlayer then return end
    if not plr.Character then return end

    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local old = plr.Character:FindFirstChild("CharzHighlight")
    if old then old:Destroy() end

    local h = Instance.new("Highlight")
    h.Name = "CharzHighlight"
    h.FillTransparency = 0.4
    h.FillColor = color
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.Parent = plr.Character
end

local function hasTool(plr, toolName)
    if plr.Backpack and plr.Backpack:FindFirstChild(toolName) then return true end
    if plr.Character and plr.Character:FindFirstChild(toolName) then return true end
    return false
end

local function tpToPart(part)
    if not part then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = part.CFrame + Vector3.new(0,3,0)
end

local function findAllGunCandidates()
    local found = {}
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("Tool") or inst:IsA("BasePart") then
            if string.find(string.lower(inst.Name), "gun") then
                table.insert(found, inst)
            end
        end
    end
    return found
end

local function pickBestGun()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local cpos = hrp and hrp.Position or Vector3.new()
    local choices = findAllGunCandidates()
    if #choices == 0 then return nil end

    local best, bestDist = nil, math.huge
    for _, inst in ipairs(choices) do
        local pos
        if inst:IsA("Tool") and inst:FindFirstChild("Handle") then
            pos = inst.Handle.Position
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

-- ======= Buttons =======

-- ESP Murderer / Sheriff
MainTab:CreateButton({
    Name = "ESP Murderer (Red) / Sheriff (Blue)",
    Callback = function()
        clearESP()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if hasTool(plr, "Gun") then
                    setESP(plr, Color3.fromRGB(0,0,255)) -- BLUE sheriff
                elseif hasTool(plr, "Knife") then
                    setESP(plr, Color3.fromRGB(255,0,0)) -- RED murderer
                end
            end
        end
    end
})

-- Grab Gun
MainTab:CreateButton({
    Name = "Grab Gun",
    Callback = function()
        local best = pickBestGun()
        if best then
            if best:IsA("Tool") and best:FindFirstChild("Handle") then
                tpToPart(best.Handle)
            elseif best:IsA("BasePart") then
                tpToPart(best)
            end
        else
            warn("No GunDrop found")
        end
    end
})

-- Grab Coins Smooth 1 Stud/sec + Noclip
MainTab:CreateButton({
    Name = "Grab Coins Smooth 1 Stud/sec + Noclip",
    Callback = function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Enable noclip
    local ncConn
    ncConn = RunService.Stepped:Connect(function()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)

    -- Find all CoinContainers
    local containers = {}
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst.Name == "CoinContainer" and inst:IsA("Model") then
            table.insert(containers, inst)
        end
    end

    -- Loop through each coin
    for _, container in ipairs(containers) do
        for _, coin in ipairs(container:GetChildren()) do
            if coin:IsA("BasePart") then
                -- Calculate distance & tween time based on 1 stud/sec
                local distance = (coin.Position - hrp.Position).Magnitude
                local tweenTime = distance / 1 -- 1 stud per second

                local tween = TweenService:Create(
                    hrp,
                    TweenInfo.new(tweenTime, Enum.EasingStyle.Linear),
                    {CFrame = coin.CFrame + Vector3.new(0,3,0)}
                )
                tween:Play()
                tween.Completed:Wait()
                task.wait(0.1)
            end
        end
    end

    -- Disable noclip
    if ncConn then ncConn:Disconnect() end
end
})

