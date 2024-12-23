--[=[
	@class playerHumanoidUtil

	A simple utility module for working with the player's humanoid.
]=]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Promise)
local Signal = require(script.Parent.Signal)
local Connection = require(script.Parent.Connection)
local instancePropertyUtil = require(script.Parent.instancePropertyUtil)
local instanceTroveUtil = require(script.Parent.instanceTroveUtil)
local playerEventsUtil = require(script.Parent.playerEventsUtil)

local playerHumanoidUtil = {}

local function kickHumanoidOutOfSeatPromise(targetHumanoid: Humanoid)
	targetHumanoid.Sit = false

	return Promise.fromEvent(targetHumanoid:GetPropertyChangedSignal("SeatPart"), function()
		return targetHumanoid.SeatPart == nil
	end)
end

--[=[ 
	Attempts to return the given `player`'s humanoid, if found. This method is sugar for:

	```lua
	local function playerHumanoid(player: Player)
		return if player.Character ~= nil then 
			player.Character:FindFirstChildWhichIsA("Humanoid") 
		else 
			nil
	end
	```
]=]

function playerHumanoidUtil.playerHumanoid(player: Player): Humanoid?
	return if player.Character ~= nil
		then player.Character:FindFirstChildWhichIsA("Humanoid")
		else nil
end

--[=[ 
	Promisfied verison of [playerHumanoidUtil.playerHumanoid].

	:::note Automatic promise cancellation
	The returned promise will be cancelled automatically once `player` is no longer in game!
	:::

	@return Promise<Humanoid>
]=]

function playerHumanoidUtil.playerHumanoidPromise(player: Player)
	local connections = {}
	local playerTrove = instanceTroveUtil.instanceTrove(player)

	local thisPlayerHumanoidPromise = playerTrove:AddPromise(Promise.new(function(resolve)
		local playerHumanoid = playerHumanoidUtil.playerHumanoid(player)
		if playerHumanoid ~= nil then
			resolve(playerHumanoid)
			return
		end

		local onPlayerHumanoidRetrievedSignal = Signal.new()

		table.insert(
			connections,
			playerEventsUtil.usePlayerCharacterAdded(player, function(newCharacter)
				playerHumanoid = playerHumanoidUtil.playerHumanoid(player)

				if playerHumanoid ~= nil then
					onPlayerHumanoidRetrievedSignal:Fire()
				else
					table.insert(
						connections,
						newCharacter.ChildAdded:Connect(function()
							playerHumanoid = playerHumanoidUtil.playerHumanoid(player)

							if playerHumanoid ~= nil then
								onPlayerHumanoidRetrievedSignal:Fire()
							end
						end)
					)
				end
			end)
		)

		Promise.fromEvent(onPlayerHumanoidRetrievedSignal):expect()
		onPlayerHumanoidRetrievedSignal:Destroy()
		resolve(playerHumanoid)
	end))

	thisPlayerHumanoidPromise:finally(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)

	return thisPlayerHumanoidPromise
end

--[=[
	@return Promise<Seat | VehicleSeat>

	Attempts to seat the given `player`'s humanoid to `seat`. Additionally, if the `player`'s humanoid is already seated on some *other* seat,
	then the humanoid will be unseated through `humanoid.Sit = false` before being seated to `seat`.

	:::warning
	- This method will throw an error if `player` is not preset in game.
	
	- On the client, this method will throw an error if `player` is not the local player.

	- If the given `seat` already has an `Occupant` which is not the `player`'s humanoid, then the returned promise
	will reject.
	:::

	:::note Automatic promise cancellation
	The returned promise will be cancelled automatically once `player` is no longer in game!
	:::
]=]

function playerHumanoidUtil.trySeatPlayerPromise(player: Player, seat: VehicleSeat | Seat)
	if RunService:IsClient() then
		assert(player == Players.LocalPlayer, "Can only seat local player to a seat!")
	end

	assert(player:IsDescendantOf(Players), "Player must be in game!")

	local playerTrove = instanceTroveUtil.instanceTrove(player)
	return playerTrove:AddPromise(Promise.new(function(resolve, reject, onCancel)
		local humanoid = playerHumanoidUtil.playerHumanoidPromise(player):expect()

		if seat.Occupant ~= nil then
			if seat.Occupant == humanoid then
				resolve(seat)
			else
				reject(string.format("Seat [%s] already has an occupant!", seat:GetFullName()))
			end

			return
		end

		if humanoid.SeatPart ~= nil and humanoid.SeatPart ~= seat then
			local kickTargetHumanoidOutOfSeatPromise = kickHumanoidOutOfSeatPromise(humanoid)
			onCancel(function()
				kickTargetHumanoidOutOfSeatPromise:cancel()
			end)
			kickTargetHumanoidOutOfSeatPromise:expect()
		end

		if humanoid.SeatPart ~= seat then
			seat:Sit(humanoid)
		end

		resolve(seat)
	end))
