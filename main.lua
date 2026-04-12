local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

getgenv().BotConfig = {
    OwnerUsername = LocalPlayer.Name,
    AutoDrop = false,
    FollowOwner = false,
    DropAmount = 15000,
    AntiWhiteScreen = true,
    WhitelistedBuyers = {},
    AutoResetKO = true
}

local function parseShorthand(str)
    str = string.upper(tostring(str:gsub(",", "")))
    local numPart, suffix = string.match(str, "([%d%.]+)([KMB]?)")
    local value = tonumber(numPart)
    if not value then return 0 end
    local multipliers = { ["K"] = 1000, ["M"] = 1000000, ["B"] = 1000000000, [""] = 1 }
    return value * (multipliers[suffix] or 1)
end

local function syncConfig()
    pcall(function()
        local config = {}
        for k, v in pairs(getgenv().BotConfig) do
            if typeof(v) == "CFrame" then
                config[k] = {v:GetComponents()}
            else
                config[k] = v
            end
        end
        writefile("bot_control.json", HttpService:JSONEncode(config))
    end)
end

syncConfig()

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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KamaikMaster"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 620, 0, 440)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui

local MainBlur = Instance.new("Frame")
MainBlur.Name = "GlassLayer"
MainBlur.Size = UDim2.new(1, 0, 1, 0)
MainBlur.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainBlur.BackgroundTransparency = 0.8
MainBlur.ZIndex = 1
MainBlur.Parent = MainFrame

local mbCorner = Instance.new("UICorner")
mbCorner.CornerRadius = UDim.new(0, 14)
mbCorner.Parent = MainBlur

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local GridOverlay = Instance.new("ImageLabel")
GridOverlay.Name = "GridOverlay"
GridOverlay.Size = UDim2.new(1, 0, 1, 0)
GridOverlay.BackgroundTransparency = 1
GridOverlay.Image = "rbxassetid://12456456071"
GridOverlay.ImageTransparency = 0.95
GridOverlay.ScaleType = Enum.ScaleType.Tile
GridOverlay.TileSize = UDim2.new(0, 64, 0, 64)
GridOverlay.ZIndex = 1
GridOverlay.Parent = MainFrame

local GridCorner = Instance.new("UICorner")
GridCorner.CornerRadius = UDim.new(0, 14)
GridCorner.Parent = GridOverlay

local Glow = Instance.new("ImageLabel")
Glow.Size = UDim2.new(1, 150, 1, 150)
Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://4975687002"
Glow.ImageColor3 = Color3.fromRGB(0, 120, 255)
Glow.ImageTransparency = 0.6
Glow.ZIndex = 0
Glow.Parent = MainFrame

local glowGradient = Instance.new("UIGradient")
glowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 40, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 255))
})
glowGradient.Parent = Glow

task.spawn(function()
    local rot = 0
    while task.wait(0.01) do
        rot = rot + 0.5
        glowGradient.Rotation = rot % 360
    end
end)

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

local TopGradient = Instance.new("UIGradient")
TopGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 15)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 25, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
})
TopGradient.Parent = Topbar

local ProfilePic = Instance.new("ImageLabel")
ProfilePic.Size = UDim2.new(0, 42, 0, 42)
ProfilePic.Position = UDim2.new(0, 5, 0.5, 0)
ProfilePic.AnchorPoint = Vector2.new(0, 0.5)
ProfilePic.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ProfilePic.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
ProfilePic.ZIndex = 6
ProfilePic.Parent = Topbar

local PicStroke = Instance.new("UIStroke")
PicStroke.Color = Color3.fromRGB(0, 120, 255)
PicStroke.Thickness = 2
PicStroke.Parent = ProfilePic

local WelcomeLabel = Instance.new("TextLabel")
WelcomeLabel.Size = UDim2.new(0, 180, 0, 20)
WelcomeLabel.Position = UDim2.new(0, 60, 0, 12)
WelcomeLabel.BackgroundTransparency = 1
WelcomeLabel.Text = "Welcome, " .. LocalPlayer.Name .. "!"
WelcomeLabel.TextColor3 = Color3.new(1, 1, 1)
WelcomeLabel.Font = Enum.Font.GothamBold
WelcomeLabel.TextSize = 15
WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
WelcomeLabel.ZIndex = 6
WelcomeLabel.Parent = Topbar

