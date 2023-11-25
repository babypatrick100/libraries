--[=[ 
	@class playerUtil

	An utility module for working with players.
 
	```lua
	playerUtil.playerGroupRole(2981707497, 1):andThen(function(groupRole)
		print(groupRole)
	end):catch(function(defaultGroupRole, errorMessage)
		warn(tostring(errorMessage))
	end)
	```
]=]

--[=[ 
	@prop defaultPlayerGroupRank 0
	@within playerUtil
]=]

--[=[ 
	@prop defaultPlayerGroupRole "Guest"
	@within playerUtil
]=]

--[=[
	@interface playerSafeChatStatus  
	@within playerUtil	
	.on string
	.off string
	.unknown string
]=]

local GroupService = game:GetService("GroupService")

local Promise = require(script.Parent.Promise)
local Sift = require(script.Parent.Sift)
local playerPolicyInfoUtil = require(script.Parent.playerPolicyInfoUtil)

local characterLoadingQueue = {}

local playerUtil = {
	defaultPlayerGroupRank = 0,
	defaultPlayerGroupRole = "Guest",
	playerSafeChatStatus = table.freeze({
		on = "on",
		off = "off",
		unknown = "unknown",
	}),
}

--[=[ 
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the group rank of the player in the given group. If the group rank couldn't be retrieved,
	then the promise will reject with [DefaultGroupRank] and with the error message.

	```lua
	playerUtil.playerGroupRank(2981707497, 1):andThen(function(groupRank)
		print(groupRank)
	end):catch(function(defaultGroupRank, errorMessage)
		print(groupRank, tostring(errorMessage))
	end)
	```

	@return Promise<groupId: number>
]=]

function playerUtil.playerGroupRank(playerUserId: number, groupId: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response =
			pcall(GroupService.GetGroupsAsync, GroupService, playerUserId, groupId)

		if wasSuccessful then
			local result = response[Sift.Array.findWhere(response, function(groupInfo)
				return groupInfo.Id == groupId
			end)]

			resolve(if result then result.Rank else 0)
		else
			reject(playerUtil.defaultPlayerGroupRank, response)
		end
	end)
end

