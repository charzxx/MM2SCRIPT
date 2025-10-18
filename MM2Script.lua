local player = game.Players.LocalPlayer
local plot = workspace:WaitForChild("Plots"):WaitForChild("Plot3")
local rep = game:GetService("ReplicatedStorage")
local BlocksFolder = rep:WaitForChild("Blocks"):WaitForChild("Blocks")

-- Your full block list
local AllBlocks = {
    BlocksFolder["Birch Wood"],
    BlocksFolder["Birch Wood Planks"],
    BlocksFolder.Brick,
    BlocksFolder["Neon Purple"],
    BlocksFolder.Water,
    -- add the rest...
}

-- Terrain settings
local basePos = plot:GetBoundingBox().Position
local terrainWidth = 10
local terrainDepth = 10
local maxHeight = 3
local spacing = 4

for x = 0, terrainWidth-1 do
    for z = 0, terrainDepth-1 do
        local height = math.random(1, maxHeight)
        for y = 0, height-1 do
            local model = AllBlocks[math.random(1,#AllBlocks)]:Clone()

            -- Make sure model has PrimaryPart
            if not model.PrimaryPart then
                local part = model:FindFirstChildWhichIsA("BasePart")
                if part then
                    model.PrimaryPart = part
                else
                    continue  -- skip if no BasePart
                end
            end

            -- Position the model
            model:SetPrimaryPartCFrame(
                CFrame.new(
                    basePos.X + x*spacing,
                    basePos.Y + y*spacing,
                    basePos.Z + z*spacing
                )
            )

            model.Parent = workspace
            task.wait(0.01)
        end
    end
end

print("✅ Terrain built locally with all Models!")
