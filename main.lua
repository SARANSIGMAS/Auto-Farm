local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

getgenv().Kamaik_Cleanup = getgenv().Kamaik_Cleanup or {}
local function trackTask(obj) table.insert(getgenv().Kamaik_Cleanup, obj) end

local function unloadScript()
    getgenv().Kamaik_Unloaded = true
    for _, obj in pairs(getgenv().Kamaik_Cleanup) do
        pcall(function()
            if typeof(obj) == "RBXScriptConnection" then obj:Disconnect()
            elseif typeof(obj) == "Instance" then obj:Destroy() end
        end)
    end
    getgenv().Kamaik_Cleanup = {}
    -- Clean up ESP
    if getgenv()._MoneyESPFolder then
        pcall(function() getgenv()._MoneyESPFolder:Destroy() end)
        getgenv()._MoneyESPFolder = nil
    end
end

-- Cleanup previous instance if exists
if getgenv().Kamaik_Unloaded == false then
    pcall(unloadScript)
end
getgenv().Kamaik_Unloaded = false

getgenv().BotConfig = {
    OwnerUsername = LocalPlayer.Name,
    AutoDrop = false,
    FollowOwner = false,
    DropAmount = 15000,
    AntiWhiteScreen = true,
    WhitelistedBuyers = {},
    AutoResetKO = true,
    MoneyESP = false,
    AutoPickup = false,
    PickupRange = 65,
    Flooring = true,
    Bank = false,
    AntiSit = true,
    FloatHeight = 8
}

local function parseShorthand(str)
    str = string.upper(tostring(str:gsub(",", "")))
    local numPart, suffix = string.match(str, "([%d%.]+)([KMB]?)")
    local value = tonumber(numPart)
    if not value then return 0 end
    local multipliers = { ["K"] = 1000, ["M"] = 1000000, ["B"] = 1000000000, [""] = 1 }
    return value * (multipliers[suffix] or 1)
end

local function formatCash(val)
    return tostring(val):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local function syncConfig(cmdType, cmdVal)
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

        if cmdType and cmdVal ~= nil then
            local valStr = tostring(cmdVal)
            if typeof(cmdVal) == "CFrame" then
                local pos = cmdVal.Position
                valStr = string.format("%.1f,%.1f,%.1f", pos.X, pos.Y, pos.Z)
            elseif typeof(cmdVal) == "table" then
                valStr = HttpService:JSONEncode(cmdVal)
            end
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local ME = ReplicatedStorage:FindFirstChild("MainEvent")
            if ME then
                local files = listfiles("")
                for _, f in pairs(files) do
                    if f:match("status_.*%.json") then
                        local success, data = pcall(function() return HttpService:JSONDecode(readfile(f)) end)
                        if success and data and os.time() - data.LastUpdate < 40 then
                            pcall(function()
                                ME:FireServer("SayMessageRequest", "/w " .. data.Name .. " sync_bt|" .. tostring(cmdType) .. "|" .. valStr, "All")
                            end)
                        end
                    end
                end
                pcall(function()
                    ME:FireServer("SayMessageRequest", "/e sync_bt|" .. tostring(cmdType) .. "|" .. valStr, "All")
                end)
            end
        end
    end)
end

-- Periodic config sync heartbeat
task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
        syncConfig("OwnerUpdate", LocalPlayer.Name)
        task.wait(30)
    end
end)

syncConfig()

-- Status writer
task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
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
trackTask(ScreenGui)

local container = (gethui and gethui()) or (game:GetService("CoreGui"):FindFirstChild("RobloxGui")) or game:GetService("CoreGui")
ScreenGui.Parent = container

local MainFrame = Instance.new("CanvasGroup")
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
DropShadow.ZIndex = 0
DropShadow.Parent = MainFrame

local MainBlur = Instance.new("Frame")
MainBlur.Name = "GlassLayer"
MainBlur.Size = UDim2.new(1, 0, 1, 0)
MainBlur.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainBlur.BackgroundTransparency = 0.5
MainBlur.ZIndex = 1
MainBlur.Parent = MainFrame

local MainGrad = Instance.new("UIGradient")
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 12, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 28))
})
MainGrad.Rotation = 45
MainGrad.Parent = MainBlur

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

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(150, 150, 180)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.6
MainStroke.Parent = MainFrame

local MainGlow = Instance.new("ImageLabel")
MainGlow.Name = "EdgeGlow"
MainGlow.Size = UDim2.new(1, 10, 1, 10)
MainGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainGlow.AnchorPoint = Vector2.new(0.5, 0.5)
MainGlow.BackgroundTransparency = 1
MainGlow.Image = "rbxassetid://4743306782"
MainGlow.ImageColor3 = Color3.fromRGB(220, 220, 255)
MainGlow.ImageTransparency = 0.8
MainGlow.ScaleType = Enum.ScaleType.Slice
MainGlow.SliceCenter = Rect.new(35, 35, 35, 35)
MainGlow.ZIndex = 0
MainGlow.Parent = MainFrame

local glowTween = TweenService:Create(MainGlow, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    ImageTransparency = 0.96,
    Size = UDim2.new(1, 2, 1, 2)
})
glowTween:Play()

-- Glow color cycle
task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
        TweenService:Create(MainGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageColor3 = Color3.fromRGB(150, 150, 255)}):Play()
        task.wait(2)
        if getgenv().Kamaik_Unloaded then break end
        TweenService:Create(MainGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        task.wait(2)
    end
end)

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 65)
Topbar.Position = UDim2.new(0, 0, 0, 0)
Topbar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Topbar.BackgroundTransparency = 0
Topbar.BorderSizePixel = 0
Topbar.ZIndex = 5
Topbar.Parent = MainFrame

local topGrad = Instance.new("UIGradient")
topGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
topGrad.Rotation = 90
topGrad.Parent = Topbar

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = Topbar

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
SubLabel.Position = UDim2.new(0, 65, 0, 31)
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
CashLabel.Position = UDim2.new(0, 65, 0, 42)
CashLabel.BackgroundTransparency = 1
CashLabel.Text = "$0"
CashLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
CashLabel.Font = Enum.Font.GothamBold
CashLabel.TextSize = 12
CashLabel.TextXAlignment = Enum.TextXAlignment.Left
CashLabel.ZIndex = 6
CashLabel.Parent = Topbar

local TopbarGloss = Instance.new("Frame")
TopbarGloss.Size = UDim2.new(1, 0, 0, 32)
TopbarGloss.BackgroundTransparency = 1
TopbarGloss.ZIndex = 5
TopbarGloss.Parent = Topbar

local glossGrad = Instance.new("UIGradient")
glossGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
    ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
})
glossGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.95),
    NumberSequenceKeypoint.new(1, 1)
})
glossGrad.Rotation = 90
glossGrad.Parent = TopbarGloss

