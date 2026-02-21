local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

-- This script should be placed in StarterGui as a LocalScript

-- Clear old GUIs (optional safety)
for _, gui in ipairs(StarterGui:GetChildren()) do
	if gui.Name == "SizeChangerGUI" then
		gui:Destroy()
	end
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SizeChangerGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Parent to PlayerGui when available
local player = Players.LocalPlayer
local function ensureParented()
	local pg = player:FindFirstChildOfClass("PlayerGui")
	if not pg then
		repeat
			task.wait()
			pg = player:FindFirstChildOfClass("PlayerGui")
		until pg
	end
	screenGui.Parent = pg
end
ensureParented()

-- Create main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 120)
mainFrame.Position = UDim2.new(0, 20, 0, 200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.1
mainFrame.Parent = screenGui

-- UICorner for smooth edges
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- UIStroke for outline
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1
stroke.Transparency = 0.4
stroke.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -10, 0, 30)
titleLabel.Position = UDim2.new(0, 5, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Player Size Changer"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Slider background
local sliderBack = Instance.new("Frame")
sliderBack.Name = "SliderBack"
sliderBack.Size = UDim2.new(1, -40, 0, 6)
sliderBack.Position = UDim2.new(0, 20, 0, 60)
sliderBack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderBack.BorderSizePixel = 0
sliderBack.Parent = mainFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = sliderBack

-- Slider fill
local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(0.5, 0, 1, 0) -- default at middle (scale 1.5 if range 0.5-2.5)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBack

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(1, 0)
sliderFillCorner.Parent = sliderFill

-- Slider button (dragger)
local sliderButton = Instance.new("TextButton")
sliderButton.Name = "SliderButton"
sliderButton.Size = UDim2.new(0, 12, 0, 12)
sliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, 0, 0.5, 0)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.Text = ""
sliderButton.AutoButtonColor = false
sliderButton.Parent = sliderBack

local sliderButtonCorner = Instance.new("UICorner")
sliderButtonCorner.CornerRadius = UDim.new(1, 0)
sliderButtonCorner.Parent = sliderButton

-- Value label
local valueLabel = Instance.new("TextLabel")
valueLabel.Name = "ValueLabel"
valueLabel.Size = UDim2.new(1, -20, 0, 20)
valueLabel.Position = UDim2.new(0, 10, 0, 80)
valueLabel.BackgroundTransparency = 1
valueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
valueLabel.Font = Enum.Font.Gotham
valueLabel.TextScaled = false
valueLabel.TextSize = 14
valueLabel.Text = "Scale: 1.0x"
valueLabel.TextXAlignment = Enum.TextXAlignment.Left
valueLabel.Parent = mainFrame

-- Instruction label
local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "InfoLabel"
infoLabel.Size = UDim2.new(1, -20, 0, 18)
infoLabel.Position = UDim2.new(0, 10, 1, -22)
infoLabel.AnchorPoint = Vector2.new(0, 1)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.Text = "Drag slider to change your size"
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = mainFrame

-- Bring GUI in smoothly
mainFrame.AnchorPoint = Vector2.new(0, 0)
mainFrame.Position = UDim2.new(0, -260, 0, 200)
local tweenIn = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 20, 0, 200)})
tweenIn:Play()

-- Slider logic
local UIS = game:GetService("UserInputService")

local dragging = false
local minScale = 0.5
local maxScale = 3.0

local function setScaleFromAlpha(alpha)
	alpha = math.clamp(alpha, 0, 1)
	local scale = minScale + (maxScale - minScale) * alpha
	scale = math.round(scale * 10) / 10 -- round to 0.1

	-- Update slider visuals
	sliderFill.Size = UDim2.new(alpha, 0, 1, 0)
	sliderButton.Position = UDim2.new(alpha, 0, 0.5, 0)
	valueLabel.Text = "Scale: " .. tostring(scale) .. "x"

	-- Apply character scaling
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local HS = humanoid:FindFirstChild("HumanoidScale") or humanoid:FindFirstChild("BodyDepthScale")
			-- Use built-in scaling if available (R15 rigs)
			if humanoid:FindFirstChild("BodyWidthScale") then
				humanoid.BodyWidthScale.Value = scale
			end
			if humanoid:FindFirstChild("BodyDepthScale") then
				humanoid.BodyDepthScale.Value = scale
			end
			if humanoid:FindFirstChild("BodyHeightScale") then
				humanoid.BodyHeightScale.Value = scale
			end
			if humanoid:FindFirstChild("HeadScale") then
				humanoid.HeadScale.Value = scale
			end
		end
	end
end

local function getAlphaFromX(x)
	local absPos = sliderBack.AbsolutePosition.X
	local absSize = sliderBack.AbsoluteSize.X
	return (x - absPos) / absSize
end

sliderButton.MouseButton1Down:Connect(function()
	dragging = true
end)

sliderBack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		local alpha = getAlphaFromX(input.Position.X)
		setScaleFromAlpha(alpha)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local alpha = getAlphaFromX(input.Position.X)
		setScaleFromAlpha(alpha)
	end
end)

-- Initialize default scale to 1.0
do
	local defaultAlpha = (1 - minScale) / (maxScale - minScale)
	setScaleFromAlpha(defaultAlpha)
end

-- Update when character respawns
player.CharacterAdded:Connect(function()
	task.wait(1)
	local currentText = valueLabel.Text
	local currentScale = tonumber(string.match(currentText, "Scale: ([%d%.]+)x")) or 1
	local alpha = (currentScale - minScale) / (maxScale - minScale)
	setScaleFromAlpha(alpha)
end)