--[[
    PrivT Script - BILINGUAL EDITION
    ESP + Aimbot + Speed + Jump + Noclip + Sky + FPS Boost
    РУССКИЙ / ENGLISH
]]

-- Проверка на инжектор
if not Drawing then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ошибка / Error",
        Text = "Нужен инжектор! / Need injector! (Krnl, Synapse)",
        Duration = 3
    })
    return
end

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- ЯЗЫК / LANGUAGE
-- ============================================
local Language = "RU" -- "RU" или "EN"
local function text(ru, en)
    return Language == "RU" and ru or en
end

-- ============================================
-- НАСТРОЙКИ
-- ============================================
local Settings = {
    ESP = false,
    Aimbot = false,
    Speed = false,
    Jump = false,
    Noclip = false,
    FPS = false,
    Sky = false,
    Boost = false
}

-- Переменные
local speedValue = 25
local jumpValue = 100
local fps = 60
local ping = 0
local frameCount = 0
local lastTime = tick()
local menuOpen = true
local currentSky = nil
local noclipConnection = nil

-- ============================================
-- НЕБО
-- ============================================
local skyBoxes = {
    [1] = { ru = "🌙 Ночь", en = "🌙 Night", SkyboxUp = "rbxassetid://159451316", SkyboxDn = "rbxassetid://159451291", SkyboxLf = "rbxassetid://159451306", SkyboxRt = "rbxassetid://159451311", SkyboxFc = "rbxassetid://159451301", SkyboxBk = "rbxassetid://159451296" },
    [2] = { ru = "🌅 Закат", en = "🌅 Sunset", SkyboxUp = "rbxassetid://159451211", SkyboxDn = "rbxassetid://159451186", SkyboxLf = "rbxassetid://159451201", SkyboxRt = "rbxassetid://159451206", SkyboxFc = "rbxassetid://159451196", SkyboxBk = "rbxassetid://159451191" },
    [3] = { ru = "☀️ День", en = "☀️ Day", SkyboxUp = "rbxassetid://159451256", SkyboxDn = "rbxassetid://159451231", SkyboxLf = "rbxassetid://159451246", SkyboxRt = "rbxassetid://159451251", SkyboxFc = "rbxassetid://159451241", SkyboxBk = "rbxassetid://159451236" },
    [4] = { ru = "🌌 Космос", en = "🌌 Space", SkyboxUp = "rbxassetid://168802432", SkyboxDn = "rbxassetid://168802488", SkyboxLf = "rbxassetid://168802540", SkyboxRt = "rbxassetid://168802574", SkyboxFc = "rbxassetid://168802606", SkyboxBk = "rbxassetid://168802637" },
    [5] = { ru = "🌈 Киберпанк", en = "🌈 Cyberpunk", SkyboxUp = "rbxassetid://133986477", SkyboxDn = "rbxassetid://133986546", SkyboxLf = "rbxassetid://133986580", SkyboxRt = "rbxassetid://133986604", SkyboxFc = "rbxassetid://133986617", SkyboxBk = "rbxassetid://133986632" }
}

local function changeSky(skyType)
    if currentSky then
        currentSky:Destroy()
        currentSky = nil
    end
    
    local sky = Instance.new("Sky")
    sky.Parent = Lighting
    
    local data = skyBoxes[skyType] or skyBoxes[1]
    sky.SkyboxUp = data.SkyboxUp
    sky.SkyboxDn = data.SkyboxDn
    sky.SkyboxLf = data.SkyboxLf
    sky.SkyboxRt = data.SkyboxRt
    sky.SkyboxFc = data.SkyboxFc
    sky.SkyboxBk = data.SkyboxBk
    
    currentSky = sky
end

local function removeSky()
    if currentSky then
        currentSky:Destroy()
        currentSky = nil
    end
end

-- ============================================
-- FPS МОНИТОР
-- ============================================
local fpsText = Drawing.new("Text")
fpsText.Visible = false
fpsText.Size = 18
fpsText.Font = 3
fpsText.Outline = true
fpsText.OutlineColor = Color3.new(0, 0, 0)
fpsText.Color = Color3.fromRGB(0, 255, 255)
fpsText.Position = Vector2.new(15, 15)

