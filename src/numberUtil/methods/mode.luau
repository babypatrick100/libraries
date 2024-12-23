--[=[
    @within numberUtil
    
    From a set of numbers `...`, returns the number which is the most frequent.

    ```lua
    print(numberUtil.mode(1, 2, 3, 3)) --> 3
    print(numberUtil.mode(1, 2, 3)) --> nil (no numbers repeat)
    ```
]=]

local function mode(...: number): number?
	local modes = {}

	for _, number in { ... } do
		modes[number] = modes[number] or 0
		modes[number] += 1
	end

	local modeNumber = nil
	local maxCount = 0

	for number, count in modes do
		if count > maxCount then
			modeNumber = number
			maxCount = count
		end
	end

	if modes[modeNumber] == 1 then
		return nil
	end

	return modeNumber
end

return mode
