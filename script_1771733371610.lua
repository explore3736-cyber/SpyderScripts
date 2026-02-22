--// LocalScript (e.g., StarterPlayerScripts)

-- CONFIG
local DEFAULT_SPEED = 50
local MIN_SPEED = 10
local MAX_SPEED = 300
local SPEED_STEP = 10

-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-- STATE
local flying = false
local flySpeed = DEFAULT_SPEED
local moveDir = Vector3.new()
local cutUIVisible = false

-- UI CREATION
local function createUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FlyControlUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 220, 0, 90)
	mainFrame.Position = UDim2.new(0, 20, 1, -110)
	mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	mainFrame.BorderSizePixel = 0
	mainFrame.BackgroundTransparency = 0.15
	mainFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = mainFrame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Transparency = 0.2
	stroke.Color = Color3.fromRGB(80, 120, 255)
	stroke.Parent = mainFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = mainFrame

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = mainFrame

	-- Left column
	local leftColumn = Instance.new("Frame")
	leftColumn.Size = UDim2.new(0, 120, 1, 0)
	leftColumn.BackgroundTransparency = 1
	leftColumn.Parent = mainFrame

	local leftLayout = Instance.new("UIListLayout")
	leftLayout.FillDirection = Enum.FillDirection.Vertical
	leftLayout.Padding = UDim.new(0, 4)
	leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	leftLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	leftLayout.Parent = leftColumn

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 20)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = "Fly Control"
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = leftColumn

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, 0, 0, 18)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.Text = "Status: OFF"
	statusLabel.TextSize = 14
	statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = leftColumn

	local speedLabel = Instance.new("TextLabel")
	speedLabel.Name = "SpeedLabel"
	speedLabel.Size = UDim2.new(1, 0, 0, 18)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Font = Enum.Font.Gotham
	speedLabel.Text = "Speed: " .. tostring(DEFAULT_SPEED)
	speedLabel.TextSize = 14
	speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	speedLabel.TextXAlignment = Enum.TextXAlignment.Left
	speedLabel.Parent = leftColumn

	local hintLabel = Instance.new("TextLabel")
	hintLabel.Size = UDim2.new(1, 0, 0, 18)
	hintLabel.BackgroundTransparency = 1
	hintLabel.Font = Enum.Font.Gotham
	hintLabel.Text = "[F] Fly  |  [+/-] Speed"
	hintLabel.TextSize = 12
	hintLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	hintLabel.TextXAlignment = Enum.TextXAlignment.Left
	hintLabel.Parent = leftColumn

	-- Right column (cut button)
	local rightColumn = Instance.new("Frame")
	rightColumn.Size = UDim2.new(1, -120, 1, 0)
	rightColumn.BackgroundTransparency = 1
	rightColumn.Parent = mainFrame

	local cutButton = Instance.new("TextButton")
	cutButton.Name = "CutButton"
	cutButton.AnchorPoint = Vector2.new(1, 0.5)
	cutButton.Size = UDim2.new(0, 70, 0, 34)
	cutButton.Position = UDim2.new(1, 0, 0.5, 0)
	cutButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
	cutButton.Text = "CUT"
	cutButton.Font = Enum.Font.GothamBold
	cutButton.TextSize = 16
	cutButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	cutButton.AutoButtonColor = false
	cutButton.Parent = rightColumn

	local cbCorner = Instance.new("UICorner")
	cbCorner.CornerRadius = UDim.new(0, 8)
	cbCorner.Parent = cutButton

	local cbStroke = Instance.new("UIStroke")
	cbStroke.Thickness = 2
	cbStroke.Color = Color3.fromRGB(255, 140, 140)
	cbStroke.Transparency = 0.1
	cbStroke.Parent = cutButton

	local cutGlow = Instance.new("UIGradient")
	cutGlow.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 220)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 160, 160))
	})
	cutGlow.Rotation = 90
	cutGlow.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 0.2)
	})
	cutGlow.Parent = cutButton

	-- Toggle bar (expand/collapse)
	local toggleBar = Instance.new("TextButton")
	toggleBar.Name = "ToggleBar"
	toggleBar.Size = UDim2.new(0, 120, 0, 22)
	toggleBar.Position = UDim2.new(0, 20, 1, -25)
	toggleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	toggleBar.BorderSizePixel = 0
	toggleBar.Text = "Fly UI"
	toggleBar.TextColor3 = Color3.fromRGB(220, 220, 220)
	toggleBar.TextSize = 14
	toggleBar.Font = Enum.Font.Gotham
	toggleBar.AutoButtonColor = false
	toggleBar.Parent = screenGui

	local tbCorner = Instance.new("UICorner")
	tbCorner.CornerRadius = UDim.new(0, 6)
	tbCorner.Parent = toggleBar

	local tbStroke = Instance.new("UIStroke")
	tbStroke.Thickness = 1.5
	tbStroke.Color = Color3.fromRGB(70, 70, 90)
	tbStroke.Transparency = 0.4
	tbStroke.Parent = toggleBar

	local arrowLabel = Instance.new("TextLabel")
	arrowLabel.Name = "Arrow"
	arrowLabel.Size = UDim2.new(0, 20, 1, 0)
	arrowLabel.Position = UDim2.new(1, -20, 0, 0)
	arrowLabel.BackgroundTransparency = 1
	arrowLabel.Font = Enum.Font.GothamBold
	arrowLabel.Text = "▲"
	arrowLabel.TextSize = 14
	arrowLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	arrowLabel.Parent = toggleBar

	mainFrame.Visible = true

	-- Toggle UI visibility (smooth)
	local collapsed = false
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function setCollapsed(state)
		collapsed = state
		if collapsed then
			local tween = TweenService:Create(
				mainFrame,
				tweenInfo,
				{Position = UDim2.new(0, 20, 1, 10), BackgroundTransparency = 1}
			)
			tween:Play()
			arrowLabel.Text = "▼"
			task.delay(0.4, function()
				if collapsed then
					mainFrame.Visible = false
				end
			end)
		else
			mainFrame.Visible = true
			mainFrame.Position = UDim2.new(0, 20, 1, 10)
			mainFrame.BackgroundTransparency = 1
			local tween = TweenService:Create(
				mainFrame,
				tweenInfo,
				{Position = UDim2.new(0, 20, 1, -110), BackgroundTransparency = 0.15}
			)
			tween:Play()
			arrowLabel.Text = "▲"
		end
	end

	toggleBar.MouseButton1Click:Connect(function()
		setCollapsed(not collapsed)
	end)

	-- Cut button behavior (smooth kill/disable)
	cutButton.MouseEnter:Connect(function()
		TweenService:Create(cutButton, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(220, 100, 100)
		}):Play()
	end)

	cutButton.MouseLeave:Connect(function()
		TweenService:Create(cutButton, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(200, 80, 80)
		}):Play()
	end)

	cutButton.MouseButton1Click:Connect(function()
		if cutUIVisible then return end
		cutUIVisible = true

		-- Smooth fade out everything and disable fly
		flying = false
		moveDir = Vector3.new()
		if humanoid and humanoid.RootPart then
			humanoid.PlatformStand = false
		end

		local fadeTween = TweenService:Create(mainFrame, TweenInfo.new(0.4), {
			BackgroundTransparency = 1
		})
		fadeTween:Play()

		local toggleFade = TweenService:Create(toggleBar, TweenInfo.new(0.4), {
			BackgroundTransparency = 1,
			TextTransparency = 1
		})
		toggleFade:Play()

		task.delay(0.4, function()
			screenGui:Destroy()
		end)
	end)

	return {
		MainFrame = mainFrame,
		StatusLabel = statusLabel,
		SpeedLabel = speedLabel,
	}