local TopMetrics = Instance.new("TextLabel")
TopMetrics.Size = UDim2.new(0, 180, 0, 14)
TopMetrics.Position = UDim2.new(1, -195, 0, 14)
TopMetrics.BackgroundTransparency = 1
TopMetrics.Text = "FPS: 60  •  PING: 0ms"
TopMetrics.TextColor3 = Color3.fromRGB(120, 120, 130)
TopMetrics.Font = Enum.Font.GothamMedium
TopMetrics.TextSize = 10
TopMetrics.TextXAlignment = Enum.TextXAlignment.Right
TopMetrics.ZIndex = 6
TopMetrics.Parent = Topbar

local frameCount = 0
trackTask(RunService.Heartbeat:Connect(function() frameCount = frameCount + 1 end))
task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
        local fps = frameCount
        frameCount = 0
        local ping = 0
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        TopMetrics.Text = string.format("FPS: %d  •  PING: %dms", fps, ping)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
        pcall(function()
            local df = LocalPlayer:FindFirstChild("DataFolder")
            local cur = df and df:FindFirstChild("Currency")
            if cur then
                CashLabel.Text = "$" .. formatCash(cur.Value)
            end
        end)
        task.wait(2)
    end
end)


local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -95)
Sidebar.Position = UDim2.new(0, 12, 0, 80)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Sidebar.BackgroundTransparency = 0
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = MainFrame

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 12)
sbCorner.Parent = Sidebar

local sbStroke = Instance.new("UIStroke")
sbStroke.Color = Color3.fromRGB(30, 30, 40)
sbStroke.Thickness = 1
sbStroke.Transparency = 0.5
sbStroke.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 2)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 6)
SidebarPadding.Parent = Sidebar

local SideGrad = Instance.new("UIGradient")
SideGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
})
SideGrad.Rotation = 90
SideGrad.Parent = Sidebar

local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -165, 1, -85)
Pages.Position = UDim2.new(0, 153, 0, 75)
Pages.BackgroundTransparency = 1
Pages.ZIndex = 2
Pages.ClipsDescendants = true
Pages.Parent = MainFrame

-- Sidebar removed blue selector logic

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
    page.ScrollBarThickness = 1
    page.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 50)
    page.Parent = pageContainer
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 12)
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
addTab("Misc")
addTab("Settings")

local function showPage(name)
    for n, ctr in pairs(TabContainers) do
        if n == name then
            ctr.Visible = true
            TweenService:Create(ctr, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
        else
            TweenService:Create(ctr, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
            task.delay(0.25, function()
                if ctr.GroupTransparency >= 0.99 then
                    ctr.Visible = false
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
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.Parent = f
    return v
end

local function createMasterToggle(parent, text, configKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(35, 35, 45)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.5
    btnStroke.Parent = btn
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -30, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 9
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextTruncate = Enum.TextTruncate.AtEnd
    textLabel.Parent = btn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 10, 0, 10)
    indicator.Position = UDim2.new(1, -16, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0.5, 0.5)
    indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    indicator.Parent = btn
    
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(1, 0)
    ic.Parent = indicator

    local function update()
        local enabled = getgenv().BotConfig[configKey]
        TweenService:Create(textLabel, TweenInfo.new(0.2), {TextColor3 = enabled and Color3.new(1,1,1) or Color3.fromRGB(140, 140, 160)}):Play()
        TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(40, 40, 50)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = enabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(35, 35, 45)}):Play()
    end

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 28)}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        getgenv().BotConfig[configKey] = not getgenv().BotConfig[configKey]
        syncConfig(configKey, getgenv().BotConfig[configKey])
        update()
    end)
    
    update()
end


local AltsScroll = Instance.new("ScrollingFrame")
AltsScroll.Size = UDim2.new(1, 0, 1, 0)
AltsScroll.BackgroundTransparency = 1
AltsScroll.BorderSizePixel = 0
AltsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
AltsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
AltsScroll.ScrollBarThickness = 2
AltsScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 65)
AltsScroll.Parent = Tabs.Alts

local alist = Instance.new("UIListLayout")
alist.Padding = UDim.new(0, 10)
alist.HorizontalAlignment = Enum.HorizontalAlignment.Center
alist.Parent = AltsScroll

local apad = Instance.new("UIPadding")
apad.PaddingTop = UDim.new(0, 8)
apad.PaddingBottom = UDim.new(0, 10)
apad.PaddingLeft = UDim.new(0, 4)
apad.PaddingRight = UDim.new(0, 4)
apad.Parent = AltsScroll

StatsRow.Parent = AltsScroll

local onlineStat = createStat("ONLINE BOTS", "0")
local droppingStat = createStat("DROPPING", "0", Color3.fromRGB(0, 255, 100))
local totalCashStat = createStat("TOTAL CASH", "$0")

-- Row 1: Toggle controls (grid layout)
local ControlRow1 = Instance.new("Frame")
ControlRow1.Name = "ControlRow1"
ControlRow1.Size = UDim2.new(1, 0, 0, 34)
ControlRow1.BackgroundTransparency = 1
ControlRow1.Parent = AltsScroll

local cr1Grid = Instance.new("UIGridLayout")
cr1Grid.CellSize = UDim2.new(0, 140, 0, 32)
cr1Grid.CellPadding = UDim2.new(0, 6, 0, 0)
cr1Grid.FillDirection = Enum.FillDirection.Horizontal
cr1Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
cr1Grid.VerticalAlignment = Enum.VerticalAlignment.Center
cr1Grid.Parent = ControlRow1

createMasterToggle(ControlRow1, "AUTO DROP", "AutoDrop")
createMasterToggle(ControlRow1, "FOLLOW OWNER", "FollowOwner")
createMasterToggle(ControlRow1, "FLOORING", "Flooring")

-- Row 2: Action buttons (grid layout)
local ControlRow2 = Instance.new("Frame")
ControlRow2.Name = "ControlRow2"
ControlRow2.Size = UDim2.new(1, 0, 0, 34)
ControlRow2.BackgroundTransparency = 1
ControlRow2.Parent = AltsScroll

local cr2Grid = Instance.new("UIGridLayout")
cr2Grid.CellSize = UDim2.new(0, 140, 0, 32)
cr2Grid.CellPadding = UDim2.new(0, 6, 0, 0)
cr2Grid.FillDirection = Enum.FillDirection.Horizontal
cr2Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
cr2Grid.VerticalAlignment = Enum.VerticalAlignment.Center
cr2Grid.Parent = ControlRow2

local tpAll = Instance.new("TextButton")
tpAll.Name = "TPAll"
tpAll.Size = UDim2.new(0, 140, 0, 32)
tpAll.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
tpAll.Text = "TP ALL BOTS"
tpAll.TextColor3 = Color3.new(1, 1, 1)
tpAll.Font = Enum.Font.GothamBold
tpAll.TextSize = 10
tpAll.AutoButtonColor = false
tpAll.Parent = ControlRow2

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 6)
tc.Parent = tpAll

