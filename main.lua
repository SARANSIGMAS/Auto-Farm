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

local function syncConfig(cmdType, cmdVal)
    pcall(function()
        -- Local File Sync (for bots on same machine)
        local config = {}
        for k, v in pairs(getgenv().BotConfig) do
            if typeof(v) == "CFrame" then
                config[k] = {v:GetComponents()}
            else
                config[k] = v
            end
        end
        writefile("bot_control.json", HttpService:JSONEncode(config))

        -- Network Sync (suppressed emotes for bots on other machines)
        if cmdType and cmdVal ~= nil then
            local valStr = tostring(cmdVal)
            if typeof(cmdVal) == "CFrame" then
                local pos = cmdVal.Position
                valStr = string.format("%.1f,%.1f,%.1f", pos.X, pos.Y, pos.Z)
            end
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local ME = ReplicatedStorage:FindFirstChild("MainEvent")
            if ME then
                ME:FireServer("SayMessageRequest", "/e sync_bt|" .. tostring(cmdType) .. "|" .. valStr, "All")
            end
        end
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
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui

local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.Size = UDim2.new(1, 40, 1, 40)
DropShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
DropShadow.BackgroundTransparency = 1
DropShadow.Image = "rbxassetid://4743306782"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.4
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(35, 35, 35, 35)
DropShadow.ZIndex = 1
DropShadow.Parent = MainFrame

-- Optional trick to make it render cleanly behind the frame
local ShadowFixer = Instance.new("CanvasGroup")
ShadowFixer.Size = UDim2.new(1,0,1,0)
ShadowFixer.BackgroundTransparency = 1
ShadowFixer.ZIndex = 2
ShadowFixer.Parent = ScreenGui 
-- Re-parenting for proper drag tracking while rendering behind
DropShadow.Parent = MainFrame
DropShadow.ZIndex = 0

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


local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local MainGlow = Instance.new("ImageLabel")
MainGlow.Name = "BloomGlow"
MainGlow.Size = UDim2.new(1, 40, 1, 40)
MainGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainGlow.AnchorPoint = Vector2.new(0.5, 0.5)
MainGlow.BackgroundTransparency = 1
MainGlow.Image = "rbxassetid://1316045217"
MainGlow.ImageColor3 = Color3.fromRGB(255, 255, 255)
MainGlow.ImageTransparency = 0.8
MainGlow.ZIndex = 0
MainGlow.Parent = MainFrame

local glowTween = TweenService:Create(MainGlow, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    ImageTransparency = 0.95,
    Size = UDim2.new(1, 25, 1, 25)
})
glowTween:Play()

MainStroke.Color = Color3.fromRGB(70, 70, 80)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.6

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 65)
Topbar.Position = UDim2.new(0, 0, 0, 0)
Topbar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
Topbar.BackgroundTransparency = 0
Topbar.BorderSizePixel = 0
Topbar.ZIndex = 5
Topbar.Parent = MainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = Topbar

-- Bottom fill to square off the bottom corners of topbar
local topFill = Instance.new("Frame")
topFill.Size = UDim2.new(1, 0, 0, 14)
topFill.Position = UDim2.new(0, 0, 1, -14)
topFill.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
topFill.BorderSizePixel = 0
topFill.ZIndex = 5
topFill.Parent = Topbar

local topSep = Instance.new("Frame")
topSep.Size = UDim2.new(1, -30, 0, 1)
topSep.Position = UDim2.new(0, 15, 1, 0)
topSep.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
topSep.BorderSizePixel = 0
topSep.ZIndex = 6
topSep.Parent = Topbar

local ProfilePic = Instance.new("ImageLabel")
ProfilePic.Size = UDim2.new(0, 38, 0, 38)
ProfilePic.Position = UDim2.new(0, 15, 0.5, 0)
ProfilePic.AnchorPoint = Vector2.new(0, 0.5)
ProfilePic.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ProfilePic.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
ProfilePic.ZIndex = 6
ProfilePic.Parent = Topbar

