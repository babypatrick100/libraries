return {
	run = function(pathwayPoint: PathWaypoint, intermediateSerializedData)
		intermediateSerializedData.components = {
			pathwayPoint.Label,
			pathwayPoint.Action.Name,
			{ pathwayPoint.Position.X, pathwayPoint.Position.Y, pathwayPoint.Position.X },
		}
	end,
}
