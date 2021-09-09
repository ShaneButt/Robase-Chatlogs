--[[
	Robase Chatlogs Plugin
	Author: @ShaneSloth (Roblox)

	Description:
		This plugin is made to make saving chat logs easier and sotrage-efficient.

		The goal of this plugin is to be simple to use, easy to implement, and light on
		budget calls.
]]

local Vendor = script:FindFirstChild("Vendor")

local Plugin = {}
Plugin.Dependencies = {
	--Promise = require(Vendor:FindFirstChild("Promise")),
	RobaseService = require(Vendor:FindFirstChild("RobaseService")),
}

return Plugin