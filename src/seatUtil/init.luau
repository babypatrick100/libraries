--[=[ 
	@class seatUtil

	A utility module for working with seats.
]=]

local Property = require(script.Parent.Property)
local Sift = require(script.Parent.Sift)
local Trove = require(script.Parent.Trove)
local playersUtil = require(script.Parent.playersUtil)

local seatUtil = {}

--[=[ 
   Returns a property which is updated based on the `Occupant` property of the given seats. Also
   returns a trove object which will cleanup everything.

   @return Property<{Seat | VehicleSeat}: Player>
]=]

function seatUtil.seatOccupanciesProperty(seats: { Seat | VehicleSeat }): Property.Property<{
	[Seat | VehicleSeat]: Player,
}>
	local trove = Trove.new()
	local property = trove:Add(Property.new({}))
	local initialSeatOccupants = {} :: { [Seat | VehicleSeat]: Player }?

	for _, seat in seats do
		if seat.Occupant ~= nil then
			initialSeatOccupants[seat] = playersUtil.playerFromInstance(seat.Occupant)
		end

		trove:Connect(seat:GetPropertyChangedSignal("Occupant"), function()
			property:set(
				Sift.Dictionary.set(
					initialSeatOccupants,
					seat,
					playersUtil.playerFromInstance(seat.Occupant)
				)
			)
		end)
	end

	property:set(initialSeatOccupants)
	return property, trove
end

return table.freeze(seatUtil)
