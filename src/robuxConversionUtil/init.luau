--[=[ 
	@class robuxConversionUtil
	
	A simple utility module for working with robux related conversions.
]=]

local ROBUX_TO_DEVEX_RATE = 0.0035

local robuxConversionUtil = {}

--[=[ 
    Returns the given robux converted to dollars.
]=]

function robuxConversionUtil.robuxToDevexAmount(robux: number): number
	return robux * ROBUX_TO_DEVEX_RATE
end

--[=[ 
    Returns the given `dollar` converted to robux.
]=]

function robuxConversionUtil.devexAmountToRobux(dollar: number): number
	return dollar / ROBUX_TO_DEVEX_RATE
end

return table.freeze(robuxConversionUtil)