local CashLabel = Instance.new("TextLabel")
CashLabel.Size = UDim2.new(0, 150, 0, 20)
CashLabel.Position = UDim2.new(0, 60, 0, 28)
CashLabel.BackgroundTransparency = 1
CashLabel.Text = "$$$ Loading..."
CashLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
CashLabel.Font = Enum.Font.GothamBold
CashLabel.TextSize = 13
CashLabel.TextXAlignment = Enum.TextXAlignment.Left
CashLabel.ZIndex = 6
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
    btn.AutoButtonColor = false
    btn.Parent = ActionButtons
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(0, 200, 255)
    s.Thickness = 1
    s.Transparency = 1
    s.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
        TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 1}):Play()
    end)
    
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
local function createPopup(title, size)
    local popupFrame = Instance.new("Frame")
    popupFrame.Size = size or UDim2.new(0, 300, 0, 250)
    popupFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    popupFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    popupFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    popupFrame.ZIndex = 10
    popupFrame.Visible = false
    popupFrame.Parent = ScreenGui
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = popupFrame
    
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(40, 40, 40)
    s.Thickness = 1
    s.Parent = popupFrame

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 35)
    top.BackgroundTransparency = 1
    top.Parent = popupFrame
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -40, 1, 0)
    t.Position = UDim2.new(0, 15, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = Color3.new(1, 1, 1)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = top
    
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 25, 0, 25)
    close.Position = UDim2.new(1, -30, 0.5, 0)
    close.AnchorPoint = Vector2.new(0, 0.5)
    close.BackgroundTransparency = 1
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(200, 200, 200)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 20
    close.Parent = top
    
    close.MouseButton1Click:Connect(function() popupFrame.Visible = false end)
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -20, 1, -45)
    content.Position = UDim2.new(0, 10, 0, 40)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarThickness = 2
    content.Parent = popupFrame
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.Parent = content
    
    return popupFrame, content
end

local CashPopup, CashContent = createPopup("Detailed Cash Breakdown")
local UtilPopup, UtilContent = createPopup("Account Utilities")

local function createPopupBtn(parent, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.Text = text
    btn.TextColor3 = color or Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(0, 200, 255)
    s.Thickness = 1.5
    s.Transparency = 1
    s.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
        TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 1}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createPopupBtn(UtilContent, "Reset All Bots", Color3.fromRGB(255, 100, 100), function()
    getgenv().BotConfig.ResetSignal = true
    syncConfig()
    task.wait(1)
    getgenv().BotConfig.ResetSignal = false
    syncConfig()
end)

createPopupBtn(UtilContent, "Rejoin All", Color3.fromRGB(100, 255, 100), function()
    -- Bots will read config and rejoin if they see a rejoin signal (to be implemented in bot script)
    getgenv().BotConfig.RejoinSignal = os.time()
    syncConfig()
end)

createPopupBtn(UtilContent, "Refresh Avatars", Color3.new(1, 1, 1), function()
    getgenv().BotConfig.RefreshAvatarSignal = os.time()
    syncConfig()
end)

createMiniBtn("Cash Counter", function() CashPopup.Visible = not CashPopup.Visible end)
createMiniBtn("Account Util", function() UtilPopup.Visible = not UtilPopup.Visible end)

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
    local pageContainer = Instance.new("CanvasGroup")
    pageContainer.Name = name .. "PageContainer"
    pageContainer.Size = UDim2.new(1, 0, 1, 0)
    pageContainer.BackgroundTransparency = 1
    pageContainer.GroupTransparency = 1
    pageContainer.Visible = false
    pageContainer.Parent = Pages

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 2
    page.Parent = pageContainer
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.Parent = page
    
    return pageContainer, page
end

local Tabs = {}
local TabContainers = {}

local function addTab(name)
    local container, page = createPage(name)
    Tabs[name] = page
    TabContainers[name] = container
end

addTab("Alts")
addTab("Buyers")
addTab("Stats")
addTab("Misc")
addTab("Settings")

