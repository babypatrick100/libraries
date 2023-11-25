return {
	run = function(physicalProperties: PhysicalProperties, intermediateSerializedData)
		intermediateSerializedData.components = {
			physicalProperties.Density,
			physicalProperties.Friction,
			physicalProperties.Elasticity,
		}
	end,
}
