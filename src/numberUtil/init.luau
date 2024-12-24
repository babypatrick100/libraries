-- #selene: allow(unused_variable)
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

local Loader = require(script.Parent.Loader)
local average = require(script.methods.average)
local clampTo = require(script.methods.clampTo)
local close = require(script.methods.close)
local comb = require(script.methods.comb)
local commas = require(script.methods.commas)
local cosec = require(script.methods.cosec)
local cotan = require(script.methods.cotan)
local cubicBezier = require(script.methods.cubicBezier)
local exponentialLerp = require(script.methods.exponentialLerp)
local factorial = require(script.methods.factorial)
local factors = require(script.methods.factors)
local inverseLerp = require(script.methods.inverseLerp)
local lerp = require(script.methods.lerp)
local logarithmicLerp = require(script.methods.logarithmicLerp)
local mean = require(script.methods.mean)
local median = require(script.methods.median)
local mode = require(script.methods.mode)
local nan = require(script.methods.nan)
local quadraticBezier = require(script.methods.quadraticBezier)
local quadraticLerp = require(script.methods.quadraticLerp)
local root = require(script.methods.root)
local secant = require(script.methods.secant)
local sphericalLerp = require(script.methods.sphericalLerp)
local suffix = require(script.methods.suffix)
local to12H = require(script.methods.to12H)
local to24H = require(script.methods.to24H)
local hms = require(script.methods.hms)
local nextOrder = require(script.methods.nextOrder)

local numberUtil = {
	e = 2.7182818284590,
	tau = 2 * math.pi,
	phi = 1.618033988749895,
	g = 6.6743e-11,
	ga = 137.5,
	ec = 0.577215664901,
	sr = 2.4142135623,
}

for methodName, method in Loader.LoadChildren(script.methods) do
	numberUtil[methodName] = method
end

return table.freeze(numberUtil) :: typeof(numberUtil) & {
	average: typeof(average),
	clampTo: typeof(clampTo),
	close: typeof(close),
	comb: typeof(comb),
	commas: typeof(commas),
	cosec: typeof(cosec),
	cotan: typeof(cotan),
	cubicBezier: typeof(cubicBezier),
	exponentialLerp: typeof(exponentialLerp),
	factorial: typeof(factorial),
	factors: typeof(factors),
	inverseLerp: typeof(inverseLerp),
	lerp: typeof(lerp),
	logarithmicLerp: typeof(logarithmicLerp),
	mean: typeof(mean),
	median: typeof(median),
	mode: typeof(mode),
	nan: typeof(nan),
	quadraticBezier: typeof(quadraticBezier),
	quadraticLerp: typeof(quadraticLerp),
	root: typeof(root),
	secant: typeof(secant),
	sphericalLerp: typeof(sphericalLerp),
	suffix: typeof(suffix),
	to12H: typeof(to12H),
	to24H: typeof(to24H),
	hms: typeof(hms),
	nextOrder: typeof(nextOrder),
}