local fpsBg = Drawing.new("Square")
fpsBg.Visible = false
fpsBg.Filled = true
fpsBg.Color = Color3.new(0, 0, 0)
fpsBg.Transparency = 0.5
fpsBg.Thickness = 0

-- ============================================
-- ESP
-- ============================================
local espBoxes = {}
local espNames = {}
local espHealthBars = {}
local espDistance = {}

local function createESP(player)
    if player == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 2
    box.Filled = false
    box.Color = Color3.fromRGB(255, 128, 0)
    espBoxes[player] = box
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 15
    name.Center = true
    name.Outline = true
    name.Color = Color3.new(1, 1, 1)
    name.Font = 2
    espNames[player] = name
    
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Filled = true
    healthBar.Thickness = 0
    espHealthBars[player] = healthBar
    
    local distance = Drawing.new("Text")
    distance.Visible = false
    distance.Size = 12
    distance.Center = true
    distance.Outline = true
    distance.Color = Color3.fromRGB(200, 200, 200)
    distance.Font = 2
    espDistance[player] = distance
end

for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)

Players.PlayerRemoving:Connect(function(player)
    if espBoxes[player] then espBoxes[player]:Remove() end
    if espNames[player] then espNames[player]:Remove() end
    if espHealthBars[player] then espHealthBars[player]:Remove() end
    if espDistance[player] then espDistance[player]:Remove() end
    espBoxes[player] = nil
    espNames[player] = nil
    espHealthBars[player] = nil
    espDistance[player] = nil
end)

-- ============================================
-- SPEED/JUMP/NOCLIP ФУНКЦИИ
-- ============================================
local function applySpeed()
    if LocalPlayer and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedValue
        end
    end
end

local function applyJump()
    if LocalPlayer and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = jumpValue
        end
    end
end

local function resetStats()
    if LocalPlayer and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
end

local function toggleNoclip()
    if Settings.Noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        if LocalPlayer and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.5)
    if Settings.Speed then applySpeed() end
    if Settings.Jump then applyJump() end
end)

-- ============================================
-- БУСТ FPS
-- ============================================
local function boostFPS()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end
    
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    workspace.Terrain.WaterWaveSize = 0
    workspace.Terrain.WaterWaveSpeed = 0
    workspace.Terrain.WaterReflectance = 0
    workspace.Terrain.WaterTransparency = 1
end

local function resetGraphics()
    settings().Rendering.QualityLevel = 3
    Lighting.GlobalShadows = true
    workspace.Terrain.WaterWaveSize = 0.1
    workspace.Terrain.WaterWaveSpeed = 5
    workspace.Terrain.WaterReflectance = 0.5
    workspace.Terrain.WaterTransparency = 0.8
end

-- ============================================
-- AIMBOT
-- ============================================
local function getClosestPlayer()
    local closest = nil
    local shortestDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local dist = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = player
                end
            end
        end
    end
    
    return closest
end

