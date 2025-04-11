-- DANH SÁCH ITEM CẦN KIỂM TRA
local itemList = {
    "Cursed Dual Katana",
    "Mirror Fractal",
    "Valkyrie Helm",
    "Godhuman"
}

local foundItems = {}
local player = game:GetService("Players").LocalPlayer

-- KIỂM TRA TRONG BACKPACK VÀ CHARACTER
for _, item in pairs(player.Backpack:GetChildren()) do
    foundItems[item.Name] = true
end
for _, item in pairs(player.Character:GetChildren()) do
    foundItems[item.Name] = true
end

-- XÓA GUI CŨ (nếu có)
pcall(function()
    game.CoreGui:FindFirstChild("ItemStatusGUI"):Destroy()
end)

-- TẠO GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ItemStatusGUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 180)
Frame.Position = UDim2.new(0, 30, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Active = false -- KHÔNG DI CHUYỂN

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "📋 Item Status"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextStrokeTransparency = 0.8

-- HIỂN THỊ ITEM + ICON TRÒN
for i, itemName in ipairs(itemList) do
    local Row = Instance.new("Frame", Frame)
    Row.Size = UDim2.new(1, -20, 0, 25)
    Row.Position = UDim2.new(0, 10, 0, 35 + (i - 1) * 30)
    Row.BackgroundTransparency = 1

    local Dot = Instance.new("Frame", Row)
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = UDim2.new(0, 0, 0.5, -8)
    Dot.BackgroundColor3 = foundItems[itemName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    Dot.BorderSizePixel = 0
    local DotCorner = Instance.new("UICorner", Dot)
    DotCorner.CornerRadius = UDim.new(1, 0)

    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(1, -25, 1, 0)
    Label.Position = UDim2.new(0, 25, 0, 0)
    Label.Text = itemName
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
end
