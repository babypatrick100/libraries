--[=[ 
    @class playerPolicyInfoUtil

    A very simple utility module for retrieving a player's policy info safely.
 
    ```lua
    playerPolicyInfoUtil.playerPolicyInfo(localPlayer):andThen(function(playerPolicyInfo)
        print(playerPolicyInfo.ArePaidRandomItemsRestricted)
        print(playerPolicyInfo.AllowedExternalLinkReferences)
        print(playerPolicyInfo.IsPaidItemTradingAllowed)
        print(playerPolicyInfo.IsSubjectToChinaPolicies)
    end):catch(function(errorMessage)
        warn(string.format("Error retrieving player policy info because %s", errorMessage))
    end)    
    ```
]=]

--[=[ 
    @interface PlayerPolicyInfo  
    @within playerPolicyInfoUtil

    .ArePaidRandomItemsRestricted boolean
    .AllowedExternalLinkReferences {number}
    .IsPaidItemTradingAllowed boolean
    .IsSubjectToChinaPolicies boolean
]=]

--[=[ 
    @interface DefaultPlayerPolicyInfo  
    @within playerPolicyInfoUtil

    .ArePaidRandomItemsRestricted false
    .AllowedExternalLinkReferences {}
    .IsPaidItemTradingAllowed false
    .IsSubjectToChinaPolicies false
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
    Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the policy info of `player`, if successfully retrieved. If the policy
    info of the given player couldn't be retrieved, then the promise will reject with [DefaultPlayerPolicyInfo] 
    and the error message.

    ```lua
    playerPolicyInfoUtil.playerPolicyInfo(somePlayer):andThen(function(policyInfo)
        print(policyInfo.ArePaidRandomItemsRestricted)
    end):catch(function(defaultPolicyInfo, errorMessage)
        warn(tostring(errorMessage))
    end)
    ```

    @return Promise<PlayerPolicyInfo>
]=]

function playerPolicyInfoUtil.playerPolicyInfo(player: Player)
	return Promise.new(function(resolve, reject)
		local playerPolicyInfoSuccessfullyRetrieved, response = pcall(function()
			return PolicyService:GetPolicyInfoForPlayerAsync(player)
		end)

		if playerPolicyInfoSuccessfullyRetrieved then
			resolve(table.freeze(response))
		else
			reject(table.clone(table.freeze(DEFAULT_PLAYER_POLICY_INFO)), response)
		end
	end)
end

return table.freeze(playerPolicyInfoUtil)
