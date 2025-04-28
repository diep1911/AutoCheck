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
title.Text = " Item Check - Không "
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

-- Hàm check item tồn tại ở bất kỳ nơi nào
local function hasItem(itemName)
    local foundInBackpack = LocalPlayer.Backpack:FindFirstChild(itemName)
    local foundInCharacter = LocalPlayer.Character:FindFirstChild(itemName)
    local foundInInventory = nil

    -- Kiểm tra trong Inventory (nếu có)
    local inv = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("ItemInventory")
    if inv then
        foundInInventory = inv:FindFirstChild(itemName)
    end

    return foundInBackpack or foundInCharacter or foundInInventory
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
                Url = "http://e0c9-42-119-148-21.ngrok-free.app/",  -- Cập nhật URL Ngrok
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

    -- Nội dung bảng
    for i, player in ipairs(players) do
        local yPos = baseY + rowHeight * i
        for j, header in ipairs(headers) do
            local text = Drawing.new("Text")
            text.Text = player[header] or "" -- Tự động điền các giá trị tương ứng
            text.Position = Vector2.new(baseX + sumColWidths(colWidths, j - 1), yPos)
            text.Size = 16
            text.Color = Color3.fromRGB(255, 255, 255)
            text.Outline = true
            text.Visible = true
            table.insert(drawingObjects, text)
        end
    end
end
