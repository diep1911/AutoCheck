local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🧠 Hàm lấy thông tin tài khoản
local function getAccountData()
    local data = {}

    data.username = LocalPlayer.Name
    data.level = LocalPlayer.Data.Level.Value
    data.beli = LocalPlayer.Data.Beli.Value
    data.fragment = LocalPlayer.Data.Fragments.Value
    data.timestamp = os.time()

    -- 🎯 Kiểm tra các item (true nếu có)
    data.items = {
        CDK = (LocalPlayer.Backpack:FindFirstChild("Cursed Dual Katana") ~= nil) or (LocalPlayer.Character:FindFirstChild("Cursed Dual Katana") ~= nil),
        Valk = (LocalPlayer.Backpack:FindFirstChild("Valkyrie Helm") ~= nil) or (LocalPlayer.Character:FindFirstChild("Valkyrie Helm") ~= nil),
        Mirror = (LocalPlayer.Backpack:FindFirstChild("Mirror Fractal") ~= nil) or (LocalPlayer.Character:FindFirstChild("Mirror Fractal") ~= nil),
        Godhuman = (LocalPlayer.Backpack:FindFirstChild("Godhuman") ~= nil) or (LocalPlayer.Character:FindFirstChild("Godhuman") ~= nil)
    }

    return data
end

-- 🔁 Gửi thông tin liên tục mỗi 60 giây
spawn(function()
    while true do
        local success, err = pcall(function()
            local data = getAccountData()

            http_request({
                Url = "http://127.0.0.1:5000/", -- hoặc đổi thành IP LAN/ngrok nếu cần
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(data) -- ✅ KHÔNG bọc trong "content"
            })

            rconsoleprint("[✅ GỬI DỮ LIỆU]: " .. data.username .. "\n")
        end)

        if not success then
            rconsolewarn("[❌ LỖI]: " .. tostring(err))
        end

        wait(60) -- ⏳ gửi mỗi 60 giây
    end
end)
