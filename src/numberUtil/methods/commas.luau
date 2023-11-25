--[=[
    @within numberUtil
    
    Returns a string formatted with commas.

    ```lua
    print(numberUtil.commas(15000)) --> 15,000
    ```
]=]

-- http://lua-users.org/wiki/FormattingNumbers
local function commas(target: number): string 
	local commas, k = target, nil

	while true do
		commas, k = string.gsub(commas, "^(-?%d+)(%d%d%d)", "%1,%2")

		if k == 0 then
			break
		end
	end

	return commas
end

return commas
