"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[7892],{1973:e=>{e.exports=JSON.parse('{"functions":[{"name":"storeInstanceSnapshot","desc":"This method will capture the \\"snapshot\\" of `instance` and store it within\\nthe instance it self via attributes. This method is to be used in conjuction with \\n[instanceReplicationUtil.instanceSnaphot].","params":[{"name":"instance","desc":"","lua_type":"Instance"}],"returns":[],"function_type":"static","source":{"line":73,"path":"src/instanceReplicationUtil/init.luau"}},{"name":"instanceSnaphot","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved once `instance` has it\'s snapshot available.\\n\\n:::warning Instance snapshot required\\nThis method will throw an error if [instanceUtil.storeInstanceSnapshot] has not been called on `instance`!\\n:::\\n\\n:::tip Waiting for an instance\'s descendants on the client\\nThis utility module comes in handy in cases where the client has access to\\nsome instance but with no guarantee whether it has fully replicated by the \\nserver or not. We can quite easily solve this problem! \\n\\nFirst we\'ll have the server store the snapshot of the instance within the instance it self:\\n\\n```lua\\ninstanceReplicationUtil.storeInstanceSnapshot(workspace.Model)\\n```\\n\\nThen on the client, we\'ll simply wait for the instance\'s snapshot to be \\navailable:\\n\\n```lua\\ninstanceReplicationUtil.instanceSnaphot(workspace.Model):andThen(function()\\n    -- At this point, you can safely access everything within workspace.Model!\\n    print(workspace.Model.SomeChild) \\nend)\\n```\\n\\n### Known Limitations\\n\\n- a) `storeInstanceSnapshot` stores the snapshot of the given instance within\\nthe instance it self, through **attributes**. This means that at any point, the\\ninstance can simply have its attributes cleared away (e.g by the developer) which\\nwill break the implementation, however do note that this will usually be a sign \\nof developer error, so you need to be careful with this!\\n\\n- b) You need to ensure that the server calls `storeInstanceSnapshot` on the given\\ninstance **before** the client actually uses `instanceSnaphot` to wait\\nfor the replication of the instance\'s snapshot, since `instanceSnaphot`\\nexpects the given instance to have it\'s snapshot stored within the instance already.\\n\\n- c) There is a limit as to how many attributes an instance can have, however the limit is very large so this\\nis really nothing to worry about.\\n:::","params":[{"name":"instance","desc":"","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"Promise<>"}],"function_type":"static","source":{"line":131,"path":"src/instanceReplicationUtil/init.luau"}}],"properties":[],"types":[],"name":"instanceReplicationUtil","desc":" \\n\\nAn utility module for working with instance replication.\\n \\n```lua\\n-- GOAL: Create a model with a part, and ensure that the model is fully\\n-- replicated to the client by the time the client accesses it.\\n\\n-- Server:\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\nlocal model = Instance.new(\\"Model\\")\\nlocal part1 = Instance.new(\\"Part\\")\\npart1.Name = \\"Part1\\"\\npart1.Parent = model\\nmodel.Parent = Workspace\\n\\n-- storeInstanceSnapshot will capture the \\"snapshot\\" of the model and \\n-- store it within the model it self via attributes.\\ninstanceReplicationUtil.storeInstanceSnapshot(model)\\n\\n-- Client:\\n\\n-- instanceSnaphot will return a [promise](https://eryn.io/roblox-lua-promise/) which will be resolved once\\n-- the model\'s snapshot (stored within the model by storeInstanceSnapshot)\\n-- is ready.\\ninstanceReplicationUtil.instanceSnaphot(workspace.Model):andThen(function()\\n    -- Safely access the part without worrying if it has successfuly replicated\\n    -- or not!\\n    print(workspace.Model.Part1)\\nend)\\n```\\n\\n:::note Possible deprecation\\nThis module is superseded by [StreamingEnabled](https://create.roblox.com/docs/workspace/streaming) (if used properly) \\n- you can set the `ModelStreamingMode` of models to `Atomic` to ensure all their descendants are loaded once the main model\\nis loaded into the client.\\n:::","source":{"line":41,"path":"src/instanceReplicationUtil/init.luau"}}')}}]);