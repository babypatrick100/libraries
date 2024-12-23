--[=[
    @within numberUtil

    A trigonometric function that in a right-angled triangle is the ratio of the length of the adjacent side to
    that of the opposite side; the reciprocal of tangent.

    ```lua
    print(numberUtil.cotan(1)) --> 0.6420926159343306
    ```
]=]

local function cotan(number: number): number
	return 1 / math.tan(number)
end

return cotan
