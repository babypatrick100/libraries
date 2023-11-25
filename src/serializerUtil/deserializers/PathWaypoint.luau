return {
	run = function(serializedPathwayPoint)
		local components = serializedPathwayPoint.components
		
		return PathWaypoint.new(
			Vector3.new(table.unpack(components[3])),
			Enum.PathWaypointAction[components[2]],
			components[1]
		)
	end,
}
