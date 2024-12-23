local MAX_DAYS_IN_MONTH = 31
local FEBRUARY_LEAP_YEAR_DAYS = 29
local FEBRUARY_NON_LEAP_YEAR_DAYS = 28
local MONTH_WITH_30_DAYS = 30

--[=[
    @within dateUtil
    
    Returns the number of days in the given month.

    ```lua
    print(dateUtil.daysInMonth(2023, 6)) --> 30
    ```
]=]

local function daysInMonth(year: number, month: number): number
	local days = MAX_DAYS_IN_MONTH

	if month == 2 then
		if year % 4 == 0 and year % 100 ~= 0 then
			days = FEBRUARY_LEAP_YEAR_DAYS
		else
			days = FEBRUARY_NON_LEAP_YEAR_DAYS
		end
	elseif month == 4 or month == 6 or month == 9 or month == 11 then
		days = MONTH_WITH_30_DAYS
	end

	return days
end

return daysInMonth
