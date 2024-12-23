--[=[
	@class viewportFrameUtil

	A simple utility for working with [ViewportFrame](https://create.roblox.com/docs/reference/engine/classes/ViewportFrame).

	*Credits to EgoMoose for some of the math related operations.*
]=]

local Trove = require(script.Parent.Trove)
local ViewportModel = require(script.Parent.ViewportModel)
local schedulerUtil = require(script.Parent.schedulerUtil)

local VIEWPORT_MODEL_HANDLER_SCHEDULER_CALLBACK_IDENTIFIER = "ViewportModelHandler"
local DEFAULT_ROTATION_SPEED = 20

local viewportCameras = {}

local viewportFrameUtil = {}

--[=[ 
	Renders the given model in the viewport frame. Returns a trove.
]=]

function viewportFrameUtil.renderModel(
	viewportFrame: ViewportFrame,
	model: Model,
	data: { cameraFieldOfView: number, rotationSpeed: number? }?
)
	local trove = Trove.new()
	trove:Add(model)

	local viewportCamera = trove:Add(Instance.new("Camera"))
	viewportFrame.CurrentCamera = viewportCamera
	viewportCamera.Parent = viewportFrame
	model:PivotTo(CFrame.identity)
	model.Parent = viewportFrame

	local viewportModel = ViewportModel.new(viewportFrame, viewportCamera)
	viewportModel:SetModel(model)
	local boundingBoxCFrame = model:GetBoundingBox()

	viewportCameras[viewportCamera] = {
		bestFitDistance = viewportModel:GetFitDistance(boundingBoxCFrame.Position),
		rotationSpeed = if data ~= nil
			then data.rotationSpeed or DEFAULT_ROTATION_SPEED
			else DEFAULT_ROTATION_SPEED,
		theta = 0,
		orientation = CFrame.identity,
		boundingBoxCFrame = boundingBoxCFrame,
	}

	viewportCamera.FieldOfView = if data ~= nil
		then data.cameraFieldOfView
		else viewportCamera.FieldOfView

	trove:Add(function()
		viewportCameras[viewportCamera] = nil
	end)

	return trove
end

schedulerUtil.schedule(
	schedulerUtil.RunServiceEvent.RenderStepped,
	VIEWPORT_MODEL_HANDLER_SCHEDULER_CALLBACK_IDENTIFIER,
	function(deltaTime)
		for viewportCamera, data in viewportCameras do
			data.theta += math.rad(data.rotationSpeed * deltaTime)
			data.orientation =
				CFrame.fromEulerAnglesYXZ(math.rad(-data.rotationSpeed), data.theta, 0)
			viewportCamera.CFrame = CFrame.new(data.boundingBoxCFrame.Position)
				* data.orientation
				* CFrame.new(0, 0, data.bestFitDistance)
		end
	end
)

return table.freeze(viewportFrameUtil)
