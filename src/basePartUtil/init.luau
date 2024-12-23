--[=[ 
	@class basePartUtil

	An utility module for working with base parts.
]=]

local Workspace = game:GetService("Workspace")

local VOXEL_GRID_RESOLUTION = 4
local DEFAULT_DEPTH = 0.01

local basePartUtil = {}

local function instanceGroundMaterial(
	basePart: BasePart,
	raycastParams: RaycastParams?,
	depth: number
): Enum.Material?
	local corners = basePartUtil.corners(basePart)
	local depthVector = Vector3.new(0, depth, 0)

	for index, cornerPosition in corners.top do
		local bottomCornerPosition = corners.bottom[index]
		local ray = Workspace:Raycast(
			cornerPosition,
			(bottomCornerPosition - cornerPosition) - depthVector,
			raycastParams
		)

		if ray then
			return ray.Material
		end
	end

	return nil
end

local function instanceIsInWater(basePart: BasePart): boolean
	local halfSize = basePart.Size / 2

	return Workspace.Terrain:ReadVoxels(
		Region3.new(basePart.Position - halfSize, basePart.Position + halfSize)
			:ExpandToGrid(VOXEL_GRID_RESOLUTION),
		VOXEL_GRID_RESOLUTION
	)[1][1][1] == Enum.Material.Water
end

--[=[
	Returns a read-only dictionary of all corners of `basePart`, top and bottom.
]=]

function basePartUtil.corners(basePart: BasePart): { top: { Vector3 }, bottom: { Vector3 } }
	local size = basePart.Size

	local frontFaceCenter = (basePart.CFrame + basePart.CFrame.LookVector * size.Z / 2)
	local backFaceCenter = (basePart.CFrame - basePart.CFrame.LookVector * size.Z / 2)
	local topFrontEdgeCenter = frontFaceCenter + frontFaceCenter.UpVector * size.Y / 2
	local bottomFrontEdgeCenter = frontFaceCenter - frontFaceCenter.UpVector * size.Y / 2
	local topBackEdgeCenter = backFaceCenter + backFaceCenter.UpVector * size.Y / 2
	local bottomBackEdgeCenter = backFaceCenter - backFaceCenter.UpVector * size.Y / 2

	return table.freeze({
		bottom = table.freeze({
			(bottomBackEdgeCenter + bottomBackEdgeCenter.RightVector * size.X / 2).Position,
			(bottomBackEdgeCenter - bottomBackEdgeCenter.RightVector * size.X / 2).Position,
			(bottomFrontEdgeCenter + bottomFrontEdgeCenter.RightVector * size.X / 2).Position,
			(bottomFrontEdgeCenter - bottomFrontEdgeCenter.RightVector * size.X / 2).Position,
		}),

		top = table.freeze({
			(topBackEdgeCenter + topBackEdgeCenter.RightVector * size.X / 2).Position,
			(topBackEdgeCenter - topBackEdgeCenter.RightVector * size.X / 2).Position,
			(topFrontEdgeCenter + topFrontEdgeCenter.RightVector * size.X / 2).Position,
			(topFrontEdgeCenter - topFrontEdgeCenter.RightVector * size.X / 2).Position,
		}),
	})
end

--[=[
	Returns the material the basePart is lying on. If `basePart` is underwater, then `Enum.Material.Water` will be returned, elseif
	`basePart` is in air, then `Enum.Material.Air` will be returned.
	
	- The 2nd argument can be passed as a [RaycastParams](https://create.roblox.com/docs/reference/engine/datatypes/RaycastParams) object,
	which will be used in determining the material of `basePart` through ray casting.
		 
	- The 3rd argument can be passed as a number (depth) which will increase the length 
	of the ray by `depth` studs (on the Y-axis). This is only useful when you want to add 
	in more leeway in determining the material of `basePart` **reliably**, since sometimes
	the basePart may be very slightly over the top of some ground due to its geometry so in those cases,
	the ray may not register properly. If this argument isn't specified, then it will default to `0.01`.
]=]

function basePartUtil.floorMaterial(
	basePart: BasePart,
	raycastParams: RaycastParams?,
	depth: number?
): Enum.Material
	if depth == nil then
		depth = DEFAULT_DEPTH
	end

	if instanceIsInWater(basePart) then
		return Enum.Material.Water
	end

	local groundInstanceMaterial = instanceGroundMaterial(basePart, raycastParams, depth :: number)

	if groundInstanceMaterial then
		return groundInstanceMaterial
	end

	return Enum.Material.Air
end

return table.freeze(basePartUtil)
