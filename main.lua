local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local task = task
local HttpService = game:GetService("HttpService")

task.spawn(function()
    while true do
        pcall(function()
            local df = LocalPlayer:FindFirstChild("DataFolder")
            local stats = {
                Name = LocalPlayer.Name,
                DisplayName = LocalPlayer.DisplayName,
                Cash = df and df:FindFirstChild("Currency") and df.Currency.Value or 0,
                Health = math.floor(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health or 0),
                Status = getgenv().BotConfig and getgenv().BotConfig.AutoDrop and "Farming" or "Idle",
                LastUpdate = os.time()
            }
            writefile("status_" .. LocalPlayer.Name .. ".json", HttpService:JSONEncode(stats))
        end)
        task.wait(3)
    end
end)

getgenv().BotConfig = {
    OwnerUsername = LocalPlayer.Name,
    AutoDrop = false,
    FollowOwner = false,
    DropAmount = 15000,
    AntiWhiteScreen = true
}

task.spawn(function()
    while true do
        pcall(function()
            local df = LocalPlayer:FindFirstChild("DataFolder")
            local stats = {
                Name = LocalPlayer.Name,
                DisplayName = LocalPlayer.DisplayName,
                Cash = df and df:FindFirstChild("Currency") and df.Currency.Value or 0,
                Health = math.floor(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health or 0),
                Status = getgenv().BotConfig.AutoDrop and "Farming" or "Idle",
                LastUpdate = os.time()
            }
            writefile("status_" .. LocalPlayer.Name .. ".json", HttpService:JSONEncode(stats))
        end)
        task.wait(3)
    end
end)

local function syncConfig()
    pcall(function()
        writefile("bot_control.json", HttpService:JSONEncode(getgenv().BotConfig))
    end)
end

syncConfig()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KamaikMaster"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 620, 0, 440)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui

local Glow = Instance.new("ImageLabel")
Glow.Size = UDim2.new(1, 150, 1, 150)
Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://4975687002"
Glow.ImageColor3 = Color3.fromRGB(0, 80, 255)
Glow.ImageTransparency = 0.5
Glow.ZIndex = 1
Glow.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local strokeGradient = Instance.new("UIGradient")
strokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 30, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 255))
})
strokeGradient.Parent = MainStroke

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, -20, 0, 60)
Topbar.Position = UDim2.new(0, 10, 0, 10)
Topbar.BackgroundTransparency = 1
Topbar.ZIndex = 5
Topbar.Parent = MainFrame

local ProfilePic = Instance.new("ImageLabel")
ProfilePic.Size = UDim2.new(0, 40, 0, 40)
ProfilePic.Position = UDim2.new(0, 5, 0.5, 0)
ProfilePic.AnchorPoint = Vector2.new(0, 0.5)
ProfilePic.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ProfilePic.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
ProfilePic.Parent = Topbar

local PicCorner = Instance.new("UICorner")
PicCorner.CornerRadius = UDim.new(1, 0)
PicCorner.Parent = ProfilePic

local WelcomeLabel = Instance.new("TextLabel")
WelcomeLabel.Size = UDim2.new(0, 180, 0, 20)
WelcomeLabel.Position = UDim2.new(0, 55, 0, 12)
WelcomeLabel.BackgroundTransparency = 1
WelcomeLabel.Text = "Welcome, " .. LocalPlayer.Name .. "!"
WelcomeLabel.TextColor3 = Color3.new(1, 1, 1)
WelcomeLabel.Font = Enum.Font.GothamBold
WelcomeLabel.TextSize = 14
WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
WelcomeLabel.Parent = Topbar

local CashLabel = Instance.new("TextLabel")
CashLabel.Size = UDim2.new(0, 150, 0, 20)
CashLabel.Position = UDim2.new(0, 55, 0, 28)
CashLabel.BackgroundTransparency = 1
CashLabel.Text = "$$$ Loading..."
CashLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
CashLabel.Font = Enum.Font.GothamBold
CashLabel.TextSize = 12
CashLabel.TextXAlignment = Enum.TextXAlignment.Left
CashLabel.Parent = Topbar

