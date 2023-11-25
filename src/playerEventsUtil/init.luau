--[=[ 
    @class playerEventsUtil

    A simple utility module for working with player events.
]=]

local Players = game:GetService("Players")

local playerEventsUtil = {}

--[=[ 
    A simple wrapper for the [PlayerAdded](https://create.roblox.com/docs/reference/engine/classes/Players#PlayerAdded) event. 
    This method additionally captures **current** players in game; during the time of the execution of this method, as well.
    
    ```lua
    playerUtil.usePlayerAdded(function(player)
        print(player.Name, " joined the game!")
    end)
    ```
]=]

function playerEventsUtil.usePlayerAdded(callback: (player: Player) -> ())
	for _, player in Players:GetPlayers() do
		task.spawn(callback, player)
	end

	return Players.PlayerAdded:Connect(callback)
end

--[=[ 
    A wrapper over the [player.CharacterAdded](https://create.roblox.com/docs/reference/engine/classes/Player#CharacterAdded) event.

    ```lua
    playerEventsUtil.usePlayerCharacterAdded(player, function(newCharacter, oldCharacter)
    
    end)
    ```
]=]

function playerEventsUtil.usePlayerCharacterAdded(
	player: Player,
	callback: (
		newPlayerCharacter: Model,
		oldPlayerCharacter: Model?
	) -> ()
)
	local oldCharacter = player.Character
	if oldCharacter then
		task.spawn(callback, oldCharacter, nil)
	end

	return player.CharacterAdded:Connect(function(newCharacter)
		callback(newCharacter, oldCharacter)
		oldCharacter = newCharacter
	end)
end

return table.freeze(playerEventsUtil)
