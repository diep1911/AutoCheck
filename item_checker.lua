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

-- TẠO GUI
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "ItemStatusGUI"
gui.ResetOnSpawn = false

-- FRAME CHÍNH
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 220)
frame.Position = UDim2.new(0, 30, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(255, 215, 0)

-- TIÊU ĐỀ
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "📋 Item Status"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextStrokeTransparency = 0.8

-- TÊN NGƯỜI DÙNG
local name = Instance.new("TextLabel", frame)
name.Size = UDim2.new(1, 0, 0, 20)
name.Position = UDim2.new(0, 0, 0, 35)
name.Text = "👑 Made for: " .. player.Name
name.TextColor3 = Color3.fromRGB(255, 223, 0)
name.BackgroundTransparency = 1
name.Font = Enum.Font.Gotham
name.TextSize = 14

-- TẠO DANH SÁCH ITEM
for i, itemName in ipairs(itemList) do
    local row = Instance.new("Frame", frame)
    row.Size = UDim2.new(1, -20, 0, 25)
    row.Position = UDim2.new(0, 10, 0, 60 + (i - 1) * 30)
    row.BackgroundTransparency = 1

    local dot = Instance.new("Frame", row)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 0, 0.5, -6)
    dot.BackgroundColor3 = foundItems[itemName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(1, -25, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.Text = itemName
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
end
