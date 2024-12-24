--[=[ 
    @class numberUnitUtil

    An utility module for working with number units.
]=]

local numberUnitUtil = {}

--[=[
    Returns `sps` (studs per second) converted to `mph` (miles per second).

    ```lua
    print(numberUnitUtil.spsToMph(100, 50, 25)) --> 0.75
    ```
]=]
function numberUnitUtil.spsToMph(sps: number): number
	return sps * 0.62620743779080167979
end

return table.freeze(numberUnitUtil)
