--[=[
	@class Timer

	The Timer class allows for code to run periodically at specified intervals.

	```lua
	local timer = Timer.new(2)
	timer.onTicked:Connect(function(tickDelta)
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
	@prop onTicked Signal <timerDelta: number>
	The event which is fired every time the timer hits its interval.
]=]

--[=[
	@return Timer
	
	Creates a new timer.
]=]

function Timer.new(interval: number)
	local self = setmetatable({
		onTicked = Signal.new(),
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
	Returns a boolean indicating whether or not the timer ticked.

	Here's an alternative variant to just listening to [Timer.onTicked]:

	```lua
	local timer = Timer.new(1)

	while true do
		if timer:ticked() then
			warn("we do something every 1~ second")
		end

		timer.onTicked:Wait()
	end
	```
]=]

function Timer:ticked(): boolean
	return self._tickDelta >= self._interval
end

--[=[
	Starts the timer and fires off the [Timer.onTicked] signal immediately. Will do
	nothing if the timer is already running.

	```lua
	timer:startNow()
	```
]=]
function Timer:startNow()
	if self:running() then
		return
	end

	self.onTicked:Fire(self._interval)
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
	Returns the timer's tick interval.
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
					self.onTicked:Fire(self._tickDelta)
					self._tickDelta = 0
				end
			end
		)
	)
end

function Timer:_init()
	self._trove:Add(self.onTicked)
end

return Timer
