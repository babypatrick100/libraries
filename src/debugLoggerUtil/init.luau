--[=[
	@class debugLoggerUtil

	A simple utility module for debug logging.

	```lua
	debugLoggerUtil.log(warn, "test") 
	```
]=]

local loggingEnabledGlobal = true
local loggingEnabledPerFiles = {}

local debugLoggerUtil = {}

--[=[
	Toggles if logging is enabled or not *globally*.

	```lua
	debugLoggerUtil.toggleLoggingEnabledGlobal(false)
	debugLoggerUtil.log(warn, "test") -- Doesn't do anything
	```
]=]

function debugLoggerUtil.toggleLoggingEnabledGlobal(toggle: boolean)
	loggingEnabledGlobal = toggle
end

--[=[
	Toggles if logging is enabled or not for the *script*.

	```lua
	debugLoggerUtil.toggleLoggingEnabled(false)
	debugLoggerUtil.log(warn, "test") -- Doesn't do anything

	-- In another script..
	debugLoggerUtil.log(warn, "123") -- Works
	```
]=]

function debugLoggerUtil.toggleLoggingEnabled(toggle: boolean)
	local file = string.match(debug.info(2, "sl"), "%w+$")
	loggingEnabledPerFiles[file] = toggle
end

--[=[
	Calls `logFunction` passing in `...` to it -- if logging is not enabled, nothing happens. 

	:::note
	If logging is toggled off for the script (in which this method is called in) or logging is toggled
	off *globally*, then this method will not anything.
	:::
]=]

function debugLoggerUtil.log(logFunction: (...any) -> (), ...: any)
	if not loggingEnabledGlobal then
		return
	end

	local file = string.match(debug.info(2, "sl"), "%w+$")
	local line = debug.info(2, "l")

	if loggingEnabledPerFiles[file] == false then
		return
	end

	logFunction(string.format("[%s]:%d: %s", file, line, ...))
end

return table.freeze(debugLoggerUtil)