local function showPage(name)
    for n, container in pairs(TabContainers) do
        if n == name then
            container.Visible = true
            TweenService:Create(container, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
        else
            TweenService:Create(container, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
            task.delay(0.35, function()
                if container.GroupTransparency >= 0.99 then
                    container.Visible = false
                end
            end)
        end
    end
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
BotScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
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
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = card
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = data.Health < 50 and Color3.new(1, 0, 0) or Color3.fromRGB(0, 255, 120)
    mainStroke.Thickness = 1.5
    mainStroke.Parent = card
    
    local glowStroke = Instance.new("UIStroke")
    glowStroke.Color = mainStroke.Color
    glowStroke.Thickness = 3
    glowStroke.Transparency = 0.6
    glowStroke.Parent = card
    
    local gsGradient = Instance.new("UIGradient")
    gsGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.4),
        NumberSequenceKeypoint.new(1, 1)
    })
    gsGradient.Parent = glowStroke
    
    task.spawn(function()
        while card.Parent do
            TweenService:Create(glowStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 5, Transparency = 0.8}):Play()
            task.wait(1.5)
            TweenService:Create(glowStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 3, Transparency = 0.6}):Play()
            task.wait(1.5)
        end
    end)
    
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
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(0, 120, 255)
    btnStroke.Thickness = 1.5
    btnStroke.Transparency = 1
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    btnStroke.Parent = btn

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 18, 0, 18)
    icon.Position = UDim2.new(0, 12, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. iconId
    icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
    icon.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 1, 0)
    label.Position = UDim2.new(0, 40, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(150, 150, 150)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn
    
    btn.MouseEnter:Connect(function()
        if TabContainers[name].Visible == false then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
            TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1)}):Play()
            TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = Color3.new(1, 1, 1)}):Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if TabContainers[name].Visible == false then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        showPage(name)
        for _, b in pairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(b.TextLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                TweenService:Create(b.ImageLabel, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                if b:FindFirstChildOfClass("UIStroke") then
                    TweenService:Create(b:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), {Transparency = 1}):Play()
                end
            end
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1)}):Play()
        TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = Color3.new(1, 1, 1)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
    end)
    
    return btn
end

createSidebarBtn("Alts", "10734950309")
createSidebarBtn("Buyers", "10734897102")
createSidebarBtn("Stats", "10723398439")
createSidebarBtn("Misc", "10723351910")
createSidebarBtn("Settings", "10723374431")
-- Topbar Controls
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, -40, 0, 40)
Topbar.Position = UDim2.new(0, 20, 0, 80)
Topbar.BackgroundTransparency = 1
Topbar.Parent = Tabs.Alts

local tbGrid = Instance.new("UIGridLayout")
tbGrid.CellSize = UDim2.new(0.23, 0, 0, 30)
tbGrid.CellPadding = UDim2.new(0.02, 0, 0, 5)
tbGrid.Parent = Topbar

local function createTopBtn(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.Text = text
    btn.TextColor3 = color or Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.Parent = Topbar
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(0, 200, 255)
    s.Thickness = 1.5
    s.Transparency = 1
    s.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
        TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 1}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
end

createTopBtn("TP CLUB", Color3.fromRGB(0, 120, 255), function()
    getgenv().BotConfig.TargetCFrame = CFrame.new(-266.1, -2.2, -367.2)
    syncConfig()
end)
createTopBtn("TP VAULT", Color3.fromRGB(0, 120, 255), function()
    getgenv().BotConfig.TargetCFrame = CFrame.new(-38.3, -29.3, -283.4)
    syncConfig()
end)
createTopBtn("CASH COUNTER", Color3.new(1, 1, 1), function()
    createPopup("Total Cash Indicator", function(c)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Text = "Calculating network total..."
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 18
        l.Parent = c
        
        task.spawn(function()
            while task.wait(3) do
                local total = 0
                if listfiles then
                    for _, f in pairs(listfiles("")) do
                        if f:match("status_.*%.json") then
                            local data = HttpService:JSONDecode(readfile(f))
                            if os.time() - data.LastUpdate < 15 then
                                total = total + (data.Cash or 0)
                            end
                        end
                    end
                end
                l.Text = "TOTAL CASH: $" .. tostring(total):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
            end
        end)
    end)
end)
createTopBtn("UTIL PANEL", Color3.new(1, 1, 1), function()
    showPage("Misc")
end)


showPage("Alts")

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

local function createInput(parent, text, min, max, default, callback)
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
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -30, 0, 24)
    input.Position = UDim2.new(0, 15, 0, 32)
    input.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    input.Text = tostring(default)
    input.PlaceholderText = "Enter amount..."
    input.TextColor3 = Color3.new(1, 1, 1)
    input.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    input.Font = Enum.Font.GothamMedium
    input.TextSize = 13
    input.ClipsDescendants = true
    input.Parent = frame
    
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 6)
    ic.Parent = input
    
    local is = Instance.new("UIStroke")
    is.Color = Color3.fromRGB(40, 40, 40)
    is.Thickness = 1
    is.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    is.Parent = input

    input.Focused:Connect(function()
        TweenService:Create(is, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 100, 255)}):Play()
    end)
    
    input.FocusLost:Connect(function()
        TweenService:Create(is, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 40)}):Play()
        local val = parseShorthand(input.Text)
        if val > 0 then
            val = math.clamp(val, min, max)
            input.Text = tostring(val):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
            callback(val)
        else
            input.Text = tostring(default)
            callback(default)
        end
    end)
end

