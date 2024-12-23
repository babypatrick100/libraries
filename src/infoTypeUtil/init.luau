--[=[ 
	@class infoTypeUtil

	An utility module for working with `Enum.InfoType`.
]=]

local TRANSFORMED_INFO_TYPE_NAMES = {
	[Enum.InfoType.GamePass] = "Gamepass",
}

local infoTypeUtil = {}

--[=[
	Returns the transformed info type name from the given `infoType` or else `infoType.Name`. 
]=]

function infoTypeUtil.transformedInfoTypeName(infoType: Enum.InfoType)
	if TRANSFORMED_INFO_TYPE_NAMES[infoType] ~= nil then
		return TRANSFORMED_INFO_TYPE_NAMES[infoType]
	end

	return infoType.Name
end

return table.freeze(infoTypeUtil)
