--[=[ 
    @class dateUtil

    An utility module for working with dates.
]=]

local Loader = require(script.Parent.Loader)
local daysInMonth = require(script.methods.daysInMonth)
local ordinal = require(script.methods.ordinal)
local stringifiedMonth = require(script.methods.stringifiedMonth)
local yearIsLeapYear = require(script.methods.yearIsLeapYear)

local dateUtil = {}

for methodName, method in Loader.LoadChildren(script.methods) do
	dateUtil[methodName] = method
end

return table.freeze(dateUtil) :: {
	daysInMonth: typeof(daysInMonth),
	ordinal: typeof(ordinal),
	stringifiedMonth: typeof(stringifiedMonth),
	yearIsLeapYear: typeof(yearIsLeapYear),
}
