--[=[ 
    @class numberUtil

    An utility module for working with numbers.
 
    ```lua
    print(numberUtil.e) --> 2.7182818284590
    print(numberUtil.nan(3)) --> false
    ```
]=]

--[=[ 
    @prop e number <2.7182818284590>
    @within numberUtil
    @tag Read only

    A mathematical constant, also known as Euler's number. 
]=]

--[=[ 
    @prop phi number <1.618033988749895>
    @within numberUtil
    @tag Read only

    A mathematical constant, also known as the golden ratio.
]=]

--[=[ 
    @prop tau number <6.283185307179586>
    @within numberUtil
    @tag Read only

    A mathematical constant, it is the circle constant representing the ratio between circumference and radius.
]=]

--[=[ 
    @prop g number <6.6743e-11>
    @within numberUtil
    @tag Read only

    A mathematical constant, used in calculating the gravitational attraction between two objects.
]=]

--[=[ 
    @prop ga number <137.5>
    @within numberUtil
    @tag Read only

    A mathematical constant (the golden angle), which is the smaller of the two angles created by
    sectioning the circumference of a circle.
]=]

--[=[ 
    @prop ec number <0.577215664901>
    @within numberUtil
    @tag Read only

    A mathematical constant (also known as Euler's constant - **not** to be confused with Euler's *number* i.e `e`
    which approximately equals to `2.718`).
]=]

local MID_NIGHT_24_HOUR = 0
local NOON_HOUR = 12
local DEFAULT_NUMBER_EPSLION = 1e-2

local numberUtil = {
	e = 2.7182818284590,
	tau = 2 * math.pi,
	phi = 1.618033988749895,
	g = 6.6743e-11,
	ga = 137.5,
	ec = 0.577215664901,
	sr = 2.4142135623,
}

--[=[
    @within numberUtil
    
    Returns the given hour formatted to the 12 hour clock.

    ```lua
    print(numberUtil.to24H(12, "am")) --> 0
    print(numberUtil.to24H(5, "pm")) --> 17
    print(numberUtil.to24H(12, "pm")) --> 12
    print(numberUtil.to24H(11, "pm")) --> 23
    print(numberUtil.to24H(11, "am")) --> 11
    ```
]=]

function numberUtil.to24H(hour: number, preset: "am" | "pm"): number
	if preset == "am" then
		if hour == NOON_HOUR then
			return MID_NIGHT_24_HOUR
		end

		return hour
	else
		if hour == NOON_HOUR then
			return hour
		end

		return hour + NOON_HOUR
	end
end

--[=[
    Returns the given hour formatted to the 12 hour clock.

    ```lua
    print(numberUtil.to12H(24)) --> 12
    print(numberUtil.to12H(17)) --> 5
    ```
]=]

function numberUtil.to12H(hour: number): number
	hour = hour % 24
	return (hour - 1) % 12 + 1
end