tpAll.MouseEnter:Connect(function()
    TweenService:Create(tpAll, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
end)
tpAll.MouseLeave:Connect(function()
    TweenService:Create(tpAll, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
end)
tpAll.MouseButton1Click:Connect(function()
    syncConfig("OwnerPos", LocalPlayer.Character and LocalPlayer.Character:GetPivot() or CFrame.new())
end)

local bankBtn = Instance.new("TextButton")
bankBtn.Name = "GoBank"
bankBtn.Size = UDim2.new(0, 140, 0, 32)
bankBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
bankBtn.Text = "GO TO BANK"
bankBtn.TextColor3 = Color3.new(1, 1, 1)
bankBtn.Font = Enum.Font.GothamBold
bankBtn.TextSize = 10
bankBtn.AutoButtonColor = false
bankBtn.Parent = ControlRow2

local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(0, 6)
bc.Parent = bankBtn

bankBtn.MouseEnter:Connect(function()
    TweenService:Create(bankBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
end)
bankBtn.MouseLeave:Connect(function()
    TweenService:Create(bankBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
end)
bankBtn.MouseButton1Click:Connect(function()
    syncConfig("GoToBank", true)
end)

createMasterToggle(ControlRow2, "ANTI-SIT", "AntiSit")

-- Drop Amount Input
local dropAmtFrame = Instance.new("Frame")
dropAmtFrame.Size = UDim2.new(1, 0, 0, 55)
dropAmtFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
dropAmtFrame.Parent = AltsScroll

local dafCorner = Instance.new("UICorner")
dafCorner.CornerRadius = UDim.new(0, 8)
dafCorner.Parent = dropAmtFrame

local dafStroke = Instance.new("UIStroke")
dafStroke.Color = Color3.fromRGB(30, 30, 40)
dafStroke.Thickness = 1
dafStroke.Transparency = 0.5
dafStroke.Parent = dropAmtFrame

local daLabel = Instance.new("TextLabel")
daLabel.Size = UDim2.new(0.45, 0, 0, 20)
daLabel.Position = UDim2.new(0, 12, 0, 6)
daLabel.BackgroundTransparency = 1
daLabel.Text = "DROP AMOUNT"
daLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
daLabel.Font = Enum.Font.GothamBold
daLabel.TextSize = 9
daLabel.TextXAlignment = Enum.TextXAlignment.Left
daLabel.Parent = dropAmtFrame

local daSubLabel = Instance.new("TextLabel")
daSubLabel.Size = UDim2.new(0, 80, 0, 14)
daSubLabel.Position = UDim2.new(1, -90, 0, 8)
daSubLabel.BackgroundTransparency = 1
daSubLabel.Text = "Max: 15,000"
daSubLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
daSubLabel.Font = Enum.Font.GothamMedium
daSubLabel.TextSize = 8
daSubLabel.TextXAlignment = Enum.TextXAlignment.Right
daSubLabel.Parent = dropAmtFrame

local daInput = Instance.new("TextBox")
daInput.Size = UDim2.new(1, -24, 0, 24)
daInput.Position = UDim2.new(0, 12, 0, 26)
daInput.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
daInput.Text = "15,000"
daInput.PlaceholderText = "Enter amount (e.g. 15k)..."
daInput.TextColor3 = Color3.fromRGB(0, 255, 120)
daInput.PlaceholderColor3 = Color3.fromRGB(60, 60, 80)
daInput.Font = Enum.Font.GothamBold
daInput.TextSize = 13
daInput.ClipsDescendants = true
daInput.Parent = dropAmtFrame

local daIC = Instance.new("UICorner")
daIC.CornerRadius = UDim.new(0, 6)
daIC.Parent = daInput

local daIS = Instance.new("UIStroke")
daIS.Color = Color3.fromRGB(35, 35, 45)
daIS.Thickness = 1
daIS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
daIS.Parent = daInput

daInput.Focused:Connect(function()
    TweenService:Create(daIS, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 255, 120)}):Play()
end)

    end
end)

-- Float Height Input
local floatHFrame = Instance.new("Frame")
floatHFrame.Size = UDim2.new(1, 0, 0, 55)
floatHFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
floatHFrame.Parent = AltsScroll

local fhfCorner = Instance.new("UICorner")
fhfCorner.CornerRadius = UDim.new(0, 8)
fhfCorner.Parent = floatHFrame

local fhfStroke = Instance.new("UIStroke")
fhfStroke.Color = Color3.fromRGB(30, 30, 40)
fhfStroke.Thickness = 1
fhfStroke.Transparency = 0.5
fhfStroke.Parent = floatHFrame

local fhLabel = Instance.new("TextLabel")
fhLabel.Size = UDim2.new(0.45, 0, 0, 20)
fhLabel.Position = UDim2.new(0, 12, 0, 6)
fhLabel.BackgroundTransparency = 1
fhLabel.Text = "FLOAT HEIGHT"
fhLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
fhLabel.Font = Enum.Font.GothamBold
fhLabel.TextSize = 9
fhLabel.TextXAlignment = Enum.TextXAlignment.Left
fhLabel.Parent = floatHFrame

local fhSubLabel = Instance.new("TextLabel")
fhSubLabel.Size = UDim2.new(0, 80, 0, 14)
fhSubLabel.Position = UDim2.new(1, -90, 0, 8)
fhSubLabel.BackgroundTransparency = 1
fhSubLabel.Text = "Default: 8"
fhSubLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
fhSubLabel.Font = Enum.Font.GothamMedium
fhSubLabel.TextSize = 8
fhSubLabel.TextXAlignment = Enum.TextXAlignment.Right
fhSubLabel.Parent = floatHFrame

local fhInput = Instance.new("TextBox")
fhInput.Size = UDim2.new(1, -24, 0, 24)
fhInput.Position = UDim2.new(0, 12, 0, 26)
fhInput.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
fhInput.Text = "8"
fhInput.PlaceholderText = "Enter height (e.g. 15)..."
fhInput.TextColor3 = Color3.fromRGB(0, 255, 120)
fhInput.PlaceholderColor3 = Color3.fromRGB(60, 60, 80)
fhInput.Font = Enum.Font.GothamBold
fhInput.TextSize = 13
fhInput.ClipsDescendants = true
fhInput.Parent = floatHFrame

local fhIC = Instance.new("UICorner")
fhIC.CornerRadius = UDim.new(0, 6)
fhIC.Parent = fhInput

local fhIS = Instance.new("UIStroke")
fhIS.Color = Color3.fromRGB(35, 35, 45)
fhIS.Thickness = 1
fhIS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
fhIS.Parent = fhInput

fhInput.Focused:Connect(function()
    TweenService:Create(fhIS, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 255, 120)}):Play()
