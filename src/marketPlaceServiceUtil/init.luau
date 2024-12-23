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

function marketPlaceServiceUtil.productInfoPromise(assetId: number, infoType: Enum.InfoType?)
	return Promise.new(function(resolve)
		resolve(MarketplaceService:GetProductInfo(assetId, infoType))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating
	if the user owns the specified gamepass or not. Incase the operation fails, the promise will reject
	with an additional value i.e the error message.

	```lua
	local wasSucessfull, userOwnsGamepass, errorMessage = marketPlaceServiceUtil.userOwnsGamepassPromise(123, 45678123):await()

	if wasSucessfull then
		print(userOwnsGamepass)
	else 
		print(userOwnsGamepass) --> false
		print(errorMessage)
	end
	```

	@return Promise<boolean>
]=]

function marketPlaceServiceUtil.userOwnsGamepassPromise(userId: number, gamepassId: number)
	return wrapBooleanResponseMethod(MarketplaceService.UserOwnsGamePassAsync, userId, gamepassId)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating
	if the player owns the specified asset or not. Incase the operation fails, the promise will reject
	with an additional value i.e the error message.

	```lua
	local wasSucessfull, playerOwnsAsset, errorMessage = marketPlaceServiceUtil.playerOwnsAssetPromise(123, 45678123):await()

	if wasSucessfull then
		print(playerOwnsAsset)
	else 
		print(playerOwnsAsset) --> false
		print(errorMessage)
	end
	```

	@return Promise<boolean>
]=]

function marketPlaceServiceUtil.playerOwnsAssetPromise(player: Player, assetId: number)
	return wrapBooleanResponseMethod(MarketplaceService.PlayerOwnsAsset, player, assetId)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating
	if the player owns the specified bundle or not. Incase the operation fails, the promise will reject
	with an additional value i.e the error message.

	```lua
	local wasSucessfull, playerOwnsBundle, errorMessage = marketPlaceServiceUtil.playerOwnsBundlePromise(123, 45678123):await()

	if wasSucessfull then
		print(playerOwnsBundle)
	else 
		print(playerOwnsBundle) --> false
		print(errorMessage)
	end
	```

	@return Promise<boolean>
]=]

function marketPlaceServiceUtil.playerOwnsBundlePromise(player: Player, bundleId: number)
	return wrapBooleanResponseMethod(MarketplaceService.PlayerOwnsBundle, player, bundleId)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the info
	of the given subscription id.

	```lua
	local wasSucessfull, subscriptionInfo = marketPlaceServiceUtil.subscriptionInfoProductPromise(subscriptionId):await()

	if wasSucessfull then
		print(subscriptionInfo)
	else
		print(tostring(subscriptionInfo)) -- Error
	end
	```

	@return Promise<SubscriptionInfo>
]=]

function marketPlaceServiceUtil.subscriptionInfoProductPromise(subscriptionId: string)
	return Promise.new(function(resolve)
		resolve(MarketplaceService:GetSubscriptionProductInfoAsync(subscriptionId))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the
	user subscription details.

	```lua
	local wasSucessfull, userSubscriptionDetails = marketPlaceServiceUtil.userSubscriptionDetailsPromise(player, subscriptionId):await()

	if wasSucessfull then
		print(userSubscriptionDetails)
	else
		print(tostring(userSubscriptionDetails)) -- Error
	end
	```

	@return Promise<UserSubscriptionDetails>
]=]

function marketPlaceServiceUtil.userSubscriptionDetailsPromise(
	player: Player,
	subscriptionId: string
)
	return Promise.new(function(resolve)
		resolve(MarketplaceService:GetUserSubscriptionDetailsAsync(player, subscriptionId))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the
	user subscription payment history.

	```lua
	local wasSucessfull, userSubscriptionPaymentHistory = marketPlaceServiceUtil.userSubscriptionPaymentHistoryPromise(player, subscriptionId):await()

	if wasSucessfull then
		print(userSubscriptionPaymentHistory)
	else
		print(tostring(userSubscriptionPaymentHistory)) -- Error
	end
	```

	@return Promise<UserSubscriptionPaymentHistory>
]=]

function marketPlaceServiceUtil.userSubscriptionPaymentHistoryPromise(
	player: Player,
	subscriptionId: string
)
	return Promise.new(function(resolve)
		resolve(MarketplaceService:GetUserSubscriptionPaymentHistoryAsync(player, subscriptionId))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the
	user subscription payment history.

	```lua
	local wasSucessfull, userSubscriptionStatus = marketPlaceServiceUtil.userSubscriptionStatusPromise(player, subscriptionId):await()

	if wasSucessfull then
		print(userSubscriptionStatus)
	else
		print(tostring(userSubscriptionStatus)) -- Error
	end
	```

	@return Promise<UserSubscriptionStatus>
]=]

function marketPlaceServiceUtil.userSubscriptionStatusPromise(
	player: Player,
	subscriptionId: string
)
	return Promise.new(function(resolve)
		resolve(MarketplaceService:GetUserSubscriptionStatusAsync(player, subscriptionId))
	end)
end

--[=[ 
    Retrieves the asset product info that belongs to a player of userid `playerUserId`.
]=]

function marketPlaceServiceUtil.activeAssetProductInfoWhichPlayerOwnsPromise(
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
