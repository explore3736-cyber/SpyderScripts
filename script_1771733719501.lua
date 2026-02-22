local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local MESSAGE = "your message here"
local DELAY = 0.2       -- time between messages
local MAX_MESSAGES = 0  -- 0 for infinite until stop, or set a number

local spamming = false
local sentCount = 0

local function sendChatMessage(text)
	if RunService:IsServer() then
		-- Server-side: chat to all via Chat service if desired
		local ChatService = game:GetService("Chat")
		for _, plr in ipairs(Players:GetPlayers()) do
			local char = plr.Character
			if char then
				local head = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
				if head then
					ChatService:Chat(head, text, Enum.ChatColor.White)
				end
			end
		end
	else
		-- Client-side: use default chat remote
		local player = Players.LocalPlayer
		if player and player:FindFirstChild("PlayerGui") then
			local chatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
			if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
				chatRemote.SayMessageRequest:FireServer(text, "All")
			end
		end
	end
end

local function startSpam()
	if spamming then return end
	spamming = true
	sentCount = 0

	task.spawn(function()
		while spamming do
			if MAX_MESSAGES > 0 and sentCount >= MAX_MESSAGES then
				spamming = false
				break
			end
			sendChatMessage(MESSAGE)
			sentCount += 1
			task.wait(DELAY)
		end
	end)
end

local function stopSpam()
	spamming = false
end

-- Example bindings:
-- Start spamming when script runs:
startSpam()

-- To stop spamming from another script:
-- require(path_to_this_module).Stop()

-- If you want this as a ModuleScript, wrap with a table:
-- return {Start = startSpam, Stop = stopSpam}