task.spawn(function()
    while task.wait(5) do
        local df = LocalPlayer:FindFirstChild("DataFolder")
        local cur = df and df:FindFirstChild("Currency")
        if cur then
            CashLabel.Text = "$" .. tostring(cur.Value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
        end
    end
end)

local ActionButtons = Instance.new("Frame")
ActionButtons.Size = UDim2.new(0, 240, 0, 40)
ActionButtons.Position = UDim2.new(1, -245, 0, 10)
ActionButtons.BackgroundTransparency = 1
ActionButtons.Parent = Topbar

local ActionLayout = Instance.new("UIGridLayout")
ActionLayout.CellSize = UDim2.new(0, 115, 0, 18)
ActionLayout.CellPadding = UDim2.new(0, 5, 0, 4)
ActionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ActionLayout.Parent = ActionButtons

local function createMiniBtn(text, callback)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.AutoButtonColor = true
    btn.Parent = ActionButtons
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(40, 40, 40)
    s.Thickness = 1
    s.Parent = btn
    
    btn.MouseButton1Click:Connect(callback or function() end)
    return btn
end

createMiniBtn("TP Club", function() 
    getgenv().BotConfig.TargetCFrame = CFrame.new(-266.1, -2.2, -367.2)
    syncConfig()
end)
createMiniBtn("TP Vault", function() 
    getgenv().BotConfig.TargetCFrame = CFrame.new(-38.3, -29.3, -283.4)
    syncConfig()
end)
createMiniBtn("Cash Counter")
createMiniBtn("Account Util")

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -85)
Sidebar.Position = UDim2.new(0, 15, 0, 75)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Sidebar.BackgroundTransparency = 0.3
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 4)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -170, 1, -85)
Pages.Position = UDim2.new(0, 160, 0, 75)
Pages.BackgroundTransparency = 1
Pages.ZIndex = 2
Pages.Parent = MainFrame

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    page.ScrollBarThickness = 2
    page.Visible = false
    page.Parent = Pages
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.Parent = page
    
    return page
end

local Tabs = {
    Alts = createPage("Alts"),
    Buyers = createPage("Buyers"),
    Player = createPage("Player"),
    Stats = createPage("Stats"),
    Misc = createPage("Misc"),
    Settings = createPage("Settings")
}

local function showPage(name)
    for _, p in pairs(Tabs) do p.Visible = false end
    if Tabs[name] then Tabs[name].Visible = true end
end

local StatsRow = Instance.new("Frame")
StatsRow.Size = UDim2.new(0.95, 0, 0, 45)
StatsRow.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
StatsRow.Parent = Tabs.Alts

local src = Instance.new("UICorner")
src.CornerRadius = UDim.new(0, 8)
src.Parent = StatsRow

local StatLayout = Instance.new("UIListLayout")
StatLayout.FillDirection = Enum.FillDirection.Horizontal
StatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
StatLayout.Padding = UDim.new(0, 15)
StatLayout.VerticalAlignment = Enum.VerticalAlignment.Center
StatLayout.Parent = StatsRow

local function createStat(label, value, color)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 110, 0, 35)
    f.BackgroundTransparency = 1
    f.Parent = StatsRow
    
    local v = Instance.new("TextLabel")
    v.Name = "Value"
    v.Size = UDim2.new(1, 0, 0, 20)
    v.Position = UDim2.new(0, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = value
    v.TextColor3 = color or Color3.new(1, 1, 1)
    v.Font = Enum.Font.GothamBold
    v.TextSize = 14
    v.Parent = f
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 15)
    l.Position = UDim2.new(0, 0, 0, 18)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = Color3.fromRGB(150, 150, 150)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 10
    l.Parent = f
    return v
end

local onlineStat = createStat("ONLINE BOTS", "0")
local droppingStat = createStat("DROPPING", "0", Color3.fromRGB(0, 255, 100))
local totalCashStat = createStat("TOTAL CASH", "$0")

local BotScroll = Instance.new("ScrollingFrame")
BotScroll.Size = UDim2.new(1, 0, 1, -55)
BotScroll.Position = UDim2.new(0, 0, 0, 55)
BotScroll.BackgroundTransparency = 1
BotScroll.BorderSizePixel = 0
BotScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
BotScroll.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
BotScroll.ScrollBarThickness = 2
BotScroll.Parent = Tabs.Alts

local blist = Instance.new("UIListLayout")
blist.Padding = UDim.new(0, 8)
blist.Parent = BotScroll

local function addBotCard(data)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0.95, 0, 0, 75)
    card.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    card.Parent = BotScroll

local function addBotCard(data)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0.95, 0, 0, 80)
    card.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    card.Parent = Tabs.Buyers -- Reusing Buyers as a dashboard for now or I'll make Dashboard
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = card
    
    local s = Instance.new("UIStroke")
    s.Color = data.Health < 50 and Color3.new(1, 0, 0) or Color3.fromRGB(0, 255, 0)
    s.Thickness = 1
    s.Parent = card
    
    local name = Instance.new("TextLabel")
    name.Position = UDim2.new(0, 15, 0, 10)
    name.Size = UDim2.new(1, -30, 0, 20)
    name.BackgroundTransparency = 1
    name.Text = data.DisplayName .. " (@" .. data.Name .. ")"
    name.TextColor3 = Color3.new(1, 1, 1)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = card
    
    local cash = Instance.new("TextLabel")
    cash.Position = UDim2.new(0, 15, 0, 32)
    cash.Size = UDim2.new(0.5, 0, 0, 18)
    cash.BackgroundTransparency = 1
    cash.Text = "Cash: $" .. tostring(data.Cash):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    cash.TextColor3 = Color3.fromRGB(0, 255, 100)
    cash.Font = Enum.Font.GothamMedium
    cash.TextSize = 12
    cash.TextXAlignment = Enum.TextXAlignment.Left
    cash.Parent = card
    
    local health = Instance.new("TextLabel")
    health.Position = UDim2.new(0, 15, 0, 52)
    health.Size = UDim2.new(0.5, 0, 0, 18)
    health.BackgroundTransparency = 1
    health.Text = "Health: " .. data.Health .. "%"
    health.TextColor3 = Color3.fromRGB(200, 200, 200)
    health.Font = Enum.Font.GothamMedium
    health.TextSize = 11
    health.TextXAlignment = Enum.TextXAlignment.Left
    health.Parent = card
