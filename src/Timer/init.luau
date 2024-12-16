--[=[
	@class Timer

	The Timer class allows for code to run periodically at specified intervals.

	```lua
	local timer = Timer.new(2)
	timer.ticked:Connect(function(tickDelta)
		print("Tock")
	end)
	timer:start()
	```
]=]

local HttpService = game:GetService("HttpService")

local Trove = require(script.Parent.Trove)
local Signal = require(script.Parent.Signal)
local schedulerUtil = require(script.Parent.schedulerUtil)

local Timer = {}
Timer.__index = Timer

--[=[
	@within Timer
	@prop ticked Signal <timerDelta: number>
	The event which is fired every time the timer hits its interval.
]=]

--[=[
	@return Timer
	
	Creates a new timer.
]=]

function Timer.new(interval: number)
	assert(
		type(interval) == "number",
		"Argument #1 to Timer.new must be a number; got " .. type(interval)
	)
	assert(
		interval >= 0,
		"Argument #1 to Timer.new must be greater or equal to 0; got " .. tostring(interval)
	)

	local self = setmetatable({
		ticked = Signal.new(),
		_trove = Trove.new(),
		_tickDelta = 0,
		_interval = interval,
		_running = false,
		_schedulerCallbackIdentifier = `Timer_{HttpService:GenerateGUID()}_{tostring(interval)}`,
	}, Timer)
	self:_init()

	return self
end

--[=[
	Returns `true` if the given object is a Timer.
]=]
function Timer.is(self: any): boolean
	return getmetatable(self) == Timer
end

--[=[
	Starts the timer. Will do nothing if the timer is already running.

	```lua
	timer:Start()
	```
]=]
function Timer:start()
	if self:running() then
		return
	end

	self:_startTimer()
end

--[=[
	Returns the timer tick delta.

	```lua
	print(timer:tickDelta())
	```
]=]

function Timer:tickDelta(): number
	return self._tickDelta
end

--[=[
	Starts the timer and fires off the [Timer.ticked] signal immediately. Will do
	nothing if the timer is already running.

	```lua
	timer:startNow()
	```
]=]
function Timer:startNow()
	if self:running() then
		return
	end

	self.ticked:Fire(self._interval)
	self:start()
end

--[=[
	Stops the timer. Will do nothing if the timer is already stopped.

	```lua
	timer:stop()
	```
]=]
function Timer:stop()
	self._running = false
	schedulerUtil.unschedule(
		schedulerUtil.RunServiceEvent.Heartbeat,
		self._schedulerCallbackIdentifier
	)
end

--[=[
	Returns the timer's interval.
]=]

function Timer:interval(): number
	return self._interval
end

--[=[
	Returns `true` if the timer is currently running.

	```lua
	if timer:running() then
		-- Do something
	end
	```
]=]
function Timer:running(): boolean
	return self._running
end

--[=[
	Destroys the timer. This will also stop the timer.
]=]
function Timer:destroy()
	self._trove:Destroy()
end

function Timer:_startTimer()
	self._running = true
	self._trove:Add(
		schedulerUtil.schedule(
			schedulerUtil.RunServiceEvent.Heartbeat,
			self._schedulerCallbackIdentifier,
			function(deltaTime)
				self._tickDelta += deltaTime

				if self._tickDelta >= self._interval then
					self.ticked:Fire(self._tickDelta)
					self._tickDelta = 0
				end
			end
		)
	)
end

function Timer:_init()
	self._trove:Add(self.ticked)
end

return Timer