createToggle(Tabs.Alts, "Auto Drop Money", false, function(v) getgenv().BotConfig.AutoDrop = v; syncConfig() end)
createToggle(Tabs.Alts, "Follow Owner", false, function(v) getgenv().BotConfig.FollowOwner = v; syncConfig() end)
createToggle(Tabs.Alts, "Auto Reset if KO'd", true, function(v) getgenv().BotConfig.AutoResetKO = v; syncConfig() end)
createInput(Tabs.Alts, "Drop Amount (e.g. 10k, 1m)", 500, 50000, 15000, function(v) getgenv().BotConfig.DropAmount = v; syncConfig() end)

local QuickSetup = Instance.new("Frame")
QuickSetup.Size = UDim2.new(0.95, 0, 0, 80)
QuickSetup.BackgroundTransparency = 1
QuickSetup.Parent = Tabs.Alts

local qsLabel = Instance.new("TextLabel")
qsLabel.Size = UDim2.new(1, 0, 0, 20)
qsLabel.BackgroundTransparency = 1
qsLabel.Text = "AUTO SETUP PRESETS"
qsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
qsLabel.Font = Enum.Font.GothamBold
qsLabel.TextSize = 10
qsLabel.Parent = QuickSetup

local qsGrid = Instance.new("UIGridLayout")
qsGrid.CellSize = UDim2.new(0.23, 0, 0, 35)
qsGrid.CellPadding = UDim2.new(0.02, 0, 0, 5)
qsGrid.Parent = QuickSetup

local SetupTPs = {
    Club = CFrame.new(-266.1, -2.2, -367.2),
    Bank = CFrame.new(-38.3, -29.3, -283.4),
    Casino = CFrame.new(-853.3, 21.3, -135.2),
    School = CFrame.new(-548.1, 21.2, 281.4)
}

for name, cf in pairs(SetupTPs) do
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.Text = name:upper()
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.Parent = QuickSetup
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(0, 200, 255)
    s.Thickness = 1.5
    s.Transparency = 1
    s.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
        TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 1}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().BotConfig.TargetCFrame = cf
        syncConfig()
    end)
end

-- Buyers Tab Content
local function updateBuyerList()
    for _, child in pairs(Tabs.Buyers:GetChildren()) do
        if child:IsA("Frame") and child.Name == "BuyerEntry" then
            child:Destroy()
        end
    end
    
    for i, username in ipairs(getgenv().BotConfig.WhitelistedBuyers) do
        local entry = Instance.new("Frame")
        entry.Name = "BuyerEntry"
        entry.Size = UDim2.new(0.95, 0, 0, 35)
        entry.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        entry.Parent = Tabs.Buyers
        
        local ec = Instance.new("UICorner")
        ec.CornerRadius = UDim.new(0, 6)
        ec.Parent = entry
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = username
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = entry
        
        local del = Instance.new("TextButton")
        del.Size = UDim2.new(0, 30, 0, 25)
        del.Position = UDim2.new(1, -35, 0.5, 0)
        del.AnchorPoint = Vector2.new(0, 0.5)
        del.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        del.Text = "X"
        del.TextColor3 = Color3.new(1, 1, 1)
        del.Font = Enum.Font.GothamBold
        del.TextSize = 12
        del.Parent = entry
        
        local dc = Instance.new("UICorner")
        dc.CornerRadius = UDim.new(0, 4)
        dc.Parent = del
        
        del.MouseButton1Click:Connect(function()
            table.remove(getgenv().BotConfig.WhitelistedBuyers, i)
            syncConfig()
            updateBuyerList()
        end)
    end
end

local addBuyerFrame = Instance.new("Frame")
addBuyerFrame.Size = UDim2.new(0.95, 0, 0, 50)
addBuyerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
addBuyerFrame.Parent = Tabs.Buyers

local abc = Instance.new("UICorner")
abc.CornerRadius = UDim.new(0, 8)
abc.Parent = addBuyerFrame

local buyerInput = Instance.new("TextBox")
buyerInput.Size = UDim2.new(1, -80, 0, 30)
buyerInput.Position = UDim2.new(0, 10, 0.5, 0)
buyerInput.AnchorPoint = Vector2.new(0, 0.5)
buyerInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
buyerInput.PlaceholderText = "Type username..."
buyerInput.Text = ""
buyerInput.TextColor3 = Color3.new(1, 1, 1)
buyerInput.Font = Enum.Font.GothamMedium
buyerInput.TextSize = 12
buyerInput.Parent = addBuyerFrame

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(0, 60, 0, 30)
addBtn.Position = UDim2.new(1, -70, 0.5, 0)
addBtn.AnchorPoint = Vector2.new(0, 0.5)
addBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
addBtn.Text = "Add"
addBtn.TextColor3 = Color3.new(1, 1, 1)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 12
addBtn.Parent = addBuyerFrame