--[=[
    Returns a result on based on [spherical linear interpolation](https://en.wikipedia.org/wiki/Slerp).
]=]

function numberUtil.sphericalLerp(
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

--[=[
    The ratio of the hypotenuse to the shorter side adjacent to an acute angle (in a right-angled triangle); the reciprocal of a cosine.

    ```lua
    print(numberUtil.secant(1)) --> 1.8508157176809255
    ```
]=]

function numberUtil.secant(number: number): number
	return 1 / math.cos(number)
end

--[=[
    Returns the `root` of `number`.

    ```lua
    print(numberUtil.root(2, 3)) --> 1.2599210498948732 (same as cube root of 2)
    print(numberUtil.root(2, 2)) --> 1.4142135623730951 (same as square root of 2)
    ```
]=]

function numberUtil.root(number: number, numberRoot: number): number
	return number ^ (1 / numberRoot)
end

--[=[
    Quadraticly interpolates `number` to `goal`, with `alpha` being the multiplier.

    ```lua
    print(numberUtil.quadraticLerp(2, 5, 0.7)) --> 4.1
    ```
]=]

function numberUtil.quadraticLerp(number: number, goal: number, alpha: number): number
	return (number - goal) * alpha * (alpha - 2) + number
end

--[=[
    Returns the quadratic bezier from the arguments.

    ```lua
    print(numberUtil.quadraticBezier(0, 0.5, 3, 5)) --> 0.5
    ```
]=]

function numberUtil.quadraticBezier(t: number, p0: number, p1: number, p2: number): number
	return (1 - t) ^ 2 * p0 + 2 * (1 - t) * t * p1 + t ^ 2 * p2
end

--[=[
	Returns a function which returns a numerical value, which is always incremented by 1.

	```lua
	local nextOrder = numberUtil.nextOrder() 
	print(nextOrder()) --> 1
	print(nextOrder()) --> 2
	print(nextOrder()) --> 3
	```
]=]

function numberUtil.nextOrder(): () -> number
	local order = 0

	return function()
		order += 1
		return order
	end
end

--[=[
    Returns a boolean indicating if `number` is NaN (Not A Number). 

    ```lua
    print(numberUtil.nan(0 / 0)) --> true
    ```
]=]

function numberUtil.nan(number: number): boolean
	if typeof(number) ~= "number" then
		return false
	end

	return number ~= number
end

--[=[
    @within numberUtil
    
    From a set of numbers `...`, returns the number which is the most frequent.

    ```lua
    print(numberUtil.mode(1, 2, 3, 3)) --> 3
    print(numberUtil.mode(1, 2, 3)) --> nil (no numbers repeat)
    ```
]=]

function numberUtil.mode(...: number): number?
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

--[=[
    Returns the median of the set of numbers `...`.

    ```lua
    print(numberUtil.median(2, 2)) --> 4
    ```
]=]

function numberUtil.median(...: number): number
	local sum = 0

	for _, number in { ... } do
		sum += number
	end

	return sum / 2
end

--[=[
    Returns the mean of the set of numbers `...`.

    ```lua
    print(numberUtil.mean(3, 5)) --> 2
    ```
]=]

function numberUtil.mean(...: number): number
	local sum = 0
	local numbers = { ... }

	for _, number in numbers do
		sum += number
	end

	return sum / #numbers
end

--[=[
    Logarithmicly lerps `number` to `goal`, with `alpha` being the multiplier.

    ```lua
    print(numberUtil.logarithmicLerp(1, 2, 3)) --> 0.125
    ```
]=]

function numberUtil.logarithmicLerp(number: number, goal: number, alpha: number): number
	return number * math.pow(number / goal, alpha)
end

--[=[
    Interpolates `number` to `goal`, with `alpha` being the multiplier.

    ```lua
    print(numberUtil.lerp(2, 5, 0.7)) --> 4.1
    ```
]=]

function numberUtil.lerp(number: number, goal: number, alpha: number): number
	return number + (goal - number) * alpha
end

--[=[
    Inverse lerp is the inverse operation of the lerp node. It can be used to determine what the input to a lerp was 
    based on its output. 

    ```lua
    print(numberUtil.inverseLerp(2, 5, 0.7)) --> -0.43333333333333335
    ```
]=]

function numberUtil.inverseLerp(min: number, max: number, alpha: number): number
	return (alpha - min) / (max - min)
end

--[=[
    Returns a string which is just `number` formatted to the HMS (Hour, Minutes, Seconds) format.

    ```lua
    print(numberUtil.hms(21660)) --> 6, 1, 0 
    ```
]=]

function numberUtil.hms(number: number): (number, number, number)
	return number / 60 ^ 2, number / 60 % 60, number % 60
end
--[=[
    Returns a read only array of all factors of `number`.

    ```lua
    print(numberUtil.factors(2)) --> {1, 2}
    ```
]=]

function numberUtil.factors(number: number): { number }
	local numberFactors = {}

	for index = 1, number do
		if number % index == 0 then
			table.insert(numberFactors, index)
		end
	end

	if number == 0 then
		table.insert(numberFactors, 0)
	end

	return table.freeze(numberFactors)
end

--[=[
    Returns the factorial of `number`.

    ```lua
    print(numberUtil.factorial(3)) --> 6
    ```
]=]

function numberUtil.factorial(number: number): number
	if number == 0 then
		return 1
	end

	return number * numberUtil.factorial(number - 1)
end

--[=[
    Exponentially lerps `number` to `goal`, with `alpha` being the multiplier.

    ```lua
    print(numberUtil.exponentialLerp(1, 5, 3)) --> 125
    ```
]=]

function numberUtil.exponentialLerp(number: number, goal: number, alpha: number): number
	return number ^ (1 - alpha) * goal ^ alpha
end

--[=[
    Returns the cubic bezier from the arguments.

    ```lua
    print(cubicBezier(2, 0.15, 0, 0.1, 0)) --> -1.35
    ```
]=]

function numberUtil.cubicBezier(t: number, p0: number, p1: number, p2: number, p3: number): number
	return (1 - t) ^ 3 * p0 + 3 * (1 - t) ^ 2 * t * p1 + 3 * (1 - t) * t ^ 2 * p2 + t ^ 3 * p3
end

--[=[
    A trigonometric function that in a right-angled triangle is the ratio of the length of the adjacent side to
    that of the opposite side; the reciprocal of tangent.

    ```lua
    print(numberUtil.cotan(1)) --> 0.6420926159343306
    ```
]=]

function numberUtil.cotan(number: number): number
	return 1 / math.tan(number)
end

--[=[
    Returns the reciprocal of `math.sign(number)`.

    ```lua
    print(numberUtil.cosec(1)) --> 1.1883951057781212
    ```
]=]

function numberUtil.cosec(number: number): number
	return 1 / math.sin(number)
end

--[=[
    Returns a number (stringified), formatted with commas.

    ```lua
    print(numberUtil.commas(15000)) --> 15,000
    ```
]=]

-- http://lua-users.org/wiki/FormattingNumbers
function numberUtil.commas(target: number): string
	local targetCommas, k = target, nil

	while true do
		targetCommas, k = string.gsub(targetCommas, "^(-?%d+)(%d%d%d)", "%1,%2")

		if k == 0 then
			break
		end
	end

	return targetCommas
end

--[=[
    Returns the number of ways picking `k` unordered outcomes from `number` possibilities, without repetition.

    :::note
    If the value of `k` is greater than `number`, then the method will return `0`.
    :::

    ```lua
    print(numberUtil.comb(2, 1)) --> 2
    ```
]=]

function numberUtil.comb(number: number, k: number): number
	if k > number then
		return 0
	end

	return numberUtil.factorial(number)
		/ (numberUtil.factorial(k) * numberUtil.factorial(number - k))
end

--[=[
    Returns a boolean indicating if the difference between `number` and `to` is lower than or equal to `eplsion`.

    ```lua
    print(numberUtil.close(0.1 + 0.2, 0.3)) --> true
    print(numberUtil.close(0.1 + 0.2, 0.3, 0)) --> false
    ```

    - If `eplison` is not specified, then it will default to `1e-2`.
]=]

function numberUtil.close(number: number, to: number, eplison: number?): boolean
	return math.abs(number - to) <= (eplison or DEFAULT_NUMBER_EPSLION)
end

--[=[
    Clamps `number` to `clamp`, if `number` is greater than `max` or lower than `min`.

    ```lua
    print(numberUtil.clampTo(1, 2, 5, 150)) --> 150
    ```
]=]

function numberUtil.clampTo(number: number, min: number, max: number, clamp: number): number
	if number > max or number < min then
		return clamp
	end

	return number
end

--[=[
    Returns the average of `...` numbers against `sum`.

    ```lua
    print(numberUtil.average(100, 50, 25)) --> 0.75
    ```
]=]

function numberUtil.average(sum: number, ...: number): number
	local accumulatedSum = 0

	for _, number in { ... } do
		accumulatedSum += number
	end

	return accumulatedSum / sum
end

return table.freeze(numberUtil)
