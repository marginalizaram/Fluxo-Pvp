--[[
    Fluxo PvP Advanced - MOBILE EDITION (Touch UI)
    Silent Aim, ESP, Spinbot, Infinite Ammo, Speed, Bypass
    UI flutuante arrastável - funciona em Android/iOS (Delta/Arceus/Fluxus/Hydrogen/Trigon)
]]

local lplr = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera
local worldToViewportPoint = camera.WorldToViewportPoint
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0, 3, 0)

local FOV_RADIUS = 130
local PURPLE = Color3.fromRGB(180, 100, 255)
local SPIN_SPEED = 1440
local SPEED_HACK = 36

local Config = {
    SilentAim = true,
    ESP = true,
    Spinbot = false,
    InfiniteAmmo = true,
    Speed = false,
    Purple = true,
    FOV = FOV_RADIUS,
}

-- ============================================================
-- 1. BYPASS (anty-cheat) - Fluxo PvP
-- ============================================================
local function loadFluxoBypass()
    pcall(function()
        local repStorage = game:GetService("ReplicatedStorage")
        for _, child in pairs(repStorage:GetChildren()) do
            if child:IsA("RemoteEvent") and child.Name == "iac-respond" then
                child:Destroy()
            end
        end
        repStorage.ChildAdded:Connect(function(child)
            if child:IsA("RemoteEvent") and child.Name == "iac-respond" then
                child:Destroy()
            end
        end)

        local originalProperties = {}
        local function spoofProperty(instance, property)
            if not instance then return end
            originalProperties[instance] = originalProperties[instance] or {}
            if originalProperties[instance][property] == nil then
                originalProperties[instance][property] = instance[property]
            end
        end

        local function overrideCam()
            local cam = workspace.CurrentCamera
            if cam then
                cam.CameraType = Enum.CameraType.Scriptable
                task.wait(0.1)
                cam.CameraType = Enum.CameraType.Custom
            end
        end
        overrideCam()

        local function applySpoof()
            local char = lplr.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                spoofProperty(hum, "WalkSpeed")
                spoofProperty(hum, "JumpPower")
            end
        end
        applySpoof()
        lplr.CharacterAdded:Connect(function()
            task.wait(0.5)
            applySpoof()
        end)
        print("[Bypass] Ativo")
    end)
end
loadFluxoBypass()

-- ============================================================
-- 2. HELPERS
-- ============================================================
local function getHum()
    local char = lplr.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function setSpeed(v)
    local hum = getHum()
    if hum then hum.WalkSpeed = v end
end

-- posição do "cursor" no mobile = centro da tela / toque atual
local function getAimPoint()
    local ok, loc = pcall(function() return UserInputService:GetMouseLocation() end)
    if ok and loc and (loc.X ~= 0 or loc.Y ~= 0) then
        return loc
    end
    return Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end

-- ============================================================
-- 3. TOUCH UI  (janela arrastável + botões)
-- ============================================================
local pg = Instance.new("ProximityPrompt") -- placeholder nada, removido abaixo
pg:Destroy()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FluxoTouchUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not screenGui.Parent then screenGui.Parent = lplr:WaitForChild("PlayerGui") end

local function corner(px, py)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, px)
    c.Parent = py
    return c
end

-- ---------- botão minimizar / abrir ----------
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenBtn"
openBtn.Size = UDim2.fromOffset(58, 58)
openBtn.Position = UDim2.new(0, 12, 0.5, -29)
openBtn.BackgroundColor3 = Color3.fromRGB(20, 12, 32)
openBtn.Text = "⚡"
openBtn.TextColor3 = PURPLE
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBold
openBtn.AutoButtonColor = false
openBtn.Active = true
openBtn.Draggable = true
openBtn.Parent = screenGui
corner(29, openBtn)

-- ---------- janela principal ----------
local window = Instance.new("Frame")
window.Size = UDim2.fromOffset(252, 340)
window.Position = UDim2.new(0.5, -126, 0.5, -170)
window.BackgroundColor3 = Color3.fromRGB(16, 10, 26)
window.BackgroundTransparency = 0.05
window.Visible = false
window.Parent = screenGui
corner(14, window)

local stroke = Instance.new("UIStroke")
stroke.Color = PURPLE
stroke.Thickness = 1.5
stroke.Transparency = 0.35
stroke.Parent = window

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(26, 16, 42)
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Draggable = true
titleBar.Parent = window
corner(14, titleBar)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -44, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "FLUXO  PvP  MOBILE"
title.TextColor3 = PURPLE
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextScaled = false
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.AnchorPoint = Vector2.new(1, 0.5)
closeBtn.Position = UDim2.new(1, -6, 0.5, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 110, 110)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    window.Visible = false
    openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    window.Visible = true
    openBtn.Visible = false
