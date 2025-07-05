-- Load UI Library với error handling
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not success then
    warn("Lỗi khi tải UI Library: " .. tostring(err))
    return
end

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

-- Biến trạng thái cho Auto functions
local AutoVoteEnabled = false
local AutoRetryEnabled = false

-- Tạo Section Auto Play
local AutoPlaySection = MainTab:AddSection("Auto Play")

-- Toggle Auto Vote Start
local AutoVoteToggle = AutoPlaySection:AddToggle("AutoVote", {
    Title = "Auto Vote Start",
    Description = "Tự động bầu chọn bắt đầu",
    Default = false,
    Callback = function(Value)
        AutoVoteEnabled = Value
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
    Description = "Tự động thử lại game",
    Default = false,
    Callback = function(Value)
        AutoRetryEnabled = Value
        if Value then
            print("Auto Retry: Bật")
        else
            print("Auto Retry: Tắt")
        end
    end
})

-- Hàm Auto Vote
local function AutoVote()
    if AutoVoteEnabled then
        local success, err = pcall(function()
            local args = {"StartVoteYes"}
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GameStuff"):FireServer(unpack(args))
        end)
        
        if not success then
            warn("Lỗi Auto Vote: " .. tostring(err))
        end
    end
end

-- Hàm Auto Retry
local function AutoRetry()
    if AutoRetryEnabled then
        local success, err = pcall(function()
            local args = {{
                Type = "Game",
                Index = "Replay",
                Mode = "Reward"
            }}
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(args))
        end)
        
        if not success then
            warn("Lỗi Auto Retry: " .. tostring(err))
        end
    end
end

-- Loop chính cho Auto functions
spawn(function()
    while true do
        wait(1) -- Đợi 1 giây giữa mỗi lần thực hiện
        
        if AutoVoteEnabled then
            AutoVote()
        end
        
        if AutoRetryEnabled then
            AutoRetry()
        end
    end
end)

-- Thiết lập hệ thống lưu trữ cấu hình
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Thiết lập folder lưu trữ
SaveManager:SetFolder("HT HUB")

-- Cấu hình interface manager
InterfaceManager:SetFolder("HT HUB")

-- Tạo tab Settings cho cấu hình
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

-- Thêm save manager vào settings tab
SaveManager:BuildConfigSection(SettingsTab)

-- Thêm interface manager vào settings tab  
InterfaceManager:BuildInterfaceSection(SettingsTab)

-- Tự động lưu cấu hình
SaveManager:LoadAutoloadConfig()

-- Thông báo script đã tải thành công
Fluent:Notify({
    Title = "Script Loaded",
    Content = "HT HUB đã tải thành công!",
    Duration = 5
})

print("Script đã tải thành công!")
print("Sử dụng Left Ctrl để thu nhỏ/mở rộng UI")
