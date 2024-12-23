--[=[
	@class weldConstraintUtil

	A simple utility for working with weld constraints.
]=]

local weldConstraintUtil = {}

--[=[
	Welds the given basepart to the target basepart.
]=]

function weldConstraintUtil.weld(basePart: BasePart, target: BasePart)
	assert(basePart.Anchored == false, "Given basepart must not be anchored!")
	assert(target.Anchored == false, "Given target basepart must not be anchored!")

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part1 = basePart
	weldConstraint.Part0 = target
	weldConstraint.Parent = basePart
end

return table.freeze(weldConstraintUtil)
