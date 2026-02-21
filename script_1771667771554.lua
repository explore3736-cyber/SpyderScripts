-- Basic Fly Script with Simple UI and Speed Changer
-- Place this in a LocalScript (e.g. StarterPlayerScripts or StarterGui)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local flying = false
local flySpeed = 50
local flyDirection = Vector3.new()
local bodyVelocity

local gui = Instance.new("ScreenGui")
gui.Name = "FlyGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 140)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0, 6)
uiCornerMain.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 26)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local uiCornerTop = Instance.new("UICorner")
uiCornerTop.CornerRadius = UDim.new(0, 6)
uiCornerTop.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Basic Fly"
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextSize = 14
titleLabel.Parent = topBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 20)
closeButton.Position = UDim2.new(1, -45, 0.5, -10)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
closeButton.TextSize = 14
closeButton.Parent = topBar

local uiCornerClose = Instance.new("UICorner")
uiCornerClose.CornerRadius = UDim.new(0, 4)
uiCornerClose.Parent = closeButton

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 80, 0, 30)
toggleButton.Position = UDim2.new(0, 15, 0, 50)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
toggleButton.BorderSizePixel = 0
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Fly: OFF"
toggleButton.TextColor3 = Color3.fromRGB(235, 235, 235)
toggleButton.TextSize = 14
toggleButton.Parent = mainFrame

local uiCornerToggle = Instance.new("UICorner")
uiCornerToggle.CornerRadius = UDim.new(0, 4)
uiCornerToggle.Parent = toggleButton

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.BackgroundTransparency = 1
speedLabel.Size = UDim2.new(0, 100, 0, 20)
speedLabel.Position = UDim2.new(0, 15, 0, 90)
speedLabel.Font = Enum.Font.Gotham
speedLabel.Text = "Speed: " .. flySpeed
speedLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedSliderBackground = Instance.new("Frame")
speedSliderBackground.Name = "SpeedSliderBackground"
speedSliderBackground.Size = UDim2.new(0, 120, 0, 6)
speedSliderBackground.Position = UDim2.new(0, 15, 0, 115)
speedSliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedSliderBackground.BorderSizePixel = 0
speedSliderBackground.Parent = mainFrame

local uiCornerSliderBack = Instance.new("UICorner")
uiCornerSliderBack.CornerRadius = UDim.new(0, 3)
uiCornerSliderBack.Parent = speedSliderBackground

local speedFill = Instance.new("Frame")
speedFill.Name = "SpeedFill"
speedFill.Size = UDim2.new(0.5, 0, 1, 0)
speedFill.Position = UDim2.new(0, 0, 0, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(90, 180, 255)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedSliderBackground

local uiCornerSliderFill = Instance.new("UICorner")
uiCornerSliderFill.CornerRadius = UDim.new(0, 3)
uiCornerSliderFill.Parent = speedFill

local speedDragButton = Instance.new("TextButton")
speedDragButton.Name = "SpeedDragButton"
speedDragButton.BackgroundTransparency = 1
speedDragButton.Size = UDim2.new(1, 0, 3, 0)
speedDragButton.Position = UDim2.new(0, 0, -1, 0)
speedDragButton.Text = ""
speedDragButton.Parent = speedSliderBackground

local mainVisible = true

local function setFlyState(state)
	flying = state
	if flying then
		if not bodyVelocity or not bodyVelocity.Parent then
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bodyVelocity.Velocity = Vector3.new()
			bodyVelocity.Parent = humanoidRootPart
		end
		toggleButton.Text = "Fly: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(80, 180, 100)
	else
		if bodyVelocity then
			bodyVelocity:Destroy()
			bodyVelocity = nil
		end
		toggleButton.Text = "Fly: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
	end
end

local function updateSpeedFill()
	local minSpeed = 10
	local maxSpeed = 200
	local alpha = (flySpeed - minSpeed) / (maxSpeed - minSpeed)
	alpha = math.clamp(alpha, 0, 1)
	speedFill.Size = UDim2.new(alpha, 0, 1, 0)
	speedLabel.Text = "Speed: " .. math.floor(flySpeed)
end

local function sliderToSpeed(xPos)
	local minSpeed = 10
	local maxSpeed = 200
	local sliderAbsPos = speedSliderBackground.AbsolutePosition.X
	local sliderAbsSize = speedSliderBackground.AbsoluteSize.X
	local alpha = (xPos - sliderAbsPos) / sliderAbsSize
	alpha = math.clamp(alpha, 0, 1)
	local s = minSpeed + (maxSpeed - minSpeed) * alpha
	return s
end

updateSpeedFill()
setFlyState(false)

toggleButton.MouseButton1Click:Connect(function()
	setFlyState(not flying)
end)

closeButton.MouseButton1Click:Connect(function()
	mainVisible = not mainVisible
	mainFrame.Visible = mainVisible
end)

local draggingSlider = false

speedDragButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = true
	end
end)

speedDragButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = false
	end
end)

userInputService.InputChanged:Connect(function(input)
	if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
		flySpeed = sliderToSpeed(input.Position.X)
		updateSpeedFill()
	end
end)

local moveKeys = {
	[Enum.KeyCode.W] = false,
	[Enum.KeyCode.S] = false,
	[Enum.KeyCode.A] = false,
	[Enum.KeyCode.D] = false,
	[Enum.KeyCode.Space] = false,
	[Enum.KeyCode.LeftControl] = false
}

userInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if moveKeys[input.KeyCode] ~= nil then
		moveKeys[input.KeyCode] = true
	elseif input.KeyCode == Enum.KeyCode.F then
		setFlyState(not flying)
	end
end)

userInputService.InputEnded:Connect(function(input)
	if moveKeys[input.KeyCode] ~= nil then
		moveKeys[input.KeyCode] = false
	end
end)

runService.RenderStepped:Connect(function(deltaTime)
	if not flying or not humanoidRootPart then return end

	local cam = workspace.CurrentCamera
	if not cam then return end

	local forward = cam.CFrame.LookVector
	local right = cam.CFrame.RightVector
	local up = Vector3.new(0, 1, 0)

	local direction = Vector3.new()

	if moveKeys[Enum.KeyCode.W] then
		direction = direction + forward
	end
	if moveKeys[Enum.KeyCode.S] then
		direction = direction - forward
	end
	if moveKeys[Enum.KeyCode.A] then
		direction = direction - right
	end
	if moveKeys[Enum.KeyCode.D] then
		direction = direction + right
	end
	if moveKeys[Enum.KeyCode.Space] then
		direction = direction + up
	end
	if moveKeys[Enum.KeyCode.LeftControl] then
		direction = direction - up
	end

	if direction.Magnitude > 0 then
		direction = direction.Unit
	end

	flyDirection = direction * flySpeed

	if bodyVelocity then
		bodyVelocity.Velocity = flyDirection
	end
end)

player.CharacterAdded:Connect(function(char)
	character = char
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	if flying then
		setFlyState(true)
	end
end)