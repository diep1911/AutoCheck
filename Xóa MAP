-- Script ẩn toàn bộ đồ họa trong Blox Fruits (client-side)
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Hàm ẩn đối tượng
local function hideObject(obj)
    -- Không ẩn nhân vật của người chơi
    if obj:IsDescendantOf(LocalPlayer.Character) then
        return
    end
    
    if obj:IsA("BasePart") then
        obj.LocalTransparencyModifier = 1 -- Ẩn trên client
        obj.CanCollide = false -- Tắt va chạm
    elseif obj:IsA("Model") then
        for _, part in pairs(obj:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 1
                part.CanCollide = false
            end
        end
    elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
        obj.Transparency = 1
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("Sound") then
        obj.Playing = false
        obj.Volume = 0
    end
end

-- Ẩn tất cả đối tượng hiện tại trong Workspace
for _, obj in pairs(Workspace:GetDescendants()) do
    hideObject(obj)
end

-- Theo dõi và ẩn các đối tượng mới
Workspace.DescendantAdded:Connect(function(obj)
    hideObject(obj)
end)

-- Xóa địa hình
Workspace.Terrain:ClearAllChildren()
Workspace.Terrain.Transparency = 1

-- Tắt các hiệu ứng ánh sáng và đặt màu xám
Lighting.Ambient = Color3.fromRGB(128, 128, 128) -- Màu xám
Lighting.Brightness = 1
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.FogStart = 100000
Lighting.ColorShift_Top = Color3.fromRGB(128, 128, 128)
Lighting.ColorShift_Bottom = Color3.fromRGB(128, 128, 128)

-- Tắt các dịch vụ render không cần thiết
for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") then
        effect.Enabled = false
    end
end

-- Đặt camera để tránh lỗi
local Camera = Workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Custom
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 10, 10))
    end
end)

-- Tắt hiển thị UI nếu cần (bỏ comment nếu muốn ẩn UI)
--[[
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
--]]

-- Tắt các SurfaceGui và BillboardGui
for _, gui in pairs(Workspace:GetDescendants()) do
    if gui:IsA("SurfaceGui") or gui:IsA("BillboardGui") then
        gui.Enabled = false
    end
end
