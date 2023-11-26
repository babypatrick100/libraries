local packages = script.Parent.Parent.Parent
local networkFolder = script.Parent.Parent

local sharedTypes = require(script.Parent.Parent.sharedTypes)
local serializerUtil = require(packages.serializerUtil)
local sharedEnums = require(networkFolder.sharedEnums)

local CALLBACK_ERROR_RESPONSE = {
	yielded = "yielded",
}

local networkUtil = {}

local function runCallbackNoYield(callback: sharedTypes.Callback, ...: any)
	local args = { ... }
	local executedSafely, callbackResponse = false, nil
	local callbackTraceback
	local thread = task.spawn(function()
		executedSafely, callbackResponse = pcall(function()
			callbackTraceback = debug.traceback()
			return callback(table.unpack(args))
		end)
	end)

	if coroutine.status(thread) ~= "dead" then
		coroutine.close(thread)
		return false, CALLBACK_ERROR_RESPONSE.yielded, callbackTraceback
	end

	return executedSafely, callbackResponse, callbackTraceback
end

function networkUtil.safeInvokeClient(remoteFunction: RemoteFunction, player: Player, value: any)
	task.spawn(function()
		-- https://developer.roblox.com/en-us/api-reference/class/RemoteFunction#:~:text=A%20RemoteFunction%20is%20used%20to,action%20and%20return%20the%20results.
		pcall(remoteFunction.InvokeClient, remoteFunction, player, value)
	end)
end

function networkUtil.accumulatedResponseFromMiddlewareCallbacks(
	callbacks: { sharedTypes.Callback },
	...: any
)
	local accumulatedResponses = {}

	for _, callback in callbacks do
		local didRunSafely, callbackResponse, callbackTraceback = runCallbackNoYield(callback, ...)
		if not didRunSafely then
			if callbackResponse == CALLBACK_ERROR_RESPONSE.yielded then
				error(
					string.format(
						"Middleware callback yielded. Middleware callbacks must never yield - thread has been closed. Traceback: \n\t%s",
						callbackTraceback
					)
				)
			else
				error(
					string.format(
						"Middleware callback errored while running [%s]. Traceback: \n\t%s",
						callbackResponse,
						callbackTraceback
					)
				)
			end
		end

		table.insert(accumulatedResponses, callbackResponse)
	end

	return table.freeze(accumulatedResponses)
end

function networkUtil.truncateAccumulatedResponses(
	callbacks: { sharedTypes.Callback },
	accumulatedResponses: { any }
)
	return if #accumulatedResponses > 1 then accumulatedResponses else accumulatedResponses[1],
		#callbacks > 0 and accumulatedResponses ~= nil
end

function networkUtil.serializeGivenArgs(
	remoteInstance: sharedTypes.RemoteInstance,
	...: any
): sharedTypes.SerializedArgs
	if
		not remoteInstance:GetAttribute(
			sharedEnums.Attribute.AutomaticArgumentSerializationAndDeserializationEnabled
		)
	then
		return { ... }
	end

	return serializerUtil.serializeTableDeep({ ... })
end

function networkUtil.deserializeAndUnpack(
	remoteInstance: sharedTypes.RemoteInstance,
	serializedArgs: sharedTypes.SerializedArgs
): ...any
	if
		not remoteInstance:GetAttribute(
			sharedEnums.Attribute.AutomaticArgumentSerializationAndDeserializationEnabled
		)
	then
		return unpack(serializedArgs)
	end

	return unpack(serializerUtil.deserializeTableDeep(serializedArgs))
end

return table.freeze(networkUtil)
