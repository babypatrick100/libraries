--[=[
	@class promiseCleanupUtil

	An utility module for working with [Promise](https://eryn.io/roblox-lua-promise/) cleanups.
]=]

local promiseCleanupUtil = {}

--[=[
    @param promise Promise 
    @param cleanupTable {[string]: Promise}

    Adds the given `promise` to `cleanupTable`, indexed by `key`. Once the promise has finished running, it'll be safely
    removed from `cleanupTable`.
]=]

function promiseCleanupUtil.addPromiseAndCleanupOnFinishedRunning(
	promise,
	key: string,
	cleanupTable: { [string]: any }
)
	cleanupTable[key] = promise
	promise:finally(function()
		if promise == cleanupTable[key] then
			cleanupTable[key] = nil
		end
	end)
end

--[=[
	Finds the given promise keyed by `key` in `cleanupTable`, if found, it will be cancelled and
	the promise will be removed from the `cleanupTable`..
]=]

function promiseCleanupUtil.findAndCancelPromise(key: string, cleanupTable: { [string]: any })
	local targetPromise = cleanupTable[key]

	if targetPromise ~= nil then
		cleanupTable[key] = nil
		targetPromise:cancel()
	end
end

return table.freeze(promiseCleanupUtil)