-- ============================================
-- ГЛАВНЫЙ ЦИКЛ
-- ============================================
RunService.RenderStepped:Connect(function()
    -- FPS
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastTime >= 1 then
        fps = frameCount
        frameCount = 0
        lastTime = currentTime
    end
    
    local stats = game:GetService("Stats")
    if stats and stats.Network and stats.Network.ServerStatsItem then
        ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
    end
    
    if Settings.FPS then
        local text = string.format("⚡ %d FPS  |  📶 %d ms", fps, ping)
        fpsText.Text = text
        fpsText.Visible = true
        
        local bounds = fpsText.TextBounds
        fpsBg.Visible = true
        fpsBg.Size = Vector2.new(bounds.X + 20, 30)
        fpsBg.Position = Vector2.new(5, 5)
    else
        fpsText.Visible = false
        fpsBg.Visible = false
    end
    
    -- Небо
    if Settings.Sky and not currentSky then
        changeSky(1)
    elseif not Settings.Sky and currentSky then
        removeSky()
    end
    
    -- ESP
    if Settings.ESP then
        for player, box in pairs(espBoxes) do
            if player and player.Character and player.Character:FindFirstChild("Humanoid") and 
               player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart") then
                
                local root = player.Character.HumanoidRootPart
                local head = player.Character:FindFirstChild("Head")
                local humanoid = player.Character.Humanoid
                
                if root and head and humanoid then
                    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local distance = (Camera.CFrame.Position - root.Position).Magnitude
                    
                    if onScreen then
                        local height = math.abs(headPos.Y - rootPos.Y) * 2
                        local width = height * 0.6
                        
                        box.Visible = true
                        box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y)
                        box.Size = Vector2.new(width, height)
                        
                        local name = espNames[player]
                        if name then
                            name.Visible = true
                            name.Position = Vector2.new(rootPos.X, rootPos.Y - 25)
                            name.Text = player.Name
                        end
                        
                        local healthBar = espHealthBars[player]
                        if healthBar then
                            healthBar.Visible = true
                            healthBar.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - 5)
                            healthBar.Size = Vector2.new(width * (humanoid.Health / humanoid.MaxHealth), 3)
                            
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            if healthPercent > 0.6 then
                                healthBar.Color = Color3.new(0, 1, 0)
                            elseif healthPercent > 0.3 then
                                healthBar.Color = Color3.new(1, 1, 0)
                            else
                                healthBar.Color = Color3.new(1, 0, 0)
                            end
                        end
                        
                        local distText = espDistance[player]
                        if distText then
                            distText.Visible = true
                            distText.Position = Vector2.new(rootPos.X, rootPos.Y + height/2 + 15)
                            distText.Text = math.floor(distance) .. "m"
                        end
                    else
                        box.Visible = false
                        if espNames[player] then espNames[player].Visible = false end
                        if espHealthBars[player] then espHealthBars[player].Visible = false end
                        if espDistance[player] then espDistance[player].Visible = false end
                    end
                end
            else
                if box then box.Visible = false end
                if espNames[player] then espNames[player].Visible = false end
                if espHealthBars[player] then espHealthBars[player].Visible = false end
                if espDistance[player] then espDistance[player].Visible = false end
            end
        end
    else
        for _, box in pairs(espBoxes) do box.Visible = false end
        for _, name in pairs(espNames) do name.Visible = false end
        for _, bar in pairs(espHealthBars) do bar.Visible = false end
        for _, dist in pairs(espDistance) do dist.Visible = false end
    end
    
    -- Aimbot
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- ============================================
-- КРАСИВОЕ БИЛИНГВАЛЬНОЕ МЕНЮ
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Parent = game:GetService("CoreGui")
gui.Name = "PrivT_Bilingual"
gui.ResetOnSpawn = false

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 650)
mainFrame.Position = UDim2.new(0, 30, 0, 30)
mainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui

-- Стеклянный эффект
local glassEffect = Instance.new("Frame")
glassEffect.Size = UDim2.new(1, 0, 1, 0)
glassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
glassEffect.BackgroundTransparency = 0.95
glassEffect.BorderSizePixel = 0
glassEffect.Parent = mainFrame

-- Сглаживание
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- Тень
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 10, 10)
shadow.Parent = mainFrame

-- Верхний градиент
local topGradient = Instance.new("Frame")
topGradient.Size = UDim2.new(1, 0, 0, 90)
topGradient.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
topGradient.BorderSizePixel = 0
topGradient.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 15)
topCorner.Parent = topGradient

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 100, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 20, 50))
})
gradient.Parent = topGradient

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 5)
title.Text = text("PRIVT ABSOLUTE", "PRIVT ABSOLUTE")
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 28
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = topGradient

-- Переключатель языка
local langBtn = Instance.new("TextButton")
langBtn.Size = UDim2.new(0, 60, 0, 30)
langBtn.Position = UDim2.new(1, -70, 0, 10)
langBtn.Text = Language == "RU" and "🇷🇺 RU" or "🇬🇧 EN"
langBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
langBtn.TextSize = 14
langBtn.Font = Enum.Font.GothamBold
langBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
langBtn.BorderSizePixel = 0
langBtn.Parent = topGradient

