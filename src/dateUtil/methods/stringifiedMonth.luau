local MONTHS = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December",
}

--[=[
    @within dateUtil
    
    Returns a stringified month.

    ```lua
    print(dateUtil.stringifiedMonth(3)) --> "March"
    ```
]=]

local function stringifiedMonth(month: number): string
	return MONTHS[month]
end

return stringifiedMonth
