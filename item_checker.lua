--// CONFIG
local webhookInput = "http://127.0.0.1:5000/"

--// Services
local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local request = http_request or syn and syn.request or http and http.request

--// UI tạo bảng hiện trạng thái item
local function createUI()
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    ScreenGui.Name = "ItemStatusGUI"

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 250, 0, 170)
    Frame.Position = UDim2.new(0, 20, 0, 100)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Name = "StatusFrame"

    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", Frame)
    Title.Text = "🔎 Item Checker by Diep1911"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14

    local items = {
        {"Cursed Dual Katana", "HasCDK"},
        {"Mirror Fractal", "Mirror"},
        {"Valkyrie Helm", "ValkyrieHelm"},
        {"Godhuman", "Style"}
    }

    for i, data in ipairs(items) do
        local label = Instance.new("TextLabel", Frame)
        label.Size = UDim2.new(1, -40, 0, 30)
        label.Position = UDim2.new(0, 10, 0, 30 * i)
        label.Text = data[1]
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left

        local status = Instance.new("Frame", Frame)
        status.Size = UDim2.new(0, 20, 0, 20)
        status.Position = UDim2.new(1, -30, 0, 30 * i + 5)
        status.Name = data[2]
        status.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        Instance.new("UICorner", status).CornerRadius = UDim.new(1, 0)
    end
end

--// Cập nhật màu trạng thái
local function updateUI()
    local Frame = game.CoreGui:FindFirstChild("ItemStatusGUI") and game.CoreGui.ItemStatusGUI:FindFirstChild("StatusFrame")
    if not Frame then return end

    local hasCDK = player.Backpack:FindFirstChild("Cursed Dual Katana") or player.Character:FindFirstChild("Cursed Dual Katana")
    local hasMirror = player.Backpack:FindFirstChild("Mirror Fractal") or player.Character:FindFirstChild("Mirror Fractal")
    local hasHelm = player.Character:FindFirstChild("Valkyrie Helm") or player.Backpack:FindFirstChild("Valkyrie Helm")
    local hasGodHuman = player.Character:FindFirstChild("Godhuman") or player.Backpack:FindFirstChild("Godhuman")

    local function setStatus(name, status)
        local circle = Frame:FindFirstChild(name)
        if circle then
            circle.BackgroundColor3 = status and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end
    end

    setStatus("HasCDK", hasCDK)
    setStatus("Mirror", hasMirror)
    setStatus("ValkyrieHelm", hasHelm)
    setStatus("Style", hasGodHuman)
end

--// Gửi thông tin vào server nội bộ (Flask Bot)
function sendToLocalBot()
    if not request then return warn("❌ Không có http_request") end

    local payload = {
        username = player.Name,
        level = player.Data.Level.Value,
        beli = player.Data.Beli.Value,
        fragment = player.Data.Fragments.Value,
        timestamp = os.time(),
        items = {
            CDK = player.Backpack:FindFirstChild("Cursed Dual Katana") or player.Character:FindFirstChild("Cursed Dual Katana") ~= nil,
            Mirror = player.Backpack:FindFirstChild("Mirror Fractal") or player.Character:FindFirstChild("Mirror Fractal") ~= nil,
            Valk = player.Character:FindFirstChild("Valkyrie Helm") or player.Backpack:FindFirstChild("Valkyrie Helm") ~= nil,
            Godhuman = player.Character:FindFirstChild("Godhuman") or player.Backpack:FindFirstChild("Godhuman") ~= nil
        }
    }

    local ok, body = pcall(function()
        return request({
            Url = webhookInput,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ content = HttpService:JSONEncode(payload) })
        })
    end)

    if not ok then
        warn("Không thể gửi dữ liệu tới bot nội bộ")
    end
end

--// Khởi tạo giao diện
createUI()

--// Vòng lặp cập nhật UI
task.spawn(function()
    while true do
        updateUI()
        wait(3)
    end
end)

--// Gửi thông tin đến Flask bot mỗi 2 phút
task.spawn(function()
    while true do
        sendToLocalBot()
        wait(120)
    end
end)
