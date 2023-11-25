--[=[ 
	@class playersUtil

	A simple utility module for working with the Players service.
]=]

local Players = game:GetService("Players")

local Promise = require(script.Parent.Promise)

local nameFromUserIdCache = {}
local userIdFromNameCache = {}

local playersUtil = {
	defaultUserThumbnail = "rbxassetid://0",
}

--[=[ 
	Returns a promise which is a wrapper over [Players:GetUserThumbnailAsync](https://create.roblox.com/docs/reference/engine/classes/Players#GetUserThumbnailAsync).
]=]

function playersUtil.playerThumbnailPromise(...: any)
	local args = { ... }

	return Promise.new(function(resolve)
		while true do
			local content, isReady = Players:GetUserThumbnailAsync(unpack(args))

			if isReady then
				resolve(content)
				break
			end
		end
	end)
end

--[=[ 
	Returns a player from the given instance, if found. This is an efficient
	wrapper over [Players:GetPlayerFromCharacter](https://create.roblox.com/docs/reference/engine/classes/Players#GetPlayerFromCharacter).
 
	```lua
	laser.Touched:Connect(function(hit)
		local player = playerUtil.playerFromInstance(hit)

		if player then
			-- Damage the player
		end
	end)
	```
]=]

function playersUtil.playerFromInstance(instance: Instance): Player?
	while instance do
		local player = Players:GetPlayerFromCharacter(instance)

		if player then
			return player
		end

		instance = instance.Parent
	end

	return nil
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the user name
	associated to the user id. 

	:::tip Caching behavior
	This method will immediately cache in the name (retrieved from the given user id), so calls
	for the same user id will return in cached user name immediately.
	:::

	```lua
	playersUtil.nameFromUserId(2981707497):andThen(function(userName)
		print(userName) --> "bubshayz"
	end)
	```

	@return Promise<string>
]=]

function playersUtil.nameFromUserId(userId: number)
	local promise = Promise.new(function(resolve)
		local cachedName = nameFromUserIdCache[userId]

		if cachedName then
			resolve(cachedName)
			return
		end

		local playerFromUserId = Players:GetPlayerByUserId(userId)

		if playerFromUserId then
			resolve(playerFromUserId.UserId)
			return
		end

		resolve(Players:GetNameFromUserIdAsync(userId))
	end)

	promise
		:andThen(function(userName)
			nameFromUserIdCache[userId] = userName
		end)
		:catch(function() end)

	return promise
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the user id 
	associated to the username.

	:::tip Caching behavior
	This method will immediately cache in the user id (retrieved from the given username), so calls
	for the same username will return in cached user id immediately.
	:::

	```lua
	playersUtil.userIdFromName("bubshayz"):andThen(function(userId)
		print(userId) --> 2981707497
	end)
	```

	@return Promise<number>
]=]

function playersUtil.userIdFromName(userName: string)
	local promise = Promise.new(function(resolve)
		local cachedUserId = userIdFromNameCache[userName]

		if cachedUserId then
			resolve(cachedUserId)
			return
		end

		local playerFromUserName = Players:FindFirstChild(userName)

		if playerFromUserName then
			resolve(playerFromUserName.UserId)
			return
		end

		resolve(Players:GetUserIdFromNameAsync(userName))
	end)

	promise
		:andThen(function(userId)
			userIdFromNameCache[userName] = userId
		end)
		:catch(function() end)

	return promise
end

return table.freeze(playersUtil)