local langCorner = Instance.new("UICorner")
langCorner.CornerRadius = UDim.new(0, 8)
langCorner.Parent = langBtn

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 20)
subtitle.Position = UDim2.new(0, 0, 0, 60)
subtitle.Text = text("ВЫБОР СКОРОСТИ И ПРЫЖКА", "SPEED & JUMP SELECTION")
subtitle.TextColor3 = Color3.fromRGB(200, 180, 255)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.BackgroundTransparency = 1
subtitle.Parent = topGradient

-- Контейнер
local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -30, 1, -120)
container.Position = UDim2.new(0, 15, 0, 100)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ScrollBarThickness = 4
container.ScrollBarImageColor3 = Color3.fromRGB(140, 100, 220)
container.CanvasSize = UDim2.new(0, 0, 0, 1000)
container.Parent = mainFrame

-- Функция создания кнопки
local yPos = 0
local buttonHeight = 45
local spacing = 8

local function createButton(ruName, enName, icon, ruDesc, enDesc, yOffset)
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, 0, 0, buttonHeight)
    btnFrame.Position = UDim2.new(0, 0, 0, yOffset)
    btnFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    btnFrame.BackgroundTransparency = 0.3
    btnFrame.BorderSizePixel = 0
    btnFrame.Parent = container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btnFrame
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 35, 1, 0)
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.TextSize = 22
    iconLabel.Font = Enum.Font.Gotham
    iconLabel.BackgroundTransparency = 1
    iconLabel.Parent = btnFrame
    
    local btnText = Instance.new("TextLabel")
    btnText.Size = UDim2.new(1, -95, 1, 0)
    btnText.Position = UDim2.new(0, 40, 0, 0)
    btnText.Text = text(ruName, enName)
    btnText.TextColor3 = Color3.fromRGB(220, 220, 220)
    btnText.TextSize = 16
    btnText.Font = Enum.Font.Gotham
    btnText.BackgroundTransparency = 1
    btnText.TextXAlignment = Enum.TextXAlignment.Left
    btnText.Parent = btnFrame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 50, 1, 0)
    status.Position = UDim2.new(1, -55, 0, 0)
    status.Text = "OFF"
    status.TextColor3 = Color3.fromRGB(255, 80, 80)
    status.TextSize = 14
    status.Font = Enum.Font.GothamBold
    status.BackgroundTransparency = 1
    status.Parent = btnFrame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -40, 0, 15)
    descLabel.Position = UDim2.new(0, 40, 1, 2)
    descLabel.Text = text(ruDesc, enDesc)
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.BackgroundTransparency = 1
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = btnFrame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""
    btn.BackgroundTransparency = 1
    btn.Parent = btnFrame
    
    return {btn = btn, frame = btnFrame, status = status}
end

-- Функция создания ползунка
local function createSlider(ruName, enName, icon, min, max, default, ruDesc, enDesc, yOffset)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.Position = UDim2.new(0, 0, 0, yOffset)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    sliderFrame.BackgroundTransparency = 0.3
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 8)
    sliderCorner.Parent = sliderFrame
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 35, 1, 0)
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.TextSize = 22
    iconLabel.Font = Enum.Font.Gotham
    iconLabel.BackgroundTransparency = 1
    iconLabel.Parent = sliderFrame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -100, 0, 25)
    nameLabel.Position = UDim2.new(0, 40, 0, 5)
    nameLabel.Text = text(ruName, enName)
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 25)
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
    valueLabel.TextSize = 16
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = sliderFrame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -50, 0, 10)
    sliderBg.Position = UDim2.new(0, 40, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = sliderFrame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(0, 5)
    sliderBgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(140, 100, 220)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 5)
    sliderFillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, 0, 1, 0)
    sliderButton.Text = ""
    sliderButton.BackgroundTransparency = 1
    sliderButton.Parent = sliderBg
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -40, 0, 15)
    descLabel.Position = UDim2.new(0, 40, 1, -17)
    descLabel.Text = text(ruDesc, enDesc)
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.BackgroundTransparency = 1
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = sliderFrame
    
    local value = default
    
    sliderButton.MouseButton1Down:Connect(function()
        local moveConn
        local releaseConn
        
        moveConn = RunService.RenderStepped:Connect(function()
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local sliderPos = sliderBg.AbsolutePosition
            local sliderSize = sliderBg.AbsoluteSize.X
            
            local percent = math.clamp((mousePos.X - sliderPos.X) / sliderSize, 0, 1)
            value = math.floor(min + (max - min) * percent)
            valueLabel.Text = tostring(value)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        end)
        
        releaseConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                moveConn:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)
    
    return {
        frame = sliderFrame,
        get = function() return value end
    }