end)

fhInput.FocusLost:Connect(function()
    TweenService:Create(fhIS, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 35, 45)}):Play()
    local val = tonumber(fhInput.Text)
    if val then
        val = math.clamp(val, 0, 500)
        fhInput.Text = tostring(val)
        getgenv().BotConfig.FloatHeight = val
        syncConfig("FloatHeight", val)
    else
        fhInput.Text = "8"
        getgenv().BotConfig.FloatHeight = 8
        syncConfig("FloatHeight", 8)
    end
end)

-- Quick Setup Presets
local qsHeader = Instance.new("TextLabel")
qsHeader.Size = UDim2.new(1, 0, 0, 16)
qsHeader.BackgroundTransparency = 1
qsHeader.Text = "QUICK DEPLOY PRESETS"
qsHeader.TextColor3 = Color3.fromRGB(100, 100, 120)
qsHeader.Font = Enum.Font.GothamBold
qsHeader.TextSize = 8
qsHeader.Parent = AltsScroll

local QuickSetup = Instance.new("Frame")
QuickSetup.Size = UDim2.new(1, 0, 0, 34)
QuickSetup.BackgroundTransparency = 1
QuickSetup.Parent = AltsScroll

local qsGrid = Instance.new("UIGridLayout")
qsGrid.CellSize = UDim2.new(0, 102, 0, 30)
qsGrid.CellPadding = UDim2.new(0, 6, 0, 0)
qsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
qsGrid.Parent = QuickSetup

local SetupTPs = {
    {Name = "SCHOOL", CF = CFrame.new(-548.1, 21.2, 281.4)},
    {Name = "CLUB", CF = CFrame.new(-266.1, -2.2, -367.2)},
    {Name = "BANK", CF = CFrame.new(-402.12, 21.75, -283.98)},
    {Name = "CASINO", CF = CFrame.new(-853.3, 21.3, -135.2)}
}

for _, loc in ipairs(SetupTPs) do
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    btn.Text = loc.Name
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.AutoButtonColor = false
    btn.Parent = QuickSetup
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(35, 35, 45)
    bStroke.Thickness = 1
    bStroke.Transparency = 0.5
    bStroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(0, 255, 120)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 24, 30)}):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(35, 35, 45)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().BotConfig.TargetCFrame = loc.CF
        syncConfig("TargetCFrame", loc.CF)
        -- Flash feedback
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 210, 100)}):Play()
        task.wait(0.15)
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(24, 24, 30)}):Play()
    end)
end

-- Separator
local altsSep = Instance.new("Frame")
altsSep.Size = UDim2.new(0.85, 0, 0, 1)
altsSep.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
altsSep.BorderSizePixel = 0
altsSep.Parent = AltsScroll

local botHeader = Instance.new("TextLabel")
botHeader.Size = UDim2.new(1, 0, 0, 16)
botHeader.BackgroundTransparency = 1
botHeader.Text = "CONNECTED ALTS"
botHeader.TextColor3 = Color3.fromRGB(100, 100, 120)
botHeader.Font = Enum.Font.GothamBold
botHeader.TextSize = 8
botHeader.Parent = AltsScroll

local WorkforceContainer = Instance.new("Frame")
WorkforceContainer.Name = "WorkforceContainer"
WorkforceContainer.Size = UDim2.new(1, 0, 0, 0)
WorkforceContainer.AutomaticSize = Enum.AutomaticSize.Y
WorkforceContainer.BackgroundTransparency = 1
WorkforceContainer.Parent = AltsScroll

local wList = Instance.new("UIListLayout")
wList.Padding = UDim.new(0, 12)
wList.HorizontalAlignment = Enum.HorizontalAlignment.Center
wList.Parent = WorkforceContainer

local BotScroll = WorkforceContainer

local function addBotCard(data)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0.97, 0, 0, 65)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    card.Parent = BotScroll
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = card

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 0.7, 0)
    accentBar.Position = UDim2.new(0, 0, 0.15, 0)
    accentBar.BackgroundColor3 = (data.Health or 0) < 50 and Color3.new(1, 0, 0) or Color3.fromRGB(0, 255, 120)
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 3
    accentBar.Parent = card
    
    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(0, 2)
    abCorner.Parent = accentBar

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
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Position = UDim2.new(0, 56, 0, 8)
    nameLabel.Size = UDim2.new(1, -120, 0, 18)
    nameLabel.BackgroundTransparency = 1

    if data.DisplayName == LocalPlayer.DisplayName or data.DisplayName == "SAR4NDHC" then
        nameLabel.Text = "@" .. (data.Name or "?") .. '  <font size="10" color="#808080">[' .. (data.DisplayName or "?") .. ']</font>'
    else
        nameLabel.Text = (data.DisplayName or "?") .. "  (@" .. (data.Name or "?") .. ")"
    end

    nameLabel.RichText = true
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card
    
    local cash = Instance.new("TextLabel")
    cash.Position = UDim2.new(0, 56, 0, 27)
    cash.Size = UDim2.new(0.8, 0, 0, 14)
    cash.BackgroundTransparency = 1
    cash.RichText = true
    cash.Text = string.format('$%s  <font color="#B666FF">$%s</font>', 
        formatCash(data.Cash or 0),
        formatCash(data.BankCash or 0)
    )
    cash.TextColor3 = Color3.new(1, 1, 1)
    cash.Font = Enum.Font.GothamBold
    cash.TextSize = 11
    cash.TextXAlignment = Enum.TextXAlignment.Left
    cash.Parent = card

    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(0.5, 0, 0, 2)
    hpBg.Position = UDim2.new(0, 56, 0, 48)
    hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    hpBg.BorderSizePixel = 0
    hpBg.Parent = card
    
    local hpBgC = Instance.new("UICorner")
    hpBgC.CornerRadius = UDim.new(1, 0)
    hpBgC.Parent = hpBg

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(math.clamp((data.Health or 0) / 100, 0, 1), 0, 1, 0)
    hpFill.BackgroundColor3 = (data.Health or 0) < 50 and Color3.new(1, 0.3, 0.3) or Color3.fromRGB(0, 255, 120)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg
    
    local hpFillC = Instance.new("UICorner")
    hpFillC.CornerRadius = UDim.new(1, 0)
    hpFillC.Parent = hpFill

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 60, 0, 20)
    badge.Position = UDim2.new(1, -70, 0.5, 0)
    badge.AnchorPoint = Vector2.new(0, 0.5)
    badge.BackgroundColor3 = (data.Status == "Dropping") and Color3.fromRGB(0, 40, 20) or Color3.fromRGB(30, 30, 30)
    badge.Text = data.Status or "Idle"
    badge.TextColor3 = (data.Status == "Dropping") and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(120, 120, 120)
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 9
    badge.Parent = card
    
    local badgeC = Instance.new("UICorner")
    badgeC.CornerRadius = UDim.new(0, 4)
    badgeC.Parent = badge
