--// Config Webhook
local webhookURL = "https://discord.com/api/webhooks/1360170962540040232/9wvZBXe3aStVhV5iR7ml3Z7YXmouge3a8Z7d6h-3-bjNjk09gEOgT3TYzhGufCYe1NK"

--// Setup
local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local request = http_request or syn and syn.request or http and http.request

--// UI Khung
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ItemCheckerUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.8, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 220, 0, 160)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.2

local Title = Instance.new("TextLabel", Frame)
Title.Text = "💎 AUTO ITEM CHECKER"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local items = {
    {"Cursed Dual Katana", "Cursed Dual Katana"},
    {"Mirror Fractal", "Mirror Fractal"},
    {"Valkyrie Helm", "Valkyrie Helm"},
    {"Godhuman", "Godhuman"}
}

for i, item in ipairs(items) do
    local Label = Instance.new("TextLabel", Frame)
    Label.Position = UDim2.new(0, 10, 0, 30 + (i - 1) * 30)
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local status = Instance.new("Frame", Label)
    status.Size = UDim2.new(0, 15, 0, 15)
    status.Position = UDim2.new(1, -20, 0.5, -7)
    status.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    status.BorderSizePixel = 0
    status.Name = "Status"
    status.BackgroundTransparency = 0.2
    status.ZIndex = 2
    status:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", status).CornerRadius = UDim.new(1, 0)

    Label.Name = item[1]
    Label.Text = "🔍 " .. item[1]
end

--// Check item function
local function checkItems()
    local backpack = player.Backpack:GetChildren()
    local character = player.Character and player.Character:GetChildren() or {}
    local inventory = {}

    for _, item in ipairs(backpack) do table.insert(inventory, item.Name) end
    for _, item in ipairs(character) do table.insert(inventory, item.Name) end

    for _, label in ipairs(Frame:GetChildren()) do
        if label:IsA("TextLabel") and items[label.LayoutOrder] then
            local itemName = label.Name
            local status = label:FindFirstChild("Status")
            if table.find(inventory, itemName) then
                status.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            else
                status.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end

--// Webhook sender
local function sendToDiscord()
    if not request then warn("❌ Không hỗ trợ gửi HTTP.") return end

    local data = {
        ["username"] = "Blox Fruits Logger",
        ["embeds"] = {{
            ["title"] = "📦 Thông Tin Tài Khoản",
            ["color"] = 0x00ff99,
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
                ["text"] = "AutoCheck Script by Diep1911"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    request({
        Url = webhookURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end

--// Auto chạy mỗi phút
task.spawn(function()
    while true do
        checkItems()
        sendToDiscord()
        task.wait(60) -- mỗi 60 giây gửi 1 lần
    end
end)
