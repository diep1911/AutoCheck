local webhookURL = "https://discord.com/api/webhooks/1360170962540040232/9wvZBXe3aStVhV5iR7ml3Z7YXmouge3a8Z7d6h-3-bjNjk09gEOgT3TYzhGufCYe1NKm" -- Thay link webhook tại đây

local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Gửi thông tin về Discord
local function sendToDiscord()
    local data = {
        ["username"] = "Blox Fruits Logger",
        ["embeds"] = {{
            ["title"] = "📦 Thông Tin Tài Khoản",
            ["color"] = 0x3498db,
            ["fields"] = {
                {
                    ["name"] = "👤 Tên tài khoản",
                    ["value"] = player.Name,
                    ["inline"] = true
                },
                {
                    ["name"] = "🧬 Level",
                    ["value"] = tostring(player.Data.Level.Value),
                    ["inline"] = true
                },
                {
                    ["name"] = "💰 Beli",
                    ["value"] = tostring(player.Data.Beli.Value),
                    ["inline"] = true
                },
                {
                    ["name"] = "💎 Fragments",
                    ["value"] = tostring(player.Data.Fragments.Value),
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = "Gửi từ AutoCheck Script 🌐"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local jsonData = HttpService:JSONEncode(data)

    syn.request({
        Url = webhookURL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = jsonData
    })
end

sendToDiscord()

-- Hàm kiểm tra item
local function HasItem(item)
    for _, v in pairs(player.Backpack:GetChildren()) do
        if v.Name == item then return true end
    end
    for _, v in pairs(player.Character:GetChildren()) do
        if v.Name == item then return true end
    end
    return false
end

-- Hàm kiểm tra Godhuman
local function HasGodHuman()
    return player.Character:FindFirstChild("Godhuman") or player.Backpack:FindFirstChild("Godhuman")
end

-- Giao diện
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ItemCheckGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.75, 0, 0.2, 0)
Frame.Size = UDim2.new(0, 300, 0, 180)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.2

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Tạo 1 dòng hiện item
local function CreateItemRow(name, has)
    local row = Instance.new("Frame", Frame)
    row.Size = UDim2.new(1, -20, 0, 25)
    row.BackgroundTransparency = 1

    local dot = Instance.new("Frame", row)
    dot.Size = UDim2.new(0, 20, 0, 20)
    dot.Position = UDim2.new(0, 0, 0.1, 0)
    dot.BackgroundColor3 = has and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    dot.BorderSizePixel = 0
    dot.BackgroundTransparency = 0
    dot.Name = "StatusDot"

    local dotCorner = Instance.new("UICorner", dot)
    dotCorner.CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel", row)
    label.Text = name
    label.Position = UDim2.new(0, 30, 0, 0)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
end

-- Thêm từng dòng item
CreateItemRow("Cursed Dual Katana", HasItem("Cursed Dual Katana"))
CreateItemRow("Mirror Fractal", HasItem("Mirror Fractal"))
CreateItemRow("Valkyrie Helm", HasItem("Valkyrie Helm"))
CreateItemRow("Godhuman", HasGodHuman())