end

task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
        task.wait(3)
        if isfolder and listfiles then
            pcall(function()
                BotScroll:ClearAllChildren()
                local l = Instance.new("UIListLayout")
                l.Padding = UDim.new(0, 8)
                l.HorizontalAlignment = Enum.HorizontalAlignment.Center
                l.Parent = BotScroll
                
                local files = listfiles("")
                local onlineCount = 0
                local droppingCount = 0
                local totalBotCash = 0

                for _, f in pairs(files) do
                    if f:match("status_.*%.json") then
                        pcall(function()
                            local content = readfile(f)
                            local data = HttpService:JSONDecode(content)
                            
                            -- Filter out local player (owner) from the bot list and stats
                            if data and data.Name ~= LocalPlayer.Name and os.time() - (data.LastUpdate or 0) < 20 then
                                onlineCount = onlineCount + 1
                                if data.Status == "Dropping" then
                                    droppingCount = droppingCount + 1
                                end
                                totalBotCash = totalBotCash + (data.Cash or 0)
                                addBotCard(data)
                            end
                        end)
                    end
                end
                
                onlineStat.Text = tostring(onlineCount)
                droppingStat.Text = tostring(droppingCount)
                totalCashStat.Text = "$" .. formatCash(totalBotCash)
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
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = btn
    
    -- Map sidebar names to tab names (Stats -> Misc fallback)
    local tabName = name
    if not TabContainers[name] then
        -- If no matching tab exists, redirect to Misc
        tabName = "Misc"
    end
    
    btn.MouseEnter:Connect(function()
        if TabContainers[tabName] and TabContainers[tabName].Visible == false then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
            TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1)}):Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if TabContainers[tabName] and TabContainers[tabName].Visible == false then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(130, 130, 150)}):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        showPage(tabName)

        for _, b in pairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                TweenService:Create(b, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                local l = b:FindFirstChild("TextLabel")
                if l then TweenService:Create(l, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(130, 130, 150)}):Play() end
            end
        end
        TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundTransparency = 0.85, BackgroundColor3 = Color3.fromRGB(30,30,45)}):Play()
        TweenService:Create(label, TweenInfo.new(0.25), {TextColor3 = Color3.new(1, 1, 1)}):Play()
    end)
    
    return btn
end

createSidebarBtn("Alts")
createSidebarBtn("Teleport")
createSidebarBtn("Buyers")
createSidebarBtn("Misc")
createSidebarBtn("Settings")

for _, btn in pairs(Sidebar:GetChildren()) do
    if btn:IsA("TextButton") and btn:FindFirstChild("TextLabel") then
        local label = btn.TextLabel
        label.TextXAlignment = Enum.TextXAlignment.Center
    end
end


showPage("Alts")
task.defer(function()
    local firstBtn = Sidebar:FindFirstChildOfClass("TextButton")
    if firstBtn then
        TweenService:Create(firstBtn, TweenInfo.new(0.25), {BackgroundTransparency = 0.85, BackgroundColor3 = Color3.fromRGB(30,30,45)}):Play()
        if firstBtn:FindFirstChild("TextLabel") then
            firstBtn.TextLabel.TextColor3 = Color3.new(1, 1, 1)
        end
    end
end)


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
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local tween = TweenService:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = loc.Position})
                tween:Play()
            end
        end)
    end)
end

-- Teleport section removed as requested

local bringSep = Instance.new("Frame")
bringSep.Size = UDim2.new(0.9, 0, 0, 1)
bringSep.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bringSep.BorderSizePixel = 0
bringSep.Parent = Tabs.Teleport

local bringBtn = Instance.new("TextButton")
bringBtn.Size = UDim2.new(0.95, 0, 0, 40)
bringBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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
    TweenService:Create(bringBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
end)
bringBtn.MouseLeave:Connect(function()
    TweenService:Create(bringBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
end)

bringBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            getgenv().BotConfig.TargetCFrame = char.HumanoidRootPart.CFrame
            syncConfig("TargetCFrame", char.HumanoidRootPart.CFrame)
        end
    end)
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
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, 0)
    btn.AnchorPoint = Vector2.new(0, 0.5)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(30, 30, 30)
    btn.Text = ""
    btn.Parent = frame
    
    local btnC = Instance.new("UICorner")
    btnC.CornerRadius = UDim.new(1, 0)
    btnC.Parent = btn
    
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
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(30, 30, 30)}):Play()
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
    label.Font = Enum.Font.GothamBold
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
    input.Font = Enum.Font.GothamBold
    input.TextSize = 13
    input.ClipsDescendants = true
    input.Parent = frame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    
    local is = Instance.new("UIStroke")
    is.Color = Color3.fromRGB(40, 40, 40)
    is.Thickness = 1
    is.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    is.Parent = input

    input.Focused:Connect(function()
        TweenService:Create(is, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 255, 120)}):Play()
    end)
    
    input.FocusLost:Connect(function()
        TweenService:Create(is, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 40)}):Play()
        local val = parseShorthand(input.Text)
        if val > 0 then
            val = math.clamp(val, min, max)
            input.Text = formatCash(val)
            callback(val)
        else
            input.Text = tostring(default)
            callback(default)
        end
    end)
end

createInput(AltsScroll, "Drop Amount (Max 15k)", 1, 15000, 15000, function(v) getgenv().BotConfig.DropAmount = v; syncConfig("DropAmount", v) end)

-- Redundant sections removed
local BuyerScroll = Tabs.Buyers

local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(0.95, 0, 0, 35)
searchFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
searchFrame.Parent = BuyerScroll

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(0, 8)
sc.Parent = searchFrame

local searchInput = Instance.new("TextBox")
searchInput.Size = UDim2.new(1, -20, 1, 0)
searchInput.Position = UDim2.new(0, 10, 0, 0)
searchInput.BackgroundTransparency = 1
searchInput.PlaceholderText = "Search players to whitelist..."
searchInput.Text = ""
searchInput.TextColor3 = Color3.new(1, 1, 1)
searchInput.Font = Enum.Font.GothamMedium
searchInput.TextSize = 12
searchInput.TextXAlignment = Enum.TextXAlignment.Left
searchInput.Parent = searchFrame

local SearchResults = Instance.new("Frame")
SearchResults.Size = UDim2.new(0.95, 0, 0, 0)
SearchResults.AutomaticSize = Enum.AutomaticSize.Y
SearchResults.BackgroundTransparency = 1
SearchResults.Parent = BuyerScroll

local srList = Instance.new("UIListLayout")
srList.Padding = UDim.new(0, 4)
srList.Parent = SearchResults

