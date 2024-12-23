local DEFAULT_NUMBER_EPSLION = 1e-2

--[=[
    @within numberUtil
    
    Returns a boolean indicating if the difference between `number` and `to` is lower than or equal to `eplsion`.

    ```lua
    print(numberUtil.close(0.1 + 0.2, 0.3)) --> true
    print(numberUtil.close(0.1 + 0.2, 0.3, 0)) --> false
    ```

    - If `eplison` is not specified, then it will default to `1e-2`.
]=]

local function close(number: number, to: number, eplison: number?): boolean
	return math.abs(number - to) <= (eplison or DEFAULT_NUMBER_EPSLION)
end

return close
