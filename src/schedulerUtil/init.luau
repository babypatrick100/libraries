--[=[ 
	@class schedulerUtil
	
	A simple utility module for scheduling [RunService](https://create.roblox.com/docs/reference/engine/classes/RunService) events with minimal performance impacts
	and with automatic performance profiling.
]=]

local RunService = game:GetService("RunService")

local debugLoggerUtil = require(script.Parent.debugLoggerUtil)

local MAX_EXPECTED_CALLBACK_EXECUTION_TIME = 0.4
local CALLBACK_PERFORMANCE_WARN_LOG_INTERVAL = 10

local callbacks = {}
local performanceWarnLogs = {}

local schedulerUtil = {
	RunServiceEvent = {
		Heartbeat = "Heartbeat",
		Stepped = "Stepped",
		RenderStepped = "RenderStepped",
	},
}

--[=[ 
	Schedules the given callback to be run during the given run service event. This is useful because
	this utility sets up all these events **once** and registers the given callbacks to be called during
	each event's invocation point - this prevents you from initializing many different types of RunService
	events.

	```lua
	schedulerUtil.schedule(schedulerUtil.RunServiceEvent.Heartbeat, "PerformMaths" function(deltaTime: number)
		local sum = 2 + 2 * deltaTime
	end)
	```

	:::warning Yielding not allowed in scheduler callbacks
	Scheduler callbacks can never yield. If they do so, an error will be outputted in the console.
	:::

	:::tip Automatic performance profiling
	A profile is created for every scheduler callback using `debug.profilebegin(callbackIdentifier)`, which will allow you to easily monitor the performance
	of individual scheduler callbacks.

	Additionally, an warn is outputted in the console *every 10 seconds* whenever a scheduled callback takes longer than `0.4`seconds to run.
	:::
]=]

function schedulerUtil.schedule(
	runServiceEventName: string,
	callbackIdentifier: string,
	callback: (...any) -> ()
)
	assert(
		schedulerUtil.RunServiceEvent[runServiceEventName],
		string.format("Invalid run service event name [%s] passed!", runServiceEventName)
	)

	if runServiceEventName == schedulerUtil.RunServiceEvent.RenderStepped then
		assert(
			RunService:IsClient(),
			string.format(
				'Attempted to schedule RunService event "%s" on a non-client console!',
				schedulerUtil.RunServiceEvent.RenderStepped
			)
		)
	end

	callbacks[runServiceEventName] = callbacks[runServiceEventName] or {}
	callbacks[runServiceEventName][callbackIdentifier] = callback

	return function()
		schedulerUtil.unschedule(runServiceEventName, callbackIdentifier)
	end
end

--[=[ 
	Deschedules the given RunService event bound callback.
]=]

function schedulerUtil.unschedule(runServiceEventName: string, callbackIdentifier: string)
	assert(
		schedulerUtil.RunServiceEvent[runServiceEventName],
		string.format("Invalid run service event name [%s] passed!", runServiceEventName)
	)

	if callbacks[runServiceEventName] then
		callbacks[runServiceEventName][callbackIdentifier] = nil
	end

	performanceWarnLogs[callbackIdentifier] = nil

	if next(callbacks[runServiceEventName]) == nil then
		callbacks[runServiceEventName] = nil
	end
end

for _, runServiceEvent in schedulerUtil.RunServiceEvent do
	if
		runServiceEvent == schedulerUtil.RunServiceEvent.RenderStepped
		and not RunService:IsClient()
	then
		continue
	end

	RunService[runServiceEvent]:Connect(function(...)
		if not callbacks[runServiceEvent] then
			return
		end

		for identifier, callback in callbacks[runServiceEvent] do
			debug.profilebegin(identifier)

			local clockBefore = os.clock()
			local thread = task.spawn(callback, ...)

			if coroutine.status(thread) ~= "dead" then
				debugLoggerUtil.log(
					error,
					string.format(
						"Callback [%s] yielded - scheduler callbacks must never yield!",
						identifier
					)
				)
			end

			local timeTakenForCallback = os.clock() - clockBefore
			if timeTakenForCallback > MAX_EXPECTED_CALLBACK_EXECUTION_TIME then
				if
					performanceWarnLogs[identifier] == nil
					or (os.clock() - performanceWarnLogs[identifier])
						>= CALLBACK_PERFORMANCE_WARN_LOG_INTERVAL
				then
					debugLoggerUtil.log(
						error,
						string.format(
							"Callback [%s] took %.2fs to run which is probably a lot high!",
							identifier,
							timeTakenForCallback
						)
					)
					performanceWarnLogs[identifier] = os.clock()
				end
			end

			debug.profileend()
		end
	end)
end

return table.freeze(schedulerUtil)