local PicCorner = Instance.new("UICorner")
PicCorner.CornerRadius = UDim.new(1, 0)
PicCorner.Parent = ProfilePic

local PicStroke = Instance.new("UIStroke")
PicStroke.Color = Color3.fromRGB(0, 120, 255)
PicStroke.Thickness = 2
PicStroke.Parent = ProfilePic

-- Online indicator dot
local onlineDot = Instance.new("Frame")
onlineDot.Size = UDim2.new(0, 10, 0, 10)
onlineDot.Position = UDim2.new(1, -2, 1, -2)
onlineDot.AnchorPoint = Vector2.new(0.5, 0.5)
onlineDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
onlineDot.ZIndex = 7
onlineDot.Parent = ProfilePic

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = onlineDot

local WelcomeLabel = Instance.new("TextLabel")
WelcomeLabel.Size = UDim2.new(0, 200, 0, 18)
WelcomeLabel.Position = UDim2.new(0, 65, 0, 14)
WelcomeLabel.BackgroundTransparency = 1
WelcomeLabel.Text = "Welcome, " .. LocalPlayer.DisplayName
WelcomeLabel.TextColor3 = Color3.new(1, 1, 1)
WelcomeLabel.Font = Enum.Font.GothamBold
WelcomeLabel.TextSize = 14
WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
WelcomeLabel.ZIndex = 6
WelcomeLabel.Parent = Topbar

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 200, 0, 14)
SubLabel.Position = UDim2.new(0, 65, 0, 33)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "@" .. LocalPlayer.Name .. " • Command Center"
SubLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
SubLabel.Font = Enum.Font.GothamMedium
SubLabel.TextSize = 10
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.ZIndex = 6
SubLabel.Parent = Topbar

local CashLabel = Instance.new("TextLabel")
CashLabel.Size = UDim2.new(0, 150, 0, 20)
CashLabel.Position = UDim2.new(0, 65, 0, 46)
CashLabel.BackgroundTransparency = 1
CashLabel.Text = "$0"
CashLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
CashLabel.Font = Enum.Font.GothamBold
CashLabel.TextSize = 12
CashLabel.TextXAlignment = Enum.TextXAlignment.Left
CashLabel.ZIndex = 6
CashLabel.Parent = Topbar

task.spawn(function()
    while task.wait(2) do
        local df = LocalPlayer:FindFirstChild("DataFolder")
        local cur = df and df:FindFirstChild("Currency")
        if cur then
            CashLabel.Text = "$" .. tostring(cur.Value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
        end
    end
end)


local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -66)
Sidebar.Position = UDim2.new(0, 0, 0, 66)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Sidebar.BackgroundTransparency = 0
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = MainFrame

-- Sidebar right separator
local sidebarSep = Instance.new("Frame")
sidebarSep.Size = UDim2.new(0, 1, 1, -66)
sidebarSep.Position = UDim2.new(0, 140, 0, 66)
sidebarSep.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
sidebarSep.BorderSizePixel = 0
sidebarSep.ZIndex = 4
sidebarSep.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 2)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 6)
SidebarPadding.Parent = Sidebar

local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -145, 1, -70)
Pages.Position = UDim2.new(0, 143, 0, 68)
Pages.BackgroundTransparency = 1
Pages.ZIndex = 2
Pages.ClipsDescendants = true
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
addTab("Teleport")
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
StatsRow.Size = UDim2.new(0.97, 0, 0, 50)
StatsRow.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
StatsRow.Parent = Tabs.Alts

local src = Instance.new("UICorner")
src.CornerRadius = UDim.new(0, 10)
src.Parent = StatsRow

local srStroke = Instance.new("UIStroke")
srStroke.Color = Color3.fromRGB(30, 30, 40)
srStroke.Thickness = 1
srStroke.Parent = StatsRow