end

-- Создаем кнопки (билингвальные)
local espBtn = createButton("ESP", "ESP", "👁️", 
    "Подсветка игроков", "Player highlighting", yPos)
yPos = yPos + buttonHeight + spacing

local aimBtn = createButton("AIMBOT", "AIMBOT", "🎯", 
    "Автонаведение (ПКМ)", "Auto aim (RMB)", yPos)
yPos = yPos + buttonHeight + spacing

-- Слайдеры
local speedSlider = createSlider("СКОРОСТЬ", "SPEED", "⚡", 
    16, 100, 25, "Выбери скорость бега", "Select movement speed", yPos)
yPos = yPos + 68

local jumpSlider = createSlider("ПРЫЖОК", "JUMP", "🦘", 
    50, 200, 100, "Выбери силу прыжка", "Select jump power", yPos)
yPos = yPos + 68

local noclipBtn = createButton("NOCLIP", "NOCLIP", "👻", 
    "Проходить сквозь стены", "Walk through walls", yPos)
yPos = yPos + buttonHeight + spacing

local fpsBtn = createButton("FPS METER", "FPS METER", "📊", 
    "Монитор производительности", "Performance monitor", yPos)
yPos = yPos + buttonHeight + spacing

local skyBtn = createButton("НЕБО", "SKY", "🌌", 
    "Красивое небо", "Beautiful sky", yPos)
yPos = yPos + buttonHeight + spacing

-- Кнопки неба
local sky1Btn = createButton("  Ночь", "  Night", "🌙", 
    "Звездное небо", "Starry sky", yPos)
yPos = yPos + buttonHeight + spacing

local sky2Btn = createButton("  Закат", "  Sunset", "🌅", 
    "Розовое небо", "Pink sky", yPos)
yPos = yPos + buttonHeight + spacing

local sky3Btn = createButton("  День", "  Day", "☀️", 
    "Голубое небо", "Blue sky", yPos)
yPos = yPos + buttonHeight + spacing

local sky4Btn = createButton("  Космос", "  Space", "🌌", 
    "Галактика", "Galaxy", yPos)
yPos = yPos + buttonHeight + spacing

local sky5Btn = createButton("  Киберпанк", "  Cyberpunk", "🌈", 
    "Неоновое небо", "Neon sky", yPos)
yPos = yPos + buttonHeight + spacing

local boostBtn = createButton("FPS BOOST", "FPS BOOST", "🚀", 
    "Максимальная производительность", "Maximum performance", yPos)
yPos = yPos + buttonHeight + spacing

local resetBtn = createButton("СБРОС ВСЁ", "RESET ALL", "🔄", 
    "Сбросить все настройки", "Reset all settings", yPos)

-- Обновляем CanvasSize
container.CanvasSize = UDim2.new(0, 0, 0, yPos + buttonHeight)

-- Нижняя панель
local bottomBar = Instance.new("Frame")
bottomBar.Size = UDim2.new(1, 0, 0, 35)
bottomBar.Position = UDim2.new(0, 0, 1, -35)
bottomBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
bottomBar.BackgroundTransparency = 0.3
bottomBar.BorderSizePixel = 0
bottomBar.Parent = mainFrame

