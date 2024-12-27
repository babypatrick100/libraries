--# selene: allow(shadowing)

--[=[ 
	@class playersUtil

	A simple utility module for working with the [Players](https://create.roblox.com/docs/reference/engine/classes/Players) service.
]=]

local Players = game:GetService("Players")

local Promise = require(script.Parent.Promise)

local nameFromUserIdCache = {}
local userIdFromNameCache = {}

local playersUtil = {}

--[=[ 
	Returns a [promise](https://eryn.io/roblox-lua-promise/) wrapped over [Players:GetUserThumbnailAsync](https://create.roblox.com/docs/reference/engine/classes/Players#GetUserThumbnailAsync). 

	```lua
	local PLACE_HOLDER_IMAGE = "rbxassetid://0"

	playersUtil.playerThumbnailPromise(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420):andThen(function(content)
		print(content)
	end):catch(function(errorMessage)
		print(PLACE_HOLDER_IMAGE)
	end)
	```

	@return Promise<string>
]=]

function playersUtil.playerThumbnailPromise(
	userId: number,
	thumbnailType: Enum.ThumbnailType,
	thumbnailSize: Enum.ThumbnailSize
)
	return Promise.new(function(resolve)
		resolve(Players:GetUserThumbnailAsync(userId, thumbnailType, thumbnailSize))
	end)
end

--[=[ 
	Returns a player from the given instance, if found. This is an efficient
	wrapper over [Players:GetPlayerFromCharacter](https://create.roblox.com/docs/reference/engine/classes/Players#GetPlayerFromCharacter) as it allows you
	to get the player object even if the given `instance` is a deep descendant of some player's character.
 
	```lua
	laser.Touched:Connect(function(hit)
		local player = playerUtil.playerFromInstance(hit)

		if player ~= nil then
			-- Damage the player
		end
	end)
	```
]=]

function playersUtil.playerFromInstance(instance: Instance): Player?
	while instance ~= nil do
		local player = Players:GetPlayerFromCharacter(instance)
		if player ~= nil then
			return player
		end

		instance = instance.Parent :: Instance
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
	playersUtil.nameFromUserId(2981707497):andThen(function(username)
		print(username) --> "bubshurb"
	end)
	```

	@return Promise<string>
]=]

function playersUtil.nameFromUserId(userId: number)
	if nameFromUserIdCache[userId] ~= nil then
		return Promise.resolve(nameFromUserIdCache[userId])
	end

	local playerFromUserId = Players:GetPlayerByUserId(userId)
	if playerFromUserId then
		nameFromUserIdCache[userId] = playerFromUserId.Name
		return Promise.resolve(nameFromUserIdCache[userId])
	end

	local promise = Promise.new(function(resolve)
		resolve(Players:GetNameFromUserIdAsync(userId))
	end)

	promise
		:andThen(function(username)
			nameFromUserIdCache[userId] = username
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
	playersUtil.userIdFromName("bubshurb"):andThen(function(userId)
		print(userId) --> 2981707497
	end)
	```

	@return Promise<number>
]=]

function playersUtil.userIdFromName(username: string)
	if userIdFromNameCache[username] ~= nil then
		return Promise.resolve(userIdFromNameCache[username])
	end

	local playerFromUserName = Players:FindFirstChild(username)
	if playerFromUserName then
		userIdFromNameCache[username] = playerFromUserName.UserId
		return Promise.resolve(userIdFromNameCache[username])
	end

	local promise = Promise.new(function(resolve)
		resolve(Players:GetUserIdFromNameAsync(username))
	end)

	promise
		:andThen(function(userId)
			userIdFromNameCache[username] = userId
		end)
		:catch(function() end)

	return promise
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with an array of the player's
	friend's data.

	If the returned promise rejects, it will reject with an empty table (for `friends`) along with the
	error message.

	```lua
	playersUtil.friendsPromise(2981707497):andThen(function(friends)
		-- `friends` will be an array of friends pages!

		for _, friendData in friends do
			print(friendData.Username)
			print(friendData.DisplayName)
			print(friendData.Id)
		end
	end):catch(function(friends, errorMessage)
		-- `friends` will be an empty array
		print(friends, tostring(errorMessage))
	end)
	```

	@return Promise<number>
]=]

function playersUtil.friendsPromise(userid: number)
	return Promise.new(function(resolve, reject)
		local friendsListPromise = Promise.new(function(resolve)
			resolve(Players:GetFriendsAsync(userid))
		end)

		local friendsListSuccessfullyRetrieved, friendsList = friendsListPromise:await()
		if not friendsListSuccessfullyRetrieved then
			reject({}, friendsList)
			return
		end

		local friends = {}

		while true do
			for _, page in friendsList:GetCurrentPage() do
				table.insert(friends, page)
			end

			if friendsList.IsFinished then
				break
			else
				friendsList:AdvanceToNextPageAsync()
			end
		end

		resolve(friends)
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is wrapped around
	[Players:GetCharacterAppearanceInfoAsync](https://create.roblox.com/docs/reference/engine/classes/Players#GetCharacterAppearanceInfoAsync).

	@return Promise<{[string]: any}>
]=]