local StatLayout = Instance.new("UIListLayout")
StatLayout.FillDirection = Enum.FillDirection.Horizontal
StatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
StatLayout.Padding = UDim.new(0, 0)
StatLayout.VerticalAlignment = Enum.VerticalAlignment.Center
StatLayout.Parent = StatsRow

local function createStat(label, value, color)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.333, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Parent = StatsRow
    
    local v = Instance.new("TextLabel")
    v.Name = "Value"
    v.Size = UDim2.new(1, 0, 0, 22)
    v.Position = UDim2.new(0, 0, 0, 6)
    v.BackgroundTransparency = 1
    v.Text = value
    v.TextColor3 = color or Color3.new(1, 1, 1)
    v.Font = Enum.Font.GothamBold
    v.TextSize = 16
    v.Parent = f
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 14)
    l.Position = UDim2.new(0, 0, 0, 28)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = Color3.fromRGB(80, 80, 100)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 9
    l.Parent = f
    return v
end

local onlineStat = createStat("ONLINE BOTS", "0")
local droppingStat = createStat("DROPPING", "0", Color3.fromRGB(0, 255, 100))
local totalCashStat = createStat("TOTAL CASH", "$0")

-- FIXED LAYOUT: Consolidated Alts Tab into one Scroll to prevent overlap
local AltsScroll = Instance.new("ScrollingFrame")
AltsScroll.Size = UDim2.new(1, 0, 1, 0)
AltsScroll.BackgroundTransparency = 1
AltsScroll.BorderSizePixel = 0
AltsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
AltsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
AltsScroll.ScrollBarThickness = 2
AltsScroll.Parent = Tabs.Alts

local alist = Instance.new("UIListLayout")
alist.Padding = UDim.new(0, 12)
alist.HorizontalAlignment = Enum.HorizontalAlignment.Center
alist.Parent = AltsScroll

local apad = Instance.new("UIPadding")
apad.PaddingTop = UDim.new(0, 10)
apad.PaddingBottom = UDim.new(0, 10)
apad.Parent = AltsScroll

local BotScroll = AltsScroll -- Redirecting older BotScroll variable to the main scroll for compatibility

local function addBotCard(data)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0.97, 0, 0, 65)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    card.Parent = BotScroll
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = card
    
    -- Left color accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 0.7, 0)
    accentBar.Position = UDim2.new(0, 0, 0.15, 0)
    accentBar.BackgroundColor3 = data.Health < 50 and Color3.new(1, 0, 0) or Color3.fromRGB(0, 255, 120)
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 3
    accentBar.Parent = card
    
    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(0, 2)
    abCorner.Parent = accentBar
    
    -- Avatar
    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 36, 0, 36)
    avatar.Position = UDim2.new(0, 12, 0.5, 0)
    avatar.AnchorPoint = Vector2.new(0, 0.5)
    avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(data.UserId or 1) .. "&w=150&h=150"
    avatar.Parent = card
    
    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0)
    avCorner.Parent = avatar
    
    local name = Instance.new("TextLabel")
    name.Position = UDim2.new(0, 56, 0, 8)
    name.Size = UDim2.new(1, -120, 0, 18)
    name.BackgroundTransparency = 1
    name.Text = data.DisplayName .. "  (@" .. data.Name .. ")"
    name.TextColor3 = Color3.new(1, 1, 1)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 12
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = card
    
    local cash = Instance.new("TextLabel")
    cash.Position = UDim2.new(0, 56, 0, 27)
    cash.Size = UDim2.new(0.8, 0, 0, 14)
    cash.BackgroundTransparency = 1
    cash.RichText = true
    cash.Text = string.format("$%s  <font color=\"#B666FF\">$%s</font>", 
        tostring(data.Cash):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", ""),
        tostring(data.BankCash or 0):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    )
    cash.TextColor3 = Color3.new(1, 1, 1)
    cash.Font = Enum.Font.GothamBold
    cash.TextSize = 11
    cash.TextXAlignment = Enum.TextXAlignment.Left
    cash.Parent = card
    
    -- Health bar background
    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(0.5, 0, 0, 2)
    hpBg.Position = UDim2.new(0, 56, 0, 48)
    hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    hpBg.BorderSizePixel = 0
    hpBg.Parent = card
    
    local hpBgC = Instance.new("UICorner")
    hpBgC.CornerRadius = UDim.new(1, 0)
    hpBgC.Parent = hpBg
    
    -- Health bar fill
    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(math.clamp(data.Health / 100, 0, 1), 0, 1, 0)
    hpFill.BackgroundColor3 = data.Health < 50 and Color3.new(1, 0.3, 0.3) or Color3.fromRGB(0, 255, 120)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg
    
    local hpFillC = Instance.new("UICorner")
    hpFillC.CornerRadius = UDim.new(1, 0)
    hpFillC.Parent = hpFill
    
    -- Status badge
    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 60, 0, 20)
    badge.Position = UDim2.new(1, -70, 0.5, 0)
    badge.AnchorPoint = Vector2.new(0, 0.5)
    badge.BackgroundColor3 = data.Status == "Dropping" and Color3.fromRGB(0, 40, 20) or Color3.fromRGB(30, 30, 30)
    badge.Text = data.Status
    badge.TextColor3 = data.Status == "Dropping" and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(120, 120, 120)
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 9
    badge.Parent = card
    
    local badgeC = Instance.new("UICorner")
    badgeC.CornerRadius = UDim.new(0, 4)
    badgeC.Parent = badge
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
                            if data.Status == "Dropping" then
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

