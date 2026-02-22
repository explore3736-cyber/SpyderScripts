--// FE Avatar Item GUI Script
--// LocalScript (e.g., in StarterPlayerScripts or executed via executor)

local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FEItemsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 260, 0, 140)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = frame

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 15, 0, 5)
title.Font = Enum.Font.GothamBold
title.Text = "Avatar Items"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, -8, 0, 15)
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

local buttonsHolder = Instance.new("Frame")
buttonsHolder.Name = "ButtonsHolder"
buttonsHolder.BackgroundTransparency = 1
buttonsHolder.Size = UDim2.new(1, -20, 0, 80)
buttonsHolder.Position = UDim2.new(0, 10, 0, 50)
buttonsHolder.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.Parent = buttonsHolder

local function createButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.5, -10, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.Font = Enum.Font.GothamSemibold
	btn.TextScaled = true
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Parent = btn

	btn.Parent = buttonsHolder
	return btn
end

local krobloxButton = createButton("Kroblox")
local headlessButton = createButton("Headless")

-- Draggable frame
local dragging = false
local dragStart
local startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Utility: Wear item by AssetId (for hats/heads/accessories)
local function wearAsset(assetId)
	task.spawn(function()
		local ok, model = pcall(function()
			return InsertService:LoadAsset(assetId)
		end)
		if not ok or not model then
			return
		end

		local char = player.Character or player.CharacterAdded:Wait()

		for _, obj in ipairs(model:GetChildren()) do
			if obj:IsA("Accessory") or obj:IsA("Hat") or obj:IsA("CharacterMesh") or obj:IsA("Decal") then
				obj.Parent = char
			elseif obj:IsA("Model") then
				for _, inner in ipairs(obj:GetChildren()) do
					if inner:IsA("Accessory") or inner:IsA("Hat") or inner:IsA("CharacterMesh") or inner:IsA("Decal") then
						inner.Parent = char
					end
				end
			end
		end

		model:Destroy()
	end)
end

krobloxButton.MouseButton1Click:Connect(function()
	wearAsset(139607718)
end)

headlessButton.MouseButton1Click:Connect(function()
	wearAsset(134082579)
end)

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)