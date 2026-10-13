--[[=====================================================================
    PRISON DELTA HUB  -  SCRIPT UNICO  (formato PVP / FARM)
    Aimbot | ESP | Salto infinito | Velocidad infinita | Volar | Noclip
    Menu flotante centrado, arrastrable -> abre/cierra con RightShift
=====================================================================]]

--[[ PVP ]]
script_mode = "pvp";
--[[ FARM ]]
-- script_mode = "farm";

--========================== SERVICIOS ==========================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local VirtualUser      = game:GetService("VirtualUser")
local TweenService     = game:GetService("TweenService")

local LP = Players.LocalPlayer
local function getCam() return workspace.CurrentCamera end

--============================ CONFIG ============================
local Config = {
    Aimbot = { Enabled=false, HoldMode=true, Key=Enum.KeyCode.E, FOV=150,
               Smooth=8, Part="Head", TeamCheck=true, VisibleOnly=false },
    ESP    = { Enabled=true, Box=true, Name=true, Distance=true,
               Health=true, Tracer=true, TeamColor=true },
    Movement = { InfJump=false, SpeedOn=false, Speed=60, JumpOn=false,
                 JumpPower=120, Fly=false, FlySpeed=60, Noclip=false },
    Misc   = { Fullbright=false, AntiAFK=true },
}

--=========================== PRESETS ============================
local Presets = {
    pvp = {
        Aimbot = { Enabled=true, FOV=150, Smooth=8, TeamCheck=true, VisibleOnly=true, Part="Head" },
        ESP = { Enabled=true, Box=true, Name=true, Distance=true, Health=true, Tracer=true },
        Movement = { InfJump=true, SpeedOn=true, Speed=60, Fly=false, Noclip=false },
        Misc = { Fullbright=true, AntiAFK=true },
    },
    farm = {
        Aimbot = { Enabled=false, FOV=220, Smooth=10, TeamCheck=false, VisibleOnly=false, Part="Head" },
        ESP = { Enabled=true, Box=false, Name=false, Distance=false, Health=false, Tracer=false },
        Movement = { InfJump=true, SpeedOn=true, Speed=140, Fly=true, Noclip=true },
        Misc = { Fullbright=true, AntiAFK=true },
    },
}

--========================== UTILIDADES ==========================
local function new(class, props)
    local inst = Instance.new(class)
    local parent = props.Parent
    props.Parent = nil
    for k, v in pairs(props) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local C = {
    Bg = Color3.fromRGB(14,14,19), Panel = Color3.fromRGB(23,23,30),
    Row = Color3.fromRGB(33,33,43), Accent = Color3.fromRGB(0,200,255),
    Text = Color3.fromRGB(233,233,243), Off = Color3.fromRGB(52,52,66),
    Warn = Color3.fromRGB(255,90,90),
}

local PG = LP:WaitForChild("PlayerGui")
local o1 = PG:FindFirstChild("PrisonDeltaHub"); if o1 then o1:Destroy() end
local o2 = PG:FindFirstChild("PDH_Notify");     if o2 then o2:Destroy() end

local function notify(msg)
    local sg = new("ScreenGui", {Name="PDH_Notify", ResetOnSpawn=false, IgnoreGuiInset=true, Parent=PG})
    local f = new("Frame", {Size=UDim2.new(0,340,0,44), Position=UDim2.new(0.5,-170,0,-60), BackgroundColor3=C.Panel, Parent=sg})
    new("UICorner", {CornerRadius=UDim.new(0,10), Parent=f})
    new("UIStroke", {Color=C.Accent, Thickness=1.5, Transparency=0.25, Parent=f})
    new("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Font=Enum.Font.GothamBold,
        Text=msg, TextSize=14, TextColor3=C.Text, Parent=f})
    TweenService:Create(f, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Position=UDim2.new(0.5,-170,0,18)}):Play()
    task.delay(3, function()
        local t = TweenService:Create(f, TweenInfo.new(0.35), {Position=UDim2.new(0.5,-170,0,-60), BackgroundTransparency=1})
        t:Play(); t.Completed:Wait(); sg:Destroy()
    end)
end

--========================== MOVIMIENTO ==========================
local function getChar()
    local c = LP.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if h and r then return c, h, r end
end

local function applySpeed()
    local _, h = getChar()
    if h then h.WalkSpeed = Config.Movement.SpeedOn and Config.Movement.Speed or 16 end
