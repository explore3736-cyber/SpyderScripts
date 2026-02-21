-- StarterGui > ScreenGui > Frame > SliderBar > SliderHandle
-- StarterGui > ScreenGui > TextLabel (ValueDisplay)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local gui = script.Parent
local frame = gui:WaitForChild("Frame")
local sliderBar = frame:WaitForChild("SliderBar")
local sliderHandle = sliderBar:WaitForChild("SliderHandle")
local valueDisplay = frame:WaitForChild("ValueDisplay")

local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local minScale = 0.5
local maxScale = 2
local currentScale = 1

local dragging = false
local tweenTime = 0.15

local function getScaleFromPosition(xPos)
	local barPos = sliderBar.AbsolutePosition.X
	local barSize = sliderBar.AbsoluteSize.X
	local relative = math.clamp((xPos - barPos) / barSize, 0, 1)
	local scale = minScale + (maxScale - minScale) * relative
	return scale, relative
end

local function updateHandlePositionFromScale(scale)
	local ratio = (scale - minScale) / (maxScale - minScale)
	local barSize = sliderBar.AbsoluteSize.X
	local targetX = barSize * ratio
	local goalPos = UDim2.new(0, targetX, sliderHandle.Position.Y.Scale, sliderHandle.Position.Y.Offset)
	TweenService:Create(sliderHandle, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goalPos}):Play()
end

local function updateValueDisplay(scale)
	valueDisplay.Text = string.format("Size: %.2fx", scale)
end

local function applyScale(scale)
	currentScale = scale
	updateValueDisplay(scale)

	if humanoid and humanoid.Parent then
		local bodyDepthScale = humanoid:FindFirstChild("BodyDepthScale")
		local bodyHeightScale = humanoid:FindFirstChild("BodyHeightScale")
		local bodyWidthScale = humanoid:FindFirstChild("BodyWidthScale")
		local headScale = humanoid:FindFirstChild("HeadScale")

		local function tweenValue(obj, prop, value)
			if not obj then return end
			TweenService:Create(obj, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[prop] = value}):Play()
		end

		tweenValue(bodyDepthScale, "Value", scale)
		tweenValue(bodyHeightScale, "Value", scale)
		tweenValue(bodyWidthScale, "Value", scale)
		tweenValue(headScale, "Value", scale)
	end
end

sliderHandle.MouseButton1Down:Connect(function()
	dragging = true
end)

userInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

runService.RenderStepped:Connect(function()
	if dragging then
		local mousePos = userInputService:GetMouseLocation().X
		local scale, _ = getScaleFromPosition(mousePos)
		applyScale(scale)
		updateHandlePositionFromScale(scale)
	end
end)

gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	updateHandlePositionFromScale(currentScale)
end)

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	wait(0.1)
	applyScale(currentScale)
end)

updateHandlePositionFromScale(currentScale)
updateValueDisplay(currentScale)
applyScale(currentScale)