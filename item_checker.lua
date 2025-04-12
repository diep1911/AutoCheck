local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local http_request = http_request or request or (syn and syn.request)

local SERVER_URL = "http://192.168.1.37:5000/" -- Dễ thay đổi

-- Tạo giao diện hiển thị trạng thái vật phẩm cá nhân
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ItemStatusUI"
screenGui.IgnoreGuiInset = true
local success, err = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    warn("[⚠️ LỖI]: Không thể đặt UI vào CoreGui, thử PlayerGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
screenGui.Enabled = true

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Position = UDim2.new(0.95, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0.35, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.5
mainFrame.Visible = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.4

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "✨ Theo Dõi Vật Phẩm - by KHÔNG " .. LocalPlayer.Name
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.Font = Enum.Font.SourceSansPro
title.TextSize = 40
title.TextStrokeTransparency = 0.9
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

local function createItemLabel(name, index)
    local isLeftColumn = index % 2 == 0
    local colOffset = isLeftColumn and 20 or 160
    local rowIndex = math.floor(index / 2)
    local label = Instance.new("TextLabel", mainFrame)
    label.Size = UDim2.new(0.35, 0, 0, 25)
    label.Position = UDim2.new(0, colOffset, 0, 40 + rowIndex * 30)
    label.BackgroundTransparency = 1
    label.Name = name .. "_Label"
    label.Text = name .. ": 🔴"
    label.Font = Enum.Font.SourceSansPro
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 0.9
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Visible = true
    return label
end

local labels = {
    CDK = createItemLabel("CDK", 0),
    Valk = createItemLabel("Valk", 1),
    Mirror = createItemLabel("Mirror", 2),
    Godhuman = createItemLabel("Godhuman", 3)
}

print("[DEBUG] ScreenGui created: ", screenGui:IsA("ScreenGui"))
print("[DEBUG] MainFrame parent: ", mainFrame.Parent.Name)
print("[DEBUG] Title text: ", title.Text)

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

local function getAccountData()
    local data = {
        username = LocalPlayer.Name,
        level = LocalPlayer.Data.Level.Value,
        beli = LocalPlayer.Data.Beli.Value,
        fragment = LocalPlayer.Data.Fragments.Value,
        timestamp = os.time(),
        items = {
            CDK = (LocalPlayer.Backpack:FindFirstChild("Cursed Dual Katana") ~= nil) or (LocalPlayer.Character:FindFirstChild("Cursed Dual Katana") ~= nil),
            Valk = (LocalPlayer.Backpack:FindFirstChild("Valkyrie Helm") ~= nil) or (LocalPlayer.Character:FindFirstChild("Valkyrie Helm") ~= nil),
            Mirror = (LocalPlayer.Backpack:FindFirstChild("Mirror Fractal") ~= nil) or (LocalPlayer.Character:FindFirstChild("Mirror Fractal") ~= nil),
            Godhuman = false -- TODO: Kiểm tra fighting style đúng cách
        }
    }
    rconsoleprint("[DEBUG] Dữ liệu gửi: " .. HttpService:JSONEncode(data) .. "\n")
    return data
end

spawn(function()
    while true do
        local data = getAccountData()
        updateStatusUI(data)
        wait(10)
    end
end)

spawn(function()
    if not http_request then
        rconsolewarn("[❌ LỖI]: Executor không hỗ trợ http_request")
        return
    end
    while true do
        local success, err = pcall(function()
            local data = getAccountData()
            local response = http_request({
                Url = SERVER_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
            if response.Success then
                rconsoleprint("[✅ GỬI]: " .. data.username .. "\n")
            else
                rconsolewarn("[❌ LỖI GỬI]: Status " .. response.StatusCode .. " - " .. response.StatusMessage .. "\n")
            end
        end)
        if not success then
            rconsolewarn("[❌ LỖI]: " .. tostring(err) .. "\n")
        end
        wait(30)
    end
end)

local drawingObjects = {}
local function clearDrawingObjects()
    for _, obj in pairs(drawingObjects) do
        obj:Remove()
    end
    drawingObjects = {}
end

local function drawStatusBoard(players)
    clearDrawingObjects()
    local baseX, baseY = 350, 100
    local rowHeight = 22
    local colWidths = {150, 50, 60, 60, 80}
    local headers = {"Username", "CDK", "Mirror", "Valk", "God"}

    for i, header in ipairs(headers) do
        local text = Drawing.new("Text")
        text.Text = header
        text.Position = Vector2.new(baseX + (i == 1 and 0 or colWidths[i - 1]), baseY)
        text.Size = 16
        text.Color = Color3.fromRGB(255, 255, 255)
        text.Outline = true
        text.Visible = true
        table.insert(drawingObjects, text)
    end

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
            table.insert(drawingObjects, text)
        end
    end
end

spawn(function()
    if not http_request then
        rconsolewarn("[❌ LỖI]: Executor không hỗ trợ http_request")
        return
    end
    while true do
        local success, result = pcall(function()
            local response = http_request({
                Url = SERVER_URL .. "status",
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
