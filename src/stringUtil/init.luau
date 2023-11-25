--[=[
	@class stringUtil

	A simple utility module for working with strings.
]=]

local stringUtil = {}

--[=[
	Returns a formatted version of the given string (essentially just add in hiphens).

	```lua
	print(stringUtil.formatLongString("bubshayz haha")) --> "bubshayz-haha"
	print(stringUtil.formatLongString("jail in the break")) --> "jail-in-the-break"
	```
]=]

function stringUtil.formatLongString(string: string)
	local shortenedString = ""

	local index = 0

	for str in string.gmatch(string, "[%a%d]+") do
		shortenedString ..= string.format(if index >= 1 then "-%s" else "%s", str)
		index += 1
	end

	return shortenedString
end

return table.freeze(stringUtil)
