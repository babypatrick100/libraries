--[=[
    @within numberUtil
    Returns the quadratic bezier from the arguments.

    ```lua
    print(numberUtil.quadraticBezier(0, 0.5, 3, 5)) --> 0.5
    ```
]=]

local function quadraticBezier(t: number, p0: number, p1: number, p2: number): number
	return (1 - t) ^ 2 * p0 + 2 * (1 - t) * t * p1 + t ^ 2 * p2
end

return quadraticBezier
