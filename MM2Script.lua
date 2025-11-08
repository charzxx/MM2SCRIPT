-- Grab Coins Nearest Tween + Noclip (dynamic loop)
local grabbingCoins = false

MainTab:CreateToggle({
    Name = "Grab Coins Nearest Tween + Noclip",
    CurrentValue = false,
    Flag = "CoinGrab",
    Callback = function(value)
        grabbingCoins = value

        if grabbingCoins then
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local speed = 60 -- studs/sec

            -- Enable noclip
            local ncConn
            ncConn = RunService.Stepped:Connect(function()
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)

            -- Main loop
            spawn(function()
                while grabbingCoins do
                    if not char or not hrp then break end

                    -- Gather all visible coins dynamically
                    local coins = {}
                    for _, inst in ipairs(workspace:GetDescendants()) do
                        if inst.Name == "CoinContainer" and inst:IsA("Model") then
                            for _, coin in ipairs(inst:GetChildren()) do
                                if coin:IsA("BasePart") and coin.Transparency < 1 then
                                    table.insert(coins, coin)
                                end
                            end
                        end
                    end

                    if #coins == 0 then
                        task.wait(0.1)
                        continue
                    end

                    -- find nearest coin
                    local nearest, nearestDist = nil, math.huge
                    for i, coin in ipairs(coins) do
                        local dist = (coin.Position - hrp.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = coin
                        end
                    end

                    if nearest then
                        local distance = (nearest.Position - hrp.Position).Magnitude
                        local tweenTime = distance / speed

                        local tween = TweenService:Create(
                            hrp,
                            TweenInfo.new(tweenTime, Enum.EasingStyle.Linear),
                            {CFrame = nearest.CFrame + Vector3.new(0,3,0)}
                        )
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(0.02)
                    else
                        task.wait(0.1)
                    end
                end

                -- Disable noclip
                if ncConn then ncConn:Disconnect() end
            end)
        end
    end
})
