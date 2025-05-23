-- 🌟 Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- 🌟 Criar GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FLING_V6_GUI"
gui.Parent = LocalPlayer.PlayerGui
gui.ResetOnSpawn = false

-- 🌟 Frame Principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 500)
frame.Position = UDim2.new(0.5, -175, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- 🌟 Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "💀 FLING V6"
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

-- 🌟 Lista de Jogadores
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(0, 320, 0, 200)
playerList.Position = UDim2.new(0, 15, 0, 50)
playerList.CanvasSize = UDim2.new(0, 0, 10, 0)
playerList.ScrollBarThickness = 6
playerList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
playerList.Parent = frame

local playerButtonTemplate = Instance.new("TextButton")
playerButtonTemplate.Size = UDim2.new(1, -10, 0, 25)
playerButtonTemplate.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playerButtonTemplate.TextColor3 = Color3.new(1,1,1)
playerButtonTemplate.Font = Enum.Font.Gotham
playerButtonTemplate.TextSize = 14
playerButtonTemplate.Text = "Jogador"

-- 🌟 TextBox para velocidade
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 80, 0, 30)
speedBox.Position = UDim2.new(0, 15, 0, 265)
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBox.PlaceholderText = "Velocidade"
speedBox.Text = "0.2"
speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 14
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Parent = frame

-- 🌟 Botões
local buttons = {}
local labels = {"✅ Ativar", "❌ Desativar", "🎥 View", "🚫 Unview"}
for i, txt in ipairs(labels) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.22, 0, 0, 30)
    btn.Position = UDim2.new(0.05 + (i-1)*0.24, 0, 0, 305)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = txt
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = frame
    table.insert(buttons, btn)
end

-- 🌟 Minimizar/Maximizar
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -70, 0, 5)
minimize.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimize.Text = "-"
minimize.TextColor3 = Color3.new(1,1,1)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 16
minimize.Parent = frame

local maximize = minimize:Clone()
maximize.Text = "+"
maximize.Position = UDim2.new(1, -35, 0, 5)
maximize.Visible = false
maximize.Parent = frame

-- 🌟 Variáveis
local selectedPlayer = nil
local active = false
local teleportLoop = nil
local sitCheckConnection = nil
local cam = workspace.CurrentCamera

-- 🌟 Atualizar lista
local function updatePlayerList()
    playerList:ClearAllChildren()
    local y = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local button = playerButtonTemplate:Clone()
            button.Text = plr.Name
            button.Position = UDim2.new(0, 5, 0, y)
            button.Parent = playerList
            y = y + 30

            button.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                for _, btn in ipairs(playerList:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    end
                end
                button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            end)
        end
    end
    playerList.CanvasSize = UDim2.new(0, 0, 0, y)
end
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- 🌟 Funções principais
local function startTeleport()
    if not selectedPlayer then return end
    active = true
    local positions = {
        Vector3.new(0, -1, -10),
        Vector3.new(0, -1, 10),
        Vector3.new(10, -1, 0),
        Vector3.new(-10, -1, 0)
    }
    teleportLoop = task.spawn(function()
        local index = 1
        while active do
            local speed = tonumber(speedBox.Text) or 0.2
            local char = LocalPlayer.Character
            local targetChar = selectedPlayer.Character
            if char and targetChar and char:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
                local offset = positions[index]
                index = (index % #positions) + 1
                char.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(offset) * CFrame.Angles(0, 0, math.rad(180))
            end
            task.wait(speed)
        end
    end)
    sitCheckConnection = RunService.Heartbeat:Connect(function()
        if not active then return end
        local targetChar = selectedPlayer.Character
        if targetChar and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Sit then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Velocity = Vector3.new(
                    math.random(-9999999,9999999),
                    math.random(9999999,19999999),
                    math.random(-9999999,9999999)
                )
            end
        end
    end)
end

local function stopTeleport()
    active = false
    if teleportLoop then
        task.cancel(teleportLoop)
        teleportLoop = nil
    end
    if sitCheckConnection then
        sitCheckConnection:Disconnect()
        sitCheckConnection = nil
    end
end

local function viewPlayer()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        cam.CameraSubject = selectedPlayer.Character.Humanoid
    end
end

local function unviewPlayer()
    cam.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
end

buttons[1].MouseButton1Click:Connect(startTeleport)
buttons[2].MouseButton1Click:Connect(stopTeleport)
buttons[3].MouseButton1Click:Connect(viewPlayer)
buttons[4].MouseButton1Click:Connect(unviewPlayer)

-- 🌟 Minimizar com animação
local minimized = false
local fullSize = frame.Size
local minimizedSize = UDim2.new(0, 200, 0, 40)

local function minimizeGUI()
    minimized = true
    local tween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = minimizedSize})
    tween:Play()
    for _, v in pairs(frame:GetChildren()) do
        if v ~= title and v ~= minimize and v ~= maximize then
            v.Visible = false
        end
    end
    minimize.Visible = false
    maximize.Visible = true
end

local function maximizeGUI()
    minimized = false
    local tween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = fullSize})
    tween:Play()
    for _, v in pairs(frame:GetChildren()) do
        v.Visible = true
    end
    maximize.Visible = false
    minimize.Visible = true
