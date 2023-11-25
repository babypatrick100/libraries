--[=[
    @class playerCharacterUtil

    A simple utility module for working with the player's character.
]=]

local playerCharacterUtil = {}

--[=[
	Set's the transparency of all descendants (Baseparts and decals) in `playerCharacter` 
	to `transparency`, except for the primary part.
]=]

function playerCharacterUtil.setCharacterTransparency(playerCharacter: Model, transparency: number)
	for _, descendant in playerCharacter:GetDescendants() do
		if
			not (descendant:IsA("BasePart") or descendant:IsA("Decal"))
			or descendant == playerCharacter.PrimaryPart
		then
			continue
		end

		descendant.Transparency = transparency
	end
end

--[=[
	Returns the distance from the `playerCharacter`'s primary part to `position`. 
	
	If `playerCharacter` is `nil` or if the primary part doesn't exist, then this method will return `math.huge`.
]=]

function playerCharacterUtil.distanceFromCharacter(
	playerCharacter: Model?,
	position: Vector3
): number
	if playerCharacter == nil then
		return math.huge
	end

	local primaryPart = playerCharacter.PrimaryPart

	if not primaryPart then
		return math.huge
	end

	return (primaryPart.Position - position).Magnitude
end

return table.freeze(playerCharacterUtil)
