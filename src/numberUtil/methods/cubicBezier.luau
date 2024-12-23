--[=[
    @within numberUtil
    
    Returns the cubic bezier from the arguments.

    ```lua
    print(cubicBezier(2, 0.15, 0, 0.1, 0)) --> -1.35
    ```
]=]

local function cubicBezier(t: number, p0: number, p1: number, p2: number, p3: number): number
	return (1 - t) ^ 3 * p0 + 3 * (1 - t) ^ 2 * t * p1 + 3 * (1 - t) * t ^ 2 * p2 + t ^ 3 * p3
end

return cubicBezier