local bottomCorner = Instance.new("UICorner")
bottomCorner.CornerRadius = UDim.new(0, 15)
bottomCorner.Parent = bottomBar

local bottomText = Instance.new("TextLabel")
bottomText.Size = UDim2.new(1, -20, 1, 0)
bottomText.Position = UDim2.new(0, 10, 0, 0)
bottomText.Text = text(
    "ПКМ - Aimbot | Insert - скрыть | 🇷🇺 RU",
    "RMB - Aimbot | Insert - hide | 🇬🇧 EN"
)
bottomText.TextColor3 = Color3.fromRGB(150, 150, 150)
bottomText.TextSize = 10
bottomText.Font = Enum.Font.Gotham
bottomText.BackgroundTransparency = 1
bottomText.TextXAlignment = Enum.TextXAlignment.Left
bottomText.Parent = bottomBar

-- ============================================
-- ОБРАБОТЧИКИ КНОПОК
-- ============================================

-- Переключатель языка
langBtn.MouseButton1Click:Connect(function()
    Language = Language == "RU" and "EN" or "RU"
    langBtn.Text = Language == "RU" and "🇷🇺 RU" or "🇬🇧 EN"
    
    -- Обновляем заголовок
    title.Text = text("PRIVT ABSOLUTE", "PRIVT ABSOLUTE")
    subtitle.Text = text("ВЫБОР СКОРОСТИ И ПРЫЖКА", "SPEED & JUMP SELECTION")
    bottomText.Text = text(
        "ПКМ - Aimbot | Insert - скрыть | 🇷🇺 RU",
        "RMB - Aimbot | Insert - hide | 🇬🇧 EN"
    )
    
    -- Обновляем текст кнопок
    espBtn.frame:FindFirstChildWhichIsA("TextLabel").Text = text("ESP", "ESP")
    aimBtn.frame:FindFirstChildWhichIsA("TextLabel").Text = text("AIMBOT", "AIMBOT")
    noclipBtn.frame:FindFirstChildWhichIsA("TextLabel").Text = text("NOCLIP", "NOCLIP")
    fpsBtn.frame:FindFirstChildWhichIsA("TextLabel").Text = text("FPS METER", "FPS METER")
    skyBtn.frame:FindFirstChildWhichIsA("TextLabel").Text = text("НЕБО", "SKY")
    boostBtn.frame:FindFirstChildWhichIsA("TextLabel").Text = text("FPS BOOST", "FPS BOOST")
    resetBtn.frame:FindFirstChildWhichIsA("TextLabel").Text = text("СБРОС ВСЁ", "RESET ALL")
    
    -- Обновляем описания
    -- (для простоты оставим как есть, можно добавить полное обновление)
end)

espBtn.btn.MouseButton1Click:Connect(function()
    Settings.ESP = not Settings.ESP
    espBtn.status.Text = Settings.ESP and "ON" or "OFF"
    espBtn.status.TextColor3 = Settings.ESP and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    espBtn.frame.BackgroundColor3 = Settings.ESP and Color3.fromRGB(30, 40, 30) or Color3.fromRGB(15, 15, 25)
end)

aimBtn.btn.MouseButton1Click:Connect(function()
    Settings.Aimbot = not Settings.Aimbot
    aimBtn.status.Text = Settings.Aimbot and "ON" or "OFF"
    aimBtn.status.TextColor3 = Settings.Aimbot and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    aimBtn.frame.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(30, 40, 30) or Color3.fromRGB(15, 15, 25)
end)

noclipBtn.btn.MouseButton1Click:Connect(function()
    Settings.Noclip = not Settings.Noclip
    noclipBtn.status.Text = Settings.Noclip and "ON" or "OFF"
    noclipBtn.status.TextColor3 = Settings.Noclip and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    noclipBtn.frame.BackgroundColor3 = Settings.Noclip and Color3.fromRGB(30, 40, 30) or Color3.fromRGB(15, 15, 25)
    toggleNoclip()
end)

