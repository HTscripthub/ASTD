-- Load thư viện Fluent UI
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not success then
    warn("Không thể load Fluent UI: " .. tostring(err))
    return
end

-- Lấy tên người chơi để tạo file cấu hình riêng
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerName = LocalPlayer.Name

-- Tạo Window chính
local Window = Fluent:CreateWindow({
    Title = "HT HUB",
    SubTitle = "",
    TabWidth = 80,
    Size = UDim2.fromOffset(300, 220),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tạo Tab Main
local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })

-- Biến lưu trạng thái
local AutoVoteStartEnabled = false
local AutoRetryEnabled = false

-- Hàm tự động lưu cấu hình
local function AutoSaveConfig()
    local config = {
        AutoVoteStart = AutoVoteStartEnabled,
        AutoRetry = AutoRetryEnabled
    }
    
    -- Lưu cấu hình với tên người chơi
    local configName = PlayerName .. "_Config"
    SaveManager:SetLibrary(Fluent)
    SaveManager:SetFolder("HT HUB/" .. PlayerName)
    SaveManager:BuildConfigSection(MainTab)
    
    -- Lưu ngay lập tức
    pcall(function()
        SaveManager:SaveConfig(configName, config)
    end)
end

-- Hàm load cấu hình
local function LoadConfig()
    local configName = PlayerName .. "_Config"
    SaveManager:SetLibrary(Fluent)
    SaveManager:SetFolder("HT HUB/" .. PlayerName)
    
    pcall(function()
        local loadedConfig = SaveManager:LoadConfig(configName)
        if loadedConfig then
            AutoVoteStartEnabled = loadedConfig.AutoVoteStart or false
            AutoRetryEnabled = loadedConfig.AutoRetry or false
        end
    end)
end

-- Tạo Section Auto Play
local AutoPlaySection = MainTab:AddSection("Auto Play")

-- Toggle Auto Vote Start
local AutoVoteStartToggle = AutoPlaySection:AddToggle("AutoVoteStart", {
    Title = "Auto Vote Start",
    Description = "Tự động vote start game",
    Default = AutoVoteStartEnabled,
    Callback = function(Value)
        AutoVoteStartEnabled = Value
        AutoSaveConfig() -- Tự động lưu ngay khi thay đổi
        
        if Value then
            print("Auto Vote Start: Bật")
        else
            print("Auto Vote Start: Tắt")
        end
    end
})

-- Toggle Auto Retry
local AutoRetryToggle = AutoPlaySection:AddToggle("AutoRetry", {
    Title = "Auto Retry",
    Description = "Tự động retry game khi thua",
    Default = AutoRetryEnabled,
    Callback = function(Value)
        AutoRetryEnabled = Value
        AutoSaveConfig() -- Tự động lưu ngay khi thay đổi
        
        if Value then
            print("Auto Retry: Bật")
        else
            print("Auto Retry: Tắt")
        end
    end
})

-- Hàm thực hiện Auto Vote Start
local function ExecuteAutoVoteStart()
    if AutoVoteStartEnabled then
        pcall(function()
            local args = {"StartVoteYes"}
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GameStuff"):FireServer(unpack(args))
        end)
    end
end

-- Hàm thực hiện Auto Retry
local function ExecuteAutoRetry()
    if AutoRetryEnabled then
        pcall(function()
            local args = {{Type = "Game", Index = "Replay", Mode = "Reward"}}
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(args))
        end)
    end
end

-- Hệ thống tự động thực hiện các chức năng
local RunService = game:GetService("RunService")
local lastVoteTime = 0
local lastRetryTime = 0

RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    
    -- Auto Vote Start mỗi 5 giây
    if currentTime - lastVoteTime >= 5 then
        ExecuteAutoVoteStart()
        lastVoteTime = currentTime
    end
    
    -- Auto Retry mỗi 3 giây
    if currentTime - lastRetryTime >= 3 then
        ExecuteAutoRetry()
        lastRetryTime = currentTime
    end
end)

-- Thêm Section Settings
local SettingsSection = MainTab:AddSection("Settings")

-- Button để lưu cấu hình thủ công
SettingsSection:AddButton({
    Title = "Lưu Cấu Hình",
    Description = "Lưu cấu hình hiện tại",
    Callback = function()
        AutoSaveConfig()
        Window:Dialog({
            Title = "Thông Báo",
            Content = "Đã lưu cấu hình thành công!",
            Buttons = {
                {
                    Title = "OK",
                    Callback = function()
                        print("Cấu hình đã được lưu")
                    end
                }
            }
        })
    end
})

-- Button để load cấu hình thủ công
SettingsSection:AddButton({
    Title = "Tải Cấu Hình",
    Description = "Tải cấu hình đã lưu",
    Callback = function()
        LoadConfig()
        
        -- Cập nhật UI với cấu hình đã load
        AutoVoteStartToggle:SetValue(AutoVoteStartEnabled)
        AutoRetryToggle:SetValue(AutoRetryEnabled)
        
        Window:Dialog({
            Title = "Thông Báo",
            Content = "Đã tải cấu hình thành công!",
            Buttons = {
                {
                    Title = "OK",
                    Callback = function()
                        print("Cấu hình đã được tải")
                    end
                }
            }
        })
    end
})

-- Thêm thông tin người chơi
local InfoSection = MainTab:AddSection("Thông Tin")
InfoSection:AddParagraph({
    Title = "Người Chơi",
    Content = "Tên: " .. PlayerName .. "\nCấu hình sẽ được lưu tự động khi thay đổi"
})

-- Setup SaveManager và InterfaceManager
SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("HT HUB/" .. PlayerName)
SaveManager:BuildConfigSection(MainTab)

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("HT HUB/" .. PlayerName)
InterfaceManager:BuildInterfaceSection(MainTab)

-- Load cấu hình khi khởi động
LoadConfig()

-- Cập nhật UI với cấu hình đã load
AutoVoteStartToggle:SetValue(AutoVoteStartEnabled)
AutoRetryToggle:SetValue(AutoRetryEnabled)

-- Thông báo khởi động
Window:Dialog({
    Title = "Chào Mừng",
    Content = "Script đã khởi động thành công!\nTất cả cấu hình sẽ được lưu tự động.",
    Buttons = {
        {
            Title = "OK",
            Callback = function()
                print("Script đã sẵn sàng!")
            end
        }
    }
})

print("=== AUTO SCRIPT LOADED ===")
print("Player: " .. PlayerName)
print("Auto Save: Enabled")
print("=========================")
