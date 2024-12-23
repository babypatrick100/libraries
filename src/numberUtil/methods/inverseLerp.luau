--[=[
    @within numberUtil
    
    Inverse lerp is the inverse operation of the lerp node. It can be used to determine what the input to a lerp was 
    based on its output. 

    ```lua
    print(numberUtil.inverseLerp(2, 5, 0.7)) --> -0.43333333333333335
    ```
]=]

local function inverseLerp(min: number, max: number, alpha: number): number
	return (alpha - min) / (max - min)
end

return inverseLerp
