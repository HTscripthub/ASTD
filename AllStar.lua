-- Load UI Library với error handling
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not success then
    warn("Lỗi khi tải UI Library: " .. tostring(err))
    return
end

-- Đợi đến khi Fluent được tải hoàn tất
if not Fluent then
    warn("Không thể tải thư viện Fluent!")
    return
end

-- Hệ thống lưu trữ cấu hình
local ConfigSystem = {}
ConfigSystem.FileName = "HTHubAllStar_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    --Tab Main
    -- Auto Play Settings
    AutoVoteEnabled = false,
    AutoRetryEnabled = false,
    AutoSkipEnabled = false,
    AutoNextEnabled = false,
    AutoLeaveEnabled = false,
    -- Speed Settings
    SpeedEnabled = false,
    SelectedSpeed = 2,

    --Tab Map
    -- Story Settings
    SelectedMap = "World1",
    SelectedChapter = 1,
    SelectedDifficulty = "Normal",
    AutoJoinEnabled = false,
    --Challenge Settings
    SelectedChallenge = "Challenge1",
    SelectedChallengeDifficulty = "Normal",
    SelectedChallengeMethod = "Start",
    AutoJoinChallengeEnabled = false,

    --Tab Auto Place - Unit Place Settings
    AutoPlaceEnabled = false,
    SelectedPlaceMethod = "first", -- Default to first

    --Tab Auto Place - Upgrade Settings
    AutoUpgradeEnabled = false,

    --Tab Auto Place - Sell Settings
    AutoSellEnabled = false,
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

-- Biến lưu trạng thái của tab Main
local autoVoteEnabled = ConfigSystem.CurrentConfig.AutoVoteEnabled or false
local autoRetryEnabled = ConfigSystem.CurrentConfig.AutoRetryEnabled or false
local autoSkipEnabled = ConfigSystem.CurrentConfig.AutoSkipEnabled or false
local autoNextEnabled = ConfigSystem.CurrentConfig.AutoNextEnabled or false
local autoLeaveEnabled = ConfigSystem.CurrentConfig.AutoLeaveEnabled or false
local speedEnabled = ConfigSystem.CurrentConfig.SpeedEnabled or false
local selectedSpeed = ConfigSystem.CurrentConfig.SelectedSpeed or 2

-- Biến Lưu trạng thái của tab Map
local selectedMap = ConfigSystem.CurrentConfig.SelectedMap or "World1"
local selectedChapter = ConfigSystem.CurrentConfig.SelectedChapter or 1
local selectedDifficulty = ConfigSystem.CurrentConfig.SelectedDifficulty or "Normal"
local autoJoinEnabled = ConfigSystem.CurrentConfig.AutoJoinEnabled or false
local selectedChallenge = ConfigSystem.CurrentConfig.SelectedChallenge or "Challenge1"
local selectedChallengeDifficulty = ConfigSystem.CurrentConfig.SelectedChallengeDifficulty or "Normal"
local selectedChallengeMethod = ConfigSystem.CurrentConfig.SelectedChallengeMethod or "Start"
local autoJoinChallengeEnabled = ConfigSystem.CurrentConfig.AutoJoinChallengeEnabled or false

-- Biến Lưu trạng thái của tab Auto Place
local autoPlaceEnabled = ConfigSystem.CurrentConfig.AutoPlaceEnabled or false
local selectedPlaceMethod = ConfigSystem.CurrentConfig.SelectedPlaceMethod or "first"

-- Biến Lưu trạng thái của tab Auto Place - Upgrade
local autoUpgradeEnabled = ConfigSystem.CurrentConfig.AutoUpgradeEnabled or false

-- Biến Lưu trạng thái của tab Auto Place - Sell
local autoSellEnabled = ConfigSystem.CurrentConfig.AutoSellEnabled or false

-- Lấy tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name