end)

local list = Instance.new("Frame")
list.Size = UDim2.new(1, -16, 1, -52)
list.Position = UDim2.fromOffset(8, 46)
list.BackgroundTransparency = 1
list.Parent = window
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

-- ---------- botão toggle ----------
local function makeToggle(text, order, onChange)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(28, 18, 45)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = list
    corner(10, btn)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.fromOffset(12, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(235, 235, 245)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.Parent = btn

    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(44, 22)
    pill.AnchorPoint = Vector2.new(1, 0.5)
    pill.Position = UDim2.new(1, -12, 0.5, 0)
    pill.BackgroundColor3 = Color3.fromRGB(55, 45, 70)
    pill.Parent = btn
    corner(11, pill)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = UDim2.fromOffset(3, 3)
    knob.BackgroundColor3 = Color3.fromRGB(190, 190, 200)
    knob.Parent = pill
    corner(8, knob)

    local state = false
    local function set(v)
        state = v
        TweenService:Create(pill, TweenInfo.new(0.18), {
            BackgroundColor3 = v and PURPLE or Color3.fromRGB(55, 45, 70)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.18), {
            Position = v and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)
        }):Play()
        if onChange then onChange(v) end
    end

    btn.MouseButton1Click:Connect(function() set(not state) end)
    return { Set = set, Get = function() return state end }
end

-- ---------- slider FOV ----------
local function makeSlider(text, min, max, start, order, onInput)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 46)
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = order
    holder.Parent = list

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ":  " .. tostring(start)
    lbl.TextColor3 = Color3.fromRGB(235, 235, 245)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, 0, 0, 22)
    bar.Position = UDim2.fromOffset(0, 22)
    bar.BackgroundColor3 = Color3.fromRGB(40, 28, 60)
    bar.Text = ""
    bar.AutoButtonColor = false
    bar.Active = true
    bar.Parent = holder
    corner(11, bar)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale((start - min) / (max - min), 1)
    fill.BackgroundColor3 = PURPLE
    fill.BorderSizePixel = 0
    fill.Parent = bar
    corner(11, fill)

    local dragging = false
    local function update(x)
        local p = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        fill.Size = UDim2.fromScale(p, 1)
        local val = math.floor(min + (max - min) * p)
        lbl.Text = text .. ":  " .. tostring(val)
        if onInput then onInput(val) end
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ============================================================
-- 4. SILENT AIM (usa o toque/centro da tela como referência)
-- ============================================================
local function getNearestPlayer()
    if not Config.SilentAim then return nil end
    local target, maxDist = nil, math.huge
    local char = lplr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local origin = getAimPoint()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= lplr and plr.Character
            and plr.Character:FindFirstChild("Head")
            and plr.Character:FindFirstChild("Humanoid")
            and plr.Character.Humanoid.Health > 0 then
            local head = plr.Character.Head
            local sp, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local d = (origin - Vector2.new(sp.X, sp.Y)).Magnitude
                if d <= Config.FOV and d < maxDist then
                    maxDist, target = d, plr
                end
            end
        end
    end
    return target
end

local function hookSilentAim()
    local ok, Caster = pcall(function()
        return require(game:GetService("ReplicatedStorage").ZexisShared.Modules.Caster)
    end)
    if not ok or not Caster then
        warn("[SilentAim] Caster não encontrado - recarregue no servidor do jogo")
        return
    end
    if getgenv().ShotHookCaster then
        pcall(function() getgenv().ShotHookCaster:Restore() end)
    end
    local oldCast = Caster.Cast
    Caster.Cast = function(p1, p2, p3, p4, p5, p6)
        local target = getNearestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            p6 = target.Character.Head.Position
        end
        return oldCast(p1, p2, p3, p4, p5, p6)
    end
    getgenv().ShotHookCaster = { Restore = function() Caster.Cast = oldCast end }
    print("[SilentAim] Hook aplicado")
end
task.defer(hookSilentAim)

-- ============================================================
-- 5. DRAWINGS (watermark, FOV circle, ESP)
-- ============================================================
local hasDrawing = (typeof(Drawing) == "table") and Drawing and Drawing.new
if not hasDrawing then
    warn("[Draw] Drawing.new indisponível nesse executor - ESP/FOV desativados")
end

