-- Kiểm tra item
local itemList = {
    "Cursed Dual Katana",
    "Mirror Fractal",
    "Valkyrie Helm",
    "Godhuman"
}

local foundItems = {}
local player = game:GetService("Players").LocalPlayer

-- Check trong Backpack & Character
for _, item in pairs(player.Backpack:GetChildren()) do
    foundItems[item.Name] = true
end
for _, item in pairs(player.Character:GetChildren()) do
    foundItems[item.Name] = true
end

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ItemStatusGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 160)
Frame.Position = UDim2.new(0, 30, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "📋 Item Status"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- Vẽ từng dòng item + icon tròn
for i, itemName in ipairs(itemList) do
    local Row = Instance.new("Frame", Frame)
    Row.Size = UDim2.new(1, -20, 0, 25)
    Row.Position = UDim2.new(0, 10, 0, 30 + (i - 1) * 28)
    Row.BackgroundTransparency = 1

    local Dot = Instance.new("Frame", Row)
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 0, 0.5, -7)
    Dot.BackgroundColor3 = foundItems[itemName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    Dot.BorderSizePixel = 0
    Dot.BackgroundTransparency = 0
    Dot.ZIndex = 2
    Dot.Name = "Dot"

    local UICorner = Instance.new("UICorner", Dot)
    UICorner.CornerRadius = UDim.new(1, 0)

    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.new(0, 20, 0, 0)
    Label.Text = itemName
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
end
