local packages = script.Parent.Parent.Parent
local networkFolder = script.Parent.Parent

local serializerUtil = require(packages.serializerUtil)
local sharedEnums = require(networkFolder.sharedEnums)

local networkUtil = {}

type Callback = (...any) -> ...any
type AnyTable = { [any]: any }

local function runCallbackNoYield(callback: Callback, ...: any)
	local callbackResponse
	local args = { ... }

	local thread = task.spawn(function()
		callbackResponse = callback(table.unpack(args))
	end)

	local executedSafely = coroutine.status(thread) == "dead"

	if not executedSafely then
		coroutine.close(thread)
	end

	return executedSafely, callbackResponse
end

function networkUtil.safeInvokeClient(remoteFunction: RemoteFunction, player: Player, value: any)
	task.spawn(function()
		-- https://developer.roblox.com/en-us/api-reference/class/RemoteFunction#:~:text=A%20RemoteFunction%20is%20used%20to,action%20and%20return%20the%20results.
		pcall(remoteFunction.InvokeClient, remoteFunction, player, value)
	end)
end

function networkUtil.accumulatedResponseFromMiddlewareCallbacks(callbacks: { Callback }, ...: any)
	local accumulatedResponses = {}

	for _, callback in callbacks do
		local didRunSafely, callbackResponse = runCallbackNoYield(callback, ...)
		assert(didRunSafely, "middleware callback yielded! Middleware callbacks must never yield.")

		table.insert(accumulatedResponses, callbackResponse)
	end

	return table.freeze(accumulatedResponses)
end

function networkUtil.truncateAccumulatedResponses(
	callbacks: { Callback },
	accumulatedResponses: { any }
)
	return if #accumulatedResponses > 1 then accumulatedResponses else accumulatedResponses[1],
		#callbacks > 0 and accumulatedResponses ~= nil
end

function networkUtil.serializeGivenArgs(
	remoteInstance: RemoteEvent | RemoteFunction,
	...: any
): AnyTable
	if
		not remoteInstance:GetAttribute(
			sharedEnums.Attribute.AutomaticSerializationAndDeserializationEnabled
		)
	then
		return { ... }
	end

	return serializerUtil.serializeTableDeep({ ... })
end

function networkUtil.deserializeAndUnpack(
	remoteInstance: RemoteFunction | RemoteEvent,
	serializedArgs: AnyTable
): ...any
	if
		not remoteInstance:GetAttribute(
			sharedEnums.Attribute.AutomaticSerializationAndDeserializationEnabled
		)
	then
		return unpack(serializedArgs)
	end

	return unpack(serializerUtil.deserializeTableDeep(serializedArgs))
end

return table.freeze(networkUtil)