end

--[=[
	@return Promise<Seat | VehicleSeat>

	Works almost exactly the same as [playerHumanoidUtil.trySeatPlayerPromise], but unlike the former method, this method
	will try to unseat the `seat`'s occupant (if any) through `humanoid.Sit = false`.

	:::warning
	- This method will throw an error if `player` is not preset in game.
	
	- On the client, this method will throw an error if `player` is not the local player.

	- If the given `seat` already has an `Occupant` which is not the `player`'s humanoid, then the returned promise
	will reject.
	:::

	:::note Automatic promise cancellation
	The returned promise will be cancelled automatically once `player` is no longer in game!
	:::
]=]

function playerHumanoidUtil.forceSeatPlayerPromise(player: Player, seat: VehicleSeat | Seat)
	if RunService:IsClient() then
		assert(player == Players.LocalPlayer, "Can only seat local player to a seat!")
	end

	assert(player:IsDescendantOf(Players), "Player must be in game!")

	local playerTrove = instanceTroveUtil.instanceTrove(player)
	return playerTrove:AddPromise(Promise.new(function(resolve, onCancel)
		local humanoid = playerHumanoidUtil.playerHumanoidPromise(player):expect()

		if seat.Occupant ~= nil then
			if seat.Occupant == humanoid then
				resolve(seat)
				return
			else
				local kickTargetHumanoidOutOfSeatPromise =
					kickHumanoidOutOfSeatPromise(seat.Occupant)
				onCancel(function()
					kickTargetHumanoidOutOfSeatPromise:cancel()
				end)
				kickTargetHumanoidOutOfSeatPromise:expect()
			end
		end

		if humanoid.SeatPart ~= nil and humanoid.SeatPart ~= seat then
			local kickTargetHumanoidOutOfSeatPromise = kickHumanoidOutOfSeatPromise(humanoid)
			onCancel(function()
				kickTargetHumanoidOutOfSeatPromise:cancel()
			end)
			kickTargetHumanoidOutOfSeatPromise:expect()
		end

		if humanoid.SeatPart ~= seat then
			seat:Sit(humanoid)
		end

		resolve(seat)
	end))
end

--[=[ 
	@return Connection
	
	```lua
	playerHumanoidUtil.playerHumanoidSeatPartObserver(player, function(seatPlayerIsSittingOn)
		print(player.Name .. " sat on seat " ..tostring(newSeatPlayerIsSittingOn.Name))		
	end, function(seatPlayerIsNoLongerSittingOn)
		if newSeatPlayerIsNoLongerSittingOn ~= nil then 
			print(player.Name .. " left seat " ..tostring(newSeatPlayerIsNoLongerSittingOn.Name))		
		end
	end)
	```

	Observes the given `player`'s `humanoid.SeatPart`, but also accounting for cases where the `player`'s humanoid has not being
	loaded yet or if the `player`'s humanoid is updated (for e.g on character respawn).
]=]

function playerHumanoidUtil.playerHumanoidSeatPartObserver(
	player: Player,
	observerSeated: ((
		seatPlayerIsSittingOn: Seat | VehicleSeat
	) -> ())?,
	observerUnseated: ((
		seatPlayerIsNoLongerSittingOn: (Seat | VehicleSeat)?
	) -> ())?
): Connection.Connection
	assert(
		observerSeated ~= nil or observerUnseated ~= nil,
		"`observerSeated` and `observerUnseated`: one of them must be specified!"
	)

	local connections = {}
	local lastHumanoidRetrievalPromise = nil

	table.insert(
		connections,
		playerEventsUtil.usePlayerCharacterAdded(player, function()
			if lastHumanoidRetrievalPromise ~= nil then
				lastHumanoidRetrievalPromise:cancel()
			end

			lastHumanoidRetrievalPromise = playerHumanoidUtil
				.playerHumanoidPromise(player)
				:andThen(function(newHumanoid)
					table.insert(
						connections,
						instancePropertyUtil.observeProperty(
							newHumanoid,
							"SeatPart",
							function(newSeatPart, oldSeatPart)
								if newSeatPart ~= nil then
									if observerSeated ~= nil then
										observerSeated(newSeatPart)
									end
								else
									if observerUnseated ~= nil then
										observerUnseated(oldSeatPart)
									end
								end
							end
						)
					)
				end)
		end)
	)

	return Connection.new(function()
		if lastHumanoidRetrievalPromise ~= nil then
			lastHumanoidRetrievalPromise:cancel()
		end

		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

return table.freeze(playerHumanoidUtil)