local abtc = Instance.new("UICorner")
abtc.CornerRadius = UDim.new(0, 6)
abtc.Parent = addBtn

addBtn.MouseButton1Click:Connect(function()
    if buyerInput.Text ~= "" then
        table.insert(getgenv().BotConfig.WhitelistedBuyers, buyerInput.Text)
        buyerInput.Text = ""
        syncConfig()
        updateBuyerList()
    end
end)

updateBuyerList()

-- Stats Tab Content
local StatsList = Instance.new("ScrollingFrame")
StatsList.Size = UDim2.new(1, 0, 1, 0)
StatsList.BackgroundTransparency = 1
StatsList.BorderSizePixel = 0
StatsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
StatsList.CanvasSize = UDim2.new(0, 0, 0, 0)
StatsList.ScrollBarThickness = 2
StatsList.Parent = Tabs.Stats

local slist = Instance.new("UIListLayout")
slist.Padding = UDim.new(0, 5)
slist.Parent = StatsList

task.spawn(function()
    while task.wait(3) do
        if isfolder and listfiles then
            pcall(function()
                StatsList:ClearAllChildren()
                CashContent:ClearAllChildren()
                local l = Instance.new("UIListLayout")
                l.Padding = UDim.new(0, 5)
                l.Parent = StatsList
                
                local cl = Instance.new("UIListLayout")
                cl.Padding = UDim.new(0, 8)
                cl.Parent = CashContent
                
                local files = listfiles("")
                for _, f in pairs(files) do
                    if f:match("status_.*%.json") then
                        local content = readfile(f)
                        local data = HttpService:JSONDecode(content)
                        if os.time() - data.LastUpdate < 15 then 
                            local row = Instance.new("Frame")
                            row.Size = UDim2.new(0.98, 0, 0, 30)
                            row.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                            row.Parent = StatsList
                            
                            local rc = Instance.new("UICorner")
                            rc.CornerRadius = UDim.new(0, 4)
                            rc.Parent = row
                            
                            local n = Instance.new("TextLabel")
                            n.Size = UDim2.new(0.4, 0, 1, 0)
                            n.Position = UDim2.new(0, 10, 0, 0)
                            n.BackgroundTransparency = 1
                            n.Text = data.Name
                            n.TextColor3 = Color3.new(1, 1, 1)
                            n.Font = Enum.Font.GothamMedium
                            n.TextSize = 11
                            n.TextXAlignment = Enum.TextXAlignment.Left
                            n.Parent = row
                            
                            local c = Instance.new("TextLabel")
                            c.Size = UDim2.new(0.3, 0, 1, 0)
                            c.Position = UDim2.new(0.4, 0, 0, 0)
                            c.BackgroundTransparency = 1
                            c.Text = "$" .. tostring(data.Cash):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
                            c.TextColor3 = Color3.fromRGB(0, 255, 100)
                            c.Font = Enum.Font.GothamBold
                            c.TextSize = 11
                            c.Parent = row
                            
                            local s = Instance.new("TextLabel")
                            s.Size = UDim2.new(0.3, 0, 1, 0)
                            s.Position = UDim2.new(0.7, 0, 0, 0)
                            s.BackgroundTransparency = 1
                            s.Text = data.Status
                            s.TextColor3 = data.Status == "Farming" and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(150, 150, 150)
                            s.Font = Enum.Font.GothamMedium
                            s.TextSize = 10
                            s.Parent = row
                            
                            -- Add to Cash Popup too
                            local crow = Instance.new("TextLabel")
                            crow.Size = UDim2.new(1, 0, 0, 20)
                            crow.BackgroundTransparency = 1
                            crow.Text = data.Name .. ": $" .. tostring(data.Cash):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
                            crow.TextColor3 = Color3.fromRGB(200, 200, 200)
                            crow.Font = Enum.Font.Gotham
                            crow.TextSize = 12
                            crow.Parent = CashContent
                        end
                    end
                end
            end)
        end
    end
end)


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

createMiscBtn(Tabs.Misc, "Reset All Bots", function()
    getgenv().BotConfig.ResetSignal = true
    syncConfig()
    task.wait(1)
    getgenv().BotConfig.ResetSignal = false
    syncConfig()
end)

createMiscBtn(Tabs.Misc, "Bring All Bots", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        getgenv().BotConfig.TargetCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        syncConfig()
    end
end)

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
