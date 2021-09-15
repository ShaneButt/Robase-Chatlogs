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
	Llama = require(Vendor:FindFirstChild("Llama"))
}

local Dictionary = Plugin.Dependencies.Llama.Dictionary

Plugin.ChatHistory = Dictionary.fromLists({},{})
Plugin.Promises = {  }
Plugin.IsCollecting = false


Plugin.CollectChatFor = function(self, duration)
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
		local speaker = tostring(chatData.SpeakerUserId)
		local state = Dictionary.copyDeep(Plugin.ChatHistory)

		if not state[speaker] then
			state = Dictionary.set(state, speaker, {})
		end

		local messages = Dictionary.mergeDeep(state[speaker], {
			[tostring(chatData.ID)] = {
				Content = chatData.Message,
				Channel = chatData.OriginalChannel,
				Time = DateTime.fromUnixTimestamp(chatData.Time)
			}
		})

		state[speaker] = messages
		Plugin.ChatHistory = state
	end

	return chatData
end

function Plugin.start(duration)
	ChatService:RegisterChatCallback(Enum.ChatCallbackType.OnServerReceivingMessage, Plugin.collect)

	print("Collecting Chatlogs")
	Plugin.CollectChatFor(Plugin, duration):andThen(function()
		print("Finished Collection")
		Plugin.stop()
		print(Plugin.ChatHistory)
	end)
end

function Plugin.stop()
	Plugin.IsCollecting = false
end

function Plugin.saveTo(robase, key)
	local logs = Dictionary.copyDeep(Plugin.ChatHistory)

	robase:UpdateAsync(key, function(oldData)
		local prev = Dictionary.copyDeep(oldData)

		return Dictionary.mergeDeep(logs, prev)
	end)
end

function Plugin.startRecording(robase, key, autoSaveInterval)
	Plugin.Dependencies.Promise.try(function()
		while true do
			Plugin.start(autoSaveInterval)
			Plugin.Dependencies.Promise.delay(autoSaveInterval):andThenCall(Plugin.saveTo, robase, key)
		end
	end)
end

return Plugin