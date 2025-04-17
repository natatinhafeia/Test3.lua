-- Aimbot + ESP por Hixdow | GUI arrastável (mobile + PC)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = true
local AimbotEnabled = true
local TargetPlayer = nil

-- RGB effect
local function rgbColor()
	local r = math.sin(tick() * 2) * 127 + 128
	local g = math.sin(tick() * 2 + 2) * 127 + 128
	local b = math.sin(tick() * 2 + 4) * 127 + 128
	return Color3.fromRGB(r, g, b)
end

-- Função para criar ESP (desenha nome sobre a cabeça, mesmo atrás de parede)
local function DrawESP(player)
	if not player.Character or not player.Character:FindFirstChild("Head") then return end
	if player.Character:FindFirstChild("ESPLabel") then return end

	local BillboardGui = Instance.new("BillboardGui")
	BillboardGui.Name = "ESPLabel"
	BillboardGui.Adornee = player.Character.Head
	BillboardGui.Size = UDim2.new(0, 100, 0, 40)
	BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
	BillboardGui.AlwaysOnTop = true
	BillboardGui.Parent = player.Character

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = player.Name
	TextLabel.TextColor3 = Color3.new(1, 0, 0)
	TextLabel.TextScaled = true
	TextLabel.Font = Enum.Font.SourceSansBold
	TextLabel.Parent = BillboardGui

	coroutine.wrap(function()
		while BillboardGui.Parent do
			TextLabel.TextColor3 = rgbColor()
			wait()
		end
	end)()
end

-- Função de Aimbot (suavizado)
local function GetClosestPlayer()
	local maxDistance = math.huge
	local closest = nil
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
			if onScreen then
				local distance = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
				if distance < maxDistance then
					maxDistance = distance
					closest = player
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	if AimbotEnabled then
		local target = GetClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			local head = target.Character.Head.Position
			local smooth = 0.05
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, head), smooth)
		end
	end
end)

-- GUI personalizada (tema vermelho + RGB texto + arrastável mobile/PC)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0.5, -110, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = gui

local topBar = Instance.new("TextButton")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
topBar.Text = "Hixdow Hub"
topBar.TextColor3 = Color3.new(1, 1, 1)
topBar.Font = Enum.Font.SourceSansBold
topBar.TextSize = 20
topBar.Parent = frame

-- Botão Aimbot
local aimbotBtn = Instance.new("TextButton")
aimbotBtn.Size = UDim2.new(1, -20, 0, 40)
aimbotBtn.Position = UDim2.new(0, 10, 0, 40)
aimbotBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
aimbotBtn.Text = "Toggle Aimbot"
aimbotBtn.TextScaled = true
aimbotBtn.Font = Enum.Font.SourceSansBold
aimbotBtn.TextColor3 = rgbColor()
aimbotBtn.Parent = frame

-- Botão ESP
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(1, -20, 0, 40)
espBtn.Position = UDim2.new(0, 10, 0, 90)
espBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
espBtn.Text = "Toggle ESP"
espBtn.TextScaled = true
espBtn.Font = Enum.Font.SourceSansBold
espBtn.TextColor3 = rgbColor()
espBtn.Parent = frame

-- RGB Text effect
coroutine.wrap(function()
	while true do
		aimbotBtn.TextColor3 = rgbColor()
		espBtn.TextColor3 = rgbColor()
		wait()
	end
end)()

-- Aimbot toggle
aimbotBtn.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
end)

-- ESP toggle
espBtn.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled
	if ESPEnabled then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				DrawESP(player)
			end
		end
	end
end)

-- Drag móvel e PC
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

topBar.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

topBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- Iniciar ESP automaticamente se ativado
if ESPEnabled then
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			DrawESP(player)
		end
	end
end
