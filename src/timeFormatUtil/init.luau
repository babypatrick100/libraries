--[=[
	@class timeFormatUtil
	
	A utility module for formatting time.
]=]

local numberUtil = require(script.Parent.numberUtil)

local timeFormatUtil = {}

--[=[ 
	Formats the given `timeString` in `12`h format to `24`h format.

	```lua
	print(timeUtil.formatTimeTo24hFormat("11:56 PM")) --> "23:56"
	```
]=]

function timeFormatUtil.formatTimeTo24hFormat(timeString: string): string
	local usingPM = string.split(timeString, " ")[2] == "PM"
	local split = string.split(string.split(timeString, " ")[1], ":")
	local hours = tonumber(split[1])
	local minutes = tonumber(split[2])

	return string.format(
		"%02i:%02i",
		numberUtil.to24H(hours, if usingPM then "pm" else "am"),
		minutes
	)
end

--[=[ 
	Formats the given `timeString` in `24`h format to `12`h format.

	```lua
	print(timeUtil.formatTimeTo12hFormat("00:41")) --> "12:41" AM
	```
]=]

function timeFormatUtil.formatTimeTo12hFormat(timeString: string): string
	local split = string.split(string.split(timeString, " ")[1], ":")
	local hours = tonumber(split[1])
	local minutes = tonumber(split[2])
	local pmOrAm = if hours >= 12 then "PM" else "AM"

	return `{string.format("%02i:%02i", numberUtil.to12H(hours), minutes)} {pmOrAm}`
end

return table.freeze(timeFormatUtil)