local CurrentWhitelist = Instance.new("Frame")
CurrentWhitelist.Size = UDim2.new(0.95, 0, 0, 0)
CurrentWhitelist.AutomaticSize = Enum.AutomaticSize.Y
CurrentWhitelist.BackgroundTransparency = 1
CurrentWhitelist.Parent = BuyerScroll

local cwList = Instance.new("UIListLayout")
cwList.Padding = UDim.new(0, 4)
cwList.Parent = CurrentWhitelist

local function refreshBuyers()
    CurrentWhitelist:ClearAllChildren()
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 5)
    l.Parent = CurrentWhitelist
    
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1, 0, 0, 20)
    h.BackgroundTransparency = 1
    h.Text = "WHITELISTED BUYERS"
    h.TextColor3 = Color3.fromRGB(120, 120, 140)
    h.Font = Enum.Font.GothamBold
    h.TextSize = 9
    h.Parent = CurrentWhitelist

    for i, name in ipairs(getgenv().BotConfig.WhitelistedBuyers) do
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, 0, 0, 32)
        entry.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        entry.Parent = CurrentWhitelist
        Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 6)
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, -40, 1, 0)
        txt.Position = UDim2.new(0, 12, 0, 0)
        txt.BackgroundTransparency = 1
        txt.Text = name
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.Font = Enum.Font.GothamMedium
        txt.TextSize = 11
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Parent = entry
        
        local del = Instance.new("TextButton")
        del.Size = UDim2.new(0, 24, 0, 24)
        del.Position = UDim2.new(1, -28, 0.5, 0)
        del.AnchorPoint = Vector2.new(0, 0.5)
        del.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        del.Text = "X"
        del.TextColor3 = Color3.new(1, 1, 1)
        del.Parent = entry
        Instance.new("UICorner", del).CornerRadius = UDim.new(0, 4)
        
        del.MouseButton1Click:Connect(function()
            table.remove(getgenv().BotConfig.WhitelistedBuyers, i)
            syncConfig("WhitelistedBuyers", getgenv().BotConfig.WhitelistedBuyers)
            refreshBuyers()
        end)
    end
end

local function updateSearch(query)
    SearchResults:ClearAllChildren()
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 4)
    l.Parent = SearchResults
    
    if query == "" then return end
    
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Name:lower():find(query:lower()) or p.DisplayName:lower():find(query:lower())) then
            count = count + 1
            if count > 5 then break end
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            btn.Text = "   + " .. p.DisplayName .. " (@" .. p.Name .. ")"
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = SearchResults
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            btn.MouseButton1Click:Connect(function()
                if not table.find(getgenv().BotConfig.WhitelistedBuyers, p.Name) then
                    table.insert(getgenv().BotConfig.WhitelistedBuyers, p.Name)
                    syncConfig("WhitelistedBuyers", getgenv().BotConfig.WhitelistedBuyers)
                    refreshBuyers()
                    searchInput.Text = ""
                    SearchResults:ClearAllChildren()
                end
            end)
        end
    end
end

searchInput:GetPropertyChangedSignal("Text"):Connect(function()
    updateSearch(searchInput.Text)
end)

refreshBuyers()

local UtilsHeader = Instance.new("TextLabel")
UtilsHeader.Size = UDim2.new(1, 0, 0, 30)
UtilsHeader.BackgroundTransparency = 1
UtilsHeader.Text = "MONEY UTILITIES"
UtilsHeader.TextColor3 = Color3.fromRGB(120, 120, 140)
UtilsHeader.Font = Enum.Font.GothamBold
UtilsHeader.TextSize = 9
UtilsHeader.Parent = BuyerScroll

createToggle(BuyerScroll, "Money ESP", false, function(v) 
    getgenv().BotConfig.MoneyESP = v
    if not v then
        -- Immediately clean up all ESP when disabled
        pcall(function()
            if getgenv()._MoneyESPFolder then
                getgenv()._MoneyESPFolder:Destroy()
                getgenv()._MoneyESPFolder = nil
            end
        end)
        -- Clean up drop highlights
        pcall(function()
            local dropFolder = workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild("Drop")
            if dropFolder then
                for _, item in pairs(dropFolder:GetChildren()) do
                    local h = item:FindFirstChild("KamaikHighlight")
                    if h then h:Destroy() end
                end
            end
        end)
    end
end)

createToggle(BuyerScroll, "Auto Pickup Money", false, function(v) 
    getgenv().BotConfig.AutoPickup = v
    syncConfig("AutoPickup", v) 
end)

createToggle(BuyerScroll, "Anti-Sit", true, function(v) getgenv().BotConfig.AntiSit = v; syncConfig("AntiSit", v) end)

-- Pickup range slider
createInput(BuyerScroll, "Pickup Range (studs)", 10, 200, 65, function(v)
    getgenv().BotConfig.PickupRange = v
    syncConfig("PickupRange", v)
end)

-- ============================================================
-- FIXED MONEY ESP SYSTEM
-- Uses a folder in CoreGui for billboards (persistent across deaths)
-- Throttled update loop instead of per-frame Heartbeat
-- Proper cleanup on player leave / ESP disable
-- ============================================================

if not getgenv().InitialCashCache then getgenv().InitialCashCache = {} end

local function getOrCreateESPFolder()
    if getgenv()._MoneyESPFolder and getgenv()._MoneyESPFolder.Parent then
        return getgenv()._MoneyESPFolder
    end
    local folder = Instance.new("Folder")
    folder.Name = "KamaikMoneyESP"
    folder.Parent = container
    getgenv()._MoneyESPFolder = folder
    return folder
end

local function createPlayerESP(player, espFolder)
    local existing = espFolder:FindFirstChild("ESP_" .. player.Name)
    if existing then return existing end
    
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local esp = Instance.new("BillboardGui")
    esp.Name = "ESP_" .. player.Name
    esp.Size = UDim2.new(0, 160, 0, 75)
    esp.AlwaysOnTop = true
    esp.Adornee = hrp
    esp.ExtentsOffset = Vector3.new(0, 4.5, 0)
    esp.ResetOnSpawn = false
    esp.Parent = espFolder
    
    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    frame.BackgroundTransparency = 0.15
    frame.Parent = esp
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 120)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.4
    stroke.Parent = frame
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.Text = player.DisplayName:upper()
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 9
    header.Parent = frame
    
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0.9, 0, 0, 1)
    sep.Position = UDim2.new(0.05, 0, 0, 20)
    sep.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sep.BorderSizePixel = 0
    sep.Parent = frame
    
    local av = Instance.new("ImageLabel")
    av.Size = UDim2.new(0, 32, 0, 32)
    av.Position = UDim2.new(0, 8, 0, 28)
    av.BackgroundTransparency = 1
    av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(player.UserId) .. "&w=150&h=150"
    av.Parent = frame
    Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
    
    local function createLabel(name, pos, color, size)
        local l = Instance.new("TextLabel")
        l.Name = name
        l.Size = UDim2.new(1, -50, 0, 14)
        l.Position = pos
        l.BackgroundTransparency = 1
        l.Text = "$0"
        l.TextColor3 = color
        l.Font = Enum.Font.GothamBold
        l.TextSize = size or 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = frame
        return l
    end
    
    createLabel("Wallet", UDim2.new(0, 46, 0, 26), Color3.fromRGB(0, 255, 120), 11)
    createLabel("Bank", UDim2.new(0, 46, 0, 40), Color3.fromRGB(255, 100, 255), 9)
    
    local gained = createLabel("Gained", UDim2.new(0, 46, 0, 56), Color3.fromRGB(0, 200, 255), 9)
    gained.Text = "+$0 PICKED UP"
    
    return esp
