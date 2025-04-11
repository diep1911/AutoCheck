-- UI CHECK ITEM Blox Fruits (CDK, Valkyrie Helm, Mirror, Godhuman)
repeat wait() until game:IsLoaded()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Backpack = player:WaitForChild("Backpack")
local Character = player.Character or player.CharacterAdded:Wait()

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ItemCheckUI"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 140)
Frame.Position = UDim2.new(1, -260, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1
Frame.ClipsDescendants = true
Frame.AnchorPoint = Vector2.new(0, 0)
Frame.Active = true
Frame.Draggable = true
Frame.Name = "ItemStatusFrame"

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "🧾 Item Status"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- Item config
local targetItems = {
    {name = "CDK", label = "Cursed Dual Katana"},
    {name = "Valk", label = "Valkyrie Helm"},
    {name = "Mirror", label = "Mirror Fractal"},
    {name = "Godhuman", label = "Godhuman"},
}

-- Function
local function hasTool(name)
    return Backpack:FindFirstChild(name) or Character:FindFirstChild(name)
end

local function hasItemInInventory(itemName)
    local inv = require(game:GetService("ReplicatedStorage"):WaitForChild("Remotes").CommF_:InvokeServer("getInventoryItems"))
    for _, item in pairs(inv) do
        if item.Name == itemName then
            return true
        end
    end
    return false
end

local function hasGodhuman()
    local currentTool = Character:FindFirstChildWhichIsA("Tool")
    if currentTool and currentTool.Name == "Godhuman" then return true end
    local fightingStyles = require(game:GetService("ReplicatedStorage").FightingStyle)
    return fightingStyles["Godhuman"] ~= nil
end

-- Function to create item row
local function createItemRow(titleText, status)
    local row = Instance.new("Frame", Frame)
    row.Size = UDim2.new(1, -10, 0, 24)
    row.BackgroundTransparency = 1
    row.LayoutOrder = 1

    local statusCircle = Instance.new("Frame", row)
    statusCircle.Size = UDim2.new(0, 16, 0, 16)
    statusCircle.Position = UDim2.new(0, 5, 0.5, -8)
    statusCircle.BackgroundColor3 = status and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    statusCircle.BorderSizePixel = 0
    local corner = Instance.new("UICorner", statusCircle)
    corner.CornerRadius = UDim.new(1, 0)

    local text = Instance.new("TextLabel", row)
    text.Size = UDim2.new(1, -30, 1, 0)
    text.Position = UDim2.new(0, 28, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = titleText .. ": " .. (status and "Đã có" or "Chưa có")
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.Font = Enum.Font.Gotham
    text.TextSize = 14
    text.TextXAlignment = Enum.TextXAlignment.Left
end

-- Check từng item
local hasCDK = hasTool("Cursed Dual Katana")
local hasValk = hasItemInInventory("Valkyrie Helm")
local hasMirror = hasItemInInventory("Mirror Fractal")
local hasGH = hasGodhuman()

-- Add UI rows
createItemRow("🔮 CDK", hasCDK)
createItemRow("👑 Valkyrie Helm", hasValk)
createItemRow("🪞 Mirror Fractal", hasMirror)
createItemRow("🥊 Godhuman", hasGH)
