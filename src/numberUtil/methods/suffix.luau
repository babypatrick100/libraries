local NUMBER_SUFFIXES = {
	"K",
	"M",
	"B",
	"t",
	"q",
	"Q",
	"s",
	"S",
	"o",
	"n",
	"d",
	"U",
	"D",
	"T",
	"Qt",
	"Qd",
	"Sd",
	"St",
	"O",
	"N",
	"v",
	"c",
}

--[=[
    @within numberUtil

    Return a string as the formatted version of `number`. 

    :::warning Cannot format extremely large numbers
    This method will struggle to format numbers larger than approximately `10^68`. 

    ```lua
    print(numberUtil.suffix(10^70)) --> 10 (no formatting...)
    ```
    :::

    ```lua
    print(numberUtil.suffix(1650)) --> "1.65K"
    ```

    Additionally, if `number` is lower than `1`, then this method will just return `number` (stringified).
]=]

local function suffix(number: number): string
	if number < 1 then
		return tostring(number)
	end

	local formattedNumberSuffix = math.floor(math.log(number, 1e3))

	return string.gsub(
		string.format("%.2f", number / math.pow(10, formattedNumberSuffix * 3)),
		"%.?0+$",
		""
	) .. (NUMBER_SUFFIXES[formattedNumberSuffix] or "")
end

return suffix