end

local function applyJump()
    local _, h = getChar()
    if h then
        h.UseJumpPower = true
        h.JumpPower = Config.Movement.JumpOn and Config.Movement.JumpPower or 50
    end
end

local function setFly(on)
    local _, h = getChar()
    if h then h.PlatformStand = on end
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5); applySpeed(); applyJump(); setFly(Config.Movement.Fly)
end)

UserInputService.JumpRequest:Connect(function()
    if not Config.Movement.InfJump then return end
    local _, h = getChar()
    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

RunService.Heartbeat:Connect(function()
    if not Config.Movement.SpeedOn then return end
    local _, h = getChar()
    if h and h.WalkSpeed ~= Config.Movement.Speed then h.WalkSpeed = Config.Movement.Speed end
end)

RunService.Stepped:Connect(function()
    if not Config.Movement.Noclip then return end
    local c = LP.Character
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

local keys = {}
UserInputService.InputBegan:Connect(function(i, gp) if not gp then keys[i.KeyCode] = true end end)
UserInputService.InputEnded:Connect(function(i) keys[i.KeyCode] = false end)

RunService.RenderStepped:Connect(function()
    if not Config.Movement.Fly then return end
    local _, _, r = getChar()
    local cam = getCam()
    if not r or not cam then return end
    local dir = Vector3.new()
    if keys[Enum.KeyCode.W] then dir += cam.CFrame.LookVector end
    if keys[Enum.KeyCode.S] then dir -= cam.CFrame.LookVector end
    if keys[Enum.KeyCode.A] then dir -= cam.CFrame.RightVector end
    if keys[Enum.KeyCode.D] then dir += cam.CFrame.RightVector end
    if keys[Enum.KeyCode.Space] then dir += Vector3.new(0,1,0) end
    if keys[Enum.KeyCode.LeftControl] then dir -= Vector3.new(0,1,0) end
    if dir.Magnitude > 0 then r.Velocity = dir.Unit * Config.Movement.FlySpeed
    else r.Velocity = Vector3.new() end
end)

--============================ AIMBOT ============================
local aimDown = false
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Config.Aimbot.Key then aimDown = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == Config.Aimbot.Key then aimDown = false end
end)

local hasDrawing = (type(Drawing) == "table" or type(Drawing) == "userdata") and Drawing.new ~= nil

local fovCircle
if hasDrawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5; fovCircle.NumSides = 60; fovCircle.Filled = false
    fovCircle.Transparency = 1; fovCircle.Color = C.Accent; fovCircle.Visible = false
end

local function getTarget()
    local cam = getCam()
    if not cam then return end
    local center = cam.ViewportSize / 2
    local best, bestD = nil, Config.Aimbot.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local part = char and (char:FindFirstChild(Config.Aimbot.Part) or char:FindFirstChild("Head"))
            if hum and hum.Health > 0 and part then
                local ok = true
                if Config.Aimbot.TeamCheck and LP.Team and plr.Team == LP.Team then ok = false end
                if ok and Config.Aimbot.VisibleOnly then
                    local rp = RaycastParams.new()
                    rp.FilterType = Enum.RaycastFilterType.Exclude
                    rp.FilterDescendantsInstances = {LP.Character, cam}
                    local hit = workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, rp)
                    if hit and hit.Instance and not hit.Instance:IsDescendantOf(char) then ok = false end
                end
                if ok then
                    local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if d < bestD then bestD = d; best = plr end
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function(dt)
    if fovCircle then
        local cam = getCam()
        if cam then fovCircle.Position = cam.ViewportSize / 2 end
        fovCircle.Radius = Config.Aimbot.FOV
        fovCircle.Visible = Config.Aimbot.Enabled
    end
    if not Config.Aimbot.Enabled then return end
    if Config.Aimbot.HoldMode and not aimDown then return end
    local t = getTarget()
    if not t then return end
    local char = t.Character
    local part = char and (char:FindFirstChild(Config.Aimbot.Part) or char:FindFirstChild("Head"))
    local cam = getCam()
    if not part or not cam then return end
    local goal = CFrame.lookAt(cam.CFrame.Position, part.Position)
    local alpha = math.clamp(1 - math.exp(-Config.Aimbot.Smooth * dt * 3), 0, 1)
    cam.CFrame = cam.CFrame:Lerp(goal, alpha)
