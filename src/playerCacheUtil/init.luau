--[=[ 
	@class playerCacheUtil

	A very simple utility module for storing in data per player in an unique way.
 
	```lua
	local cache = playerCacheUtil.cacheForPlayer(player.UserId)  
	cache.test = 1

	print(cache.test) --> 1 
	```
]=]

local PLAYER_CACHE_CLEANUP_ATTRIBUTE = "__playerCacheCleanup"
local DEFAULT_PLAYER_CACHE = {}

local cachePerPlayer = {}

local playerCacheUtil = {}

--[=[
	Cleans up the given player's cache. Calls to [playerCacheUtil.cacheForPlayer] for the same player will now
	return **a global empty table**.

	```lua
	-- Script 1:
	local cache = playerCacheUtil.cleanupPlayerCache(player)
	cache.test = 150

	print(cache) --> {test = 150}
	print(playerCacheUtil.cacheForPlayer(player) == cache) --> true

	playerCacheUtil.cleanupPlayerCache(player)

	local cacheNow = playerCacheUtil.cacheForPlayer(player)
	print(cacheNow) --> {}
	print(cacheNow == cache) --> false
	```

	:::warning Potential memory leak
	This method assigns an attribute to the player object, `__playerCacheCleanup` for cleanup purposes. If this attribute
	is removed as a result of developer work, then this can potentially induce a memory leak! Ideally you should call this method 
	for the player once they leave the game.
	:::
]=]

function playerCacheUtil.cleanupPlayerCache(player: Player)
	player:SetAttribute(PLAYER_CACHE_CLEANUP_ATTRIBUTE, true)
	cachePerPlayer[player] = nil
end

--[=[
	Returns the cache for the given player. 
	
	:::tip Uniqueness
	Player caches are stored per each player, uniquely keyed by script names. This means a player's cache 
	will always be unique when accessed from different scripts.

	For e.g:

	```lua
	-- Script 1:
	local cache = playerCacheUtil.cacheForPlayer(player)  
	cache.test = 1

	print(cache) --> {test = 1}


	-- Script 2:
	local cache = playerCacheUtil.cacheForPlayer(player)  
	cache.opper = 5
	print(cache) --> {opper = 5} 
	```

	:::
]=]

function playerCacheUtil.cacheForPlayer(player: Player)
	if player:GetAttribute(PLAYER_CACHE_CLEANUP_ATTRIBUTE) then
		return DEFAULT_PLAYER_CACHE
	end

	cachePerPlayer[player] = cachePerPlayer[player] or {}

	local file = debug.info(2, "sl")
	cachePerPlayer[player][file] = cachePerPlayer[player][file] or {}
	return cachePerPlayer[player][file]
end

return table.freeze(playerCacheUtil)