local function createSidebarBtn(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Name = "TextLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(130, 130, 150)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = btn
    
    btn.MouseEnter:Connect(function()
        if TabContainers[name].Visible == false then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
            TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1)}):Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if TabContainers[name].Visible == false then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(130, 130, 150)}):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        showPage(name)
        for _, b in pairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                if b:FindFirstChild("TextLabel") then
                    TweenService:Create(b.TextLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(130, 130, 150)}):Play()
                end
            end
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1)}):Play()
    end)
    
    return btn
end

createSidebarBtn("Alts")
createSidebarBtn("Teleport")
createSidebarBtn("Buyers")
createSidebarBtn("Stats")
createSidebarBtn("Misc")
createSidebarBtn("Settings")

showPage("Alts")

-- Teleport Tab Content (Owner Teleport)
local TeleportLocations = {
    {Name = "Club", Position = CFrame.new(-266.1, -2.2, -367.2), Color = Color3.fromRGB(0, 150, 255)},
    {Name = "Vault", Position = CFrame.new(-38.3, -29.3, -283.4), Color = Color3.fromRGB(255, 180, 0)},
    {Name = "Bank", Position = CFrame.new(-402.12, 21.75, -283.98), Color = Color3.fromRGB(0, 255, 120)}
}

local tpHeader = Instance.new("TextLabel")
tpHeader.Size = UDim2.new(0.95, 0, 0, 30)
tpHeader.BackgroundTransparency = 1
tpHeader.Text = "OWNER TELEPORT"
tpHeader.TextColor3 = Color3.fromRGB(200, 200, 200)
tpHeader.Font = Enum.Font.GothamBold
tpHeader.TextSize = 12
tpHeader.Parent = Tabs.Teleport