-- Cấu hình UI
local Window = Fluent:CreateWindow({
    Title = "HT HUB | All Star Tower Defense",
    SubTitle = "",
    TabWidth = 80,
    Size = UDim2.fromOffset(300, 220),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Hệ thống Tạo Tab

-- Tạo Tab Main
local MainTab = Window:AddTab({ Title = "Main", Icon = "rbxassetid://13311802307" })

-- Tạo Tab Map
local MapTab = Window:AddTab({ Title = "Map", Icon = "rbxassetid://13311804137" })

-- Tạo Tab Auto Place
local AutoPlaceTab = Window:AddTab({ Title = "Auto Place", Icon = "rbxassetid://13311805545" })

-- Tạo Tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://13311798537" })

-- Tab Main ( Tab thứ 1 )
-- Section Auto Play trong tab Main
local AutoPlaySection = MainTab:AddSection("Auto Play")

-- Section Speed trong tab Main
local SpeedSection = MainTab:AddSection("Speed")

-- Hàm Auto Vote Start
local function executeAutoVote()
    if autoVoteEnabled then
        local success, err = pcall(function()
            local args = { "StartVoteYes" }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GameStuff"):FireServer(unpack(
                args))
        end)

        if not success then
            warn("Lỗi Auto Vote: " .. tostring(err))
        else
            print("Auto Vote executed successfully")
        end
    end
end


-- Hàm Auto Retry
local function executeAutoRetry()
    if autoRetryEnabled then
        local success, err = pcall(function()
            local args = { {
                Type = "Game",
                Index = "Replay",
                Mode = "Reward"
            } }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(
                args))
        end)

        if not success then
            warn("Lỗi Auto Retry: " .. tostring(err))
        else
            print("Auto Retry executed successfully")
        end
    end
end

-- Hàm Auto Skip
local function executeAutoSkip()
    if autoSkipEnabled then
        local success, err = pcall(function()
            local args = { "SkipVoteYes" }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GameStuff"):FireServer(unpack(
                args))
        end)

        if not success then
            warn("Lỗi Auto Skip: " .. tostring(err))
        else
            print("Auto Skip executed successfully")
        end
    end
end

-- Hàm Auto Next
local function executeAutoNext()
    if autoNextEnabled then
        local success, err = pcall(function()
            local args = { {
                Type = "Game",
                Index = "Level",
                Mode = "Reward"
            } }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(
                args))
        end)

        if not success then
            warn("Lỗi Auto Next: " .. tostring(err))
        else
            print("Auto Next executed successfully")
        end
    end
end

-- Hàm Auto Leave
local function executeAutoLeave()
    if autoLeaveEnabled then
        local success, err = pcall(function()
            local args = { {
                Type = "Game",
                Index = "Return",
                Mode = "Reward"
            } }
            game:GetService("ReplicatedStorage").Remotes.GetFunction:InvokeServer(unpack(args))
        end)

        if not success then
            warn("Lỗi Auto Leave: " .. tostring(err))
        else
            print("Auto Leave executed successfully")
        end
    end
end

-- Hàm Speed
local function executeSpeed()
    if not speedEnabled then return end

    local success, err = pcall(function()
        local args = {{
            Index = selectedSpeed,
            Type = "Speed"
        }}
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(args))
    end)

    if not success then
        warn("Lỗi Speed: " .. tostring(err))
    else
        print("Speed executed successfully - Speed: " .. selectedSpeed)
    end
end