end

-- Money ESP + Drop ESP + Auto Pickup (throttled loop, NOT per-frame)
task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
        
        pcall(function()
            -- Money DROP ESP (highlights on ground money)
            if getgenv().BotConfig.MoneyESP then
                local dropFolder = workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild("Drop")
                if dropFolder then
                    for _, item in pairs(dropFolder:GetChildren()) do
                        if (item.Name == "MoneyDrop" or item.Name:match("Money") or item.Name:match("Drop")) and not item:FindFirstChild("KamaikHighlight") then
                            local h = Instance.new("Highlight")
                            h.Name = "KamaikHighlight"
                            h.FillTransparency = 0.7
                            h.FillColor = Color3.fromRGB(0, 255, 100)
                            h.OutlineColor = Color3.new(1, 1, 1)
                            h.OutlineTransparency = 0.3
                            h.Parent = item
                            
                            -- Also add a distance label
                            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if myHrp then
                                local bb = item:FindFirstChild("KamaikDistLabel")
                                if not bb then
                                    bb = Instance.new("BillboardGui")
                                    bb.Name = "KamaikDistLabel"
                                    bb.Size = UDim2.new(0, 60, 0, 20)
                                    bb.AlwaysOnTop = true
                                    bb.ExtentsOffset = Vector3.new(0, 2, 0)
                                    bb.Parent = item
                                    
                                    local t = Instance.new("TextLabel")
                                    t.Name = "Dist"
                                    t.Size = UDim2.new(1, 0, 1, 0)
                                    t.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                                    t.BackgroundTransparency = 0.4
                                    t.TextColor3 = Color3.fromRGB(0, 255, 100)
                                    t.Font = Enum.Font.GothamBold
                                    t.TextSize = 10
                                    t.Text = "$"
                                    t.Parent = bb
                                    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 4)
                                end
                            end
                        end
                    end
                    
                    -- Update distance labels
                    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        for _, item in pairs(dropFolder:GetChildren()) do
                            local bb = item:FindFirstChild("KamaikDistLabel")
                            if bb then
                                local distLabel = bb:FindFirstChild("Dist")
                                if distLabel and item:IsA("BasePart") then
                                    local dist = math.floor((myHrp.Position - item.Position).Magnitude)
                                    distLabel.Text = "$  " .. dist .. "st"
                                elseif distLabel then
                                    -- Model
                                    local primary = item:FindFirstChildWhichIsA("BasePart")
                                    if primary then
                                        local dist = math.floor((myHrp.Position - primary.Position).Magnitude)
                                        distLabel.Text = "$  " .. dist .. "st"
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- PLAYER CASH ESP
            if getgenv().BotConfig.MoneyESP then
                local espFolder = getOrCreateESPFolder()
                local buyers = getgenv().BotConfig.WhitelistedBuyers or {}
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer then
                        local char = p.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        
                        if hrp then
                            local esp = createPlayerESP(p, espFolder)
                            if esp then
                                esp.Adornee = hrp
                                
                                local df = p:FindFirstChild("DataFolder")
                                if df then
                                    local wallet = df:FindFirstChild("Currency") and df.Currency.Value or 0
                                    local bank = df:FindFirstChild("Bank") and df.Bank.Value or 0
                                    
                                    if not getgenv().InitialCashCache[p.UserId] then
                                        getgenv().InitialCashCache[p.UserId] = wallet
                                    end
                                    
                                    local gained = wallet - getgenv().InitialCashCache[p.UserId]
                                    local isBuyer = table.find(buyers, p.UserId) or table.find(buyers, p.Name)
                                    
                                    local fr = esp:FindFirstChild("Frame")
                                    if fr then
                                        local w = fr:FindFirstChild("Wallet")
                                        local b = fr:FindFirstChild("Bank")
                                        local g = fr:FindFirstChild("Gained")
                                        local s = fr:FindFirstChild("UIStroke")
                                        
                                        if w then w.Text = "$" .. formatCash(wallet) end
                                        if b then b.Text = "$" .. formatCash(bank) end
                                        
                                        if g then 
                                            local oldG = tonumber(g.Text:match("%$([%d,]+)")) or 0
                                            g.Text = "+$" .. formatCash(math.max(0, gained)) .. " PICKED"
                                            
                                            -- Pulse effect on pickup
                                            if gained > 0 and gained > oldG then
                                                TweenService:Create(fr, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {BackgroundColor3 = Color3.fromRGB(0, 50, 40), BackgroundTransparency = 0}):Play()
                                            end
                                        end
                                        
                                        if s then
                                            if isBuyer then
                                                s.Color = Color3.fromRGB(255, 215, 0) -- Gold for buyers
                                                s.Transparency = 0
                                            else
                                                s.Color = gained > 0 and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(0, 255, 120)
                                                s.Transparency = gained > 0 and 0 or 0.4
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            local existing = espFolder:FindFirstChild("ESP_" .. p.Name)
                            if existing then existing.Adornee = nil end
                        end
                    end
                end
                
                -- Clean up ESP for players who left
                for _, child in pairs(espFolder:GetChildren()) do
                    local playerName = child.Name:gsub("ESP_", "")
                    if not Players:FindFirstChild(playerName) then
                        child:Destroy()
                    end
                end
            else
                -- ESP disabled - clean up
                if getgenv()._MoneyESPFolder and getgenv()._MoneyESPFolder.Parent then
                    getgenv()._MoneyESPFolder:Destroy()
                    getgenv()._MoneyESPFolder = nil
                end
            end
        end)
        
        task.wait(0.5) -- Throttled to 2x per second instead of every frame
    end
end)

-- Clean up ESP on player leaving
trackTask(Players.PlayerRemoving:Connect(function(player)
    pcall(function()
        if getgenv()._MoneyESPFolder then
            local esp = getgenv()._MoneyESPFolder:FindFirstChild("ESP_" .. player.Name)
            if esp then esp:Destroy() end
        end
        if getgenv().InitialCashCache then
            getgenv().InitialCashCache[player.UserId] = nil
        end
    end)
end))

