--[=[
    @within numberUtil
    
    Returns the `root` of `number`.

    ```lua
    print(numberUtil.root(2, 3)) --> 1.2599210498948732 (same as cube root of 2)
    print(numberUtil.root(2, 2)) --> 1.4142135623730951 (same as square root of 2)
    ```
]=]

local function root(number: number, root: number): number
	return number ^ (1 / root)
end

return root
