local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🔁 Tự động nhận hàm request phù hợp với executor
local http_request = http_request or request or (syn and syn.request)

-- 🧠 Hàm lấy thông tin tài khoản
local function getAccountData()
    local data = {}

    data.username = LocalPlayer.Name
    data.level = LocalPlayer.Data.Level.Value
    data.beli = LocalPlayer.Data.Beli.Value
    data.fragment = LocalPlayer.Data.Fragments.Value
    data.timestamp = os.time()

    -- 🎯 Kiểm tra các item
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
            local json = HttpService:JSONEncode(data)

            local response = http_request({
                Url = "Url = "http://192.168.1.37:5000/",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = json
            })

            rconsoleprint("[✅ GỬI DỮ LIỆU]: " .. data.username .. "\n")
            rconsoleprint("[📥 SERVER PHẢN HỒI]: " .. tostring(response and response.Body) .. "\n")
        end)

        if not success then
            rconsolewarn("[❌ LỖI]: " .. tostring(err))
        end

        wait(60)
    end
end)
