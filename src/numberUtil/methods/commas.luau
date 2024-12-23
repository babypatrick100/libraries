--[=[
    @within numberUtil
    
    Returns a number (stringified), formatted with commas.

    ```lua
    print(numberUtil.commas(15000)) --> 15,000
    ```
]=]

-- http://lua-users.org/wiki/FormattingNumbers
local function commas(target: number): string
	local targetCommas, k = target, nil

	while true do
		targetCommas, k = string.gsub(targetCommas, "^(-?%d+)(%d%d%d)", "%1,%2")

		if k == 0 then
			break
		end
	end

	return targetCommas
end

return commas