end)

--============================== ESP ==============================
local espList = {}

local function makeESP(plr)
    if not hasDrawing or espList[plr] then return end
    local o = {}
    o.box = Drawing.new("Square");  o.box.Thickness=1.6; o.box.Filled=false; o.box.Transparency=1; o.box.Color=Color3.fromRGB(255,60,60)
    o.barBg = Drawing.new("Square");o.barBg.Filled=true; o.barBg.Transparency=1; o.barBg.Color=Color3.fromRGB(15,15,15)
    o.bar = Drawing.new("Square");  o.bar.Filled=true;  o.bar.Transparency=1;  o.bar.Color=Color3.fromRGB(0,255,0)
    o.name = Drawing.new("Text");   o.name.Center=true; o.name.Outline=true; o.name.OutlineColor=Color3.fromRGB(0,0,0); o.name.Size=14; o.name.Color=Color3.fromRGB(255,255,255); o.name.Transparency=1
    o.dist = Drawing.new("Text");   o.dist.Center=true; o.dist.Outline=true; o.dist.OutlineColor=Color3.fromRGB(0,0,0); o.dist.Size=13; o.dist.Color=Color3.fromRGB(210,210,210); o.dist.Transparency=1
    o.tracer = Drawing.new("Line"); o.tracer.Thickness=1; o.tracer.Transparency=1; o.tracer.Color=Color3.fromRGB(255,60,60)
    espList[plr] = o
end

local function removeESP(plr)
    local o = espList[plr]
    if not o then return end
    for _, v in pairs(o) do pcall(function() v:Remove() end) end
    espList[plr] = nil
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then makeESP(p) end end
Players.PlayerAdded:Connect(function(p) makeESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

RunService.RenderStepped:Connect(function()
    if not hasDrawing then return end
    local cam = getCam()
    if not cam then return end
    local vp = cam.ViewportSize
    for plr, o in pairs(espList) do
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local vis = Config.ESP.Enabled and char and hum and head and hrp and hum.Health > 0
        local x, y, w, h, col
        if vis then
            local top, onTop = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
            local bot, onBot = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            if onTop and onBot and top.Z > 0 and bot.Z > 0 then
                h = math.abs(bot.Y - top.Y); w = h * 0.55
                x = top.X - w / 2; y = math.min(top.Y, bot.Y)
                col = Config.ESP.TeamColor and plr.TeamColor.Color or Color3.fromRGB(255, 60, 60)
            else vis = false end
        end

        if vis then
            o.box.Visible = Config.ESP.Box
            o.box.Position = Vector2.new(x, y); o.box.Size = Vector2.new(w, h); o.box.Color = col

            o.name.Visible = Config.ESP.Name
            o.name.Text = plr.Name
            o.name.Position = Vector2.new(x + w/2, y - 17)

            o.dist.Visible = Config.ESP.Distance
            o.dist.Text = math.floor((hrp.Position - cam.CFrame.Position).Magnitude) .. " studs"
            o.dist.Position = Vector2.new(x + w/2, y + h + 1)

            o.tracer.Visible = Config.ESP.Tracer
            o.tracer.From = Vector2.new(vp.X/2, vp.Y)
            o.tracer.To = Vector2.new(x + w/2, y + h)

            local frac = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            o.barBg.Visible = Config.ESP.Health
            o.barBg.Position = Vector2.new(x - 6, y); o.barBg.Size = Vector2.new(3, h)
            o.bar.Visible = Config.ESP.Health
            o.bar.Position = Vector2.new(x - 6, y + h * (1 - frac)); o.bar.Size = Vector2.new(3, h * frac)
            o.bar.Color = Color3.fromRGB(255 * (1 - frac), 255 * frac, 0)
        else
            for _, v in pairs(o) do v.Visible = false end
        end
    end
end)

--============================ EXTRAS ============================
local origLight = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
}

