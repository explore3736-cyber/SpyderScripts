--// FE Avatar Accessory GUI Script
--// LocalScript, execute in client (e.g., as an executor script)

local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

local function createTween(obj, info, props)
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

-- Clear existing same-name GUIs
for _,g in ipairs(playerGui:GetChildren()) do
	if g.Name == "FEOutfitGui" then
		g:Destroy()
	end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FEOutfitGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Black background
local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Size = UDim2.new(1,0,1,0)
bg.Position = UDim2.new(0,0,0,0)
bg.BackgroundColor3 = Color3.new(0,0,0)
bg.BorderSizePixel = 0
bg.BackgroundTransparency = 0
bg.Parent = screenGui

-- Loading label
local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(1,0,1,0)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Text = "Loading..."
loadingLabel.TextColor3 = Color3.new(1,1,1)
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.TextScaled = true
loadingLabel.Parent = bg

-- Simple fake loading
RunService.RenderStepped:Wait()
task.wait(1.5)

-- Fade loading out
local TweenService = game:GetService("TweenService")
createTween(loadingLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Wait()
loadingLabel:Destroy()

-- Main panel
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 200)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.new(0.05,0.05,0.05)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0
mainFrame.Parent = bg

-- Smooth corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.new(1,1,1)
stroke.Thickness = 1.5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = mainFrame

-- Top bar (cut X)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1,0,0,32)
topBar.Position = UDim2.new(0,0,0,0)
topBar.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0,12)
topCorner.Parent = topBar

-- Mask top corners so bottom remain sharp
local topMask = Instance.new("Frame")
topMask.Size = UDim2.new(1,0,1,8)
topMask.Position = UDim2.new(0,0,0,-8)
topMask.BackgroundTransparency = 1
topMask.BorderSizePixel = 0
topMask.Parent = mainFrame

-- Title text
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1,-40,1,0)
title.Position = UDim2.new(0,10,0,0)
title.Font = Enum.Font.GothamSemibold
title.Text = "FE Avatar Changer"
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 16
title.Parent = topBar

-- Close (X) button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0,32,0,32)
closeBtn.Position = UDim2.new(1,-32,0,0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = topBar

-- Main content area
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1,0,1,-32)
contentFrame.Position = UDim2.new(0,0,0,32)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0,16)
layout.Parent = contentFrame

-- Helper to make buttons
local function createOptionButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,220,0,44)
	btn.BackgroundColor3 = Color3.new(0.15,0.15,0.15)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 16

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,10)
	c.Parent = btn

	local s = Instance.new("UIStroke")
	s.Color = Color3.new(1,1,1)
	s.Thickness = 1
	s.Transparency = 0.3
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = btn

	btn.Parent = contentFrame
	return btn
end

local krobloxButton = createOptionButton("Wear Kroblox")
local headlessButton = createOptionButton("Wear Headless")

-- Hover effects
local function addHoverEffects(btn)
	local origColor = btn.BackgroundColor3
	btn.MouseEnter:Connect(function()
		createTween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.new(0.25,0.25,0.25)
		})
	end)
	btn.MouseLeave:Connect(function()
		createTween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = origColor
		})
	end)
end

addHoverEffects(krobloxButton)
addHoverEffects(headlessButton)

-- Fade in main UI
mainFrame.BackgroundTransparency = 1
topBar.BackgroundTransparency = 1
for _,obj in ipairs(mainFrame:GetDescendants()) do
	if obj:IsA("TextLabel") or obj:IsA("TextButton") then
		obj.TextTransparency = 1
	elseif obj:IsA("Frame") then
		obj.BackgroundTransparency = 1
	end
end

createTween(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
createTween(topBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.1})

for _,obj in ipairs(mainFrame:GetDescendants()) do
	if obj:IsA("TextLabel") or obj:IsA("TextButton") then
		createTween(obj, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
	elseif obj:IsA("Frame") and obj ~= mainFrame and obj ~= topBar then
		if obj.BackgroundTransparency ~= 1 then
			createTween(obj, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
		end
	end
end

-- Accessory equip function
local function applyAccessory(assetId)
	if not character or not character.Parent then
		character = player.Character or player.CharacterAdded:Wait()
	end

	local success, model = pcall(function()
		return InsertService:LoadAsset(assetId)
	end)

	if not success or not model then
		return
	end

	local accessory = nil
	for _,obj in ipairs(model:GetChildren()) do
		if obj:IsA("Accessory") or obj:IsA("Hat") then
			accessory = obj
			break
		end
	end

	if accessory then
		accessory.Parent = character
	end

	model:Destroy()
end

-- Click connections
krobloxButton.MouseButton1Click:Connect(function()
	applyAccessory(139607718)
end)

headlessButton.MouseButton1Click:Connect(function()
	applyAccessory(134082579)
end)

-- Close button logic (cut X)
local closing = false
closeBtn.MouseButton1Click:Connect(function()
	if closing then return end
	closing = true

	createTween(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
	for _,obj in ipairs(mainFrame:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			createTween(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1})
		elseif obj:IsA("Frame") and obj ~= mainFrame then
			if obj.BackgroundTransparency ~= 1 then
				createTween(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
			end
		end
	end

	task.wait(0.3)
	screenGui:Destroy()
end)