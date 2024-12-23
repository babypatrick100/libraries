--[=[
    @within dateUtil

    Returns the given number in ordinal format.

    ```lua
    print(dateUtil.ordinal(24)) --> 24th
    ```
]=]

-- https://stackoverflow.com/questions/20694133/how-to-to-add-th-or-rd-to-the-date
local function ordinal(number: number): string
	local ordinals, digit = { "st", "nd", "rd" }, string.sub(tostring(number), -1)

	if
		tonumber(digit) > 0
		and tonumber(digit) <= 3
		and string.sub(tostring(number), -2) ~= tostring(11)
		and string.sub(tostring(number), -2) ~= tostring(12)
		and string.sub(tostring(number), -2) ~= tostring(13)
	then
		return number .. ordinals[tonumber(digit) :: number]
	else
		return number .. "th"
	end
end

return ordinal