local function setFullbright(on)
    if on then
        Lighting.Brightness = 3; Lighting.ClockTime = 12
        Lighting.Ambient = Color3.fromRGB(178,178,178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
        Lighting.FogEnd = 1e6; Lighting.GlobalShadows = false
    else
        Lighting.Brightness = origLight.Brightness; Lighting.ClockTime = origLight.ClockTime
        Lighting.Ambient = origLight.Ambient; Lighting.OutdoorAmbient = origLight.OutdoorAmbient
        Lighting.FogEnd = origLight.FogEnd; Lighting.GlobalShadows = origLight.GlobalShadows
    end
end

local function tpNearest()
    local _, _, myHrp = getChar()
    if not myHrp then return end
    local best, bestD
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local c = plr.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if r and hum and hum.Health > 0 then
                local d = (r.Position - myHrp.Position).Magnitude
                if not bestD or d < bestD then bestD = d; best = r end
            end
        end
    end
    if best then
        myHrp.CFrame = best.CFrame * CFrame.new(0, 0, 3)
        notify("TP -> " .. best.Parent.Name)
    end
end

LP.Idled:Connect(function()
    if not Config.Misc.AntiAFK then return end
    VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
end)

--============================== GUI ==============================
local gui = new("ScreenGui", {Name="PrisonDeltaHub", ResetOnSpawn=false,
    IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, Parent=PG})

local main = new("Frame", {Name="Main", AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(0,400,0,500),
    BackgroundColor3=C.Bg, Parent=gui})
new("UICorner", {CornerRadius=UDim.new(0,12), Parent=main})
new("UIStroke", {Color=C.Accent, Thickness=1.5, Transparency=0.35, Parent=main})

local bar = new("Frame", {Size=UDim2.new(1,0,0,38), BackgroundColor3=C.Panel, Parent=main})
new("UICorner", {CornerRadius=UDim.new(0,12), Parent=bar})
new("Frame", {Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-14),
    BackgroundColor3=C.Panel, BorderSizePixel=0, Parent=bar})

local title = new("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-140,1,0),
    Position=UDim2.new(0,14,0,0), Font=Enum.Font.GothamBold, Text="PRISON DELTA HUB",
    TextSize=15, TextColor3=C.Accent, TextXAlignment=Enum.TextXAlignment.Left, Parent=bar})

local modeLabel = new("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0,70,1,0),
    Position=UDim2.new(1,-140,0,0), Font=Enum.Font.GothamBold, Text="MODO: PVP",
    TextSize=11, TextColor3=C.Warn, TextXAlignment=Enum.TextXAlignment.Right, Parent=bar})

local body = new("ScrollingFrame", {Size=UDim2.new(1,-16,1,-52),
    Position=UDim2.new(0,8,0,46), BackgroundTransparency=1, BorderSizePixel=0,
    ScrollBarThickness=3, ScrollBarImageColor3=C.Accent, CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y, Parent=main})
new("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder, Parent=body})
new("UIPadding", {PaddingTop=UDim.new(0,2), PaddingBottom=UDim.new(0,10), Parent=body})

local order = 0
local function nextOrder() order += 1; return order end

local collapsed = false
local function barBtn(offX, txt, cb)
    local b = new("TextButton", {Size=UDim2.new(0,24,0,24), Position=UDim2.new(1,offX,0.5,-12),
        BackgroundColor3=C.Row, Text=txt, Font=Enum.Font.GothamBold, TextSize=13,
        TextColor3=C.Text, Parent=bar})
    new("UICorner", {CornerRadius=UDim.new(0,7), Parent=b})
    b.MouseButton1Click:Connect(cb)
end
barBtn(-64, "-", function()
    collapsed = not collapsed
    body.Visible = not collapsed
    main.Size = collapsed and UDim2.new(0,400,0,38) or UDim2.new(0,400,0,500)
end)
barBtn(-34, "X", function() main.Visible = false end)

do
    local dragging, dragStart, startPos
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                      startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local dot = new("TextButton", {Size=UDim2.new(0,46,0,46), Position=UDim2.new(0,16,0.5,-23),
    BackgroundColor3=C.Panel, Text="PDH", Font=Enum.Font.GothamBold, TextSize=12,
    TextColor3=C.Accent, Parent=gui})
new("UICorner", {CornerRadius=UDim.new(1,0), Parent=dot})
new("UIStroke", {Color=C.Accent, Thickness=1.5, Transparency=0.3, Parent=dot})
do
    local dragging, dragStart, startPos
    dot.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = dot.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            dot.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                     startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    dot.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
end

local function section(t)
    local s = new("Frame", {Size=UDim2.new(1,0,0,0), BackgroundColor3=C.Panel, Parent=body})
    s.LayoutOrder = nextOrder(); s.AutomaticSize = Enum.AutomaticSize.Y
    new("UICo
