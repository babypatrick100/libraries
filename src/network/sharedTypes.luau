local packages = script.Parent.Parent

local Janitor = require(packages.Janitor)
local Signal = require(packages.Signal)

export type Signal = typeof(Signal.new())
export type Janitor = typeof(Janitor.new())

return nil