-- Re-adorn ESP when players respawn
trackTask(Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        if getgenv().BotConfig.MoneyESP and getgenv()._MoneyESPFolder then
            local esp = getgenv()._MoneyESPFolder:FindFirstChild("ESP_" .. player.Name)
            if esp then
                local hrp = char:WaitForChild("HumanoidRootPart", 5)
                if hrp then
                    esp.Adornee = hrp
                end
            end
        end
    end)
end))

-- Also connect for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        pcall(function()
            player.CharacterAdded:Connect(function(char)
                task.wait(1)
                if getgenv().BotConfig.MoneyESP and getgenv()._MoneyESPFolder then
                    local esp = getgenv()._MoneyESPFolder:FindFirstChild("ESP_" .. player.Name)
                    if esp then
                        local hrp = char:WaitForChild("HumanoidRootPart", 5)
                        if hrp then
                            esp.Adornee = hrp
                        end
                    end
                end
            end)
        end)
    end
end

-- ============================================================
-- FIXED AUTO COLLECT MONEY SYSTEM 
-- Throttled loop (every 0.3s), proper range check, multiple item types
-- Uses both fireclickdetector and fireproximityprompt for compatibility
-- ============================================================
task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
        
        if getgenv().BotConfig.AutoPickup then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local pickupRange = getgenv().BotConfig.PickupRange or 65
                
                -- Check multiple possible drop folder locations
                local ignored = workspace:FindFirstChild("Ignored")
                if not ignored then return end
                
                local dropFolders = {}
                local dropFolder = ignored:FindFirstChild("Drop")
                local cashFolder = ignored:FindFirstChild("DroppedCash")
                if dropFolder then table.insert(dropFolders, dropFolder) end
                if cashFolder then table.insert(dropFolders, cashFolder) end
                
                for _, folder in pairs(dropFolders) do
                    for _, item in pairs(folder:GetChildren()) do
                        -- Check all money-related names
                        local isMoneyItem = item.Name == "MoneyDrop" 
                            or item.Name:lower():match("money") 
                            or item.Name:lower():match("cash")
                            or item.Name:lower():match("drop")
                        
                        if isMoneyItem then
                            -- Calculate distance
                            local itemPos
                            if item:IsA("BasePart") then
                                itemPos = item.Position
                            elseif item:IsA("Model") then
                                local primary = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                                if primary then itemPos = primary.Position end
                            end
                            
                            if itemPos and (hrp.Position - itemPos).Magnitude < pickupRange then
                                -- Try multiple pickup methods
                                local cd = item:FindFirstChild("ClickDetector") or item:FindFirstChildWhichIsA("ClickDetector", true)
                                if cd then
                                    pcall(function() fireclickdetector(cd) end)
                                end
                                
                                local pp = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if pp then
                                    pcall(function() fireproximityprompt(pp) end)
                                end
                                
                                -- Also try touching with character
                                pcall(function()
                                    if item:IsA("BasePart") then
                                        firetouchinterest(hrp, item, 0)
                                        task.defer(function()
                                            pcall(function() firetouchinterest(hrp, item, 1) end)
                                        end)
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        end
        
        task.wait(0.3) -- Throttled collection rate
    end
end)


local function createMiscBtn(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
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
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local cf = LocalPlayer.Character.HumanoidRootPart.CFrame
            getgenv().BotConfig.TargetCFrame = cf
            syncConfig("TargetCFrame", cf)
        end
    end)
end)


-- Bot Deployment Setups removed as requested


local TPHeader = Instance.new("TextLabel")
TPHeader.Size = UDim2.new(1, -20, 0, 25)
TPHeader.BackgroundTransparency = 1
TPHeader.Text = "LOCAL PLAYER TELEPORTS"
TPHeader.TextColor3 = Color3.fromRGB(120, 120, 140)
TPHeader.Font = Enum.Font.GothamBold
TPHeader.TextSize = 9
TPHeader.Parent = Tabs.Teleport

local TPGrid = Instance.new("Frame")
TPGrid.Size = UDim2.new(1, -20, 0, 100)
TPGrid.BackgroundTransparency = 1
TPGrid.Parent = Tabs.Teleport

local grid2 = Instance.new("UIGridLayout")
grid2.CellSize = UDim2.new(0.48, 0, 0, 40)
grid2.CellPadding = UDim2.new(0, 8, 0, 8)
grid2.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid2.Parent = TPGrid

createMiscBtn(TPGrid, "TP -> BANK", function() 
    pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-434, 34, -282) end)
end)
createMiscBtn(TPGrid, "TP -> CLUB", function() 
    pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-266.1, -2.2, -367.2) end)
end)

createMiscBtn(Tabs.Misc, "Rejoin Server", function()
    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end)

createMiscBtn(Tabs.Misc, "Server Hop", function()
    pcall(function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local success, raw = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100") end)
        if not success then return end
        
        local _servers = Http:JSONDecode(raw)
        for _, s in pairs(_servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TPS:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end)
end)

createToggle(Tabs.Settings, "Broadcast Anti-White Screen", true, function(v) getgenv().BotConfig.AntiWhiteScreen = v; syncConfig("AntiWhiteScreen", v) end)

createMiscBtn(Tabs.Settings, "Unload Script", function()
    unloadScript()
end)

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
    label.Font = Enum.Font.GothamBold
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
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = frame
    
    local bc2 = Instance.new("UICorner")
    bc2.CornerRadius = UDim.new(0, 6)
    bc2.Parent = btn
    
    local listening = false
    btn.MouseButton1Click:Connect(function()
        listening = true
        btn.Text = "..."
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 100, 255)}):Play()
    end)
    
    trackTask(UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            btn.Text = input.KeyCode.Name
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
            callback(input.KeyCode)
        end
    end))
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

trackTask(UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end))

trackTask(RunService.RenderStepped:Connect(function()
    if getgenv().Kamaik_Unloaded then return end
    if dragToggle and dragInput then
        updateInput(dragInput)
    end
end))

-- FIXED: UIScale now properly parented to MainFrame
local MainScale = Instance.new("UIScale")
MainScale.Scale = 1
MainScale.Parent = MainFrame
MainFrame.GroupTransparency = 0
MainFrame.Visible = true

local isGuiVisible = true
local function toggleGui(visible)
    isGuiVisible = visible
    if isGuiVisible then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
        TweenService:Create(MainScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1}):Play()
        local t = TweenService:Create(MainScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0.9})
        t:Play()
        t.Completed:Connect(function()
            if not isGuiVisible then MainFrame.Visible = false end
        end)
    end
end


MainFrame.GroupTransparency = 1
MainScale.Scale = 0.95
toggleGui(true)

trackTask(UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == ToggleKey then
        toggleGui(not isGuiVisible)
    end
end))
