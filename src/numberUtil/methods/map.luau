--[=[
    @within numberUtil

    Maps `number` between `inMin` and `inMax`, and `outMin` and `outMax`.

    ```lua
    print(numberUtil.map(1,2,3,4,5)) --> 3
    ```
]=]

local function map(
	number: number,
	inMin: number,
	inMax: number,
	outMin: number,
	outMax: number
): number
	return outMin + ((outMax - outMin) * ((number - inMin) / (inMax - inMin)))
end

return map
