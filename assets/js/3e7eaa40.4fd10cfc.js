"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[7301],{66424:e=>{e.exports=JSON.parse('{"functions":[{"name":"corners","desc":"Returns a read-only dictionary of all corners of `basePart`, top and bottom.","params":[{"name":"basePart","desc":"","lua_type":"BasePart"}],"returns":[{"desc":"","lua_type":"{ top: { Vector3 }, bottom: { Vector3 } }\\n"}],"function_type":"static","source":{"line":51,"path":"src/basePartUtil/init.luau"}},{"name":"floorMaterial","desc":"Returns the material the basePart is lying on. If `basePart` is underwater, then `Enum.Material.Water` will be returned, elseif\\n`basePart` is in air, then `Enum.Material.Air` will be returned.\\n\\n- The 2nd argument can be passed as a [RaycastParams](https://create.roblox.com/docs/reference/engine/datatypes/RaycastParams) object,\\nwhich will be used in determining the material of `basePart` through ray casting.\\n\\t \\n- The 3rd argument can be passed as a number (depth) which will increase the length \\nof the ray by `depth` studs (on the Y-axis). This is only useful when you want to add \\nin more leeway in determining the material of `basePart` **reliably**, since sometimes\\nthe basePart may be very slightly over the top of some ground due to its geometry so in those cases,\\nthe ray may not register properly. If this argument isn\'t specified, then it will default to `0.01`.","params":[{"name":"basePart","desc":"","lua_type":"BasePart"},{"name":"raycastParams","desc":"","lua_type":"RaycastParams?"},{"name":"depth","desc":"","lua_type":"number?\\n"}],"returns":[{"desc":"","lua_type":"Enum.Material\\n"}],"function_type":"static","source":{"line":92,"path":"src/basePartUtil/init.luau"}}],"properties":[],"types":[],"name":"basePartUtil","desc":" \\n\\nAn utility module for working with base parts.","source":{"line":6,"path":"src/basePartUtil/init.luau"}}')}}]);