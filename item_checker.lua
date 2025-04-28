-- Script Lua cho Blox Fruits (Tối ưu cho Delta)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- URL của Flask server
local SERVER_URL = "http://<YOUR_SERVER_IP>:5000/" -- Thay bằng IP hoặc domain của Flask server

-- Hàm kiểm tra kết nối mạng
local function testConnection()
    local success, response = pcall(function()
        return HttpService:GetAsync("https://www.google.com") -- Test với một URL công khai
    end)
    return success
end

-- Hàm lấy thông tin người chơi
local function getPlayerInfo()
    local player = Players.LocalPlayer
    if not player then
        warn("[ERROR] Không tìm thấy LocalPlayer")
        return nil
    end

    local username = player.Name
    local level = 0
    local beli = 0
    local fragment = 0
    local items = {}

    -- Lấy thông tin từ PlayerData
    local playerData = player:FindFirstChild("Data")
    if playerData then
        local levelObj = playerData:FindFirstChild("Level")
        local beliObj = playerData:FindFirstChild("Beli")
        local fragObj = playerData:FindFirstChild("Fragments")

        level = levelObj and levelObj.Value or 0
        beli = beliObj and beliObj.Value or 0
        fragment = fragObj and fragObj.Value or 0

        print(string.format("[DEBUG] Username: %s, Level: %d, Beli: %d, Fragments: %d", username, level, beli, fragment))
    else
        warn("[ERROR] Không tìm thấy PlayerData")
    end

    -- Kiểm tra items (giả sử inventory nằm trong player hoặc Data)
    -- Cần kiểm tra thực tế trong game
    local inventory = player:FindFirstChild("Inventory") or playerData
    if inventory then
        items.Mirror = inventory:FindFirstChild("Mirror Fractal") and true or false
        items.Valk = inventory:FindFirstChild("Valkyrie Helm") and true or false
        items.CDK = inventory:FindFirstChild("Cursed Dual Katana") and true or false
        print("[DEBUG] Items:", HttpService:JSONEncode(items))
    else
        warn("[ERROR] Không tìm thấy Inventory")
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
        warn("[ERROR] Không có dữ liệu để gửi")
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
        print("[SUCCESS] Gửi dữ liệu thành công:", response)
    else
        warn("[ERROR] Lỗi khi gửi dữ liệu:", response)
    end
end

-- Hàm chính
local function mainLoop()
    -- Kiểm tra kết nối mạng
    if not testConnection() then
        warn("[ERROR] Không thể kết nối mạng. Vui lòng kiểm tra Delta hoặc mạng.")
        return
    end

    while true do
        local playerInfo = getPlayerInfo()
        sendDataToServer(playerInfo)
        wait(30) -- Gửi mỗi 30 giây
    end
end

-- Chạy script
print("[INFO] Bắt đầu chạy script...")
spawn(mainLoop)
