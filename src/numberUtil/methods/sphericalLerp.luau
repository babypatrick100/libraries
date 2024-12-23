--[=[
    @within numberUtil
    
    Returns a result on based on [spherical linear interpolation](https://en.wikipedia.org/wiki/Slerp).

    ```lua
    print(numberUtil.sphericalLerp(1, 1, 1, 1, 1, 1, 1, 1, 1, 1)) --> 2.3
    ```
]=]

local function sphericalLerp(
	t: number,
	w0: number,
	x0: number,
	y0: number,
	z0: number,
	w1: number,
	x1: number,
	y1: number,
	z1: number,
	d: number
): number
	local t0, t1

	if d < 0.9999 then
		local d0 = y0 * x1 + w0 * z1 - x0 * y1 - z0 * w1
		local d1 = y0 * w1 - w0 * y1 + z0 * x1 - x0 * z1
		local d2 = y0 * z1 - w0 * x1 - z0 * y1 + x0 * w1
		local theta = math.atan2(math.sqrt(d0 * d0 + d1 * d1 + d2 * d2), d)
		local rsa = math.sqrt(1 - d * d)
		t0, t1 = math.sin((1 - t) * theta) / rsa, math.sin(t * theta) / rsa
	else
		t0, t1 = 1 - t, t
	end

	return w0 * t0 + w1 * t1, x0 * t0 + x1 * t1, y0 * t0 + y1 * t1, z0 * t0 + z1 * t1
end

return sphericalLerp
