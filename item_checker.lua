local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local http_request = http_request or request or (syn and syn.request)

-- UI hiển thị trạng thái item
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "ItemStatusUI"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Position = UDim2.new(0, 10, 0, 100)
mainFrame.Size = UDim2.new(0, 250, 0, 120)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.2

local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "📦 Item Tracker - By Không"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamSemibold
title.TextSize = 18

local function createItemLabel(name, index)
    local label = Instance.new("TextLabel", mainFrame)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 30 + index * 22)
    label.BackgroundTransparency = 1
    label.Name = name .. "_Label"
    label.Text = name .. ": 🔴"
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
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

-- Cập nhật UI mỗi 10s
spawn(function()
    while true do
        local data = getAccountData()
        updateStatusUI(data)
        wait(10)
    end
end)

-- Gửi dữ liệu về server Flask mỗi 60s
spawn(function()
    while true do
        local success, err = pcall(function()
            local data = getAccountData()
            local response = http_request({
                Url = "http://192.168.1.37:5000/",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(data)
            })
            rconsoleprint("[✅ GỬI]: " .. data.username .. "\n")
        end)

        if not success then
            rconsolewarn("[❌ LỖI]: " .. tostring(err))
        end

        wait(60)
    end
end)

-- Phần bảng trạng thái (menu) sửa lỗi
local drawingObjects = {} -- Lưu các Drawing objects

-- Xóa các object cũ
local function clearDrawingObjects()
    for _, obj in pairs(drawingObjects) do
        obj:Remove()
    end
    drawingObjects = {}
end

-- Hàm tính tổng chiều rộng cột đến cột i
local function sumColWidths(colWidths, i)
    local sum = 0
    for j = 1, i do
        sum = sum + colWidths[j]
    end
    return sum
end

-- Vẽ bảng trạng thái từ nhiều acc
local function drawStatusBoard(players)
    clearDrawingObjects() -- Xóa trước khi vẽ mới

    local baseX, baseY = 850, 10 -- Góc trên bên phải (điều chỉnh theo màn hình)
    local rowHeight = 25
    local colWidths = {200, 60, 80, 60, 80} -- Chiều rộng cột
    local headers = {"Username", "CDK", "Mirror", "Valk", "God"}
    local padding = 10 -- Khoảng cách khung so với bảng

    -- Tính chiều cao và chiều rộng của bảng
    local tableWidth = sumColWidths(colWidths, #colWidths - 1) + colWidths[#colWidths]
    local tableHeight = rowHeight * (#players + 1) -- +1 cho header

    -- Vẽ khung trắng
    local frame = Drawing.new("Square")
    frame.Position = Vector2.new(baseX - padding, baseY - padding)
    frame.Size = Vector2.new(tableWidth + 2 * padding, tableHeight + 2 * padding)
    frame.Color = Color3.fromRGB(255, 255, 255) -- Màu trắng
    frame.Thickness = 2 -- Độ dày khung
    frame.Filled = false -- Không tô màu bên trong
    frame.Visible = true
    table.insert(drawingObjects, frame)

    -- Debug dữ liệu nhận được
    rconsoleprint("[DEBUG] Số người chơi nhận được: " .. #players .. "\n")
    for i, player in ipairs(players) do
        rconsoleprint("[DEBUG] Người chơi " .. i .. ": " .. HttpService:JSONEncode(player) .. "\n")
    end

    -- Header
    for i, header in ipairs(headers) do
        local text = Drawing.new("Text")
        text.Text = header
        text.Position = Vector2.new(baseX + sumColWidths(colWidths, i - 1), baseY)
        text.Size = 18
        text.Color = Color3.fromRGB(255, 255, 255)
        text.Outline = true
        text.Visible = true
        table.insert(drawingObjects, text)
    end

    -- Rows
    for row, player in ipairs(players) do
        local y = baseY + row * rowHeight
        local values = {
            player.username or "Unknown",
            player.items and player.items.CDK and "✅" or "❌",
            player.items and player.items.Mirror and "✅" or "❌",
            player.items and player.items.Valk and "✅" or "❌",
            player.items and player.items.Godhuman and "✅" or "❌"
        }

        for i, value in ipairs(values) do
            local text = Drawing.new("Text")
            text.Text = value
            text.Position = Vector2.new(baseX + sumColWidths(colWidths, i - 1), y)
            text.Size = 16
            text.Color = (value == "✅" and Color3.fromRGB(0, 255, 0)) or (value == "❌" and Color3.fromRGB(255, 0, 0)) or Color3.fromRGB(255, 255, 255)
            text.Outline = true
            text.Visible = true
            table.insert(drawingObjects, text)
        end
    end
end

-- Lấy danh sách acc và hiển thị bảng mỗi 30s
spawn(function()
    if not http_request then
        rconsolewarn("[❌ LỖI]: Executor không hỗ trợ http_request")
        return
    end
    while true do
        local success, result = pcall(function()
            local response = http_request({
                Url = "http://192.168.1.37:5000/status",
                Method = "GET"
            })
            if response.Success then
                return response
            else
                error("GET failed: " .. response.StatusCode .. " - " .. response.StatusMessage)
            end
        end)
        if success then
            local players = HttpService:JSONDecode(result.Body)
            drawStatusBoard(players)
        else
            rconsolewarn("[❌ KHÔNG LẤY ĐƯỢC DANH SÁCH ACC]: " .. tostring(result) .. "\n")
        end
        wait(30)
    end
end)
