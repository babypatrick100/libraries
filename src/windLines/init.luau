-- Original author: boatbomber, refactored and modified by bubshurb.

--[=[
	@interface WindLinesConfig  
	@within windLines	
	.lifetime number? -- The life time of wind lines.
	.direction Vector3? -- The direction of wind lines.
	.speed number? -- The speed at which wind lines move.
	.spawnRate number? -- The rate at which wind lines are created.
	.raycastParams RaycastParams? -- A `RaycastParams` object, to be used in determining if the player is under a roof or not.

	This is a config template, none of these members are required in the config table when configuring windLines through [windLines.setConfig], however
	the config table must not be empty!
]=]

--[=[
	@interface DefaultWindLinesConfig 
	@within windLines	
	.lifetime 3 
	.direction Vector3.new(1, 0, 0) 
	.speed 6 
	.spawnRate 25
	.raycastParams nil
	
	This is the **default** config template that windLines initially uses. You can configure windLines through [windLines.setConfig].
]=]

--[=[ 
	@class windLines

	windLines is a fork of boatbomber's wind lines module, however it is heavily refactored and has a few slight changes 
	in behavior. Overall, it is a module for creating wind line effects.

	```lua
	windLines.onEffectStarted:Connect(function()
		print("WindLines effect started")
	end)

	windLines.onEffectStopped:Connect(function()
		print("WindLines effect stopped")
	end)

	windLines.start()
	```
]=]

--[=[ 
	@prop onEffectStarted Signal <>
	@within windLines
	@tag Signal
	@tag Read only
	A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the wind lines effect starts.
]=]

--[=[ 
	@prop onEffectStopped Signal <>
	@within windLines
	@tag Signal
	@tag Read only
	A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the wind lines effect stops.
]=]

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Signal)
local WindLine = require(script.WindLine)
local Janitor = require(script.Parent.Janitor)
local t = require(script.Parent.t)

local WIND_POSITION_OFFSET = Vector3.new(0, 0.1, 0)
local CAMERA_CEILING_Y_VECTOR = Vector3.new(0, 1000, 0)
local DEFAULT_CONFIG = {
	lifetime = 3,
	direction = Vector3.xAxis,
	speed = 6,
	spawnRate = 25,
	raycastParams = RaycastParams.new(),
}

local ConfigInterface = t.strictInterface({
	lifetime = t.optional(t.integer),
	direction = t.optional(t.Vector3),
	speed = t.optional(t.integer),
	spawnRate = t.optional(t.integer),
	raycastParams = t.optional(t.RaycastParams),
})

local camera = Workspace.CurrentCamera
local started = false
local effectStarted = false

local windLines = {
	onEffectStarted = Signal.new(),
	onEffectStopped = Signal.new(),
	_janitor = Janitor.new(),
	_updateQueue = table.create(30),
	_updateQueueFinished = Signal.new(),
	_config = {},
}

type WindLinesConfig = {
	lifetime: number?,
	direction: number?,
	speed: number?,
	spawnRate: number?,
	raycastParams: RaycastParams?,
}
--[=[
	Returns a boolean indicating if the wind lines **effect** is started.
]=]

function windLines.effectStarted(): boolean
	return effectStarted
end

--[=[
	Returns a boolean indicating if windLines is started through [windLines.start].
]=]

function windLines.started(): boolean
	return started
end

--[=[
	@param newConfig WindLinesConfig

	Sets the current config of windLines to `newConfig`, so that this new config will be used for wind line effects.
]=]

function windLines.setConfig(newConfig: WindLinesConfig)
	assert(t.table(newConfig))
	assert(ConfigInterface(newConfig))

	for key, value in newConfig do
		windLines._config[key] = value
	end
end

--[=[
	Starts up the wind lines effect.

	:::tip Custom behavior 
	If the player is standing under a roof, then the wind lines effect will be stopped for realism purposes and this
	behavior cannot be toggled. However, you can adjust this behavior through [windLines.setConfig] through the 
	[RaycastParams](https://create.roblox.com/docs/reference/engine/datatypes/RaycastParams) member, since ray casting 
	is used in determining if the player is standing under a roof. 

	For e.g, the following config does not consider descendants in the `filteredPartsFolder` folder as roofs, 
	so if a player stands under them, the wind lines effect will not be stopped:

	```lua
	local Workspace = game:GetService("Workspace")

	local filteredPartsFolder = Workspace.SomeFolder
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {filteredPartsFolder} 

	windLines.setConfig({raycastParams = raycastParams})
	windLines.start()
	```
	:::
]=]

function windLines.start()
	assert(not windLines.started(), "Cannot start windlines as it is already started!")

	started = true
	local heartbeatUpdateConnection = windLines._startHeartbeatUpdate()

	windLines._janitor:Add(function()
		started = false
		effectStarted = false

		local function updateQueueFinished()
			heartbeatUpdateConnection:Disconnect()
			windLines._updateQueueFinished:DisconnectAll()
		end

		if #windLines._updateQueue == 0 then
			updateQueueFinished()
		else
			windLines._updateQueueFinished:Connect(updateQueueFinished)
		end
	end)
end

--[=[
	Stops the wind lines effect.
]=]

function windLines.stop()
	assert(windLines.started(), "Cannot stop windlines as it is not started!")

	windLines._janitor:Cleanup()
end

function windLines._startHeartbeatUpdate()
	local lastClockSincewindLinespawned = os.clock()
	local config = windLines._config
	local spawnRate = 1 / config.spawnRate

	return RunService.Heartbeat:Connect(function()
		local clockNow = os.clock()
		local isCameraUnderPart = Workspace:Raycast(
			camera.CFrame.Position,
			CAMERA_CEILING_Y_VECTOR,
			config.raycastParams
		) ~= nil

		if (clockNow - lastClockSincewindLinespawned) > spawnRate and started then
			if not isCameraUnderPart then
				if not effectStarted then
					effectStarted = true
					windLines.onEffectStarted:Fire()
				end

				WindLine.new(config, windLines._updateQueue)
				lastClockSincewindLinespawned = clockNow
			elseif windLines.effectStarted() then
				effectStarted = false
				windLines.onEffectStopped:Fire()
			end
		end

		for _, windLine in windLines._updateQueue do
			local aliveTime = clockNow - windLine.startClock

			if aliveTime >= windLine.lifetime then
				windLine:destroy()
				continue
			end

			windLine.trail.MaxLength = 20 - (20 * (aliveTime / windLine.lifetime))

			local seededClock = (clockNow + windLine.seed) * (windLine.speed * 0.2)
			local startPosition = windLine.position

			windLine.attachment0.WorldPosition = (CFrame.new(
				startPosition,
				startPosition + windLine.direction
			) * CFrame.new(0, 0, windLine.speed * -aliveTime)).Position + Vector3.new(
				math.sin(seededClock) * 0.5,
				math.sin(seededClock) * 0.8,
				math.sin(seededClock) * 0.5
			)

			windLine.attachment1.WorldPosition = windLine.attachment0.WorldPosition
				+ WIND_POSITION_OFFSET
		end

		if #windLines._updateQueue == 0 and not started then
			windLines._updateQueueFinished:Fire()
		end
	end)
end

windLines.setConfig(DEFAULT_CONFIG)

return table.freeze(windLines)
