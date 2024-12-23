--[=[
	@class timeFormatUtil
	
	A utility module for formatting time.
]=]

local numberUtil = require(script.Parent.numberUtil)

local timeFormatUtil = {}

--[=[ 
	Formats a time format in `12`h format to `24`h format.

	```lua
	print(timeUtil.format12hFormatTo24hFormat("1:56 AM")) --> "01:56"
	```
]=]

function timeFormatUtil.format12hFormatTo24hFormat(time: string): string
	local usingPM = string.split(time, " ")[2] == "PM"
	local split = string.split(string.split(time, " ")[1], ":")
	local hours = tonumber(split[1])
	local minutes = tonumber(split[2])

	return string.format(
		"%02i:%02i",
		numberUtil.to24H(hours, if usingPM then "pm" else "am"),
		minutes
	)
end

return table.freeze(timeFormatUtil)
