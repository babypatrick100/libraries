--[=[ 
	@class clientMovementInputUtil
	
	A simple utility module which wraps `PlayerModule` and `PlayerModule.ControlModule`.
]=]

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local ControlModule = require(localPlayer.PlayerScripts.PlayerModule.ControlModule :: ModuleScript)
local PlayerModule = require(localPlayer.PlayerScripts.PlayerModule :: ModuleScript)

local clientMovementInputUtil = {}

--[=[ 
	Returns the thumbstick move vector.
]=]

function clientMovementInputUtil.thumbstickMoveVector(): Vector3
	return ControlModule:GetMoveVector()
end

--[=[ 
	Enables player controls.
]=]

function clientMovementInputUtil.enableControls()
	PlayerModule:GetControls():Enable()
end

--[=[ 
	Disables player controls.
]=]

function clientMovementInputUtil.disableControls()
	PlayerModule:GetControls():Disable()
end

return table.freeze(clientMovementInputUtil)
