local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not success then
    warn("Failed to load Fluent UI:", err)
    return
end

-- Hệ thống lưu trữ cấu hình
local ConfigSystem = {}
ConfigSystem.FileName = "HTHubConfig_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    -- Map Settings
}
ConfigSystem.CurrentConfig = {}

-- Hàm để lưu cấu hình
ConfigSystem.SaveConfig = function()
    local success, err = pcall(function()
        writefile(ConfigSystem.FileName, game:GetService("HttpService"):JSONEncode(ConfigSystem.CurrentConfig))
    end)
    if success then
        print("Đã lưu cấu hình thành công!")
    else
        warn("Lưu cấu hình thất bại:", err)
    end
end

-- Hàm để tải cấu hình
ConfigSystem.LoadConfig = function()
    local success, content = pcall(function()
        if isfile(ConfigSystem.FileName) then
            return readfile(ConfigSystem.FileName)
        end
        return nil
    end)
    
    if success and content then
        local data = game:GetService("HttpService"):JSONDecode(content)
        ConfigSystem.CurrentConfig = data
        return true
    else
        ConfigSystem.CurrentConfig = table.clone(ConfigSystem.DefaultConfig)
        ConfigSystem.SaveConfig()
        return false
    end
end

-- Tải cấu hình khi khởi động
ConfigSystem.LoadConfig()

local window = Fluent:CreateWindow({
    Title = "HT Hub",
    SubTitle = "",
    TabWidth = 80,
    Size = UDim2.fromOffset(300, 220),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Lớp Tab
local mainTab = window:AddTab({
    Title = "Main",
    Icon = "home"
})

local settingTab = window:AddTab({
    Title = "Setting",
    Icon = "settings"
})

-- Thêm hỗ trợ Logo khi minimize
repeat task.wait(0.25) until game:IsLoaded()
getgenv().Image = "rbxassetid://13099788281" -- ID tài nguyên hình ảnh logo
getgenv().ToggleUI = "LeftControl" -- Phím để bật/tắt giao diện

-- Tạo logo để mở lại UI khi đã minimize
task.spawn(function()
    local success, errorMsg = pcall(function()
        if not getgenv().LoadedMobileUI == true then 
            getgenv().LoadedMobileUI = true
            local OpenUI = Instance.new("ScreenGui")
            local ImageButton = Instance.new("ImageButton")
            local UICorner = Instance.new("UICorner")
            
            -- Kiểm tra môi trường
            if syn and syn.protect_gui then
                syn.protect_gui(OpenUI)
                OpenUI.Parent = game:GetService("CoreGui")
            elseif gethui then
                OpenUI.Parent = gethui()
            else
                OpenUI.Parent = game:GetService("CoreGui")
            end
            
            OpenUI.Name = "OpenUI"
            OpenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            ImageButton.Parent = OpenUI
            ImageButton.BackgroundColor3 = Color3.fromRGB(105,105,105)
            ImageButton.BackgroundTransparency = 0.8
            ImageButton.Position = UDim2.new(0.9,0,0.1,0)
            ImageButton.Size = UDim2.new(0,50,0,50)
            ImageButton.Image = getgenv().Image
            ImageButton.Draggable = true
            ImageButton.Transparency = 0.2
            
            UICorner.CornerRadius = UDim.new(0,200)
            UICorner.Parent = ImageButton
            
            -- Khi click vào logo sẽ mở lại UI
            ImageButton.MouseButton1Click:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true,getgenv().ToggleUI,false,game)
            end)
        end
    end)
    
    if not success then
        warn("Lỗi khi tạo nút Logo UI: " .. tostring(errorMsg))
    end
end)

-- Settings tab
local SettingsSection = settingTab:AddSection("Script Settings")
-- Integration with SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Lưu cấu hình để sử dụng tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name
InterfaceManager:SetFolder("HTHubASTD")
SaveManager:SetFolder("HTHubASTD/" .. playerName)

-- Auto Save Config - chạy ít thường xuyên hơn
local function AutoSaveConfig()
    spawn(function()
        while wait(5) do -- Lưu mỗi 5 giây
            pcall(function()
                ConfigSystem.SaveConfig()
            end)
        end
    end)
end

-- Thực thi tự động lưu cấu hình
AutoSaveConfig()

-- Thêm thông tin vào tab Settings
settingTab:AddParagraph({
    Title = "Cấu hình tự động",
    Content = "Cấu hình của bạn đang được tự động lưu theo tên nhân vật: " .. playerName
})

settingTab:AddParagraph({
    Title = "Phím tắt",
    Content = "Nhấn LeftControl để ẩn/hiện giao diện"
})

--Tab Main
-- Thêm Section Auto Play vào tab Main
local autoPlaySection = mainTab:AddSection("Auto Play")

-- Thêm biến lưu trạng thái toggle
if ConfigSystem.CurrentConfig.AutoVoteStart == nil then
    ConfigSystem.CurrentConfig.AutoVoteStart = false
end
if ConfigSystem.CurrentConfig.AutoRetry == nil then
    ConfigSystem.CurrentConfig.AutoRetry = false
end

-- Hàm Auto Vote Start
local autoVoteStartConnection
local function handleAutoVoteStart(enabled)
    if autoVoteStartConnection then
        autoVoteStartConnection:Disconnect()
        autoVoteStartConnection = nil
    end
    if enabled then
        autoVoteStartConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local args = {"StartVoteYes"}
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GameStuff"):FireServer(unpack(args))
            end)
            task.wait(2) -- Gửi mỗi 2 giây
        end)
    end
end

-- Hàm Auto Retry
local autoRetryConnection
local function handleAutoRetry(enabled)
    if autoRetryConnection then
        autoRetryConnection:Disconnect()
        autoRetryConnection = nil
    end
    if enabled then
        autoRetryConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local args = {
                {
                    Type = "Game",
                    Index = "Replay",
                    Mode = "Reward"
                }
            }
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(args))
            end)
            task.wait(2) -- Gửi mỗi 2 giây
        end)
    end
end

-- Toggle Auto Vote Start
mainTab:AddToggle("Auto Vote Start", {
    Title = "Auto Vote Start",
    Default = ConfigSystem.CurrentConfig.AutoVoteStart,
    Callback = function(state)
        ConfigSystem.CurrentConfig.AutoVoteStart = state
        ConfigSystem.SaveConfig()
        handleAutoVoteStart(state)
    end
})

-- Toggle Auto Retry
mainTab:AddToggle("Auto Retry", {
    Title = "Auto Retry",
    Default = ConfigSystem.CurrentConfig.AutoRetry,
    Callback = function(state)
        ConfigSystem.CurrentConfig.AutoRetry = state
        ConfigSystem.SaveConfig()
        handleAutoRetry(state)
    end
})

-- Khởi động lại các auto nếu đã bật trong config
handleAutoVoteStart(ConfigSystem.CurrentConfig.AutoVoteStart)
handleAutoRetry(ConfigSystem.CurrentConfig.AutoRetry)
