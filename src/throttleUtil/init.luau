local RunService = game:GetService("RunService")

--[=[ 
    @class throttleUtil

    A simple utility module which implements a somewhat similar functionality of [Matter.useThrottle](https://eryn.io/matter/api/Matter#useThrottle),
    however this small utility module allows you to use this functionality outside of Matter in a similar fashion!
 
    ```lua
    RunService.Heartbeat:Connect(function()
        if throttleUtil.useThrottle(2) then
            warn("Every 2 seconds, something happens..")
        end
    end)
    ```
]=]

local MAX_LAST_PICKUP_INTERVAL_BEFORE_CLEANUP = 1

local activeThrottles = {}

local throttleUtil = {}

--[=[
    Accepts a duration `seconds`, and returns true if it has been that long since the last time this function returned `true`. Always returns `false` 
    the first time it is called. 

    This method returns unique results keyed by script and line number, however you also can pass in some unique value as the
    `descriminator` if you want the method to return unique results keyed by that instead of script and line number.

    ```lua
    RunService.Heartbeat:Connect(function()
        if throttleUtil.throttle(1) then
            print("Every second, something happens (during a.. heartbeat!)")
        end
    end)
    ```

    Additionally, a second value i.e `totalDelta` is returned which is basically how much time has passed
    ever **since the last throttle.**

    ```lua
    RunService.Heartbeat:Connect(function()
        local throttle, totalDelta = throttleUtil.throttle(1)
        if throttle then
            print("Time elapsed since last throttle: ", totalDelta) 
        end
    end)

    --> Time elapsed since last throttle:  1.0079841441474855
    --> Time elapsed since last throttle:  1.0000211205333471
    --> Time elapsed since last throttle:  1.004997929558158
    ```

    :::note
    Throttle data keyed by script and line (or script and descriminator, if `descriminator` is passed) will be cleared out if it has been
    more than `1` seconds since the last `throttleUtil.throttle` call.
    :::
]=]

function throttleUtil.throttle(seconds: number, descriminator: any): (boolean, number)
	local file, line = debug.info(2, "sl")

	if descriminator ~= nil then
		activeThrottles[file] = activeThrottles[file] or {}
		activeThrottles[file][descriminator] = activeThrottles[file][descriminator]
			or { time = os.clock() }

		local clockDelta = os.clock() - activeThrottles[file][descriminator].time

		activeThrottles[file][descriminator].seconds = seconds
		activeThrottles[file][descriminator].lastPickup = os.clock()

		if clockDelta >= seconds then
			activeThrottles[file][descriminator].time = os.clock()

			if not next(activeThrottles[file]) then
				activeThrottles[file] = nil
			end

			return true, clockDelta
		else
			return false, clockDelta
		end
	else
		activeThrottles[file] = activeThrottles[file] or {}
		activeThrottles[file][line] = activeThrottles[file][line] or { time = os.clock() }
		local clockDelta = os.clock() - activeThrottles[file][line].time

		activeThrottles[file][line].seconds = seconds
		activeThrottles[file][line].lastPickup = os.clock()

		if clockDelta >= seconds then
			activeThrottles[file][line].time = os.clock()

			if not next(activeThrottles[file]) then
				activeThrottles[file] = nil
			end

			return true, clockDelta
		else
			return false, clockDelta
		end
	end
end

--[=[
    Sets the throttle keyed by `descriminator`, to `seconds`. This method is only usually useful in cases
    where you want to reset throttles.

    For e.g:

    ```lua
    local descriminator = "LastInputTypeThrottle"

    RunService.RenderStepped:Connect(function()
        if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton1 then
            if throttleUtil.throttle(2, descriminator) then
                print("GetLastInputType has been Enum.UserInputType.MouseButton1 for 2 seconds now")
            end
        else
            throttleUtil.setThrottle(descriminator, 0)
        end 
    end)
    ``` 
]=]

function throttleUtil.setThrottle(descriminator: number, seconds: number)
	local file = debug.info(2, "sl")

	if activeThrottles[file] and activeThrottles[file][descriminator] then
		activeThrottles[file][descriminator].seconds = seconds
	end
end

RunService.Heartbeat:Connect(function()
	for _, file in activeThrottles do
		for key, desc in file do
			if (os.clock() - desc.lastPickup) > MAX_LAST_PICKUP_INTERVAL_BEFORE_CLEANUP then
				file[key] = nil
			end
		end

		if not next(file) then
			activeThrottles[file] = nil
		end
	end
end)

return table.freeze(throttleUtil)
