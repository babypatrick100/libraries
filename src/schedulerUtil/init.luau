--[=[ 
	@class schedulerUtil
	
	A simple utility module for scheduling [RunService](https://create.roblox.com/docs/reference/engine/classes/RunService) events with minimal performance impacts
	and with automatic performance profiling.
]=]

local RunService = game:GetService("RunService")

local debugLoggerUtil = require(script.Parent.debugLoggerUtil)
local Connection = require(script.Parent.Connection)

local DEFAULT_MAX_EXPECTED_CALLBACK_EXECUTION_TIME = 0.4
local CALLBACK_PERFORMANCE_WARN_LOG_INTERVAL = 10
local scheduledCallbacksData = {}
local performanceWarnLogs = {}

local schedulerUtil = {
	RunServiceEvent = {
		Heartbeat = "Heartbeat",
		Stepped = "Stepped",
		RenderStepped = "RenderStepped",
	},
}

--[=[ 
	@return Connection

	Schedules the given callback to be run during the given run service event. This is useful because
	this utility sets up all these events **once** and registers the given scheduledCallbacksData to be called during
	each event's invocation point - this prevents you from initializing many different types of RunService
	events.

	```lua
	schedulerUtil.schedule(schedulerUtil.RunServiceEvent.Stepped, "PerformPhyicsUpdate" function(_, deltaTime: number)
		-- Perform physics update here
	end)
	```

	:::warning Yielding is not allowed
	Scheduled callbacks **should** never yield. If they do so, other scheduled callbacks will not be able to run and the utility
	offers no protection against this due to performance related issues.
	:::

	:::tip Automatic memory & performance profiling
	A debug profile is automatically created for the scheduled callback using `debug.profilebegin(callbackIdentifier)`, 
	which will allow you to easily  monitor the performance of individual scheduled callback. Additionally, a debug memory
	category is also setup for the given callback using `debug.setmemorycategory(callbackIdentifier)`.

	This utility automatically outputs a warning message in the console **every 10 seconds** if a given scheduled callback takes a bit too
	long to finish running - so you can also pass in an optional 4th argument, `maxExpectedCallbackRunTime` to have the system know how long
	the given scheduled callback should be expected to finish running.
	:::
]=]

function schedulerUtil.schedule(
	runServiceEventName: string,
	callbackIdentifier: string,
	callback: (...any) -> (),
	maxExpectedCallbackRunTime: number?
): Connection.Connection
	assert(
		schedulerUtil.RunServiceEvent[runServiceEventName],
		string.format("Invalid run service event name [%s] passed!", runServiceEventName)
	)

	if runServiceEventName == schedulerUtil.RunServiceEvent.RenderStepped then
		assert(
			RunService:IsClient(),
			string.format(
				'Attempted to schedule RunService event "%s" on a non-client machine!',
				schedulerUtil.RunServiceEvent.RenderStepped
			)
		)
	end

	scheduledCallbacksData[runServiceEventName] = scheduledCallbacksData[runServiceEventName] or {}
	scheduledCallbacksData[runServiceEventName][callbackIdentifier] = {
		callback = callback,
		maxExpectedCallbackRunTime = maxExpectedCallbackRunTime
			or DEFAULT_MAX_EXPECTED_CALLBACK_EXECUTION_TIME,
	}

	return Connection.new(function()
		schedulerUtil.unschedule(runServiceEventName, callbackIdentifier)
	end)
end

--[=[ 
	Deschedules the given RunService event bound callback.
]=]

function schedulerUtil.unschedule(runServiceEventName: string, callbackIdentifier: string)
	assert(
		schedulerUtil.RunServiceEvent[runServiceEventName],
		string.format("Invalid run service event name [%s] passed!", runServiceEventName)
	)

	if scheduledCallbacksData[runServiceEventName] ~= nil then
		scheduledCallbacksData[runServiceEventName][callbackIdentifier] = nil
	end

	performanceWarnLogs[callbackIdentifier] = nil

	if next(scheduledCallbacksData[runServiceEventName]) == nil then
		scheduledCallbacksData[runServiceEventName] = nil
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
		if scheduledCallbacksData[runServiceEvent] == nil then
			return
		end

		for identifier, scheduledCallbackData in scheduledCallbacksData[runServiceEvent] do
			debug.setmemorycategory(identifier)
			debug.profilebegin(identifier)
			local clockBefore = os.clock()
			scheduledCallbackData.callback(...)
			local timeTakenForCallbackToFinishRunning = os.clock() - clockBefore
			debug.profileend()
			debug.resetmemorycategory()

			if
				timeTakenForCallbackToFinishRunning
				> scheduledCallbackData.maxExpectedCallbackRunTime
			then
				if
					performanceWarnLogs[identifier] == nil
					or (os.clock() - performanceWarnLogs[identifier])
						>= CALLBACK_PERFORMANCE_WARN_LOG_INTERVAL
				then
					debugLoggerUtil.log(
						error,
						string.format(
							"[PERFORMANCE WARN]: Callback [%s] took %.2fs to run. Expected callback run time: %.2fs!",
							identifier,
							timeTakenForCallbackToFinishRunning,
							scheduledCallbackData.maxExpectedCallbackRunTime
						)
					)
					performanceWarnLogs[identifier] = os.clock()
				end
			end
		end
	end)
end

return table.freeze(schedulerUtil)
