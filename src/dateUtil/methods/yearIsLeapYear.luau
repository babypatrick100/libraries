--[=[
    @within dateUtil
    
    Returns a boolean indicating whether or not the given year is a leap year.

    ```lua
    print(dateUtil.yearIsLeapYear(2024)) --> true
    ```
]=]

local function yearIsLeapYear(year: number): boolean
	return year % 4 == 0 and year % 100 ~= 0
end

return yearIsLeapYear