end

minimize.MouseButton1Click:Connect(minimizeGUI)
maximize.MouseButton1Click:Connect(maximizeGUI)

-- 🌈 RGB Efeito
task.spawn(function()
    while true do
        for i = 0, 1, 0.01 do
            local color = Color3.fromHSV(i, 1, 1)
            title.TextColor3 = color
            speedBox.BackgroundColor3 = color
            frame.BorderColor3 = color
            task.wait(0.01)
        end
    end
end)

-- 🌟 Botão de Acesso Rápido
local openMenuButton = Instance.new("TextButton")
openMenuButton.Size = UDim2.new(0, 100, 0, 30)
openMenuButton.Position = UDim2.new(0, 10, 0, 10) -- canto superior esquerdo
openMenuButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
openMenuButton.TextColor3 = Color3.new(1, 1, 1)
openMenuButton.Font = Enum.Font.GothamBold
openMenuButton.TextSize = 14
openMenuButton.Text = "🚀 Abrir Menu"
openMenuButton.Parent = gui

-- 🌟 Menu de Escolhas
local choiceFrame = Instance.new("Frame")
choiceFrame.Size = UDim2.new(0, 160, 0, 80)
choiceFrame.Position = UDim2.new(0, 10, 0, 50)
choiceFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
choiceFrame.BorderSizePixel = 0
choiceFrame.Visible = false
choiceFrame.Parent = gui

-- Botão MI GUI
local miGuiButton = Instance.new("TextButton")
miGuiButton.Size = UDim2.new(1, -10, 0, 30)
miGuiButton.Position = UDim2.new(0, 5, 0, 5)
miGuiButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
miGuiButton.Text = "💻 MI GUI"
miGuiButton.TextColor3 = Color3.new(1, 1, 1)
miGuiButton.Font = Enum.Font.GothamBold
miGuiButton.TextSize = 14
miGuiButton.Parent = choiceFrame

-- Botão MI BACKDOOR
local miBackdoorButton = Instance.new("TextButton")
miBackdoorButton.Size = UDim2.new(1, -10, 0, 30)
miBackdoorButton.Position = UDim2.new(0, 5, 0, 40)
miBackdoorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
miBackdoorButton.Text = "🛠 MI BACKDOOR"
miBackdoorButton.TextColor3 = Color3.new(1, 1, 1)
miBackdoorButton.Font = Enum.Font.GothamBold
miBackdoorButton.TextSize = 14
miBackdoorButton.Parent = choiceFrame

-- 🌟 Botão de Acesso Rápido
local openMenuButton = Instance.new("TextButton")
openMenuButton.Size = UDim2.new(0, 100, 0, 30)
openMenuButton.Position = UDim2.new(0, 10, 0, 10) -- canto superior esquerdo
openMenuButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
openMenuButton.TextColor3 = Color3.new(1, 1, 1)
openMenuButton.Font = Enum.Font.GothamBold
openMenuButton.TextSize = 14
openMenuButton.Text = "🚀 Abrir Menu"
openMenuButton.Parent = gui

-- 🌟 Menu de Escolhas
local choiceFrame = Instance.new("Frame")
choiceFrame.Size = UDim2.new(0, 160, 0, 80)
choiceFrame.Position = UDim2.new(0, 10, 0, 50)
choiceFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
choiceFrame.BorderSizePixel = 0
choiceFrame.Visible = false
choiceFrame.Parent = gui

-- Botão MI GUI
local miGuiButton = Instance.new("TextButton")
miGuiButton.Size = UDim2.new(1, -10, 0, 30)
miGuiButton.Position = UDim2.new(0, 5, 0, 5)
miGuiButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
miGuiButton.Text = "💻 MI GUI"
miGuiButton.TextColor3 = Color3.new(1, 1, 1)
miGuiButton.Font = Enum.Font.GothamBold
miGuiButton.TextSize = 14
miGuiButton.Parent = choiceFrame

-- Botão MI BACKDOOR
local miBackdoorButton = Instance.new("TextButton")
miBackdoorButton.Size = UDim2.new(1, -10, 0, 30)
miBackdoorButton.Position = UDim2.new(0, 5, 0, 40)
miBackdoorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
miBackdoorButton.Text = "🛠 MI BACKDOOR"
miBackdoorButton.TextColor3 = Color3.new(1, 1, 1)
miBackdoorButton.Font = Enum.Font.GothamBold
miBackdoorButton.TextSize = 14
miBackdoorButton.Parent = choiceFrame

-- 🌟 Ações dos botões
openMenuButton.MouseButton1Click:Connect(function()
    choiceFrame.Visible = not choiceFrame.Visible
end)

miGuiButton.MouseButton1Click:Connect(function()
    choiceFrame.Visible = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/cubodegelo1116/MI-GUI/refs/heads/main/mi%20gui"))()
end)

miBackdoorButton.MouseButton1Click:Connect(function()
    choiceFrame.Visible = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/cubodegelo1116/mi-hub-backdoor/refs/heads/main/MI%20BACKDOOR"))()
end)
