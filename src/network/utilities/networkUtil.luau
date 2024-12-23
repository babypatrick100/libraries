local packages = script.Parent.Parent.Parent
local networkFolder = script.Parent.Parent

local serializerUtil = require(packages.serializerUtil)
local sharedEnums = require(networkFolder.sharedEnums)

local CALLBACK_ERROR_RESPONSE = {
	YIELDED = "YIELDED",
}

local networkUtil = {}

local function runCallbackNoYield(callback, ...)
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
		return false, CALLBACK_ERROR_RESPONSE.YIELDED, callbackTraceback
	end

	return executedSafely, callbackResponse, callbackTraceback
end

function networkUtil.safeInvokeClient(remoteFunction: RemoteFunction, player: Player, value: any)
	task.spawn(function()
		-- https://developer.roblox.com/en-us/api-reference/class/RemoteFunction#:~:text=A%20RemoteFunction%20is%20used%20to,action%20and%20return%20the%20results.
		pcall(remoteFunction.InvokeClient, remoteFunction, player, value)
	end)
end

function networkUtil.accumulatedResponseFromMiddlewareCallbacks(callbacks, ...)
	local accumulatedResponses = {}

	for _, callback in callbacks do
		local didRunSafely, callbackResponse, callbackTraceback = runCallbackNoYield(callback, ...)
		if not didRunSafely then
			if callbackResponse == CALLBACK_ERROR_RESPONSE.YIELDED then
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

function networkUtil.truncateAccumulatedResponses(callbacks, accumulatedResponses)
	return if #accumulatedResponses > 1 then accumulatedResponses else accumulatedResponses[1],
		#callbacks > 0 and accumulatedResponses ~= nil
end

function networkUtil.middlewareAccumulatedResponsesAreDefault(callbacks, accumulatedResponses)
	return if #accumulatedResponses > 1 then accumulatedResponses else accumulatedResponses[1],
		#callbacks > 0 and accumulatedResponses ~= nil
end

function networkUtil.serializeGivenArgs(remoteInstance, ...)
	if
		not remoteInstance:GetAttribute(
			sharedEnums.Attribute.AutomaticRemoteArgumentSerializationAndDeserializationEnabled
		)
	then
		return { ... }
	end

	return serializerUtil.serializeTableDeep({ ... })
end

function networkUtil.deserializeAndUnpackArgs(remoteInstance, serializedArgs): ...any
	if
		not remoteInstance:GetAttribute(
			sharedEnums.Attribute.AutomaticRemoteArgumentSerializationAndDeserializationEnabled
		)
	then
		return table.unpack(serializedArgs)
	end

	return table.unpack(serializerUtil.deserializeTableDeep(serializedArgs))
end

return table.freeze(networkUtil)
