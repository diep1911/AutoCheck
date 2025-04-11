-- DANH SÁCH ITEM
local itemList = {
    "Cursed Dual Katana",
    "Mirror Fractal",
    "Valkyrie Helm",
    "Godhuman"
}

local foundItems = {}
local player = game:GetService("Players").LocalPlayer

-- KIỂM TRA ITEM
for _, item in pairs(player.Backpack:GetChildren()) do
    foundItems[item.Name] = true
end
for _, item in pairs(player.Character:GetChildren()) do
    foundItems[item.Name] = true
end

-- XÓA GUI CŨ
pcall(function()
    game.CoreGui:FindFirstChild("ItemStatusGUI"):Destroy()
end)

-- TẠO GUI MỚI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ItemStatusGUI"
ScreenGui.ResetOnSpawn = false

-- KHUNG CHÍNH
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 220)
Frame.Position = UDim2.new(0, 30, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BackgroundTransparency = 0
Frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Color = Color3.fromRGB(255, 208, 0)
UIStroke.Thickness = 1.2
UIStroke.Transparency = 0.4

-- TIÊU ĐỀ
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "📋 Item Status"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextStrokeTransparency = 0.7

-- TÊN ANH
local NameTag = Instance.new("TextLabel", Frame)
NameTag.Size = UDim2.new(1, 0, 0, 20)
NameTag.Position = UDim2.new(0, 0, 0, 35)
NameTag.Text = "👑 Made for: DYLAN " .. player.Name
NameTag.TextColor3 = Color3.fromRGB(255, 208, 0)
NameTag.BackgroundTransparency = 1
NameTag.Font = Enum.Font.GothamMedium
NameTag.TextSize = 14

-- DANH SÁCH ITEM
for i, itemName in ipairs(itemList) do
    local Row = Instance.new("Frame", Frame)
    Row.Size = UDim2.new(1, -20, 0, 25)
    Row.Position = UDim2.new(0, 10, 0, 60 + (i - 1) * 30)
    Row.BackgroundTransparency = 1

    local Dot = Instance.new("Frame", Row)
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 0, 0.5, -7)
    Dot.BackgroundColor3 = foundItems[itemName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    Dot.BorderSizePixel = 0
    local DotCorner = Instance.new("UICorner", Dot)
    DotCorner.CornerRadius = UDim.new(1, 0)

    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(1, -25, 1, 0)
    Label.Position = UDim2.new(0, 20, 0, 0)
    Label.Text = itemName
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
end