-- Hàm Auto Join Challenge
local function executeAutoJoinChallenge()
    if not autoJoinChallengeEnabled then return end

    local success, err = pcall(function()
        -- Bước 1: Tương tác với Challenge Pod
        local args1 = {
            {
                Type = "Lobby",
                Object = workspace:WaitForChild("Map"):WaitForChild("Buildings"):WaitForChild("ChallengePods"):WaitForChild("Pod"):WaitForChild("Interact"),
                Mode = "Pod"
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(args1))

        task.wait(1) -- Đợi 1 giây giữa các bước

        -- Bước 2: Chọn challenge và difficulty
        local args2 = {
            {
                Chapter = 1, -- Chapter is always 1 for challenges
                Type = "Lobby",
                Name = selectedChallenge,
                Difficulty = selectedChallengeDifficulty,
                Mode = "Pod",
                Friend = false,
                Update = true
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(args2))

        task.wait(1) -- Đợi 1 giây giữa các bước

        -- Bước 3: Start hoặc Find Team
        if selectedChallengeMethod == "Start" then
            local args3 = {
                {
                    Start = true,
                    Type = "Lobby",
                    Update = true,
                    Mode = "Pod"
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(args3))
        elseif selectedChallengeMethod == "Find Team" then
            local args3 = {
                {
                    Mode = "Pod",
                    Type = "Lobby",
                    Matchmake = true,
                    Update = true
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(args3))
        end
    end)

    if not success then
        warn("Lỗi Auto Join Challenge: " .. tostring(err))
    else
        print("Auto Join Challenge executed successfully - Challenge: " ..
            selectedChallenge .. ", Difficulty: " .. selectedChallengeDifficulty .. ", Method: " .. selectedChallengeMethod)
    end
end

-- Hàm Auto Place
local function executeAutoPlace()
    if not autoPlaceEnabled then return end

    local success, err = pcall(function()
        local attackVFXFolder = game:GetService("ReplicatedStorage"):WaitForChild("AttackVFX")
        local units = attackVFXFolder:GetChildren()

        if #units == 0 then
            warn("Không tìm thấy đơn vị nào trong AttackVFX.")
            return
        end

        local targetCFrame
        if selectedPlaceMethod == "first" then
            targetCFrame = workspace.Paths["1"]["3"].CFrame
        elseif selectedPlaceMethod == "mid" then
            targetCFrame = workspace.Paths["1"]["7"].CFrame
        elseif selectedPlaceMethod == "last" then
            targetCFrame = workspace.Paths["1"]["11"].CFrame
        else
            warn("Phương thức đặt không hợp lệ: " .. selectedPlaceMethod)
            return
        end

        -- Đặt tất cả các đơn vị trong thư mục AttackVFX
        for i, unit in ipairs(units) do
            local offsetX = math.random() * 20 - 10 -- Tăng phạm vi offset lên -10 đến 10
            local offsetZ = math.random() * 20 - 10 -- Tăng phạm vi offset lên -10 đến 10
            local placeCFrame = targetCFrame * CFrame.new(offsetX, 0, offsetZ)
            local args = { "GameStuff", { "Summon", unit.Name, placeCFrame } }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SetEvent"):FireServer(unpack(args))
            task.wait(0.5) -- Đợi một chút giữa các lần đặt để tránh spam
        end
        print("Auto Place executed successfully.")
    end)

    if not success then
        warn("Lỗi Auto Place: " .. tostring(err))
    end
end

-- Hàm Auto Upgrade
local function executeAutoUpgrade()
    if not autoUpgradeEnabled then return end

    local success, err = pcall(function()
        local attackVFXFolder = game:GetService("ReplicatedStorage"):WaitForChild("AttackVFX")
        local upgradeableUnits = {}

        -- Lấy danh sách các đơn vị có thể nâng cấp từ AttackVFX
        for _, unit in ipairs(attackVFXFolder:GetChildren()) do
            table.insert(upgradeableUnits, unit.Name)
        end

        -- Quét các đơn vị đã đặt trong UnitFolder và nâng cấp chúng
        for _, unitInFolder in ipairs(workspace:WaitForChild("UnitFolder"):GetChildren()) do
            if table.find(upgradeableUnits, unitInFolder.Name) then
                local args = {
                    {
                        Type = "GameStuff"
                    },
                    {
                        "Upgrade",
                        unitInFolder
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(args))
                task.wait(0.2) -- Đợi một chút giữa các lần nâng cấp để tránh spam
            end
        end
        print("Auto Upgrade executed successfully.")
    end)

    if not success then
        warn("Lỗi Auto Upgrade: " .. tostring(err))
    end
end

-- Hàm Auto Sell
local function executeAutoSell()
    if not autoSellEnabled then return end

    local success, err = pcall(function()
        -- Quét tất cả các đơn vị trong UnitFolder và bán chúng
        for _, unitInFolder in ipairs(workspace:WaitForChild("UnitFolder"):GetChildren()) do
            local args = {
                {
                    Type = "GameStuff"
                },
                {
                    "Sell",
                    unitInFolder
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(args))
            task.wait(0.2) -- Đợi một chút giữa các lần bán để tránh spam
        end
        print("Auto Sell executed successfully.")
    end)

    if not success then
        warn("Lỗi Auto Sell: " .. tostring(err))
    end
end

-- Toggle Auto Vote Start
AutoPlaySection:AddToggle("AutoVoteToggle", {
    Title = "Auto Vote Start",
    Description = "",
    Default = ConfigSystem.CurrentConfig.AutoVoteEnabled or false,
    Callback = function(Value)
        autoVoteEnabled = Value
        ConfigSystem.CurrentConfig.AutoVoteEnabled = Value
        ConfigSystem.SaveConfig()

        if autoVoteEnabled then
            Fluent:Notify({
                Title = "Auto Vote Start Enabled",
                Content = "Đã bật tự động bầu chọn bắt đầu",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Vote Start Disabled",
                Content = "Đã tắt tự động bầu chọn bắt đầu",
                Duration = 3
            })
        end
    end
})

-- Toggle Auto Retry
AutoPlaySection:AddToggle("AutoRetryToggle", {
    Title = "Auto Retry",
    Description = "",
    Default = ConfigSystem.CurrentConfig.AutoRetryEnabled or false,
    Callback = function(Value)
        autoRetryEnabled = Value
        ConfigSystem.CurrentConfig.AutoRetryEnabled = Value
        ConfigSystem.SaveConfig()

        if autoRetryEnabled then
            Fluent:Notify({
                Title = "Auto Retry Enabled",
                Content = "Đã bật tự động thử lại game",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Retry Disabled",
                Content = "Đã tắt tự động thử lại game",
                Duration = 3
            })
        end
    end
})

-- Toggle Auto Skip
AutoPlaySection:AddToggle("AutoSkipToggle", {
    Title = "Auto Skip",
    Description = "",
    Default = ConfigSystem.CurrentConfig.AutoSkipEnabled or false,
    Callback = function(Value)
        autoSkipEnabled = Value
        ConfigSystem.CurrentConfig.AutoSkipEnabled = Value
        ConfigSystem.SaveConfig()

        if autoSkipEnabled then
            Fluent:Notify({
                Title = "Auto Skip Enabled",
                Content = "Đã bật tự động bỏ qua lượt",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Skip Disabled",
                Content = "Đã tắt tự động bỏ qua lượt",
                Duration = 3
            })
        end
    end
})

-- Toggle Auto Next
AutoPlaySection:AddToggle("AutoNextToggle", {
    Title = "Auto Next",
    Description = "",
    Default = ConfigSystem.CurrentConfig.AutoNextEnabled or false,
    Callback = function(Value)
        autoNextEnabled = Value
        ConfigSystem.CurrentConfig.AutoNextEnabled = Value
        ConfigSystem.SaveConfig()

        if autoNextEnabled then
            Fluent:Notify({
                Title = "Auto Next Enabled",
                Content = "Đã bật tự động chuyển màn tiếp theo",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Next Disabled",
                Content = "Đã tắt tự động chuyển màn tiếp theo",
                Duration = 3
            })
        end
    end
})

-- Toggle Auto Leave
AutoPlaySection:AddToggle("AutoLeaveToggle", {
    Title = "Auto Leave",
    Description = "",
    Default = ConfigSystem.CurrentConfig.AutoLeaveEnabled or false,
    Callback = function(Value)
        autoLeaveEnabled = Value
        ConfigSystem.CurrentConfig.AutoLeaveEnabled = Value
        ConfigSystem.SaveConfig()

        if autoLeaveEnabled then
            Fluent:Notify({
                Title = "Auto Leave Enabled",
                Content = "Đã bật tự động rời trận",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Leave Disabled",
                Content = "Đã tắt tự động rời trận",
                Duration = 3
            })
        end
    end
})

-- Dropdown Choose Speed
SpeedSection:AddDropdown("ChooseSpeedDropdown", {
    Title = "Speed",
    Description = "",
    Values = { "2", "3" },
    Multi = false,
    Default = tostring(selectedSpeed),
    Callback = function(Value)
        selectedSpeed = tonumber(Value)
        ConfigSystem.CurrentConfig.SelectedSpeed = selectedSpeed
        ConfigSystem.SaveConfig()

        print("Đã chọn tốc độ: " .. selectedSpeed)
    end
})

-- Toggle Enable Speed
SpeedSection:AddToggle("EnableSpeedToggle", {
    Title = "Enable Speed",
    Description = "",
    Default = ConfigSystem.CurrentConfig.SpeedEnabled or false,
    Callback = function(Value)
        speedEnabled = Value
        ConfigSystem.CurrentConfig.SpeedEnabled = Value
        ConfigSystem.SaveConfig()

        if speedEnabled then
            Fluent:Notify({
                Title = "Speed Enabled",
                Content = "Đã bật tốc độ",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Speed Disabled",
                Content = "Đã tắt tốc độ",
                Duration = 3
            })
        end
    end
})

-- Tab Map ( Tab thứ 2 )
-- Section Story trong tab Map
local StorySection = MapTab:AddSection("Story")

-- Section Challenge trong tab Map
local ChallengeSection = MapTab:AddSection("Challenge")

-- Dropdown Choose Map
local MapDropdown = StorySection:AddDropdown("MapDropdown", {
    Title = "Map",
    Description = "",
    Values = {
        "Innovation Island",
        "City Of Voldstandig",
        "Future City",
        "Hidden Storm Village"
    },
    Multi = false,
    Default = selectedMap == "World1" and "Innovation Island" or
        selectedMap == "World2" and "City Of Voldstandig" or
        selectedMap == "World3" and "Future City" or
        selectedMap == "World4" and "Hidden Storm Village" or
        "Innovation Island",
    Callback = function(Value)
        if Value == "Innovation Island" then
            selectedMap = "World1"
        elseif Value == "City Of Voldstandig" then
            selectedMap = "World2"
        elseif Value == "Future City" then
            selectedMap = "World3"
        elseif Value == "Hidden Storm Village" then
            selectedMap = "World4"
        end

        ConfigSystem.CurrentConfig.SelectedMap = selectedMap
        ConfigSystem.SaveConfig()

        print("Đã chọn map: " .. selectedMap)
    end
})

-- Dropdown Choose Chapter
local ChapterDropdown = StorySection:AddDropdown("ChapterDropdown", {
    Title = "Chapter",
    Description = "",
    Values = { "1", "2", "3", "4", "5", "6", "7" },
    Multi = false,
    Default = tostring(selectedChapter),
    Callback = function(Value)
        selectedChapter = tonumber(Value)
        ConfigSystem.CurrentConfig.SelectedChapter = selectedChapter
        ConfigSystem.SaveConfig()

        print("Đã chọn chapter: " .. selectedChapter)
    end
})

-- Dropdown Choose Difficulty
local DifficultyDropdown = StorySection:AddDropdown("DifficultyDropdown", {
    Title = "Difficulty",
    Description = "",
    Values = { "Normal", "Hard" },
    Multi = false,
    Default = selectedDifficulty,
    Callback = function(Value)
        selectedDifficulty = Value
        ConfigSystem.CurrentConfig.SelectedDifficulty = selectedDifficulty
        ConfigSystem.SaveConfig()

        print("Đã chọn độ khó: " .. selectedDifficulty)
    end
})

-- Hàm Auto Join Story
local function executeAutoJoin()
    if not autoJoinEnabled then return end

    local success, err = pcall(function()
        -- Bước 1: Tương tác với Story Pod
        local args1 = {
            {
                Type = "Lobby",
                Object = workspace:WaitForChild("Map"):WaitForChild("Buildings"):WaitForChild("Pods"):WaitForChild(
                    "StoryPod"):WaitForChild("Interact"),
                Mode = "Pod"
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(
            args1))

        wait(1) -- Đợi 1 giây giữa các bước

        -- Bước 2: Chọn map, chapter và difficulty
        local args2 = {
            {
                Chapter = selectedChapter,
                Type = "Lobby",
                Name = selectedMap,
                Difficulty = selectedDifficulty,
                Mode = "Pod",
                Friend = false,
                Update = true
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(
            args2))

        wait(1) -- Đợi 1 giây giữa các bước

        -- Bước 3: Bắt đầu game
        local args3 = {
            {
                Start = true,
                Type = "Lobby",
                Update = true,
                Mode = "Pod"
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer(unpack(
            args3))
    end)

    if not success then
        warn("Lỗi Auto Join: " .. tostring(err))
    else
        print("Auto Join executed successfully - Map: " ..
            selectedMap .. ", Chapter: " .. selectedChapter .. ", Difficulty: " .. selectedDifficulty)
    end
end

-- Toggle Auto Join
StorySection:AddToggle("AutoJoinToggle", {
    Title = "Auto Join",
    Description = "",
    Default = ConfigSystem.CurrentConfig.AutoJoinEnabled or false,
    Callback = function(Value)
        autoJoinEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinEnabled = Value
        ConfigSystem.SaveConfig()

        if autoJoinEnabled then
            Fluent:Notify({
                Title = "Auto Join Enabled",
                Content = "Đã bật tự động tham gia game",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Join Disabled",
                Content = "Đã tắt tự động tham gia game",
                Duration = 3
            })
        end
    end
})

-- Dropdown Choose Challenge
ChallengeSection:AddDropdown("ChooseChallengeDropdown", {
    Title = "Challenge",
    Description = "",
    Values = { "Flying Enemies", "Single Placement", "Unsellable" },
    Multi = false,
    Default = selectedChallenge == "Challenge1" and "Flying Enemies" or
              selectedChallenge == "Challenge4" and "Single Placement" or
              selectedChallenge == "Challenge3" and "Unsellable" or
              "Flying Enemies",
    Callback = function(Value)
        if Value == "Flying Enemies" then
            selectedChallenge = "Challenge1"
        elseif Value == "Single Placement" then
            selectedChallenge = "Challenge4"
        elseif Value == "Unsellable" then
            selectedChallenge = "Challenge3"
        end
        ConfigSystem.CurrentConfig.SelectedChallenge = selectedChallenge
        ConfigSystem.SaveConfig()
        print("Đã chọn thử thách: " .. selectedChallenge)
    end
})

-- Dropdown Choose Difficulty (Challenge)
ChallengeSection:AddDropdown("ChooseChallengeDifficultyDropdown", {
    Title = "Difficulty",
    Description = "",
    Values = { "Normal", "Hard" },
    Multi = false,
    Default = selectedChallengeDifficulty,
    Callback = function(Value)
        selectedChallengeDifficulty = Value
        ConfigSystem.CurrentConfig.SelectedChallengeDifficulty = selectedChallengeDifficulty
        ConfigSystem.SaveConfig()
        print("Đã chọn độ khó thử thách: " .. selectedChallengeDifficulty)
    end
})

-- Dropdown Method
ChallengeSection:AddDropdown("MethodDropdown", {
    Title = "Method",
    Description = "",
    Values = { "Start", "Find Team" },
    Multi = false,
    Default = selectedChallengeMethod,
    Callback = function(Value)
        selectedChallengeMethod = Value
        ConfigSystem.CurrentConfig.SelectedChallengeMethod = selectedChallengeMethod
        ConfigSystem.SaveConfig()
        print("Đã chọn phương thức: " .. selectedChallengeMethod)
    end
})

-- Toggle Auto Join Challenge
ChallengeSection:AddToggle("AutoJoinChallengeToggle", {
    Title = "Auto Join",
    Description = "",
    Default = ConfigSystem.CurrentConfig.AutoJoinChallengeEnabled or false,
    Callback = function(Value)
        autoJoinChallengeEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinChallengeEnabled = Value
        ConfigSystem.SaveConfig()
        if autoJoinChallengeEnabled then
            Fluent:Notify({
                Title = "Auto Join Challenge Enabled",
                Content = "Đã bật tự động tham gia thử thách",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Join Challenge Disabled",
                Content = "Đã tắt tự động tham gia thử thách",
                Duration = 3
            })
        end
    end
})

-- Tab Auto Place ( Tab thứ 3 )
-- Section Unit Place trong tab Auto Place
local UnitPlaceSection = AutoPlaceTab:AddSection("Unit Place")

-- Section Upgrade trong tab Auto Place
local UpgradeSection = AutoPlaceTab:AddSection("Upgrade")

-- Section Sell trong tab Auto Place
local SellSection = AutoPlaceTab:AddSection("Sell")

-- Dropdown Method (Unit Place)
UnitPlaceSection:AddDropdown("PlaceMethodDropdown", {
    Title = "Method",
    Description = "Chọn vị trí đặt đơn vị",
    Values = { "first", "mid", "last" },
    Multi = false,
    Default = selectedPlaceMethod,
    Callback = function(Value)
        selectedPlaceMethod = Value
        ConfigSystem.CurrentConfig.SelectedPlaceMethod = selectedPlaceMethod
        ConfigSystem.SaveConfig()
        print("Đã chọn phương thức đặt: " .. selectedPlaceMethod)
    end
})

-- Toggle Auto Place
UnitPlaceSection:AddToggle("AutoPlaceToggle", {
    Title = "Auto Place",
    Description = "Tự động đặt đơn vị",
    Default = ConfigSystem.CurrentConfig.AutoPlaceEnabled or false,
    Callback = function(Value)
        autoPlaceEnabled = Value
        ConfigSystem.CurrentConfig.AutoPlaceEnabled = Value
        ConfigSystem.SaveConfig()
        if autoPlaceEnabled then
            Fluent:Notify({
                Title = "Auto Place Enabled",
                Content = "Đã bật tự động đặt đơn vị",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Place Disabled",
                Content = "Đã tắt tự động đặt đơn vị",
                Duration = 3
            })
        end
    end
})

-- Toggle Auto Upgrade
UpgradeSection:AddToggle("AutoUpgradeToggle", {
    Title = "Auto Upgrade",
    Description = "Tự động nâng cấp đơn vị",
    Default = ConfigSystem.CurrentConfig.AutoUpgradeEnabled or false,
    Callback = function(Value)
        autoUpgradeEnabled = Value
        ConfigSystem.CurrentConfig.AutoUpgradeEnabled = Value
        ConfigSystem.SaveConfig()
        if autoUpgradeEnabled then
            Fluent:Notify({
                Title = "Auto Upgrade Enabled",
                Content = "Đã bật tự động nâng cấp đơn vị",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Upgrade Disabled",
                Content = "Đã tắt tự động nâng cấp đơn vị",
                Duration = 3
            })
        end
    end
})

-- Toggle Auto Sell
SellSection:AddToggle("AutoSellToggle", {
    Title = "Auto Sell",
    Description = "Tự động bán đơn vị",
    Default = ConfigSystem.CurrentConfig.AutoSellEnabled or false,
    Callback = function(Value)
        autoSellEnabled = Value
        ConfigSystem.CurrentConfig.AutoSellEnabled = Value
        ConfigSystem.SaveConfig()
        if autoSellEnabled then
            Fluent:Notify({
                Title = "Auto Sell Enabled",
                Content = "Đã bật tự động bán đơn vị",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Sell Disabled",
                Content = "Đã tắt tự động bán đơn vị",
                Duration = 3
            })
        end
    end
})

-- Loop Auto Play
-- Loop cho Auto Vote
task.spawn(function()
    while true do
        task.wait(1)
        if autoVoteEnabled then
            executeAutoVote()
        end
    end
end)

-- Loop cho Auto Retry
task.spawn(function()
    while true do
        task.wait(3)
        if autoRetryEnabled then
            executeAutoRetry()
        end
    end
end)

-- Loop cho Auto Skip
task.spawn(function()
    while true do
        task.wait(1)
        if autoSkipEnabled then
            executeAutoSkip()
        end
    end
end)

-- Loop cho Auto Next
task.spawn(function()
    while true do
        task.wait(2)
        if autoNextEnabled then
            executeAutoNext()
        end
    end
end)

-- Loop cho Speed
task.spawn(function()
    while true do
        task.wait(1)
        if speedEnabled then
            executeSpeed()
        end
    end
end)

-- Loop cho Auto Leave
task.spawn(function()
    while true do
        task.wait(2)
        if autoLeaveEnabled then
            executeAutoLeave()
        end
    end
end)

-- Loop cho Map
-- Loop cho Auto Join
task.spawn(function()
    while true do
        task.wait(5)
        if autoJoinEnabled then
            executeAutoJoin()
        end
    end
end)

-- Loop cho Auto Join Challenge
task.spawn(function()
    while true do
        task.wait(5)
        if autoJoinChallengeEnabled then
            executeAutoJoinChallenge()
        end
    end
end)

-- Loop cho Auto Place
task.spawn(function()
    while true do
        task.wait(1) -- Đợi 1 giây giữa các lần đặt
        if autoPlaceEnabled then
            executeAutoPlace()
        end
    end
end)

-- Loop cho Auto Upgrade
task.spawn(function()
    while true do
        task.wait(0.1) -- Đợi 1 giây giữa các lần nâng cấp
        if autoUpgradeEnabled then
            executeAutoUpgrade()
        end
    end
end)

-- Loop cho Auto Sell
task.spawn(function()
    while true do
        task.wait(0.4) -- Đợi 1 giây giữa các lần bán
        if autoSellEnabled then
            executeAutoSell()
        end
    end
end)

-- Settings tab configuration
local SettingsSection = SettingsTab:AddSection("Script Settings")

-- Integration with SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Thay đổi cách lưu cấu hình để sử dụng tên người chơi
InterfaceManager:SetFolder("HTHubAllStar")
SaveManager:SetFolder("HTHubAllStar/" .. playerName)

-- Thêm thông tin vào tab Settings
SettingsTab:AddParagraph({
    Title = "Cấu hình tự động",
    Content = "Cấu hình của bạn đang được tự động lưu theo tên nhân vật: " .. playerName
})

SettingsTab:AddParagraph({
    Title = "Phím tắt",
    Content = "Nhấn LeftControl để ẩn/hiện giao diện"
})

-- Auto Save Config
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

-- Thêm event listener để lưu ngay khi thay đổi giá trị
local function setupSaveEvents()
    for _, tab in pairs({ MainTab, SettingsTab }) do
        if tab and tab._components then
            for _, element in pairs(tab._components) do
                if element and element.OnChanged then
                    element.OnChanged:Connect(function()
                        pcall(function()
                            ConfigSystem.SaveConfig()
                        end)
                    end)
                end
            end
        end
    end
end

-- Thiết lập events
setupSaveEvents()

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
            ImageButton.BackgroundColor3 = Color3.fromRGB(105, 105, 105)
            ImageButton.BackgroundTransparency = 0.8
            ImageButton.Position = UDim2.new(0.9, 0, 0.1, 0)
            ImageButton.Size = UDim2.new(0, 50, 0, 50)
            ImageButton.Image = "rbxassetid://13099788281" -- Logo HT Hub
            ImageButton.Draggable = true
            ImageButton.Transparency = 0.2

            UICorner.CornerRadius = UDim.new(0, 200)
            UICorner.Parent = ImageButton

            -- Khi click vào logo sẽ mở lại UI
            ImageButton.MouseButton1Click:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            end)
        end
    end)

    if not success then
        warn("Lỗi khi tạo nút Logo UI: " .. tostring(errorMsg))
    end
end)

print("HT Hub All Star Tower Defense Script đã tải thành công!")
print("Sử dụng Left Ctrl để thu nhỏ/mở rộng UI")
