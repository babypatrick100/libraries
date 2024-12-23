--[=[ 
	@class clientMouseUtil
	
	A simple utility module for working with the client's mouse.
]=]

local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Connection = require(script.Parent.Connection)
local schedulerUtil = require(script.Parent.schedulerUtil)

local DEFAULT_MAX_ACTIVATION_DISTANCE = 500
local MOUSE_POSITION_RAYCAST_CALLBACK_IDENTIFIER = "MousePositionRaycast"

local mouse3DHoverStartCallbacks = {}
local mouse3DHoverEndCallbacks = {}

local clientMouseUtil = {}

local function mousePositionRayResult(position: Vector2)
	local unitRay = Workspace.CurrentCamera:ViewportPointToRay(position.X, position.Y)
	return Workspace:Raycast(unitRay.Origin, unitRay.Direction * DEFAULT_MAX_ACTIVATION_DISTANCE),
		unitRay
end

--[=[ 
	@return Connection

	Registers the given callback which is called whenever the player hovers over a 3D instance.
]=]

function clientMouseUtil.registerMouseHoverStart(
	callback: (
		instance: Instance,
		mousePosition: Vector2
	) -> (),
	minActivationDistance: number?,
	maxActivationDistance: number?
): Connection.Connection
	local callbackData = {
		callback = callback,
		maxActivationDistance = math.min(
			maxActivationDistance or DEFAULT_MAX_ACTIVATION_DISTANCE,
			DEFAULT_MAX_ACTIVATION_DISTANCE
		),
		minActivationDistance = minActivationDistance or 0,
	}
	table.insert(mouse3DHoverStartCallbacks, callbackData)
	return Connection.new(mouse3DHoverStartCallbacks, callbackData)
end

--[=[ 
	@return Connection
	
	Registers the given callback which is called whenever the player no hovers over a 3D instance.
]=]

function clientMouseUtil.registerMouseHoverEnd(callback: (
	instance: Instance,
	mousePosition: Vector2
) -> ()): Connection.Connection
	local callbackData = { callback = callback, lastInstance = nil }
	table.insert(mouse3DHoverEndCallbacks, callbackData)
	return Connection.new(mouse3DHoverEndCallbacks, callbackData)
end

schedulerUtil.schedule(
	schedulerUtil.RunServiceEvent.RenderStepped,
	MOUSE_POSITION_RAYCAST_CALLBACK_IDENTIFIER,
	function()
		local mouseLocation = UserInputService:GetMouseLocation()
		local raycastResult, unitRay = mousePositionRayResult(mouseLocation)

		if raycastResult then
			for _, callbackData in mouse3DHoverEndCallbacks do
				if
					callbackData.lastInstance
					and callbackData.lastInstance ~= raycastResult.Instance
				then
					callbackData.callback(callbackData.lastInstance, mouseLocation)
				end

				callbackData.lastInstance = raycastResult.Instance
			end

			for _, callbackData in mouse3DHoverStartCallbacks do
				if
					(unitRay.Origin - raycastResult.Position).Magnitude
						<= callbackData.maxActivationDistance
					and (unitRay.Origin - raycastResult.Position).Magnitude >= callbackData.minActivationDistance
					and callbackData.lastInstance ~= raycastResult.Instance
				then
					callbackData.lastInstance = raycastResult.Instance
					callbackData.callback(raycastResult.Instance, mouseLocation)
				end
			end
		else
			for _, callbackData in mouse3DHoverEndCallbacks do
				if callbackData.lastInstance then
					callbackData.callback(callbackData.lastInstance, mouseLocation)
					callbackData.lastInstance = nil
				end
			end
		end
	end
)

return table.freeze(clientMouseUtil)
