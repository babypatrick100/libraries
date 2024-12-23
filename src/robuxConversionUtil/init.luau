--[=[ 
	@class robuxConversionUtil
	
	A simple utility module for working with robux related conversions.
]=]

local ROBUX_TO_DOLLAR_RATE = 0.0035

local robuxConversionUtil = {}

--[=[ 
    Returns the given robux converted to dollars.
]=]

function robuxConversionUtil.robuxToDollar(robux: number)
	return robux * ROBUX_TO_DOLLAR_RATE
end

--[=[ 
    Returns the given `dollar` converted to robux.
]=]

function robuxConversionUtil.dollarToRobux(dollar: number)
	return dollar / ROBUX_TO_DOLLAR_RATE
end

return table.freeze(robuxConversionUtil)