fpsBtn.btn.MouseButton1Click:Connect(function()
    Settings.FPS = not Settings.FPS
    fpsBtn.status.Text = Settings.FPS and "ON" or "OFF"
    fpsBtn.status.TextColor3 = Settings.FPS and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    fpsBtn.frame.BackgroundColor3 = Settings.FPS and Color3.fromRGB(30, 40, 30) or Color3.fromRGB(15, 15, 25)
end)

skyBtn.btn.MouseButton1Click:Connect(function()
    Settings.Sky = not Settings.Sky
    skyBtn.status.Text = Settings.Sky and "ON" or "OFF"
    skyBtn.status.TextColor3 = Settings.Sky and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    skyBtn.frame.BackgroundColor3 = Settings.Sky and Color3.fromRGB(30, 40, 30) or Color3.fromRGB(15, 15, 25)
    
    if Settings.Sky then
        changeSky(1)
    else
        removeSky()
    end
end)

sky1Btn.btn.MouseButton1Click:Connect(function()
    Settings.Sky = true
    skyBtn.status.Text = "ON"
    skyBtn.status.TextColor3 = Color3.fromRGB(80, 255, 80)
    skyBtn.frame.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
    changeSky(1)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = text("Небо", "Sky"),
        Text = text("Ночь", "Night"),
        Duration = 1
    })
end)

sky2Btn.btn.MouseButton1Click:Connect(function()
    Settings.Sky = true
    skyBtn.status.Text = "ON"
    skyBtn.status.TextColor3 = Color3.fromRGB(80, 255, 80)
    skyBtn.frame.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
    changeSky(2)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = text("Небо", "Sky"),
        Text = text("Закат", "Sunset"),
        Duration = 1
    })
end)

sky3Btn.btn.MouseButton1Click:Connect(function()
    Settings.Sky = true
    skyBtn.status.Text = "ON"
    skyBtn.status.TextColor3 = Color3.fromRGB(80, 255, 80)
    skyBtn.frame.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
    changeSky(3)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = text("Небо", "Sky"),
        Text = text("День", "Day"),
        Duration = 1
    })
end)

sky4Btn.btn.MouseButton1Click:Connect(function()
    Settings.Sky = true
    skyBtn.status.Text = "ON"
    skyBtn.status.TextColor3 = Color3.fromRGB(80, 255, 80)
    skyBtn.frame.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
    changeSky(4)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = text("Небо", "Sky"),
        Text = text("Космос", "Space"),
        Duration = 1
    })
end)

sky5Btn.btn.MouseButton1Click:Connect(function()
    Settings.Sky = true
    skyBtn.status.Text = "ON"
    skyBtn.status.TextColor3 = Color3.fromRGB(80, 255, 80)
    skyBtn.frame.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
    changeSky(5)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = text("Небо", "Sky"),
        Text = text("Киберпанк", "Cyberpunk"),
        Duration = 1
    })
end)

boostBtn.btn.MouseButton1Click:Connect(function()
    Settings.Boost = not Settings.Boost
    boostBtn.status.Text = Settings.Boost and "ON" or "OFF"
    boostBtn.status.TextColor3 = Settings.Boost and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    boostBtn.frame.BackgroundColor3 = Settings.Boost and Color3.fromRGB(30, 40, 30) or Color3.fromRGB(15, 15, 25)
    
    if Settings.Boost then
        boostFPS()
    else
        resetGraphics()
    end
end)

resetBtn.btn.MouseButton1Click:Connect(function()
    Settings.ESP = false
    Settings.Aimbot = false
    Settings.Speed = false
    Settings.Jump = false
    Settings.Noclip = false
    Settings.FPS = false
    Settings.Sky = false
    Settings.Boost = false
    
    -- Обновляем кнопки
    espBtn.status.Text = "OFF"
    espBtn.status.TextColor3 = Color3.fromRGB(255, 80, 80)
    espBtn.frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    
    aimBtn.status.Text = "OFF"
    aimBtn.status.TextColor3 = Color3.fromRGB(255, 80, 80)
    aimBtn.frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    
    noclipBtn.status.Text = "OFF"
    noclipBtn.status.TextColor3 = Color3.fromRGB(255, 80, 80)
    noclipBtn.frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    
    fpsBtn.status.Text = "OFF"
    fpsBtn.status.TextColor3 = Color3.fromRGB(255, 80, 80)
    fpsBtn.frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    
    skyBtn.status.Text = "OFF"
    skyBtn.status.TextColor3 = Color3.fromRGB(255, 80, 80)
    skyBtn.frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    
    boostBtn.status.Text = "OFF"
    boostBtn.status.TextColor3 = Color3.fromRGB(255, 80, 80)
    boostBtn.frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    
    removeSky()
    resetStats()
    resetGraphics()
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end)

