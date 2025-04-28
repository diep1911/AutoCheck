-- Script Lua cho Blox Fruits
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- URL của Flask server
local SERVER_URL = "http://<YOUR_SERVER_IP>:5000/" -- Thay <YOUR_SERVER_IP> bằng IP hoặc domain của server Flask

-- Hàm lấy thông tin người chơi
local function getPlayerInfo()
    local player = Players.LocalPlayer
    if not player then
        return nil
    end

    -- Lấy thông tin cơ bản
    local username = player.Name
    local level = 0
    local beli = 0
    local fragment = 0
    local items = {}

    -- Lấy level (Data của Blox Fruits thường lưu trong PlayerData)
    local playerData = player:FindFirstChild("Data")
    if playerData then
        level = playerData:FindFirstChild("Level") and playerData.Level.Value or 0
        beli = playerData:FindFirstChild("Beli") and playerData.Beli.Value or 0
        fragment = playerData:FindFirstChild("Fragments") and playerData.Fragments.Value or 0
    end

    -- Kiểm tra một số item đặc biệt (Mirror, Valkyrie, CDK)
    -- Đây là ví dụ, cần điều chỉnh theo hệ thống inventory của Blox Fruits
    local inventory = player:FindFirstChild("Inventory") -- Giả sử inventory nằm ở đây
    if inventory then
        items.Mirror = inventory:FindFirstChild("Mirror Fractal") and true or false
        items.Valk = inventory:FindFirstChild("Valkyrie Helm") and true or false
        items.CDK = inventory:FindFirstChild("Cursed Dual Katana") and true or false
    end

    return {
        username = username,
        level = level,
        beli = beli,
        fragment = fragment,
        items = items,
        timestamp = os.time()
    }
end

-- Hàm gửi dữ liệu qua HTTP POST
local function sendDataToServer(data)
    if not data then
        warn("Không thể lấy dữ liệu người chơi")
        return
    end

    local success, response = pcall(function()
        return HttpService:PostAsync(
            SERVER_URL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)

    if success then
        print("Gửi dữ liệu thành công:", response)
    else
        warn("Lỗi khi gửi dữ liệu:", response)
    end
end

-- Hàm chính chạy lặp mỗi 30 giây
local function mainLoop()
    while true do
        local playerInfo = getPlayerInfo()
        sendDataToServer(playerInfo)
        wait(30) -- Gửi mỗi 30 giây để tránh spam server
    end
end

-- Chạy script
spawn(mainLoop)
