local plugin = require(script.Parent)

game.Players.PlayerAdded:Connect(function(player)
		player.CharacterAppearanceLoaded:Connect(function(character)
		print("waiting")
		task.wait(10)
		plugin.start(10)
	end)
end)