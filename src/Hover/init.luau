--[=[ 
	@class Hover
	
	A simple hover class for implementing hover effects.

	```lua
	local hover = Hover.new(0, 1, 0)
	local originalPosition = part.Position

	RunService.Stepped:Connect(function(_, deltaTime)
		hover:update(deltaTime, 0.5, 1)
		part.Position = originalPosition + hover:vector()
	end)
	```
]=]

--[=[ 
    @type Hover Hover 
    @within Hover
]=]

local Hover = {}
Hover.__index = Hover

--[=[ 
	Constructs a new hover object, with forces `x`, `y` and `z` which can only be `0` and `1`.
	These forces determine on which axis the hover effect is applied to - e.g if `x` is `1`,
	then the hover effect will be applied on the X axis and if `y` is `1`, then the hover effect
	will be applied on the Y axis.

	:::note
	`x` and `z` will both default to `0` if not specified *but* `y` will default to `1` if not 
	specified - which means by default, the hover effect will always be applied on the Y axis.
	:::
]=]

function Hover.new(x: number?, y: number?, z: number?): Hover
	local self = setmetatable({
		_hoverPhase = 0,
		_hoverAmplitude = 0,
		_paused = false,
		_forces = { x = 0, y = 0, z = 0 },
	}, Hover)

	self:setForces(x or 0, y or 1, z or 0)
	return self
end

--[=[ 
	Pauses the hover effect.
]=]

function Hover:pause()
	self._paused = true
end

--[=[ 
	Resumes the hover effect.
]=]

function Hover:resume()
	self._paused = false
end

--[=[ 
	Updates the hover effect. `deltaTime` is a measure of how fast the hover effect
	is updated **per frame**, along with `speed`. `hoverAmplitude` is a measure of 
	how much the hover effect is applied on each axis.

	:::note
	If the hover effect is paused, then this method will not do anything.
	:::
]=]

function Hover:update(deltaTime: number, speed: number, hoverAmplitude: number)
	if self._paused then
		return
	end

	self._hoverPhase += deltaTime * speed
	self._hoverAmplitude = hoverAmplitude
end

--[=[ 
	Sets the forces of the hover object to `x`, `y` and `z`.
]=]

function Hover:setForces(x: number?, y: number?, z: number?)
	self._forces.x = math.clamp(x or 0, 0, 1)
	self._forces.y = math.clamp(y or 0, 0, 1)
	self._forces.z = math.clamp(z or 0, 0, 1)
end

--[=[ 
	Returns the vector used in implementing the actual hover effect.

	:::note
	If the hover effect is paused, then this method will return `Vector3.zero`.
	:::

	```lua
	local hover = Hover.new(0, 1, 0)
	local originalPosition = part.Position

	RunService.Stepped:Connect(function(_, deltaTime)
		hover:update(deltaTime, 0.5, 1)
		part.Position = originalPosition + hover:vector()
	end)
	```
]=]

function Hover:vector(): Vector3
	if self._paused then
		return Vector3.zero
	end

	return Vector3.new(
		math.sin(self._hoverPhase) * self._hoverAmplitude * self._forces.x,
		math.sin(self._hoverPhase) * self._hoverAmplitude * self._forces.y,
		math.sin(self._hoverPhase) * self._hoverAmplitude * self._forces.z
	)
end

--[=[ 
	Destroys the hover object and renders it unusable.
]=]

function Hover:destroy()
	setmetatable(self, nil)
end

export type Hover = typeof(Hover.new())

return table.freeze(Hover)