--[=[ 
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating whether or not
	the given player is friends with the given `userId`. This is a wrapper over 
	[Player:IsFriendsWith](https://create.roblox.com/docs/reference/engine/classes/Player#IsFriendsWith).

	```lua
	playerUtil.playerIsFriendsWith(2981707497, 27842645):andThen(function(isFriends)
		print(isFriends)
	end):catch(function(isFriends, errorMessage)
		print(isFriends, tostring(errorMessage))
	end)
	```

	@return Promise<boolean>
]=]

function playerUtil.playerIsFriendsWith(player: Player, userId: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response = pcall(player.IsFriendsWith, player, userId)

		if wasSuccessful then
			resolve(response)
		else
			reject(false, response)
		end
	end)
end

--[=[ 
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with an array of fields of info
	regarding the given player's friends. This is a wrapper over 
	[Player:GetFriendsOnline](https://create.roblox.com/docs/reference/engine/classes/Player#GetFriendsOnline).

	```lua
	playerUtil.playerFriendsOnline(player, 15):andThen(function(friends)
		for _, friend in friends do
			print(friend.UserName)
		end
	end):catch(function(friends, errorMessage)
		-- friends will be an empty array
		print(friends, tostring(errorMessage))
	end)
	```

	@return Promise<{...}>
]=]

function playerUtil.playerFriendsOnline(player: Player, maxFriends: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response = pcall(player.GetFriendsOnline, player, maxFriends)

		if wasSuccessful then
			resolve(response)
		else
			reject({}, response)
		end
	end)
end

--[=[ 
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the group role of the player in the given group. If the group role couldn't be retrieved,
	then the promise will reject with [DefaultGroupRole] and with the error message.

	```lua
	playerUtil.playerGroupRole(2981707497, 1):andThen(function(groupRole)
		print(groupRole)
	end):catch(function(defaultGroupRole, errorMessage)
		warn(tostring(errorMessage))
	end)
	```

	@return Promise<groupRole: string>
]=]

function playerUtil.playerGroupRole(playerUserId: number, groupId: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response =
			pcall(GroupService.GetGroupsAsync, GroupService, playerUserId, groupId)

		if wasSuccessful then
			local result = response[Sift.Array.findWhere(response, function(groupInfo)
				return groupInfo.Id == groupId
			end)]

			resolve(if result then result.Role else playerUtil.defaultPlayerGroupRole)
		else
			reject(playerUtil.defaultPlayerGroupRole, response)
		end
	end)
end

--[=[ 
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating if the given player is in the given group or not. 
	If the player's group status couldn't be retrieved, then the promise will reject with a false value, 
	along with the error message.

	```lua
	playerUtil.playerIsInGroup(2981707497, 1):andThen(function(playerIsInGroup)
		print(playerIsInGroup)
	end):catch(function(playerIsInGroup, errorMessage)
		-- playerIsInGroup will always be false here
		print(playerIsInGroup, tostring(errorMessage))
	end)
	```

	@return Promise<boolean>
]=]

function playerUtil.playerIsInGroup(playerUserId: number, groupId: number)
	return Promise.new(function(resolve, reject)
		local playerGroupRankSuccessfullyRetrieved, playerGroupRank, errorMessage =
			playerUtil.playerGroupRank(playerUserId, groupId):await()

		if playerGroupRankSuccessfullyRetrieved then
			resolve(playerGroupRank > playerUtil.defaultPlayerGroupRank)
		else
			reject(false, errorMessage)
		end
	end)
end

--[=[ 
	A simple wrapper over [Player:LoadCharacter](https://create.roblox.com/docs/reference/engine/classes/Player#LoadCharacter), except that it handles the necessary edge cases
	to ensure smooth player character loading.

	:::note Player character loading queue
	Player character loadings are queued; so if you call this method for a player while it was
	previously called for the same player (and that operation has not yet completed), then the 
	new call will not load the player's character until the previous player character load call
	has finished.

	```lua
	playerUtil.safeLoadCharacter(player) 
	playerUtil.safeLoadCharacter(player) -- This operation won't load the character until the above call finishes loading the character.
	```
	:::

	```lua
	playerUtil.safeLoadCharacter(player):andThen(function(newPlayerCharacter)
		print(newPlayerCharacter)
	end):catch(function(errorMessage)
		print(tostring(errorMessage))
	end)
	```

	@return Promise<Model>
]=]

function playerUtil.safeLoadCharacter(player: Player)
	characterLoadingQueue[player.UserId] = characterLoadingQueue[player.UserId] or {}

	local safeLoadCharacterPromise
	safeLoadCharacterPromise = Promise.defer(function(resolve, reject)
		local currentIndex =
			table.find(characterLoadingQueue[player.UserId], safeLoadCharacterPromise)
		local lastPlayerSafeLoadCharacterPromise =
			characterLoadingQueue[player.UserId][currentIndex - 1]

		if lastPlayerSafeLoadCharacterPromise then
			lastPlayerSafeLoadCharacterPromise:await()
		end

		local characterLoadWasSuccessful, response = pcall(player.LoadCharacter, player)

		if characterLoadWasSuccessful then
			resolve(player.Character)
		else
			reject(response)
		end
	end)

	table.insert(characterLoadingQueue[player.UserId], safeLoadCharacterPromise)

	return safeLoadCharacterPromise:finally(function()
		table.remove(
			characterLoadingQueue[player.UserId],
			table.find(characterLoadingQueue[player.UserId], safeLoadCharacterPromise)
		)

		if not next(characterLoadingQueue[player.UserId]) then
			characterLoadingQueue[player.UserId] = nil
		end
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the safe chat status of the given player.

	```lua
	playerUtil.safeChatStatus(player):andThen(function(safeChatStatus)
		print(safeChatStatus == playerUtil.playerSafeChatStatus.on)
	end)
	```

	@return Promise<"on" | "off" | "unknown">
]=]

function playerUtil.safeChatStatus(player: Player)
	return Promise.new(function(resolve)
		local _, playerPolicyInfo = playerPolicyInfoUtil.playerPolicyInfo(player):await()

		if
			not table.find(playerPolicyInfo.AllowedExternalLinkReferences, "Discord")
			and playerPolicyInfo.IsSubjectToChinaPolicies
		then
			resolve(playerUtil.playerSafeChatStatus.unknown)
		elseif not table.find(playerPolicyInfo.AllowedExternalLinkReferences, "Discord") then
			resolve(playerUtil.playerSafeChatStatus.on)
		else
			resolve(playerUtil.playerSafeChatStatus.off)
		end
	end)
end

return table.freeze(playerUtil)
