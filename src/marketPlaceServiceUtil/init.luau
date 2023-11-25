--[=[
	@class marketPlaceServiceUtil

	An utility module for working with [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService).
]=]

local MarketplaceService = game:GetService("MarketplaceService")
local GroupService = game:GetService("GroupService")

local Promise = require(script.Parent.Promise)

local marketPlaceServiceUtil = {}

local function wrapBooleanResponseMethod(method: (...any) -> boolean, ...)
	local args = { ... }

	return Promise.new(function(resolve, reject)
		local wasSuccessfull, response = pcall(function()
			return method(MarketplaceService, table.unpack(args))
		end)

		if wasSuccessfull then
			resolve(response)
		else
			reject(false, response)
		end
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved wih the product info of the given
	place id.

	@return Promise<ProductInfo>
]=]

function marketPlaceServiceUtil.productInfo(assetId: number, infoType: Enum.InfoType?)
	return Promise.new(function(resolve)
		resolve(MarketplaceService:GetProductInfo(assetId, infoType))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating
	if the user owns the specified gamepass or not. Incase the operation fails, the promise will reject
	with an additional value i.e the error message.

	```lua
	local wasSucessfull, userOwnsGamepass, errorMessage = marketPlaceServiceUtil.userOwnsGamepassAsync(123, 45678123):await()

	if wasSucessfull then
		print(userOwnsGamepass)
	else 
		print(userOwnsGamepass) --> false
		print(errorMessage)
	end
	```

	@return Promise<boolean>
]=]

function marketPlaceServiceUtil.userOwnsGamepassAsync(userId: number, gamepassId: number)
	return wrapBooleanResponseMethod(MarketplaceService.UserOwnsGamePassAsync, userId, gamepassId)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating
	if the player owns the specified asset or not. Incase the operation fails, the promise will reject
	with an additional value i.e the error message.

	```lua
	local wasSucessfull, playerOwnsAsset, errorMessage = marketPlaceServiceUtil.playerOwnsAsset(123, 45678123):await()

	if wasSucessfull then
		print(playerOwnsAsset)
	else 
		print(playerOwnsAsset) --> false
		print(errorMessage)
	end
	```

	@return Promise<boolean>
]=]

function marketPlaceServiceUtil.playerOwnsAsset(player: Player, assetId: number)
	return wrapBooleanResponseMethod(MarketplaceService.PlayerOwnsAsset, player, assetId)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating
	if the player owns the specified bundle or not. Incase the operation fails, the promise will reject
	with an additional value i.e the error message.

	```lua
	local wasSucessfull, playerOwnsBundle, errorMessage = marketPlaceServiceUtil.playerOwnsBundle(123, 45678123):await()

	if wasSucessfull then
		print(playerOwnsBundle)
	else 
		print(playerOwnsBundle) --> false
		print(errorMessage)
	end
	```

	@return Promise<boolean>
]=]

function marketPlaceServiceUtil.playerOwnsBundle(player: Player, bundleId: number)
	return wrapBooleanResponseMethod(MarketplaceService.PlayerOwnsBundle, player, bundleId)
end

--[=[ 
    Retrieves the asset product info that belongs to a player of userid `playerUserId`.
]=]

function marketPlaceServiceUtil.activeAssetProductInfoWhichPlayerOwns(
	playerUserId: number,
	assetId: number
)
	return Promise.new(function(resolve, reject)
		for _, infoType in Enum.InfoType:GetEnumItems() do
			if infoType == Enum.InfoType.Product then
				continue
			end

			local productInfo = MarketplaceService:GetProductInfo(assetId, infoType)

			if
				productInfo.Creator.CreatorType == Enum.CreatorType.Group.Name
				and productInfo.IsForSale
			then
				if
					GroupService:GetGroupInfoAsync(productInfo.Creator.CreatorTargetId).Owner.Id
					== playerUserId
				then
					resolve(productInfo, infoType)
					return
				end
			elseif
				playerUserId == productInfo.Creator.CreatorTargetId and productInfo.IsForSale
			then
				resolve(productInfo, infoType)
				return
			end
		end

		reject(nil)
	end)
end

return table.freeze(marketPlaceServiceUtil)