for _, loc in ipairs(TeleportLocations) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    frame.Parent = Tabs.Teleport
    
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 8)
    fc.Parent = frame
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 0.6, 0)
    indicator.Position = UDim2.new(0, 8, 0.2, 0)
    indicator.BackgroundColor3 = loc.Color
    indicator.BorderSizePixel = 0
    indicator.Parent = frame
    
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 2)
    ic.Parent = indicator
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = loc.Name
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 80, 0, 30)
    tpBtn.Position = UDim2.new(1, -90, 0.5, 0)
    tpBtn.AnchorPoint = Vector2.new(0, 0.5)
    tpBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    tpBtn.Text = "Teleport"
    tpBtn.TextColor3 = loc.Color
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.TextSize = 11
    tpBtn.AutoButtonColor = false
    tpBtn.Parent = frame
    
    local tbc = Instance.new("UICorner")
    tbc.CornerRadius = UDim.new(0, 6)
    tbc.Parent = tpBtn
    
    tpBtn.MouseEnter:Connect(function()
        TweenService:Create(tpBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)
    tpBtn.MouseLeave:Connect(function()
        TweenService:Create(tpBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()
    end)
    
    tpBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local tween = TweenService:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = loc.Position})
            tween:Play()
        end
    end)
end

local tpSep = Instance.new("Frame")
tpSep.Size = UDim2.new(0.9, 0, 0, 1)
tpSep.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tpSep.BorderSizePixel = 0
tpSep.Parent = Tabs.Teleport

local tpBotHeader = Instance.new("TextLabel")
tpBotHeader.Size = UDim2.new(0.95, 0, 0, 30)
tpBotHeader.BackgroundTransparency = 1
tpBotHeader.Text = "SEND ALL BOTS TO"
tpBotHeader.TextColor3 = Color3.fromRGB(200, 200, 200)
tpBotHeader.Font = Enum.Font.GothamBold
tpBotHeader.TextSize = 12
tpBotHeader.Parent = Tabs.Teleport

for _, loc in ipairs(TeleportLocations) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    btn.Text = "  Setup Bots → " .. loc.Name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = Tabs.Teleport
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18, 18, 18)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().BotConfig.TargetCFrame = loc.Position
        syncConfig()
    end)
end

local bringSep = Instance.new("Frame")
bringSep.Size = UDim2.new(0.9, 0, 0, 1)
bringSep.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bringSep.BorderSizePixel = 0
bringSep.Parent = Tabs.Teleport

local bringBtn = Instance.new("TextButton")
bringBtn.Size = UDim2.new(0.95, 0, 0, 40)
bringBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
bringBtn.Text = "Bring All Bots To Me"
bringBtn.TextColor3 = Color3.new(1, 1, 1)
bringBtn.Font = Enum.Font.GothamBold
bringBtn.TextSize = 13
bringBtn.AutoButtonColor = false
bringBtn.Parent = Tabs.Teleport

local bbCorner = Instance.new("UICorner")
bbCorner.CornerRadius = UDim.new(0, 8)
bbCorner.Parent = bringBtn

bringBtn.MouseEnter:Connect(function()
    TweenService:Create(bringBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
end)
bringBtn.MouseLeave:Connect(function()
    TweenService:Create(bringBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 120, 255)}):Play()
end)

bringBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        getgenv().BotConfig.TargetCFrame = char.HumanoidRootPart.CFrame
        syncConfig("TargetCFrame", char.HumanoidRootPart.CFrame)
    end
end)

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

createToggle(AltsScroll, "Auto Drop Money", false, function(v) getgenv().BotConfig.AutoDrop = v; syncConfig("AutoDrop", v) end)
createToggle(AltsScroll, "Follow Owner", false, function(v) getgenv().BotConfig.FollowOwner = v; syncConfig("FollowOwner", v) end)
createToggle(AltsScroll, "Auto Reset if KO'd", true, function(v) getgenv().BotConfig.AutoResetKO = v; syncConfig("AutoResetKO", v) end)
createInput(AltsScroll, "Drop Amount (Max 15k)", 1, 15000, 15000, function(v) getgenv().BotConfig.DropAmount = v; syncConfig("DropAmount", v) end)

