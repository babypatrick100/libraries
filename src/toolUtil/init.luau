--[=[
	@class toolUtil

	A simple utility module for working with tools.
]=]

local Connection = require(script.Parent.Connection)
local playerEventsUtil = require(script.Parent.playerEventsUtil)
local playersUtil = require(script.Parent.playersUtil)

local toolUtil = {}

local function observePlayerBackpack(
	player: Player,
	observer: (newBackpack: Backpack) -> ()
): Connection.Connection
	local connections = {}

	local function playerChildAdded(childAdded)
		if not childAdded:IsA("Backpack") then
			return
		end

		observer(childAdded)
	end

	table.insert(connections, player.ChildAdded:Connect(playerChildAdded))

	for _, child in player:GetChildren() do
		task.spawn(playerChildAdded, child)
	end

	return Connection.new(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

--[=[
	Attempts to returns the owner of the given tool, if found.
]=]

function toolUtil.toolOwner(tool: Tool): Player?
	local playerFromTool = playersUtil.playerFromInstance(tool)
	local toolParent = tool.Parent

	if playerFromTool ~= nil then
		return playerFromTool
	end

	if toolParent ~= nil and toolParent:IsA("Backpack") then
		return toolParent.Parent
	end

	return nil
end

--[=[ 
    Places the given tool in the given `player`'s backpack and a cloned variant of it in `player.StarterGear`.
]=]

function toolUtil.tryPlaceToolInBackpackAndStarterGear(player: Player, tool: Tool)
	tool.Parent = player.Backpack
	tool:Clone().Parent = player.StarterGear
end

--[=[ 
    Places the given tool in the given `player`'s backpack and tries to equips it on the humanoid.
]=]

function toolUtil.tryPlaceToolInBackpackAndEquip(player: Player, tool: Tool)
	tool.Parent = player.Backpack

	local humanoid = if player.Character
		then player.Character:FindFirstChildWhichIsA("Humanoid")
		else nil

	if humanoid ~= nil then
		humanoid:EquipTool(tool)
	end
end

--[=[
	Returns the player tool count. `predicate` is called on every tool owned by the given `player`, and each time it returns `true`, 
	the tool count is incremented by 1.
]=]

function toolUtil.mappedPlayerToolCount(player: Player, predicate: (tool: Tool) -> boolean)
	local toolCount = 0
	for _, playerTool in toolUtil.playerTools(player) do
		if predicate(playerTool) == true then
			toolCount += 1
		end
	end

	return toolCount
end

--[=[
	Returns a read only array of all player tools - both equipped and unequipped.
]=]

function toolUtil.playerTools(player: Player)
	local tools = player.Backpack:GetChildren()

	if player.Character ~= nil then
		for _, child in player.Character:GetChildren() do
			if child:IsA("Tool") then
				table.insert(tools, child)
			end
		end
	end

	return table.freeze(tools)
end

--[=[ 
    Returns the current equipped tool by the player.
]=]

function toolUtil.currentEquippedTool(player: Player)
	return if player.Character ~= nil then player.Character:FindFirstChildWhichIsA("Tool") else nil
end

--[=[ 
	Observes the player for any new tools equipped or unequipped. Also captures
	all the initial tool equipped. 

	```lua
	toolUtil.observePlayerForEquippedTool(player, function(newToolEquipped)
	
	end, function(newToolUnequipped)
	
	end)
	```

	:::warning
	This method will throw an error if both `observerForToolEquipped` and `observerForToolUnequipped` are not specified, at least any *one* of them must be specified.
	:::
]=]

function toolUtil.observePlayerForToolsEquippedAndUnequipped(
	player: Player,
	observerForToolEquipped: ((toolEquipped: Tool) -> ())?,
	observerForToolUnequipped: ((toolUnequipped: Tool) -> ())?
)
	assert(
		observerForToolEquipped ~= nil or observerForToolUnequipped ~= nil,
		"`observerForToolEquipped` or `observerForToolUnequipped`; any one of them must be specified."
	)

	local currentEquippedTool = toolUtil.currentEquippedTool(player)

	if currentEquippedTool ~= nil and observerForToolEquipped ~= nil then
		task.spawn(observerForToolEquipped, currentEquippedTool)
	end

	local connections = {}
	table.insert(
		connections,
		playerEventsUtil.usePlayerCharacterAdded(player, function(newPlayerCharacter)
			if observerForToolEquipped ~= nil then
				table.insert(
					connections,
					newPlayerCharacter.ChildAdded:Connect(function(child)
						if not child:IsA("Tool") then
							return
						end

						task.spawn(observerForToolEquipped, child)
					end)
				)
			end

			if observerForToolUnequipped ~= nil then
				table.insert(
					connections,
					newPlayerCharacter.ChildRemoved:Connect(function(child)
						if not child:IsA("Tool") then
							return
						end

						task.spawn(observerForToolUnequipped, child)
					end)
				)
			end
		end)
	)

	return Connection.new(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

--[=[ 
	Observes the player's backpack for any new tools added or removed. Also captures
	all initial tools in the player backpack.

	```lua
	toolUtil.observePlayerBackpackForTools(player, function(toolAdded)
	
	end, function(toolRemoved)
	
	end)
	```

	:::warning
	This method will throw an error if both `observerForToolAdded` and `observerForToolRemoved` are not specified, at least any *one* of them must be specified.
	:::
]=]

function toolUtil.observePlayerBackpackForTools(
	player: Player,
	observerForToolAdded: ((newToolAdded: Tool) -> ())?,
	observerForToolRemoved: ((newToolRemoved: Tool) -> ())?
)
	assert(
		observerForToolAdded ~= nil or observerForToolRemoved ~= nil,
		"`observerForToolAdded` or `observerForToolRemoved`; any one of them must be specified."
	)

	local connections = {}

	table.insert(
		connections,
		observePlayerBackpack(player, function(newBackpack)
			if observerForToolAdded ~= nil then
				for _, tool in newBackpack:GetChildren() do
					task.spawn(observerForToolAdded, tool)
				end

				table.insert(
					connections,
					newBackpack.ChildAdded:Connect(function(tool)
						task.spawn(observerForToolAdded, tool)
					end)
				)
			end

			if observerForToolRemoved ~= nil then
				table.insert(
					connections,
					newBackpack.ChildRemoved:Connect(function(tool)
						task.spawn(observerForToolRemoved, tool)
					end)
				)
			end
		end)
	)

	return Connection.new(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

--[=[ 
	Observes the player's backpack and character for any new tools added or removed.

	```lua
	toolUtil.observePlayerForToolOwnership(player, function(toolOwnershipGranted)
	
	end, function(toolOwnershipRemoved)
	
	end)
	```

	:::warning
	This method will throw an error if both `observerForToolOwnershipGranted` and `observerForToolOwnershipRemoved` are not specified, at least any
	*one* of them must be specified.
	:::
]=]

function toolUtil.observePlayerForToolOwnership(
	player: Player,
	observerForToolOwnershipGranted: ((newTool: Tool) -> ())?,
	observerForToolOwnershipRemoved: ((newTool: Tool) -> ())?
)
	assert(
		observerForToolOwnershipGranted ~= nil or observerForToolOwnershipRemoved ~= nil,
		"`observerForToolOwnershipGranted` or `observerForToolOwnershipRemoved`; any one of them must be specified."
	)

	local connections = {}
	local toolsOwnershipObserved = {}

	-- We check if the child added or removed is a tool (in/from backpack) - while
	-- this is not necessary, it is done so to not have the code break as a result
	-- of potential developer error (player.Backpack must ideally consist of only tools!)
	local function backpackChildAdded(childAdded)
		if toolsOwnershipObserved[childAdded] or not childAdded:IsA("Tool") then
			return
		end

		toolsOwnershipObserved[childAdded] = true

		if observerForToolOwnershipGranted ~= nil then
			task.spawn(observerForToolOwnershipGranted, childAdded)
		end
	end

	local function backpackChildRemoved(childRemoved)
		if
			childRemoved.Parent == player.Character
			or toolsOwnershipObserved[childRemoved] == nil
			or not childRemoved:IsA("Tool")
		then
			return
		end

		toolsOwnershipObserved[childRemoved] = nil

		if childRemoved.Parent ~= player.Character then
			task.spawn(observerForToolOwnershipRemoved, childRemoved)
		end
	end

	local function characterChildAdded(childAdded)
		if not childAdded:IsA("Tool") or toolsOwnershipObserved[childAdded] then
			return
		end

		toolsOwnershipObserved[childAdded] = true

		if observerForToolOwnershipGranted ~= nil then
			task.spawn(observerForToolOwnershipGranted, childAdded)
		end
	end

	local function characterChildRemoved(childRemoved)
		if
			not childRemoved:IsA("Tool")
			or childRemoved.Parent == player.Backpack
			or toolsOwnershipObserved[childRemoved] == nil
		then
			return
		end

		toolsOwnershipObserved[childRemoved] = nil

		if observerForToolOwnershipRemoved ~= nil then
			task.spawn(observerForToolOwnershipRemoved, childRemoved)
		end
	end

	table.insert(
		connections,
		observePlayerBackpack(player, function(newBackpack)
			for _, child in newBackpack:GetChildren() do
				backpackChildAdded(child)
			end

			table.insert(connections, newBackpack.ChildAdded:Connect(backpackChildAdded))
			table.insert(connections, newBackpack.ChildRemoved:Connect(backpackChildRemoved))
		end)
	)

	table.insert(
		connections,
		playerEventsUtil.usePlayerCharacterAdded(player, function(newPlayerCharacter)
			-- EDGECASE: `player.Character.ChildRemoving` does not fire if the player's
			-- character is reloaded, so we'll manually have to flush out old tools marked
			-- for ownership!
			for tool in toolsOwnershipObserved do
				-- If the tool's parent is not a backpack, then we like to make the assumption
				-- that it'll be the old player's character.
				if not tool.Parent:IsA("Backpack") then
					characterChildRemoved(tool)
				end
			end

			table.insert(connections, newPlayerCharacter.ChildAdded:Connect(characterChildAdded))
			table.insert(
				connections,
				newPlayerCharacter.ChildRemoved:Connect(characterChildRemoved)
			)

			for _, child in newPlayerCharacter:GetChildren() do
				task.spawn(characterChildAdded, child)
			end
		end)
	)

	return Connection.new(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

return table.freeze(toolUtil)
