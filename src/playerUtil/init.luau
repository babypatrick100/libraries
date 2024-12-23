--[=[ 
	@class playerUtil

	An utility module for working with players.
 
	```lua
	playerUtil.playerGroupRolePromise(2981707497, 1):andThen(function(groupRole)
		print(groupRole)
	end):catch(function(defaultGroupRole, errorMessage)
		warn(tostring(errorMessage))
	end)
	```
]=]

--[=[ 
	@interface PlayerGroupRank
	@within playerUtil
	.Default 0
]=]

--[=[ 
	@interface PlayerGroupRole
	@within playerUtil
	.Default "Guest"
]=]

--[=[
	@interface PlayerSafeChatStatus  
	@within playerUtil	
	.On "On"
	.Off "Off"
	.Unknown "Unknown"
]=]

local GroupService = game:GetService("GroupService")

local Promise = require(script.Parent.Promise)
local Sift = require(script.Parent.Sift)
local playerPolicyInfoUtil = require(script.Parent.playerPolicyInfoUtil)

local playerUtil = {
	PlayerSafeChatStatus = {
		On = "On",
		Off = "Off",
		Unknown = "Unknown",
	},

	PlayerGroupRank = {
		Default = 0,
	},

	PlayerGroupRole = {
		Default = "Guest",
	},
}

--[=[
	@return Promise<number>

	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the group rank of the player in the given group. If the group rank couldn't be retrieved,
	then the promise will reject with [DefaultGroupRank] and with the error message.

	```lua
	playerUtil.playerGroupRankPromise(2981707497, 1):andThen(function(groupRank)
		print(groupRank)
	end):catch(function(defaultGroupRank, errorMessage)
		print(groupRank, tostring(errorMessage))
	end)
	```
]=]

function playerUtil.playerGroupRankPromise(playerUserId: number, groupId: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response =
			pcall(GroupService.GetGroupsAsync, GroupService, playerUserId, groupId)

		if wasSuccessful then
			local result = response[Sift.Array.findWhere(response, function(groupInfo)
				return groupInfo.Id == groupId
			end)]

			resolve(if result then result.Rank else playerUtil.PlayerGroupRank.Default)
		else
			reject(playerUtil.PlayerGroupRank.Default, response)
		end
	end)
end

--[=[ 
	@return Promise<boolean>

	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating whether or not
	the given player is friends with the given `userId`. This is a wrapper over [Player:IsFriendsWith](https://create.roblox.com/docs/reference/engine/classes/Player#IsFriendsWith).

	```lua
	playerUtil.playerIsFriendsWithPromise(2981707497, 27842645):andThen(function(isFriends)
		print(isFriends)
	end):catch(function(isFriends, errorMessage)
		print(isFriends, tostring(errorMessage))
	end)
	```
]=]

function playerUtil.playerIsFriendsWithPromise(player: Player, userId: number)
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
	@return Promise<{[string]: any}>

	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with an array of fields of info
	regarding the given player's friends. This is a wrapper over 
	[Player:GetFriendsOnline](https://create.roblox.com/docs/reference/engine/classes/Player#GetFriendsOnline).

	:::tip Promise rejection with default data
	The promise will reject with `{}` for `friends` and an error message, instead of just the error message - allowing your code to adapt
	easily incase of failure.
	:::

	```lua
	playerUtil.playerFriendsOnlinePromise(player, 15):andThen(function(friends)
		for _, friend in friends do
			print(friend.UserName)
		end
	end):catch(function(friends, errorMessage)
		-- `friends` will be an empty array
		print(friends, tostring(errorMessage))
	end)
	```
]=]

function playerUtil.playerFriendsOnlinePromise(player: Player, maxFriends: number)
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
	@return Promise<string>

	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the group role of the player in the given group. If the group role couldn't be retrieved,
	then the promise will reject with [DefaultGroupRole] and with the error message.

	:::tip Promise rejection with default data
	The promise will reject with [PlayerGroupRole] and an error message, instead of just the error message - allowing your code to adapt
	easily incase of failure.
	:::

	```lua
	playerUtil.playerGroupRolePromise(2981707497, 1):andThen(function(groupRole)
		print(groupRole)
	end):catch(function(defaultGroupRole, errorMessage)
		warn(tostring(errorMessage))
	end)
	```
]=]

function playerUtil.playerGroupRolePromise(playerUserId: number, groupId: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response =
			pcall(GroupService.GetGroupsAsync, GroupService, playerUserId, groupId)

		if wasSuccessful then
			local result = response[Sift.Array.findWhere(response, function(groupInfo)
				return groupInfo.Id == groupId
			end)]

			resolve(if result ~= nil then result.Role else playerUtil.PlayerGroupRole.Default)
		else
			reject(playerUtil.PlayerGroupRole.Default, response)
		end
	end)
end

--[=[ 
	@return Promise<boolean>

	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating if the given player is in the given group or not. 

	:::tip Promise rejection with default data
	The promise will reject with `false` for `playerIsInGroupPromise` and an error message, instead of just the error message - allowing your code to adapt
	easily incase of failure.
	:::

	```lua
	playerUtil.playerIsInGroupPromise(2981707497, 1):andThen(function(playerIsInGroupPromise)
		print(playerIsInGroupPromise)
	end):catch(function(playerIsInGroupPromise, errorMessage)
		-- playerIsInGroupPromise will always be false here
		print(playerIsInGroupPromise, tostring(errorMessage))
	end)
	```
]=]

function playerUtil.playerIsInGroupPromise(playerUserId: number, groupId: number)
	return Promise.new(function(resolve, reject)
		local playerGroupRankSuccessfullyRetrieved, playerGroupRankPromise, errorMessage =
			playerUtil.playerGroupRankPromise(playerUserId, groupId):await()

		if playerGroupRankSuccessfullyRetrieved then
			resolve(playerGroupRankPromise > playerUtil.PlayerGroupRank.Default)
		else
			reject(false, errorMessage)
		end
	end)
end

--[=[
	@return Promise<PlayerSafeChatStatus>
	
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the safe chat status of the given player.

	
	:::tip Promise rejection with default data
	The promise will reject with `PlayerSafeChatStatus.Unknown` as the player safe chat status and an error message, instead of
	just the error message - allowing your code to adapt easily incase of failure.
	:::

	```lua
	playerUtil.safeChatStatusPromise(player):andThen(function(safeChatStatusPromise)
		print(safeChatStatusPromise == playerUtil.PlayerSafeChatStatus.On)
	end)
	```
]=]

function playerUtil.safeChatStatusPromise(player: Player)
	return Promise.new(function(resolve, reject)
		local playerPolicyInfoRetrievalWasSuccessful, playerPolicyInfo =
			playerPolicyInfoUtil.playerPolicyInfo(player):await()

		if not playerPolicyInfoRetrievalWasSuccessful then
			reject(playerUtil.PlayerSafeChatStatus.Unknown, playerPolicyInfo)
			return
		end

		if
			not table.find(playerPolicyInfo.AllowedExternalLinkReferences, "Discord")
			and playerPolicyInfo.IsSubjectToChinaPolicies
		then
			resolve(playerUtil.PlayerSafeChatStatus.Unknown)
		elseif not table.find(playerPolicyInfo.AllowedExternalLinkReferences, "Discord") then
			resolve(playerUtil.PlayerSafeChatStatus.On)
		else
			resolve(playerUtil.PlayerSafeChatStatus.Off)
		end
	end)
end

return table.freeze(playerUtil)