end

local ui = createUI()

-- FLY CONTROL
local function updateStatusLabel()
	if not ui or not ui.StatusLabel then return end
	if flying then
		ui.StatusLabel.Text = "Status: ON"
		ui.StatusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
	else
		ui.StatusLabel.Text = "Status: OFF"
		ui.StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
	end
end

local function updateSpeedLabel()
	if not ui or not ui.SpeedLabel then return end
	ui.SpeedLabel.Text = "Speed: " .. tostring(flySpeed)
end

local function toggleFly()
	flying = not flying
	if humanoid and humanoid.RootPart then
		humanoid.PlatformStand = flying
	end
	updateStatusLabel()
end

local pressed = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false,
	Up = false,
	Down = false
}

local function computeMoveDir()
	local dir = Vector3.new()
	if not camera then return dir end

	local camCF = camera.CFrame
	local forward = camCF.LookVector
	local right = camCF.RightVector
	local up = camCF.UpVector

	if pressed.Forward then dir += forward end
	if pressed.Backward then dir -= forward end
	if pressed.Right then dir += right end
	if pressed.Left then dir -= right end
	if pressed.Up then dir += up end
	if pressed.Down then dir -= up end

	if dir.Magnitude > 0 then
		dir = dir.Unit
	end
	return dir
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.W then
		pressed.Forward = true
	elseif input.KeyCode == Enum.KeyCode.S then
		pressed.Backward = true
	elseif input.KeyCode == Enum.KeyCode.A then
		pressed.Left = true
	elseif input.KeyCode == Enum.KeyCode.D then
		pressed.Right = true
	elseif input.KeyCode == Enum.KeyCode.Space then
		pressed.Up = true
	elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
		pressed.Down = true
	elseif input.KeyCode == Enum.KeyCode.F then
		toggleFly()
	elseif input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.KeypadPlus then
		flySpeed = math.clamp(flySpeed + SPEED_STEP, MIN_SPEED, MAX_SPEED)
		updateSpeedLabel()
	elseif input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.KeypadMinus then
		flySpeed = math.clamp(flySpeed - SPEED_STEP, MIN_SPEED, MAX_SPEED)
		updateSpeedLabel()
	end
end)

UserInputService.InputEnded:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.W then
		pressed.Forward = false
	elseif input.KeyCode == Enum.KeyCode.S then
		pressed.Backward = false
	elseif input.KeyCode == Enum.KeyCode.A then
		pressed.Left = false
	elseif input.KeyCode == Enum.KeyCode.D then
		pressed.Right = false
	elseif input.KeyCode == Enum.KeyCode.Space then
		pressed.Up = false
	elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
		pressed.Down = false
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if not flying then return end
	character = player.Character or character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	moveDir = computeMoveDir()
	if moveDir.Magnitude == 0 then
		root.Velocity = Vector3.new(0, 0, 0)
	else
		root.Velocity = moveDir * flySpeed
	end
end)

updateStatusLabel()
updateSpeedLabel()