local packages = script.Parent.Parent

local Janitor = require(packages.Janitor)
local Signal = require(packages.Signal)

export type Signal = typeof(Signal.new())
export type Janitor = typeof(Janitor.new())
export type SerializedArgs = { [any]: any }
export type RemoteEventOrUnreliable = RemoteEvent | UnreliableRemoteEvent
export type RemoteInstance = RemoteEventOrUnreliable | RemoteFunction
export type Callback = (...any) -> ...any

return nil