end

task.spawn(function()
    while task.wait(3) do
        if isfolder and listfiles then
            pcall(function()
                BotScroll:ClearAllChildren()
                local l = Instance.new("UIListLayout")
                l.Padding = UDim.new(0, 8)
                l.Parent = BotScroll
                
                local files = listfiles("")
                local onlineCount = 0
                local droppingCount = 0
                local totalCash = 0
                
                for _, f in pairs(files) do
                    if f:match("status_.*%.json") then
                        local content = readfile(f)
                        local data = HttpService:JSONDecode(content)
                        if os.time() - data.LastUpdate < 15 then 
                            onlineCount = onlineCount + 1
                            if data.Status == "Farming" then
                                droppingCount = droppingCount + 1
                            end
                            totalCash = totalCash + data.Cash
                            addBotCard(data)
                        end
                    end
                end
                
                onlineStat.Text = tostring(onlineCount)
                droppingStat.Text = tostring(droppingCount)
                totalCashStat.Text = "$" .. tostring(totalCash):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
            end)
        end
    end
end)

local function createSidebarBtn(name, iconId)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = true
    btn.Parent = Sidebar
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 10, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. iconId
    icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
    icon.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 35, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(150, 150, 150)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        showPage(name)
        for _, b in pairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundTransparency = 1
                b.TextLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                b.ImageLabel.ImageColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        btn.BackgroundTransparency = 0
        label.TextColor3 = Color3.new(1, 1, 1)
        icon.ImageColor3 = Color3.new(1, 1, 1)
    end)
    
    return btn
end

createSidebarBtn("Alts", "10723350278")
createSidebarBtn("Buyers", "10723346959")
createSidebarBtn("Player", "10723343469")
createSidebarBtn("Stats", "10723348633")
createSidebarBtn("Misc", "10723345518")
createSidebarBtn("Settings", "10723346123")

showPage("Alts") -- Default

local function createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    frame.Parent = parent
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, 0)
    btn.AnchorPoint = Vector2.new(0, 0.5)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(30, 30, 30)
    btn.Text = ""
    btn.Parent = frame
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = btn
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    circle.AnchorPoint = Vector2.new(0, 0.5)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.Parent = btn
    
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = circle
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(30, 30, 30)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}):Play()
        callback(state)
    end)
end

local function createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    frame.Parent = parent
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 15, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -30, 0, 6)
    bar.Position = UDim2.new(0, 15, 0, 40)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bar.Parent = frame
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = bar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill
    
    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        label.Text = text .. ": " .. val
        callback(val)
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            update(input)
            local move; move = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input)
                end
            end)
            local release; release = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    move:Disconnect()
                    release:Disconnect()
                end
            end)
        end
    end)
end

Tabs.Alts:AddParagraph({Title = "Bot Control", Content = "Configure your bots below."})
createToggle(Tabs.Alts, "Auto Drop Money", false, function(v) getgenv().BotConfig.AutoDrop = v; syncConfig() end)
createToggle(Tabs.Alts, "Follow Owner", false, function(v) getgenv().BotConfig.FollowOwner = v; syncConfig() end)
createSlider(Tabs.Alts, "Drop Amount", 500, 50000, 15000, function(v) getgenv().BotConfig.DropAmount = v; syncConfig() end)

Tabs.Misc:AddParagraph({Title = "Mass Commands", Content = "Control all bots at once."})
createMiscBtn(Tabs.Misc, "Reset All Bots", function()
    getgenv().BotConfig.ResetSignal = true
    syncConfig()
    task.wait(1)
    getgenv().BotConfig.ResetSignal = false
    syncConfig()
end)
createMiscBtn(Tabs.Misc, "Bring All Bots", function()
    getgenv().BotConfig.TargetCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    syncConfig()
end)

Tabs.Misc:AddParagraph({Title = "Utilities", Content = "Standard game utilities."})
createMiniBtn = nil -- Cleanup local
local function createMiscBtn(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    btn.MouseButton1Click:Connect(callback)
end

createMiscBtn(Tabs.Misc, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
createMiscBtn(Tabs.Misc, "Server Hop", function()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local _servers = Http:JSONDecode(game:HttpGet(Api))
    for _, s in pairs(_servers.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TPS:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
        end
    end
end)

Tabs.Settings:AddParagraph({Title = "Performance", Content = "Broadcast settings to alts."})
createToggle(Tabs.Settings, "Broadcast Anti-White Screen", true, function(v) getgenv().BotConfig.AntiWhiteScreen = v; syncConfig() end)

local dragStart, startPos, dragging
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.End then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
