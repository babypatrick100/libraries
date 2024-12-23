--[=[
    @within numberUtil
    
    The ratio of the hypotenuse to the shorter side adjacent to an acute angle (in a right-angled triangle); the reciprocal of a cosine.

    ```lua
    print(numberUtil.secant(1)) --> 1.8508157176809255
    ```
]=]

local function secant(number: number): number
	return 1 / math.cos(number)
end

return secant
