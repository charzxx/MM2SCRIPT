local player = game.Players.LocalPlayer
local plot = workspace:WaitForChild("Plots"):WaitForChild("Plot3")
local rep = game:GetService("ReplicatedStorage")
local BlocksFolder = rep:WaitForChild("Blocks"):WaitForChild("Blocks")

-- ✅ All your blocks in a table
local AllBlocks = {
    BlocksFolder["Birch Wood"],
    BlocksFolder["Birch Wood Planks"],
    BlocksFolder.Brick,
    BlocksFolder["Carpet Beige"],
    BlocksFolder["Carpet Grey"],
    BlocksFolder["Carpet White"],
    BlocksFolder.Cobblestone,
    BlocksFolder.Concrete,
    BlocksFolder["Diamond Plate"],
    BlocksFolder.Dirt,
    BlocksFolder.Drywall,
    BlocksFolder["Ebony Wood"],
    BlocksFolder["Fabric Blue"],
    BlocksFolder["Fabric Red"],
    BlocksFolder["Fabric White"],
    BlocksFolder.Glass,
    BlocksFolder["Glass Block"],
    BlocksFolder.Granite,
    BlocksFolder.Grass,
    BlocksFolder["Grey Diamond Plate"],
    BlocksFolder.Marble,
    BlocksFolder.Metal,
    BlocksFolder["Neon Purple"],
    BlocksFolder["Oak Wood"],
    BlocksFolder["Oak Wood Planks"],
    BlocksFolder["Orange Diamond Plate"],
    BlocksFolder["Pine Wood"],
    BlocksFolder["Pine Wood Planks"],
    BlocksFolder.Plastic,
    BlocksFolder["Pool Tiles"],
    BlocksFolder.Sand,
    BlocksFolder.Sandstone,
    BlocksFolder["Sandy Brick"],
    BlocksFolder.Slate,
    BlocksFolder["Smooth Pale Red Brick"],
    BlocksFolder["Smooth Red Brick"],
    BlocksFolder["Smooth Yellow Brick"],
    BlocksFolder["Spruce Wood"],
    BlocksFolder["Spruce Wood Planks"],
    BlocksFolder.Stone,
    BlocksFolder.Water,
    BlocksFolder["Water Clear"],
    BlocksFolder.Wood,
    BlocksFolder.WoodGrain
}

print("✅ Blocks table ready, total blocks:", #AllBlocks)

-- Terrain settings
local basePos = plot:GetBoundingBox().Position
local terrainWidth = 20   -- X-axis blocks
local terrainDepth = 20   -- Z-axis blocks
local maxHeight = 5       -- max Y blocks height
local blockSize = 4

-- Build terrain
for x = 0, terrainWidth-1 do
    for z = 0, terrainDepth-1 do
        local height = math.random(1, maxHeight)
        for y = 0, height-1 do
            local randomBlock = AllBlocks[math.random(1, #AllBlocks)]:Clone()
            randomBlock.CFrame = CFrame.new(
                basePos.X + x * blockSize,
                basePos.Y + y * blockSize,
                basePos.Z + z * blockSize
            )
            randomBlock.Parent = workspace
            task.wait(0.01) -- slow spawn for visibility
        end
    end
end

print("✅ Land built locally with all blocks!")