function playersUtil.characterAppearanceInfoPromise(userid: number)
	return Promise.new(function(resolve)
		resolve(Players:GetCharacterAppearanceInfoAsync(userid))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is wrapped around
	[Players:GetBanHistoryAsync](https://create.roblox.com/docs/reference/engine/classes/Players#GetBanHistoryAsync).

	```lua
	playersUtil.banHistoryPromise(2981707497):andThen(function(banHistory)
		-- `banHistory` will be an array of ban history pages!

		for _, banData in banHistory do
			print(banData.Ban)
			print(banData.Duration)
			print(banData.StartTime)
			-- and more, etc..
		end
	end):catch(function(banHistory, errorMessage)
		-- `banHistory` will be an empty array
		print(banHistory, tostring(errorMessage))
	end)
	```

	If the returned promise rejects, it will reject with an empty table (for `banHistory`) along with the
	error message.

	@return Promise<{...}>
]=]

function playersUtil.banHistoryPromise(userid: number)
	return Promise.new(function(resolve, reject)
		local banHistoryPromise = Promise.new(function(resolve)
			resolve(Players:GetBanHistoryAsync(userid))
		end)

		local banHistorySuccessfullyRetrieved, banHistory = banHistoryPromise:await()
		if not banHistorySuccessfullyRetrieved then
			reject({}, banHistory)
			return
		end

		local formattedBanHistory = {}

		while true do
			for _, page in banHistory:GetCurrentPage() do
				table.insert(formattedBanHistory, page)
			end

			if banHistory.IsFinished then
				break
			else
				banHistory:AdvanceToNextPageAsync()
			end
		end

		resolve(formattedBanHistory)
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is wrapped around
	[Players:BanAsync](https://create.roblox.com/docs/reference/engine/classes/Players#BanAsync).

	@return Promise<>
]=]

function playersUtil.banPromise(config: {
	UserIds: { number },
	ApplyToUniverse: boolean,
	Duration: number,
	DisplayReason: string,
	PrivateReason: string,
	ExcludeAltAccounts: boolean,
})
	return Promise.new(function(resolve)
		resolve(Players:BanAsync(config))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is wrapped around
	[Players:UnbanAsync](https://create.roblox.com/docs/reference/engine/classes/Players#UnbanAsync).

	@return Promise<>
]=]

function playersUtil.unbanPromise(config: {
	UserIds: { number },
	ApplyToUniverse: boolean,
})
	return Promise.new(function(resolve)
		resolve(Players:UnbanAsync(config))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is wrapped around
	[Players:GetHumanoidDescriptionFromOutfitId](https://create.roblox.com/docs/reference/engine/classes/Players#GetHumanoidDescriptionFromOutfitId).

	@return Promise<>
]=]

function playersUtil.humanoidDescriptionFromOutfitIdPromise(outfitId: number)
	return Promise.new(function(resolve)
		resolve(Players:GetHumanoidDescriptionFromOutfitId(outfitId))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is wrapped around
	[Players:GetCharacterAppearanceInfoAsync](https://create.roblox.com/docs/reference/engine/classes/Players#GetCharacterAppearanceInfoAsync).

	@return Promise<>
]=]

function playersUtil.characterAppearanceInfoPromise(userId: number)
	return Promise.new(function(resolve)
		resolve(Players:GetCharacterAppearanceInfoAsync(userId))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is wrapped around
	[Players:GetHumanoidDescriptionFromOutfitId](https://create.roblox.com/docs/reference/engine/classes/Players#GetHumanoidDescriptionFromOutfitId).

	@return Promise<>
]=]

function playersUtil.humanoidDescriptionFromOutfitIdPromise(userId: number)
	return Promise.new(function(resolve)
		resolve(Players:GetHumanoidDescriptionFromOutfitId(userId))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is wrapped around
	[Players:GetHumanoidDescriptionFromUserId](https://create.roblox.com/docs/reference/engine/classes/Players#GetHumanoidDescriptionFromUserId).

	@return Promise<>
]=]

function playersUtil.humanoidDescriptionFromUserIdPromise(userId: number)
	return Promise.new(function(resolve)
		resolve(Players:GetHumanoidDescriptionFromUserId(userId))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is wrapped around
	[Players:CreateHumanoidModelFromDescription](https://create.roblox.com/docs/reference/engine/classes/Players#CreateHumanoidModelFromDescription).

	@return Promise<Model>
]=]

function playersUtil.createHumanoidModelFromDescriptionPromise(
	description: HumanoidDescription,
	rigType: Enum.HumanoidRigType,
	assetTypeVerification: Enum.AssetTypeVerification
)
	return Promise.new(function(resolve)
		resolve(
			Players:CreateHumanoidModelFromDescription(description, rigType, assetTypeVerification)
		)
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is wrapped around
	[Players:CreateHumanoidModelFromUserId](https://create.roblox.com/docs/reference/engine/classes/Players#CreateHumanoidModelFromUserId).

	@return Promise<Model>
]=]

function playersUtil.createHumanoidModelFromUserIdPromise(userId: number)
	return Promise.new(function(resolve)
		resolve(Players:CreateHumanoidModelFromUserId(userId))
	end)
end

return table.freeze(playersUtil)
