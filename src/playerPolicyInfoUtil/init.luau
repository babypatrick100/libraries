--[=[ 
    @class playerPolicyInfoUtil

    A very simple utility module for retrieving a player's policy info safely.
 
    ```lua
    playerPolicyInfoUtil.playerPolicyInfo(localPlayer):andThen(function(playerPolicyInfo)
        print(playerPolicyInfo.ArePaidRandomItemsRestricted)
        print(playerPolicyInfo.AllowedExternalLinkReferences)
        print(playerPolicyInfo.IsPaidItemTradingAllowed)
        print(playerPolicyInfo.IsSubjectToChinaPolicies)
    end):catch(function(defaultPlayerPolicyInfo, errorMessage)
        warn(string.format("Error retrieving player policy info because %s", errorMessage))
    end)    
    ```
]=]

--[=[ 
    @interface PlayerPolicyInfo  
    @within playerPolicyInfoUtil

    .ArePaidRandomItemsRestricted boolean
    .AllowedExternalLinkReferences {string}
    .IsPaidItemTradingAllowed boolean
    .IsSubjectToChinaPolicies boolean
]=]

--[=[ 
    @interface DEFAULT_PLAYER_POLICY_INFO  
    @within playerPolicyInfoUtil
    @tag Constant

    .ArePaidRandomItemsRestricted false
    .AllowedExternalLinkReferences {}
    .IsPaidItemTradingAllowed false
    .IsSubjectToChinaPolicies false

    :::warning
    Constant, not accessible within `playerPolicyInfoUtil`.
    :::
]=]

local PolicyService = game:GetService("PolicyService")

local Promise = require(script.Parent.Promise)

local DEFAULT_PLAYER_POLICY_INFO = {
	ArePaidRandomItemsRestricted = false,
	AllowedExternalLinkReferences = {},
	IsPaidItemTradingAllowed = false,
	IsSubjectToChinaPolicies = false,
}

local playerPolicyInfoUtil = {}

--[=[
    Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a *read only* policy info
    dictionary for the given player.
    
    If the promise rejects, then the promise will reject with a *read only* copy of [DEFAULT_PLAYER_POLICY_INFO] and an error message.

    ```lua
    playerPolicyInfoUtil.playerPolicyInfoPromise(somePlayer):andThen(function(policyInfo)
        print(policyInfo.ArePaidRandomItemsRestricted)
    end):catch(function(defaultPlayerPolicyInfo, errorMessage)
        warn(defaultPlayerPolicyInfo, tostring(errorMessage))
    end)
    ```

    :::note Read only policy info
    The policy info table will be *read-only*, through [table.freeze](https://create.roblox.com/docs/reference/engine/libraries/table#freeze).
    :::

    @return Promise<PlayerPolicyInfo>
]=]

function playerPolicyInfoUtil.playerPolicyInfoPromise(player: Player)
	return Promise.new(function(resolve, reject)
		local playerPolicyInfoSuccessfullyRetrieved, response = pcall(function()
			return PolicyService:GetPolicyInfoForPlayerAsync(player)
		end)

		if playerPolicyInfoSuccessfullyRetrieved then
			resolve(table.freeze(response))
		else
			reject(table.freeze(table.clone(DEFAULT_PLAYER_POLICY_INFO)), response)
		end
	end)
end

return table.freeze(playerPolicyInfoUtil)
