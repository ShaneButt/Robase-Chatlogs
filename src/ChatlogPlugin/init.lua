--[[
	Robase Chatlogs Plugin
	Author: @ShaneSloth (Roblox)

	Description:
		This plugin is made to make saving chat logs easier and sotrage-efficient.

		The goal of this plugin is to be simple to use, easy to implement, and light on
		budget calls.
]]
local RunService = game:GetService("RunService")
local ChatService = game:GetService("Chat")

local Vendor = script:FindFirstChild("Vendor")

local Plugin = {  }
Plugin.Dependencies = {
	Promise = require(Vendor:FindFirstChild("Promise")),
	RobaseService = require(Vendor:FindFirstChild("RobaseService")),
}
Plugin.ChatHistory = {  }
Plugin.Promises = {  }
Plugin.IsCollecting = false

--[[ Plugin.Promises.CollectChatFor = Plugin.Dependencies.Promise.promisify(function(self, duration)
	local dt = 0
	Plugin.IsCollecting = true
	while dt < duration and self.IsCollecting do
		local step = RunService.Heartbeat:Wait()
		print(step)
		dt += step
	end

	return dt >= duration, dt
end) ]]

Plugin.Promises.CollectChatFor = function(self, duration)
	local dt = 0
	self.IsCollecting = true
	return Plugin.Dependencies.Promise.fromEvent(RunService.Heartbeat, function(step)
		dt += step
		if not self.IsCollecting then
			return true
		end
		if duration ~= 0 and dt >= duration then
			return true
		else
			return false
		end
	end)
end

function Plugin.collect(chatData)
	if Plugin.IsCollecting then
		print(chatData)
		Plugin.ChatHistory[tostring(chatData.SpeakerUserId)] = {
			[tostring(chatData.ID)] = {
				Content = chatData.Message,
				Channel = chatData.OriginalChannel,
				Time = DateTime.fromUnixTimestamp(chatData.Time)
			}
		}
	end
	return chatData
end

function Plugin.start(duration)
	ChatService:RegisterChatCallback(Enum.ChatCallbackType.OnServerReceivingMessage, Plugin.collect)

	print("Collecting Chatlogs")
	Plugin.Promises.CollectChatFor(Plugin, duration):andThen(function(step)
		print("Finished Collection")
		Plugin.stop()
		print(Plugin.ChatHistory)
	end)
end

function Plugin.stop()
	Plugin.IsCollecting = false
end

return Plugin