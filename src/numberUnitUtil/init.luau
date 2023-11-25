--[=[ 
    @class numberUnitUtil

    An utility module for working with number units.
]=]

local Loader = require(script.Parent.Loader)
local spsToMph = require(script.methods.spsToMph)

local numberUnitUtil = {}

for methodName, method in Loader.LoadChildren(script.methods) do
	numberUnitUtil[methodName] = method
end

return table.freeze(numberUnitUtil) :: {
    spsToMph: typeof(spsToMph)
}