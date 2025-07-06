-- Load MacLib
local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

-- Tạo Window
local Window = MacLib:CreateWindow({
    Title = "Auto Script",
    Subtitle = "by Your Name",
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark"
})

-- Lấy tên người chơi
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerName = LocalPlayer.Name

-- Hệ thống lưu cấu hình
local ConfigFile = PlayerName .. "_config.json"
local DefaultConfig = {
    AutoVoteStart = false,
    AutoRetry = false
}

-- Hàm lưu cấu hình
local function SaveConfig(config)
    local success, result = pcall(function()
        writefile(ConfigFile, game:GetService("HttpService"):JSONEncode(config))
    end)
    if not success then
        warn("Không thể lưu cấu hình: " .. tostring(result))
    end
end

-- Hàm tải cấu hình
local function LoadConfig()
    local success, result = pcall(function()
        if isfile(ConfigFile) then
            local data = readfile(ConfigFile)
            return game:GetService("HttpService"):JSONDecode(data)
        end
        return DefaultConfig
    end)
    
    if success then
        return result
    else
        warn("Không thể tải cấu hình: " .. tostring(result))
        return DefaultConfig
    end
end

-- Tải cấu hình ban đầu
local Config = LoadConfig()

-- Biến điều khiển auto
local AutoVoteStartEnabled = Config.AutoVoteStart
local AutoRetryEnabled = Config.AutoRetry

-- Hàm Auto Vote Start
local function AutoVoteStart()
    if AutoVoteStartEnabled then
        spawn(function()
            while AutoVoteStartEnabled do
                local success, error = pcall(function()
                    local args = {"StartVoteYes"}
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GameStuff"):FireServer(unpack(args))
                end)
                
                if not success then
                    warn("Lỗi Auto Vote Start: " .. tostring(error))
                end
                
                wait(1) -- Delay 1 giây để tránh spam
            end
        end)
    end
end

-- Hàm Auto Retry
local function AutoRetry()
    if AutoRetryEnabled then
        spawn(function()
            while AutoRetryEnabled do
                local success, error = pcall(function()
                    local args = {
                        {
                            Type = "Game",
                            Index = "Replay",
                            Mode = "Reward"
                        }
                    }
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(args))
                end)
                
                if not success then
                    warn("Lỗi Auto Retry: " .. tostring(error))
                end
                
                wait(2) -- Delay 2 giây cho Auto Retry
            end
        end)
    end
end

-- Tạo Tab Main
local MainTab = Window:CreateTab({
    Title = "Main",
    Icon = "play"
})

-- Tạo Section Auto Play
local AutoPlaySection = MainTab:CreateSection({
    Title = "Auto Play",
    Side = "Left"
})

-- Toggle Auto Vote Start
local AutoVoteStartToggle = AutoPlaySection:CreateToggle({
    Title = "Auto Vote Start",
    Description = "Tự động bỏ phiếu bắt đầu game",
    Default = Config.AutoVoteStart,
    Callback = function(state)
        AutoVoteStartEnabled = state
        Config.AutoVoteStart = state
        SaveConfig(Config)
        
        if state then
            AutoVoteStart()
            print("Auto Vote Start: BẬT")
        else
            print("Auto Vote Start: TẮT")
        end
    end
})

-- Toggle Auto Retry
local AutoRetryToggle = AutoPlaySection:CreateToggle({
    Title = "Auto Retry",
    Description = "Tự động thử lại game",
    Default = Config.AutoRetry,
    Callback = function(state)
        AutoRetryEnabled = state
        Config.AutoRetry = state
        SaveConfig(Config)
        
        if state then
            AutoRetry()
            print("Auto Retry: BẬT")
        else
            print("Auto Retry: TẮT")
        end
    end
})

-- Tạo Section thông tin
local InfoSection = MainTab:CreateSection({
    Title = "Thông tin",
    Side = "Right"
})

-- Hiển thị tên người chơi
InfoSection:CreateLabel({
    Title = "Người chơi: " .. PlayerName,
    Description = "Cấu hình được lưu riêng cho tài khoản này"
})

-- Nút lưu cấu hình thủ công
InfoSection:CreateButton({
    Title = "Lưu cấu hình",
    Description = "Lưu cấu hình hiện tại",
    Callback = function()
        SaveConfig(Config)
        print("Đã lưu cấu hình cho " .. PlayerName)
    end
})

-- Nút reset cấu hình
InfoSection:CreateButton({
    Title = "Reset cấu hình",
    Description = "Khôi phục cấu hình mặc định",
    Callback = function()
        Config = DefaultConfig
        SaveConfig(Config)
        
        -- Cập nhật UI
        AutoVoteStartToggle:Set(Config.AutoVoteStart)
        AutoRetryToggle:Set(Config.AutoRetry)
        
        -- Tắt tất cả auto
        AutoVoteStartEnabled = false
        AutoRetryEnabled = false
        
        print("Đã reset cấu hình về mặc định")
    end
})

-- Tự động bật các tính năng nếu đã được lưu
if Config.AutoVoteStart then
    AutoVoteStart()
end

if Config.AutoRetry then
    AutoRetry()
end

-- Lưu cấu hình khi player thoát game
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        SaveConfig(Config)
    end
end)

print("Script đã tải hoàn tất cho " .. PlayerName)
print("Cấu hình được lưu tự động tại: " .. ConfigFile)
