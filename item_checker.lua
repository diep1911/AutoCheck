local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local http_request = http_request or request or (syn and syn.request)

-- Tạo giao diện hiển thị trạng thái vật phẩm cá nhân
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ItemStatusUI"
screenGui.IgnoreGuiInset = true -- Đảm bảo sử dụng toàn bộ màn hình
screenGui.Parent = game:GetService("CoreGui") -- Đặt Parent sau khi tạo để tránh lỗi
screenGui.Enabled = true -- Bật GUI ngay lập tức

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Position = UDim2.new(0.2, 0, 0, 0) -- Căn giữa ngang, trên cùng
mainFrame.Size = UDim2.new(0.6, 0, 0.3, 0) -- Rộng 60%, cao 30%
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Màu vàng
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.1
mainFrame.Visible = true -- Đảm bảo khung hiển thị
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5) -- Đặt lại vị trí để chắc chắn
title.BackgroundTransparency = 1
title.Text = "📦 Theo Dõi Vật Phẩm - " .. LocalPlayer.Name
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamSemibold
title.TextSize = 20
title.TextStrokeTransparency = 0.8
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Hàm tạo nhãn cho từng vật phẩm
local function createItemLabel(name, index)
    local label = Instance.new("TextLabel", mainFrame)
    label.Size = UDim2.new(0.45, -20, 0, 25)
    label.Position = UDim2.new(0, 20, 0, 40 + index * 30)
    label.BackgroundTransparency = 1
    label.Name = name .. "_Label"
    label.Text = name .. ": 🔴"
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 0.8
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Visible = true
    return label
end

-- Tạo danh sách nhãn vật phẩm
local labels = {
    CDK = createItemLabel("CDK", 0),
    Valk = createItemLabel("Valk", 1),
    Mirror = createItemLabel("Mirror", 2),
    Godhuman = createItemLabel("Godhuman", 3)
}

-- Debug để kiểm tra GUI
print("[DEBUG] ScreenGui created: ", screenGui:IsA("ScreenGui"))
print("[DEBUG] MainFrame parent: ", mainFrame.Parent.Name)
print("[DEBUG] Title text: ", title.Text)

-- Hàm cập nhật giao diện trạng thái
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

-- Hàm lấy thông tin tài khoản
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
                Url = "http://192.168.1.37:5000/status",
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
