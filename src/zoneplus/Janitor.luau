--@ignore
-- Janitor
-- Original by Validark
-- Modifications by pobammer
-- roblox-ts support by OverHash and Validark
-- LinkToInstance fixed by Elttob.

local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat

local IndicesReference = newproxy(true)
getmetatable(IndicesReference).__tostring = function()
	return "IndicesReference"
end

local LinkToInstanceIndex = newproxy(true)
getmetatable(LinkToInstanceIndex).__tostring = function()
	return "LinkToInstanceIndex"
end

local METHOD_NOT_FOUND_ERROR =
	"Object %s doesn't have method %s, are you sure you want to add it? Traceback: %s"
--local NOT_A_PROMISE = "Invalid argument #1 to 'Janitor:AddPromise' (Promise expected, got %s (%s))"

local Janitor = {
	ClassName = "Janitor",
	__index = {
		CurrentlyCleaning = true,
		[IndicesReference] = nil,
	},
}

local TypeDefaults = {
	["function"] = true,
	RBXScriptConnection = "Disconnect",
}

--[[**
	Instantiates a new Janitor object.
	@returns [t:Janitor]
**--]]
function Janitor.new()
	return setmetatable({
		CurrentlyCleaning = false,
		[IndicesReference] = nil,
	}, Janitor)
end

function Janitor.Is(Object)
	return type(Object) == "table" and getmetatable(Object) == Janitor
end

Janitor.is = Janitor.Is

function Janitor.__index:Add(Object, MethodName, Index)
	if Index == nil then
		Index = newproxy(false)
	end

	if Index then
		self:Remove(Index)

		local This = self[IndicesReference]
		if not This then
			This = {}
			self[IndicesReference] = This
		end

		This[Index] = Object
	end
	--[[
	if Promise.is(Object) then
		local Id = newproxy(false)
		if Object:getStatus() == Promise.Status.Started then
			local NewPromise = self:Add(Promise.resolve(Object), "cancel", Id)
			NewPromise:finallyCall(self.Remove, self, Id)
			return NewPromise, Id
		else
			return Object
		end
	end--]]

	MethodName = MethodName or TypeDefaults[typeof(Object)] or "Destroy"
	if type(Object) ~= "function" and not Object[MethodName] then
		warn(
			string.format(
				METHOD_NOT_FOUND_ERROR,
				tostring(Object),
				tostring(MethodName),
				debug.traceback(nil, 2)
			)
		)
	end

	self[Object] = MethodName
	return Object, Index
end

Janitor.__index.Give = Janitor.__index.Add

-- This will assume whether or not the object is a Promise or a regular object.
function Janitor.__index:AddObject(Object)
	local Id = newproxy(false)
	return self:Add(Object, false, Id), Id
end

Janitor.__index.GiveObject = Janitor.__index.AddObject

function Janitor.__index:Remove(Index)
	local This = self[IndicesReference]

	if This then
		local Object = This[Index]

		if Object then
			local MethodName = self[Object]

			if MethodName then
				if MethodName == true then
					Object()
				else
					local ObjectMethod = Object[MethodName]
					if ObjectMethod then
						ObjectMethod(Object)
					end
				end

				self[Object] = nil
			end

			This[Index] = nil
		end
	end

	return self
end

function Janitor.__index:Get(Index)
	local This = self[IndicesReference]
	if This then
		return This[Index]
	end

	return nil
end

--[[**
	Calls each Object's `MethodName` (or calls the Object if `MethodName == true`) and removes them from the Janitor. Also clears the namespace. This function is also called when you call a Janitor Object (so it can be used as a destructor callback).
	@returns [t:void]
**--]]
function Janitor.__index:Cleanup()
	if not self.CurrentlyCleaning then
		self.CurrentlyCleaning = nil
		for Object, MethodName in next, self do
			if Object == IndicesReference then
				continue
			end

			-- Weird decision to rawset directly to the janitor in Agent. This should protect against it though.
			local TypeOf = type(Object)
			if TypeOf == "string" or TypeOf == "number" then
				self[Object] = nil
				continue
			end

			if MethodName == true then
				Object()
			else
				local ObjectMethod = Object[MethodName]
				if ObjectMethod then
					ObjectMethod(Object)
				end
			end

			self[Object] = nil
		end

		local This = self[IndicesReference]
		if This then
			for Index in next, This do
				This[Index] = nil
			end

			self[IndicesReference] = {}
		end

		self.CurrentlyCleaning = false
	end
end

Janitor.__index.Clean = Janitor.__index.Cleanup

--[[**
	Calls `:Cleanup()` and renders the Janitor unusable.
	@returns [t:void]
**--]]
function Janitor.__index:Destroy()
	self:Cleanup()
	--table.clear(self)
	--setmetatable(self, nil)
end

Janitor.__call = Janitor.__index.Cleanup

local Disconnect = { Connected = true }
Disconnect.__index = Disconnect
function Disconnect:Disconnect()
	if self.Connected then
		self.Connected = false
		self.Connection:Disconnect()
	end
end

function Disconnect:__tostring()
	return "Disconnect<" .. tostring(self.Connected) .. ">"
end

function Janitor.__index:LinkToInstance(Object, AllowMultiple)
	local Connection
	local IndexToUse = AllowMultiple and newproxy(false) or LinkToInstanceIndex
	local IsNilParented = Object.Parent == nil
	local ManualDisconnect = setmetatable({}, Disconnect)

	local function ChangedFunction(_DoNotUse, NewParent)
		if ManualDisconnect.Connected then
			_DoNotUse = nil
			IsNilParented = NewParent == nil

			if IsNilParented then
				coroutine.wrap(function()
					Heartbeat:Wait()
					if not ManualDisconnect.Connected then
						return
					elseif not Connection.Connected then
						self:Cleanup()
					else
						while
							IsNilParented
							and Connection.Connected
							and ManualDisconnect.Connected
						do
							Heartbeat:Wait()
						end

						if ManualDisconnect.Connected and IsNilParented then
							self:Cleanup()
						end
					end
				end)()
			end
		end
	end

	Connection = Object.AncestryChanged:Connect(ChangedFunction)
	ManualDisconnect.Connection = Connection

	if IsNilParented then
		ChangedFunction(nil, Object.Parent)
	end

	Object = nil
	return self:Add(ManualDisconnect, "Disconnect", IndexToUse)
end

function Janitor.__index:LinkToInstances(...)
	local ManualCleanup = Janitor.new()
	for _, Object in ipairs({ ... }) do
		ManualCleanup:Add(self:LinkToInstance(Object, true), "Disconnect")
	end

	return ManualCleanup
end

for FunctionName, Function in next, Janitor.__index do
	local NewFunctionName = string.sub(string.lower(FunctionName), 1, 1)
		.. string.sub(FunctionName, 2)
	Janitor.__index[NewFunctionName] = Function
end

return Janitor
