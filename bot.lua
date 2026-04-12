local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local HttpService = game:GetService("HttpService")

getgenv().BotConfig = getgenv().BotConfig or {}
local defaults = {
    OwnerUsername = LocalPlayer.Name,
    AutoDrop = false,
    FollowOwner = false,
    DropAmount = 15000,
    AntiWhiteScreen = true,
    WhitelistedBuyers = {},
    AutoResetKO = true
}

for k, v in pairs(defaults) do
    if getgenv().BotConfig[k] == nil then
        getgenv().BotConfig[k] = v
    end
end

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

task.spawn(function()
    while true do
        pcall(function()
            if isfile("bot_control.json") then
                local data = readfile("bot_control.json")
                local config = HttpService:JSONDecode(data)
                for k, v in pairs(config) do
                    if k == "TargetCFrame" and type(v) == "table" then
                        getgenv().BotConfig[k] = CFrame.new(unpack(v))
                    else
                        getgenv().BotConfig[k] = v
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

local AltConfig = {
    MinAge = 7,
    Whitelist = {LocalPlayer.UserId}
}

local function checkAlt(player)
    if player.AccountAge < AltConfig.MinAge and not table.find(AltConfig.Whitelist, player.UserId) then
        print("[!] Alt Detected: " .. player.Name .. " (Age: " .. player.AccountAge .. ")")
    end
end

Players.PlayerAdded:Connect(checkAlt)
for _, p in ipairs(Players:GetPlayers()) do checkAlt(p) end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AntiWhiteScreen"
ScreenGui.DisplayOrder = 100
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local BlackFrame = Instance.new("Frame")
BlackFrame.Size = UDim2.new(1, 0, 1, 0)
BlackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
BlackFrame.BorderSizePixel = 0
BlackFrame.Parent = ScreenGui

local Dashboard = Instance.new("Frame")
Dashboard.Size = UDim2.new(0, 280, 0, 140)
Dashboard.AnchorPoint = Vector2.new(0.5, 0.5)
Dashboard.Position = UDim2.new(0.5, 0, 0.5, 0)
Dashboard.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Dashboard.BackgroundTransparency = 0.4
Dashboard.BorderSizePixel = 0
Dashboard.Parent = ScreenGui

local DashboardUICorner = Instance.new("UICorner")
DashboardUICorner.CornerRadius = UDim.new(0, 12)
DashboardUICorner.Parent = Dashboard

local DashboardStroke = Instance.new("UIStroke")
DashboardStroke.Thickness = 1.5
DashboardStroke.Color = Color3.new(1, 1, 1)
DashboardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
DashboardStroke.Transparency = 0.6
DashboardStroke.Parent = Dashboard

local DashboardGradient = Instance.new("UIGradient")
DashboardGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0))
})
DashboardGradient.Rotation = 45
DashboardGradient.Parent = DashboardStroke

local Glow = Instance.new("ImageLabel")
Glow.Name = "Glow"
Glow.BackgroundTransparency = 1
Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.Size = UDim2.new(1, 120, 1, 120)
Glow.Image = "rbxassetid://4975687002"
Glow.ImageColor3 = Color3.new(0, 1, 0)
Glow.ImageTransparency = 0.4
Glow.ZIndex = Dashboard.ZIndex - 1
Glow.Parent = Dashboard

task.spawn(function()
    while true do
        TweenService:Create(Glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.6}):Play()
        task.wait(2)
        TweenService:Create(Glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.2}):Play()
        task.wait(2)
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 20)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "DA HOOD BOT [V1.3]"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 10
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Dashboard

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
TitleGradient.Rotation = 90
TitleGradient.Parent = Title

local StatusLight = Instance.new("Frame")
StatusLight.Size = UDim2.new(0, 6, 0, 6)
StatusLight.Position = UDim2.new(1, -15, 0, 17)
StatusLight.AnchorPoint = Vector2.new(0.5, 0.5)
StatusLight.BackgroundColor3 = Color3.new(0, 1, 0)
StatusLight.BorderSizePixel = 0
StatusLight.Parent = Dashboard

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusLight

task.spawn(function()
    while true do
        TweenService:Create(StatusLight, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.8}):Play()
        task.wait(0.5)
        TweenService:Create(StatusLight, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
        task.wait(0.5)
    end
end)

local MoneyLabel = Instance.new("TextLabel")
MoneyLabel.Size = UDim2.new(1, -20, 0, 40)
MoneyLabel.Position = UDim2.new(0, 10, 0, 30)
MoneyLabel.BackgroundTransparency = 1
MoneyLabel.Text = "$0"
MoneyLabel.TextColor3 = Color3.new(1, 1, 1)
MoneyLabel.Font = Enum.Font.GothamBold
MoneyLabel.TextSize = 28
MoneyLabel.TextXAlignment = Enum.TextXAlignment.Left
MoneyLabel.Parent = Dashboard

local MoneyGradient = Instance.new("UIGradient")
MoneyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 0))
})
MoneyGradient.Rotation = 90
MoneyGradient.Parent = MoneyLabel

local NotifyFrame = Instance.new("Frame")
NotifyFrame.Size = UDim2.new(1, -20, 0, 50)
NotifyFrame.Position = UDim2.new(0, 10, 0, 75)
NotifyFrame.BackgroundTransparency = 1
NotifyFrame.Parent = Dashboard

local UIList = Instance.new("UIListLayout")
UIList.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 2)
UIList.Parent = NotifyFrame

local function notify(msg)
    task.spawn(function()
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 0, 15)
        t.BackgroundTransparency = 1
        t.Text = tostring(msg)
        t.TextColor3 = Color3.new(1, 1, 1)
        t.Font = Enum.Font.GothamMedium
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextTransparency = 1
        t.RichText = true
        t.Parent = NotifyFrame
        
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
        })
        g.Rotation = 90
        g.Parent = t
        
        TweenService:Create(t, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        task.wait(4)
        local tween = TweenService:Create(t, TweenInfo.new(1), {TextTransparency = 1})
        tween:Play()
        tween.Completed:Wait()
        t:Destroy()
    end)
end

local function format(val)
    return tostring(val):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local visualCash = Instance.new("NumberValue")
visualCash.Value = 0
visualCash.Changed:Connect(function()
    MoneyLabel.Text = "$" .. format(math.floor(visualCash.Value))
end)

task.spawn(function()
    local df = LocalPlayer:WaitForChild("DataFolder", 10)
    local cur = df and df:WaitForChild("Currency", 5)
    if cur then
        local function update(newVal) 
            TweenService:Create(visualCash, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Value = cur.Value}):Play()
        end
        cur:GetPropertyChangedSignal("Value"):Connect(update)
        update(cur.Value)
    end
end)

pcall(function()
    if setfpscap then setfpscap(15) end
    RunService:Set3dRenderingEnabled(not getgenv().BotConfig.AntiWhiteScreen)
end)

local formationOffset = (function()
    local name = LocalPlayer.Name
    local hash = 0
    for i = 1, #name do hash = hash + string.byte(name, i) end
    local angle = (hash % 360) / 360 * (math.pi * 2)
    return Vector3.new(math.cos(angle) * 7, 5, math.sin(angle) * 7)
end)()

RunService.Heartbeat:Connect(function()
    if getgenv().BotConfig.FollowOwner and getgenv().BotConfig.OwnerUsername ~= "" then
        pcall(function()
            local owner = Players:FindFirstChild(getgenv().BotConfig.OwnerUsername)
            local char = LocalPlayer.Character
            if owner and owner.Character and owner.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
                local targetCF = owner.Character.HumanoidRootPart.CFrame * CFrame.new(formationOffset)
                char.HumanoidRootPart.CFrame = targetCF
            end
        end)
    end
end)

local lastRejoin = 0
local lastRefresh = 0

