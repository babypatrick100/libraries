--[=[
    @class playerCharacterAccessoryUtil

    A simple utility module for working with the player's character's accessories.
]=]

local playerCharacterAccessoryUtil = {}

--[=[ 
    Returns an array of all accessories of type `accesstoryType` in `playerCharacter`.
]=]

function playerCharacterAccessoryUtil.accessories(
	playerCharacter: Model,
	accessoryType: Enum.AccessoryType
): { Accessory }
	local accessories = {}

	for _, child in playerCharacter:GetChildren() do
		if child:IsA("Accessory") and child.AccessoryType == accessoryType then
			table.insert(accessories, child)
		end
	end

	return table.freeze(accessories)
end

return table.freeze(playerCharacterAccessoryUtil)