local QuickSetup = Instance.new("Frame")
QuickSetup.Size = UDim2.new(0.95, 0, 0, 80)
QuickSetup.BackgroundTransparency = 1
QuickSetup.Parent = AltsScroll

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
    School = CFrame.new(-548.1, 21.2, 281.4),
    Club = CFrame.new(-266.1, -2.2, -367.2),
    Casino = CFrame.new(-853.3, 21.3, -135.2),
    Bank = CFrame.new(-402.12, 21.75, -283.98)
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
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.Size = UDim2.new(1, 14, 1, 14)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 2)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://4743306782"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(35, 35, 35, 35)
    shadow.ZIndex = btn.ZIndex - 1
    shadow.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().BotConfig.TargetCFrame = cf
        syncConfig("TargetCFrame", cf)
    end)
end

-- Horizontal Separator before bots
local botSep = Instance.new("Frame")
botSep.Size = UDim2.new(0.9, 0, 0, 1)
botSep.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
botSep.BorderSizePixel = 0
botSep.Parent = AltsScroll

local botHeader = Instance.new("TextLabel")
botHeader.Size = UDim2.new(1, 0, 0, 20)
botHeader.BackgroundTransparency = 1
botHeader.Text = "CONNECTED ALTS"
botHeader.TextColor3 = Color3.fromRGB(180, 180, 180)
botHeader.Font = Enum.Font.GothamBold
botHeader.TextSize = 10
botHeader.Parent = AltsScroll

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
            syncConfig("WhitelistedBuyers", getgenv().BotConfig.WhitelistedBuyers)
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
        syncConfig("WhitelistedBuyers", getgenv().BotConfig.WhitelistedBuyers)
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
    btn.AutoButtonColor = false
    btn.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18, 18, 18)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
end

createMiscBtn(Tabs.Misc, "Reset All Bots", function()
    getgenv().BotConfig.ResetSignal = true
    syncConfig("ResetSignal", true)
    task.wait(1)
    getgenv().BotConfig.ResetSignal = false
    syncConfig("ResetSignal", false)
end)

createMiscBtn(Tabs.Misc, "Bring All Bots", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local cf = LocalPlayer.Character.HumanoidRootPart.CFrame
        getgenv().BotConfig.TargetCFrame = cf
        syncConfig("TargetCFrame", cf)
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

createToggle(Tabs.Settings, "Broadcast Anti-White Screen", true, function(v) getgenv().BotConfig.AntiWhiteScreen = v; syncConfig("AntiWhiteScreen", v) end)

local ToggleKey = Enum.KeyCode.RightShift

local function createKeybind(parent, text, defaultKey, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    frame.Parent = parent
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 24)
    btn.Position = UDim2.new(1, -95, 0.5, 0)
    btn.AnchorPoint = Vector2.new(0, 0.5)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = defaultKey.Name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.Parent = frame
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn
    
    local listening = false
    btn.MouseButton1Click:Connect(function()
        listening = true
        btn.Text = "..."
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 100, 255)}):Play()
    end)
    
    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            btn.Text = input.KeyCode.Name
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
            callback(input.KeyCode)
        end
    end)
end

createKeybind(Tabs.Settings, "Toggle GUI Keybind", ToggleKey, function(key)
    ToggleKey = key
end)

local dragToggle, dragInput, dragStart, dragPos
local dragSpeed = 0.1

local function updateInput(input)
    local delta = input.Position - dragStart
    local position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(dragSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = position}):Play()
end

MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true
        dragStart = input.Position
        dragPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if dragToggle and dragInput then
        updateInput(dragInput)
    end
end)

local MainScale = Instance.new("UIScale")
MainScale.Scale = 1
MainScale.Parent = MainFrame

local isGuiVisible = true
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == ToggleKey then
        isGuiVisible = not isGuiVisible
        if isGuiVisible then
            MainFrame.Visible = true
            TweenService:Create(MainScale, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1}):Play()
        else
            local t = TweenService:Create(MainScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = 0})
            t:Play()
            t.Completed:Connect(function()
                if not isGuiVisible then MainFrame.Visible = false end
            end)
        end
    end
end)