local watermark, fovCircle
if hasDrawing then
    watermark = Drawing.new("Text")
    watermark.Text = "JAGIT CHEATS"
    watermark.Color = PURPLE
    watermark.Size = 26
    watermark.Center = true
    watermark.Outline = true
    watermark.OutlineColor = Color3.fromRGB(0, 0, 0)
    watermark.Transparency = 0.6
    watermark.Visible = true

    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.Color = PURPLE
    fovCircle.Filled = false
    fovCircle.NumSides = 48
    fovCircle.Transparency = 1
    fovCircle.Visible = true

    RunService.RenderStepped:Connect(function()
        local vp = camera.ViewportSize
        watermark.Position = Vector2.new(vp.X / 2, 46)
        fovCircle.Radius = Config.FOV
        fovCircle.Position = getAimPoint()
        fovCircle.Visible = Config.SilentAim
    end)
end

local function createBoxEsp(v)
    if not hasDrawing then return end
    local Box = Drawing.new("Square")
    Box.Color, Box.Thickness, Box.Filled, Box.Visible = PURPLE, 2, false, false

    local HealthBar = Drawing.new("Line")
    HealthBar.Thickness, HealthBar.Visible = 2, false

    local NameTag = Drawing.new("Text")
    NameTag.Size, NameTag.Center, NameTag.Outline = 14, true, true
    NameTag.Color, NameTag.OutlineColor, NameTag.Visible = PURPLE, Color3.new(0, 0, 0), false

    local DistanceTag = Drawing.new("Text")
    DistanceTag.Size, DistanceTag.Center, DistanceTag.Outline = 14, true, true
    DistanceTag.Color, DistanceTag.OutlineColor, DistanceTag.Visible = PURPLE, Color3.new(0, 0, 0), false

    local Tracer = Drawing.new("Line")
    Tracer.Color, Tracer.Thickness, Tracer.Visible = PURPLE, 2, false

    RunService.RenderStepped:Connect(function()
        local show = Config.ESP
        local char = v.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")

        if show and v ~= lplr and hum and hrp and head and hum.Health > 0 and lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
            local _, onScreen = worldToViewportPoint(camera, hrp.Position)
            local rootVp = worldToViewportPoint(camera, hrp.Position)
            local headVp = worldToViewportPoint(camera, head.Position + HeadOff)
            local legVp = worldToViewportPoint(camera, hrp.Position - LegOff)

            Box.Size = Vector2.new(math.max(1000 / math.max(rootVp.Z, 0.1), 8), math.max(headVp.Y - legVp.Y, 8))
            Box.Position = Vector2.new(rootVp.X - Box.Size.X / 2, rootVp.Y - Box.Size.Y / 2)

            local health = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            HealthBar.From = Vector2.new(Box.Position.X + Box.Size.X + 5, Box.Position.Y + Box.Size.Y * (1 - health))
            HealthBar.To = Vector2.new(Box.Position.X + Box.Size.X + 5, Box.Position.Y + Box.Size.Y)
            HealthBar.Color = Color3.new(1 - health, health, 0)

            NameTag.Position = Vector2.new(Box.Position.X + Box.Size.X / 2, Box.Position.Y - 20)
            NameTag.Text = v.Name

            DistanceTag.Position = Vector2.new(Box.Position.X + Box.Size.X / 2, Box.Position.Y + Box.Size.Y)
            DistanceTag.Text = tostring(math.floor((lplr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)) .. "m"

            local sp, onScreenTracer = camera:WorldToViewportPoint(head.Position)
            if onScreenTracer and (getAimPoint() - Vector2.new(sp.X, sp.Y)).Magnitude <= Config.FOV then
                local myHead = lplr.Character:FindFirstChild("Head")
                if myHead then
                    local myVp = worldToViewportPoint(camera, myHead.Position)
                    Tracer.From = Vector2.new(myVp.X, myVp.Y)
                    Tracer.To = Vector2.new(rootVp.X, rootVp.Y)
                    Tracer.Visible = true
                end
            else
                Tracer.Visible = false
            end

            Box.Visible = onScreen
            HealthBar.Visible = onScreen
            NameTag.Visible = onScreen
            DistanceTag.Visible = onScreen
        else
            Box.Visible = HealthBar.Visible = NameTag.Visible = DistanceTag.Visible = Tracer.Visible = false
        end
    end)
end

for _, v in ipairs(game.Players:GetPlayers()) do createBoxEsp(v) end
game.Players.PlayerAdded:Connect(createBoxEsp)

-- ============================================================
-- 6. INFINITE AMMO
-- ============================================================
local AMMO_NAMES = {"Ammo","Magazine","Bullets","CurrentAmmo","Clip","MaxAmmo","Stored","ReserveAmmo","Amount"}
local function infiniteAmmo()
    if not Config.InfiniteAmmo then return end
    local char = lplr.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            for _, name in ipairs(AMMO_NAMES) do
                local prop = tool:FindFirstChild(name)
                if prop and (typeof(prop) == "Instance") and prop:IsA("ValueBase") then
                    pcall(function() prop.Value = 999 end)
                end
            end
        end
    end
end
RunService.Heartbeat:Connect(infiniteAmmo)

-- ============================================================
-- 7. SPINBOT + SPEED (controlados pela UI)
-- ============================================================
local spinAngle, spinConn = 0, nil
local function setSpin(v)
    Config.Spinbot = v
    if v then
        if not spinConn then
            spinConn = RunService.RenderStepped:Connect(function(dt)
                if not Config.Spinbot then return end
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    spinAngle = spinAngle + math.rad(SPIN_SPEED * dt)
                    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
                end
            end)
        end
    else
        if spinConn then spinConn:Disconnect() spinConn = nil end
    end
end

local function setPurple(v)
    Config.Purple = v
    if v then
        Lighting.Ambient = PURPLE
        Lighting.OutdoorAmbient = PURPLE
        Lighting.Brightness = 1.5
    else
        Lighting.Ambient = Color3.fromRGB(53, 53, 53)
        Lighting.OutdoorAmbient = Color3.fromRGB(105, 164, 208)
        Lighting.Brightness = 2
    end
end
local ambientConn
RunService.RenderStepped:Connect(function()
    if Config.Purple and Lighting.Ambient ~= PURPLE then
        Lighting.Ambient = PURPLE
        Lighting.OutdoorAmbient = PURPLE
    end
end)

-- ============================================================
-- 8. BOTÕES EXTRAS (ação rápida, fora da janela)
-- ============================================================
local function makeQuickButton(text, order, onClick)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(64, 44)
    b.BackgroundColor3 = Color3.fromRGB(24, 14, 38)
    b.Text = text
    b.TextColor3 = PURPLE
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Active = true
    b.Draggable = true
    b.LayoutOrder = order
    b.Parent = screenGui
    corner(12, b)
    local s = Instance.new("UIStroke")
    s.Color = PURPLE
    s.Transparency = 0.5
    s.Thickness = 1
    s.Parent = b
    b.MouseButton1Click:Connect(onClick)
    return b
end

local spinQuick = makeQuickButton("SPIN", 1, function()
    setSpin(not Config.Spinbot)
    spinToggle.Set(Config.Spinbot)
end)
spinQuick.Position = UDim2.new(1, -76, 0.5, -60)

local speedQuick = makeQuickButton("SPEED", 2, function()
    Config.Speed = not Config.Speed
    setSpeed(Config.Speed and SPEED_HACK or 16)
    speedToggle.Set(Config.Speed)
end)
speedQuick.Position = UDim2.new(1, -76, 0.5, -8)

local fireBtn = makeQuickButton("AIM", 3, function()
    Config.SilentAim = not Config.SilentAim
    aimToggle.Set(Config.SilentAim)
end)
fireBtn.Position = UDim2.new(1, -76, 0.5, 44)

-- ============================================================
-- 9. LIGA OS TOGGLES DA JANELA
-- ============================================================
local aimToggle = makeToggle("Silent Aim", 1, function(v) Config.SilentAim = v end)
aimToggle.Set(true)

local espToggle = makeToggle("ESP Box + Tracer", 2, function(v) Config.ESP = v end)
espToggle.Set(true)

spinToggle = makeToggle("Spinbot", 3, function(v) setSpin(v) end)
spinToggle.Set(false)

local ammoToggle = makeToggle("Infinite Ammo", 4, function(v) Config.InfiniteAmmo = v end)
ammoToggle.Set(true)

speedToggle = makeToggle("Speed Hack", 5, function(v)
    Config.Speed = v
    setSpeed(v and SPEED_HACK or 16)
end)
speedToggle.Set(false)

local purpleToggle = makeToggle("Purple Ambient", 6, function(v) setPurple(v) end)
purpleToggle.Set(true)

makeSlider("FOV", 40, 400, FOV_RADIUS, 7, function(v) Config.FOV = v end)

-- ============================================================
-- 10. RESPAWN / LIMPEZA
-- ============================================================
lplr.CharacterAdded:Connect(function()
    task.wait(0.5)
    setSpeed(Config.Speed and SPEED_HACK or 16)
    infiniteAmmo()
    if Config.Spinbot then setSpin(true) end
    task.defer(hookSilentAim)
end)

game:GetService("RunService").RenderStepped:Connect(function() end)

print("Fluxo PvP MOBILE carregado - toque no ⚡ para abrir o menu.")
