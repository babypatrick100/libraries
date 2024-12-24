--[=[ 
	@class numberFormatUtil

	A simple utility for formatting numbers in human readable format.
]=]

local NUMBERS_MAPPED_TO_TUPLES = {
	[2] = "Double",
	[3] = "Triple",
	[4] = "Quadruple",
	[5] = "Quintuple",
	[6] = "Sextuple",
	[7] = "Septuple",
	[8] = "Octuple",
	[9] = "Nonuple",
	[10] = "Decuple",
	[11] = "Undecuple",
	[12] = "Duodecuple",
	[13] = "Tredecuple",
	[14] = "Quattuordecuple",
	[15] = "Quindecuple",
	[16] = "Sexdecuple",
	[17] = "Septendecuple",
	[18] = "Octodecuple",
	[19] = "Novemdecuple",
	[20] = "Vigintuple",
	[30] = "Trigintuple",
	[40] = "Quadragintuple",
	[50] = "Quinquagintuple",
	[60] = "Sexagintuple",
	[70] = "Septuagintuple",
	[80] = "Octogintuple",
	[90] = "Nonagintuple",
	[100] = "Centuple",
	[200] = "Ducentuple",
	[300] = "Trecentuple",
	[400] = "Quadringentuple",
	[500] = "Quingentuple",
	[600] = "Sescentuple",
	[700] = "Septingentuple",
	[800] = "Octingentuple",
	[900] = "Nongentuple",
	[1000] = "Milluple",
	[2000] = "Bimilluple",
	[10000] = "Decamilluple",
	[1_000_000] = "Micruple",
	[1_000_000_000] = "Nanuple",
	[10 ^ 12] = "Picuple",
	[10 ^ 15] = "Femtuple",
	[10 ^ 18] = "Attuple",
	[10 ^ 21] = "Zeptuple",
	[10 ^ 24] = "Yoctuple",
	[10 ^ 27] = "Rontuple",
	[10 ^ 30] = "Quectuple",
	[10 ^ 33] = "Bundectuple",
	[10 ^ 36] = "Biduple",
	[10 ^ 39] = "Triduple",
	[10 ^ 42] = "Quadiduple",
	[10 ^ 45] = "Quintiduple",
	[10 ^ 48] = "Sextiduple",
	[10 ^ 51] = "Septiduple",
	[10 ^ 54] = "Octiduple",
	[10 ^ 57] = "Noniduple",
	[10 ^ 60] = "Voguple",
}

local numberFormatUtil = {}

--[=[
	Returns the given `number`'s tuple, if any. Supports up to `57` tuples!

	```lua
	print(numberFormatUtil.numberToTuple(2)) --> "Double"
	print(numberFormatUtil.numberToTuple(3)) --> "Triple"
	print(numberFormatUtil.numberToTuple(4)) --> "Quadruple"
	```
]=]

function numberFormatUtil.numberToTuple(number: number): string?
	return NUMBERS_MAPPED_TO_TUPLES[number]
end

--[=[
    Returns the given number in ordinal format.

    ```lua
    print(numberFormatUtil.ordinal(24)) --> 24th
    ```
]=]

function numberFormatUtil.ordinal(number: number): string
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

return table.freeze(numberFormatUtil)
