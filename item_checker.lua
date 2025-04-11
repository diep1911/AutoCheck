local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local http_request = http_request or request or (syn and syn.request)

-- UI hiển thị trạng thái item cá nhân
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "ItemStatusUI"
screenGui.IgnoreGuiInset = true -

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Position = UDim2.new(0, 10, 0, 100)
mainFrame.Size = UDim2.new(0, 250, 0, 120)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "📦 Item Tracker - " .. LocalPlayer.Name -- Display account name
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamSemibold
title.TextSize = 20
title.TextStrokeTransparency = 0.8
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Position = UDim2.new(0.2, 0, 0, 0) -- Center horizontally (20% from left), top of screen
mainFrame.Size = UDim2.new(0.6, 0, 0.3, 0) -- 60% width, 30% height
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Gold/Yellow color
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.1
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local function createItemLabel(name, index)
    local label = Instance.new("TextLabel", mainFrame)
    label.Size = UDim2.new(0.45, -20, 0, 25)
    label.Position = UDim2.new(0, 20, 0, 40 + index * 30) -- Adjusted spacing
    label.BackgroundTransparency = 1
    label.Name = name .. "_Label"
    label.Text = name .. ": 🔴"
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 0.8
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    return label
end

local labels = {
    CDK = createItemLabel("CDK", 0),
    Valk = createItemLabel("Valk", 1),
    Mirror = createItemLabel("Mirror", 2),
    Godhuman = createItemLabel("Godhuman", 3)
}

-- Hàm kiểm tra item và update UI
local function updateStatusUI(data)
    for name, label in pairs(labels) do
        local has = data.items[name]
        if has then
            label.Text = name .. ": 🟢"
            label.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            label.Text = name .. ": 🔴"
            label.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end
end

-- Hàm lấy thông tin acc
local function getAccountData()
    return {
        username = LocalPlayer.Name,
        level = LocalPlayer.Data.Level.Value,
        beli = LocalPlayer.Data.Beli.Value,
        fragment = LocalPlayer.Data.Fragments.Value,
        timestamp = os.time(),
        items = {
            CDK = (LocalPlayer.Backpack:FindFirstChild("Cursed Dual Katana") ~= nil) or (LocalPlayer.Character:FindFirstChild("Cursed Dual Katana") ~= nil),
            Valk = (LocalPlayer.Backpack:FindFirstChild("Valkyrie Helm") ~= nil) or (LocalPlayer.Character:FindFirstChild("Valkyrie Helm") ~= nil),
            Mirror = (LocalPlayer.Backpack:FindFirstChild("Mirror Fractal") ~= nil) or (LocalPlayer.Character:FindFirstChild("Mirror Fractal") ~= nil),
            Godhuman = (LocalPlayer.Backpack:FindFirstChild("Godhuman") ~= nil) or (LocalPlayer.Character:FindFirstChild("Godhuman") ~= nil)
        }
    }
end

-- Gửi dữ liệu cá nhân và update UI mỗi 10s
spawn(function()
    while true do
        local data = getAccountData()
        updateStatusUI(data)
        wait(10)
    end
end)

-- Gửi lên server mỗi 30s
spawn(function()
    while true do
        local success, err = pcall(function()
            local data = getAccountData()
            http_request({
                Url = "http://192.168.1.37:5000/",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
            rconsoleprint("[✅ GỬI]: " .. data.username .. "\n")
        end)
        if not success then rconsolewarn("[❌ LỖI]: " .. tostring(err)) end
        wait(30)
    end
end)

-- Vẽ bảng trạng thái từ nhiều acc (nhận từ server)
local function drawStatusBoard(players)
    local baseX, baseY = 350, 100
    local rowHeight = 22
    local colWidths = {150, 50, 60, 60, 80}
    local headers = {"Username", "CDK", "Mirror", "Valk", "God"}

    -- Header
    for i, header in ipairs(headers) do
        local text = Drawing.new("Text")
        text.Text = header
        text.Position = Vector2.new(baseX + (i == 1 and 0 or colWidths[i - 1]), baseY)
        text.Size = 16
        text.Color = Color3.fromRGB(255, 255, 255)
        text.Outline = true
        text.Visible = true
    end

    -- Rows
    for row, player in ipairs(players) do
        local y = baseY + row * rowHeight
        local values = {
            player.username,
            player.items.CDK and "✅" or "❌",
            player.items.Mirror and "✅" or "❌",
            player.items.Valk and "✅" or "❌",
            player.items.Godhuman and "✅" or "❌"
        }

        for i, value in ipairs(values) do
            local text = Drawing.new("Text")
            text.Text = value
            text.Position = Vector2.new(baseX + (i == 1 and 0 or colWidths[i - 1]), y)
            text.Size = 16
            text.Color = (value == "✅" and Color3.fromRGB(0, 255, 0)) or (value == "❌" and Color3.fromRGB(255, 0, 0)) or Color3.fromRGB(255, 255, 255)
            text.Outline = true
            text.Visible = true
        end
    end
end

-- Lấy danh sách acc và hiển thị bảng mỗi 30s
spawn(function()
    while true do
        local success, result = pcall(function()
            return http_request({
                Url = "http://192.168.1.37:5000/status", -- endpoint này phải trả JSON list
                Method = "GET"
            })
        end)

        if success then
            local players = HttpService:JSONDecode(result.Body)
            drawStatusBoard(players)
        else
            rconsolewarn("[❌ KHÔNG LẤY ĐƯỢC DANH SÁCH ACC]")
        end

        wait(30)
    end
end)