task.spawn(function()
    while task.wait(1) do
        if getgenv().BotConfig.RejoinSignal and getgenv().BotConfig.RejoinSignal > lastRejoin then
            lastRejoin = getgenv().BotConfig.RejoinSignal
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end
        if getgenv().BotConfig.RefreshAvatarSignal and getgenv().BotConfig.RefreshAvatarSignal > lastRefresh then
            lastRefresh = getgenv().BotConfig.RefreshAvatarSignal
            LocalPlayer:LoadCharacter()
        end
    end
end)

setmetatable(getgenv().BotConfig, {
    __newindex = function(t, k, v)
        rawset(t, k, v)
        if k == "AntiWhiteScreen" then
            RunService:Set3dRenderingEnabled(not v)
        end
    end
})

RunService.Stepped:Connect(function()
    local ignored = workspace:FindFirstChild("Ignored")
    local dropped = ignored and ignored:FindFirstChild("DroppedCash")
    if dropped then
        for _, v in pairs(dropped:GetChildren()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, v in pairs(p.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end
end)

LocalPlayer.Idled:Connect(function() 
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) 
end)

local TPs = {
    Club = CFrame.new(-266.1, -2.2, -367.2)
}

local function doTP(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local dist = (hrp.Position - targetCFrame.Position).Magnitude
        
        local tweenInfo = TweenInfo.new(dist / 90, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        
        local noclip
        noclip = RunService.Stepped:Connect(function()
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
            end
        end)
        
        tween:Play()
        tween.Completed:Wait()
        if noclip then noclip:Disconnect() end
    end
end

if not game:IsLoaded() then game.Loaded:Wait() end
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart", 5)

local ME = ReplicatedStorage:WaitForChild("MainEvent")

task.spawn(function()
    local codes = {
        "SpringTime26", "EASTER26", "APRIL26", "DEAGLE", "SPRING26"
    }
    notify("Auto-Redeeming Codes...")
    for _, c in ipairs(codes) do 
        pcall(function() ME:FireServer("EnterPromoCode", c) end)
        notify("Code: <font color=\"#00FF00\">" .. c .. "</font>")
        task.wait(1.5) 
    end
    notify("Codes Complete.")
end)

task.spawn(function()
    if hrp then
        task.wait(5)
        local targetCF = TPs.Club * CFrame.new(0, 7, 0)
        local plat = Instance.new("Part")
        plat.Size = Vector3.new(25, 1, 25)
        plat.Anchored = true
        plat.Transparency = 1
        plat.CFrame = targetCF * CFrame.new(0, -2, 0)
        plat.Parent = workspace
        doTP(targetCF)
    end
    
    while true do
        if getgenv().BotConfig.ResetSignal or (getgenv().BotConfig.AutoResetKO and (function()
            local be = char and char:FindFirstChild("BodyEffects")
            return be and be:FindFirstChild("K.O") and be["K.O"].Value == true
        end)()) then
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Health = 0
            end
            task.wait(1)
        end
        if getgenv().BotConfig.AutoDrop then
            char = LocalPlayer.Character
            local isAlive = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
            local be = char and char:FindFirstChild("BodyEffects")
            local isKO = be and be:FindFirstChild("K.O") and be["K.O"].Value == true
            
            if isAlive and not isKO then
                local dropPos = TPs.Club * CFrame.new(math.random(-6, 6), 7, math.random(-6, 6))
                
                if getgenv().BotConfig.TargetCFrame then
                    dropPos = getgenv().BotConfig.TargetCFrame * CFrame.new(math.random(-6, 6), 7, math.random(-6, 6))
                end

                if char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = dropPos
                end
                
                pcall(function() ME:FireServer("DropMoney", tostring(getgenv().BotConfig.DropAmount)) end)
                
                local hum = char:FindFirstChild("Humanoid")
                if hum and char:FindFirstChild("HumanoidRootPart") then
                    local rOffset = Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
                    hum:MoveTo(dropPos.Position + rOffset)
                end
            end
            task.wait(15.5)
        else
            task.wait(1)
        end
    end
end)