-- Обновление скорости и прыжка
RunService.Heartbeat:Connect(function()
    if Settings.Speed then
        speedValue = speedSlider.get()
        applySpeed()
    end
    
    if Settings.Jump then
        jumpValue = jumpSlider.get()
        applyJump()
    end
end)

-- Кнопка применения скорости
local speedApplyBtn = Instance.new("TextButton")
speedApplyBtn.Size = UDim2.new(0, 60, 0, 25)
speedApplyBtn.Position = UDim2.new(1, -70, 0, 5)
speedApplyBtn.Text = text("ПРИМ", "APPLY")
speedApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedApplyBtn.TextSize = 12
speedApplyBtn.Font = Enum.Font.Gotham
speedApplyBtn.BackgroundColor3 = Color3.fromRGB(140, 100, 220)
speedApplyBtn.BorderSizePixel = 0
speedApplyBtn.Parent = speedSlider.frame

speedApplyBtn.MouseButton1Click:Connect(function()
    if Settings.Speed then
        speedValue = speedSlider.get()
        applySpeed()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = text("Скорость", "Speed"),
            Text = text("Скорость: " .. speedValue, "Speed: " .. speedValue),
            Duration = 1
        })
    end
end)

-- Кнопка применения прыжка
local jumpApplyBtn = Instance.new("TextButton")
jumpApplyBtn.Size = UDim2.new(0, 60, 0, 25)
jumpApplyBtn.Position = UDim2.new(1, -70, 0, 5)
jumpApplyBtn.Text = text("ПРИМ", "APPLY")
jumpApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpApplyBtn.TextSize = 12
jumpApplyBtn.Font = Enum.Font.Gotham
jumpApplyBtn.BackgroundColor3 = Color3.fromRGB(140, 100, 220)
jumpApplyBtn.BorderSizePixel = 0
jumpApplyBtn.Parent = jumpSlider.frame

jumpApplyBtn.MouseButton1Click:Connect(function()
    if Settings.Jump then
        jumpValue = jumpSlider.get()
        applyJump()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = text("Прыжок", "Jump"),
            Text = text("Прыжок: " .. jumpValue, "Jump: " .. jumpValue),
            Duration = 1
        })
    end
end)

-- Скрыть/показать меню
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        mainFrame.Visible = menuOpen
    end
end)

-- ============================================
-- ЗАГРУЗКА
-- ============================================
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = text("✨ PRIVT BILINGUAL ✨", "✨ PRIVT BILINGUAL ✨"),
    Text = text("🇷🇺 Русский / 🇬🇧 English", "🇷🇺 Russian / 🇬🇧 English"),
    Duration = 4
})

print[[
╔═══════════════════════════════════╗
║     ✨ PRIVT BILINGUAL ✨          ║
║  🇷🇺 РУССКАЯ ВЕРСИЯ                ║
║  🇬🇧 ENGLISH VERSION               ║
║  ✓ ESP + Health Bars              ║
║  ✓ Aimbot (RMB)                   ║
║  ✓ Speed (16-100)                 ║
║  ✓ Jump (50-200)                  ║
║  ✓ NOCLIP                         ║
║  ✓ Sky (5 types)                  ║
║  ✓ FPS Boost                      ║
║  ✓ FPS + Ping meter               ║
║  ✓ Glass interface                ║
║  ✓ Insert - hide menu             ║
╚═══════════════════════════════════╝
]]