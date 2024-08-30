"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[3257],{89039:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Creates and returns a new remote property with the value of `initialValue`.\\n\\n- If the 2nd parameter `middleware` is not specified, then it will default to [DefaultRemotePropertyMiddleware] instead.\\n\\t\\n- If the 3rd parameter `remotePropertyConfig` is not specified, then it will default to [DefaultRemotePropertyConfig] instead. ","params":[{"name":"initialValue","desc":"","lua_type":"any"},{"name":"middleware","desc":"","lua_type":"RemotePropertyMiddleware?"},{"name":"remotePropertyConfig","desc":"","lua_type":"RemotePropertyConfig?"}],"returns":[{"desc":"","lua_type":"RemoteProperty\\r\\n"}],"function_type":"static","source":{"line":363,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"is","desc":"Returns a boolean indicating if `self` is a remote property or not.","params":[{"name":"self","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","source":{"line":407,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"get","desc":"Returns a shallow copy of the current value set for the remote property.","params":[],"returns":[{"desc":"","lua_type":"any\\r\\n"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":417,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"valuePromise","desc":"Returns a promise which is resolved with a non-nil value of the remote property, given\\nthat `valuePredicate` is not passed as an argument.\\n\\n```lua\\nremoteProperty:valuePromise():andThen(function(value)\\n\\tprint(value) \\nend)\\n```\\n\\n`valuePredicate` can also be passed, which allows you to filter out values. If it returns\\nexactly `true`, only then will the promise resolve with the new value.\\n\\n```lua\\nremoteProperty:valuePromise(function(newValue, oldValue) \\n\\treturn newValue == 10 and oldValue == 1\\nend):andThen(function(value)\\n\\tprint(value) \\nend)\\n\\nremoteProperty:set(1) \\nremoteProperty:set(10) \\n\\n--\x3e 10\\n```","params":[{"name":"valuePredicate","desc":"","lua_type":"(newValue: any, oldValue: any?) -> boolean\\r\\n"}],"returns":[{"desc":"","lua_type":"Promise<any>"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":451,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"setRateLimitForClientSettingValue","desc":"Rate limits the given client setting their own value by `rateLimit` seconds.\\n\\n:::note\\nThis specific rate limit set for this client will be **removed**\\nonce the client leaves the game.\\n:::\\n\\n```lua\\n-- Server\\nremoteProperty:setRateLimitForClientSettingValue(client, 30) -- 30 seconds\\n\\n-- Client\\nclientRemoteProperty.onUpdate:Connect(function(newValue)\\n\\tprint(newValue) \\nend)\\n\\n-- Spam the setting of value for the client, so we ought for the value of the \\n-- client stored in the remote property (finally) to be `100`, but instead\\n-- it will be `1`, as subsequent calls after the first one will be ignored\\n-- due to the rate limit imposed.\\nfor index = 1, 100 do\\n\\tclientRemoteProperty:set(index)\\nend\\n\\n--\x3e 1 \\n```","params":[{"name":"client","desc":"","lua_type":"Player"},{"name":"rateLimit","desc":"","lua_type":"number"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":488,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"setForClients","desc":"Calls [RemoteProperty:setForClient] for all clients in `clients`.","params":[{"name":"clients","desc":"","lua_type":"{ Player }"},{"name":"value","desc":"","lua_type":"T"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":498,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"setForClient","desc":"Sets the value of the remote property for `client` *specifically*, to `value`. This client\\nwill now no longer be receiving updates of the value *of the* remote property, and thus will only\\nbe receiving updates of their own specific value set in the remote property.\\n\\n:::note\\n[RemoteProperty:removeForClient] will be called for the given client whenever they leave the game, so\\nthat this value is cleared out for the player, and thus this helps prevent memory leaks.\\n:::\\n\\n:::warning Precaution!\\n- Setting the value for `client` to `nil` will **not** remove the client\'s value - call [RemoteProperty:removeForClient]\\nto do that.\\n\\n- This method will throw an error if you attempt to set a value for the client who are not present anymore\\nin the server (i.e not a descendant of [Players](https://create.roblox.com/docs/reference/engine/classes/Players))  - this is done to avoid memory leaks.\\n:::","params":[{"name":"client","desc":"","lua_type":"Player"},{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":525,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"removeForClient","desc":"Removes the value stored for `client` *specifically* in the remote property. This client will\\nnow be informed of the current value *of the* remote property and will now no longer be\\nreceiving updates of their specific value (that was previously set in the remote property, as\\nit has been removed), instead the client will start receiving updates of the value of the remote\\nproperty itself.","params":[{"name":"client","desc":"","lua_type":"Player"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":550,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"removeForClients","desc":"Iterates through `clients` and calls [RemoteProperty:removeForClient] for each client.","params":[{"name":"clients","desc":"","lua_type":"{ Player }"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":573,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"clientHasValueSet","desc":"Returns a boolean indicating if there is a specific value stored for `client` \\nin the remote property.","params":[{"name":"client","desc":"","lua_type":"Player"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":586,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"clientValue","desc":"Returns a shallow copy of value stored *specifically* for `client` in the remote property. ","params":[{"name":"client","desc":"","lua_type":"Player"}],"returns":[{"desc":"","lua_type":"any"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":597,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"clientValuePromise","desc":"Returns a promise which is resolved with a non-nil value of the value stored for the client in the remote property.\\n\\n```lua\\nremoteProperty:clientValuePromise(client):andThen(function(value)\\n\\tprint(value) \\nend)\\n```\\n\\n`valuePredicate` (an optional predicate), allows you to filter out values:\\n\\n```lua\\nremoteProperty:clientValuePromise(client, function(newValue, oldValue) \\n\\tprint(newValue, oldValue)\\n\\treturn oldValue == 1\\nend):andThen(function(value)\\n\\tprint(value) \\nend)\\n\\nremoteProperty:setForClient(client, 1) \\nremoteProperty:setForClient(client, 2) \\n\\n-- Output:\\n-- 1, nil\\n-- 2, 1\\n-- 2\\n```","params":[{"name":"client","desc":"","lua_type":"Player"},{"name":"valuePredicate","desc":"","lua_type":"(newValue: any, oldValue: any?) -> boolean\\r\\n"}],"returns":[{"desc":"","lua_type":"Promise<any>"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":634,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"set","desc":"Sets the value of the remote property to `value`. Clients who have a specific value set\\nwill not be informed of this new value of this remote property.","params":[{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":649,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"clientValueOnUpdateSignalForClient","desc":"Returns a signal that is fired whenever a value is set for the client, or the client\'s\\nspecific value is updated in the remote property (through [RemoteProperty:setForClient]).\\n\\n```lua\\nremoteProperty:clientValueOnUpdateSignalForClient(somePlayer):Connect(function(newValue, oldValue)\\n\\tprint(newValue, oldValue)\\nend)\\n\\nremoteProperty:setForClient(somePlayer, 1)\\n--\x3e 1, nil\\n```","params":[{"name":"client","desc":"","lua_type":"Player"}],"returns":[{"desc":"","lua_type":"Signal"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":670,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"observeClientValue","desc":"Observes the value of the given client stored in the remote property.\\n\\n```lua\\nremoteProperty:observeClientValue(somePlayer, function(newValue, oldValue)\\n\\tprint(newValue, oldValue) \\nend)\\n\\nremoteProperty:setForClient(somePlayer, 1)\\n--\x3e nil, nil\\n--\x3e 1, nil\\n```","params":[{"name":"client","desc":"","lua_type":"Player"},{"name":"callback","desc":"","lua_type":"(newValue: any, oldValue: any?) -> ()\\r\\n"}],"returns":[{"desc":"","lua_type":"Connection"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":692,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"observe","desc":"Observes the value of the remote property. \\n\\n```lua\\nlocal remoteProperty = RemoteProperty.new()\\nremoteProperty:observe(function(newValue, oldValue)\\n\\tprint(newValue, oldValue)\\nend)\\n\\nremoteProperty:set(1)\\n--\x3e nil, nil\\n--\x3e 1, nil\\n```","params":[{"name":"callback","desc":"","lua_type":"(newValue: any, oldValue: any?) -> ()"}],"returns":[{"desc":"","lua_type":"Connection"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":718,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"observeClientsValue","desc":"Observes the values set for clients in the remote property. \\n\\n```lua\\nlocal remoteProperty = RemoteProperty.new()\\nremoteProperty:observeClientsValue(function(client: Player, newValue, oldValue)\\n\\nend)\\n```","params":[{"name":"observer","desc":"","lua_type":"(\\r\\n\\tplayer: Player,\\r\\n\\tnewValue: any,\\r\\n\\toldValue: any?\\r\\n) -> ()"}],"returns":[{"desc":"","lua_type":"Connection"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":736,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"destroy","desc":"\\t\\nDestroys the remote property and renders it unusable. All clients who have a specific value\\nset for themselves in the remote property will be removed through [RemoteProperty:removeForClient].","params":[],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":755,"path":"src/network/Server/RemoteProperty.luau"}}],"properties":[{"name":"RejectClientSetRequest","desc":" \\n\\nA marker that can be passed from a `clientSet` middleware callback, to reject a client\'s request of setting\\nsome value (for themselves in the remote property).","lua_type":"\\"RejectClientSetRequest\\"","tags":["Read only"],"source":{"line":17,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"onUpdate","desc":" \\n\\t\\nA [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the value \\nof the remote property is set to a new one. The signal is only passed the new value as the only argument.\\n\\t","lua_type":"Signal <newValue: T, oldValue: T?>","tags":["Read only","Signal","RemoteProperty Instance"],"source":{"line":116,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"clientValueOnUpdate","desc":" \\n\\t\\nA [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the value \\nof `player` specifically in the remote property is set to a new one. The signal is passed the player \\nas the first argument, and the new specific value of `player` set in the remote property, as the second argument. \\n\\t","lua_type":"Signal <client: Player, newValue: T, oldValue: T?>","tags":["Read only","Signal","RemoteProperty Instance"],"source":{"line":128,"path":"src/network/Server/RemoteProperty.luau"}}],"types":[{"name":"DefaultRemotePropertyConfig","desc":" ","fields":[{"name":"automaticArgumentSerializationAndDeserializationEnabled","lua_type":"true","desc":""}],"source":{"line":23,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"DefaultRemotePropertyMiddleware","desc":"By default, `clientSet` contains a function which always returns [RejectClientSetRequest], in\\norder to reject the client\'s request of setting a value for themselves in the remote property, as this is a \\nsecurity risk, if by default, this behavior is allowed. Additionally, a warn is also produced in the output \\nto let you know of this.\\n\\nSo in order to allow clients to request the server to set their value, then you must define a middleware where `clientSet` contains\\n**at least** 1 function, for e.g;\\n\\n```lua\\nlocal remoteProperty = RemoteProperty.new({\\n\\tclientSet = {\\n\\t\\tfunction(_, _, valueFromClient) \\n\\t\\t\\treturn valueFromClient\\n\\t\\tend\\n\\t}\\n})\\n```","fields":[{"name":"clientSet","lua_type":"{...}","desc":""},{"name":"clientGet","lua_type":"{}","desc":""}],"source":{"line":48,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"RemotePropertyConfig","desc":" \\n\\t\\n- `automaticArgumentSerializationAndDeserializationEnabled` -> `true`\\n\\t- Arguments and values sent across the network by the remote property \\n\\twill be automatically serialized and deserialized respectively, with the\\n\\thelp of an internal library, i.e [serializerUtil](https://babypatrick100.github.io/libraries/api/serializerUtil/).\\n\\t\\n\\t:::note Serialization and deserialization limitations!\\n\\tWhile the serializer utility used to accomplish this supports a variety of data types, do keep in mind that not all data types\\n\\tcan be supported on the go for serialization and deserialization - check the above hyperlink to the serializer utility on how\\n\\tmany data types it supports.\\n\\t::::\\n\\t\\n\\t**See the type of the value of the remote property being `TweenInfo` on the client**:\\n\\t\\n\\t```lua\\n\\t-- Server\\n\\tlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\n\\tlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\n\\tlocal remoteProperty = network.Server.RemoteProperty.new(TweenInfo.new())\\n\\ttestNetwork:append(\\"remoteProperty\\",  remoteProperty) \\n\\ttestNetwork:dispatch(Workspace)\\n\\t\\n\\t-- Client\\n\\tlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\n\\tlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\n\\tprint(typeof(testNetwork.remoteProperty:get())) --\x3e \\"TweenInfo\\"\\n\\t```\\n\\n- `automaticArgumentSerializationAndDeserializationEnabled` -> `false`\\n\\t- Arguments and values sent across the network will not be internally serialized\\n\\tand deserialized. Using the same example as above:\\n\\t\\n\\t**See the type of the value of the remote property being `table` on the client instead of `TweenInfo`**:\\n\\t\\n\\t```lua\\n\\t-- Server\\n\\tlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\n\\tlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\n\\tlocal remoteProperty = network.Server.RemoteProperty.new(TweenInfo.new())\\n\\ttestNetwork:append(\\"remoteProperty\\",  remoteProperty) \\n\\ttestNetwork:dispatch(Workspace)\\n\\t\\n\\t-- Client\\n\\tlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\n\\tlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\n\\tprint(typeof(testNetwork.remoteProperty:get())) --\x3e \\"table\\"\\n\\t```\\n\\t","fields":[{"name":"automaticArgumentSerializationAndDeserializationEnabled","lua_type":"boolean","desc":"determines whether or not values sent to clients by the remote signal be internally serialized/deserialized or not."}],"source":{"line":105,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"RemoteProperty","desc":" ","lua_type":"RemoteProperty","source":{"line":133,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"RemoteProperty","desc":" ","lua_type":"RemoteProperty","source":{"line":138,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"Observer","desc":" ","lua_type":"(newValue: T, oldValue: T?) -> ()","source":{"line":143,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"RemotePropertyMiddleware","desc":"\\t\\n:::warning Yielding in middleware callbacks is not allowed\\nMiddleware callbacks aren\'t allowed to yield. If they do so, their thread will be closed via\\n[coroutine.close](https://create.roblox.com/docs/reference/engine/libraries/coroutine#close) and an\\nerror will be outputted in the console.\\n\\nYielding, (especially in network-related code) results in weird bugs and behavior which can be hard to track down!\\n:::\\n\\t\\n### clientSet\\n\\t\\nCallbacks in `clientSet` are called whenever the client tries to set the value of the remote property\\n*for themselves specifically*.\\n\\t\\nThe first argument passed to each callback is a reference to the remote property itself,\\nfollowed by the client object and the value the client is trying to set.\\n\\t\\n```lua\\nlocal clientSetCallbacks = {\\n\\tfunction (remoteProperty, client, value)\\n\\t\\tprint(RemoteProperty.is(remoteProperty)) --\x3e true\\n\\t\\tprint(client:IsA(\\"Player\\")) --\x3e true \\n\\tend\\n}\\n---\\n```\\n\\t\\n:::tip More control\\nA `clientSet` callback can return a **non-nil** value, which will then be set as the value for the client in the remote property.\\nThis is useful in cases where you want to have more control over what values the client can set for themseves in the remote\\nproperty.\\n\\nFor e.g:\\n\\t\\n```lua\\n-- Server\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\nlocal testRemoteProperty = network.Server.RemoteProperty.new(50, {\\n\\tclientSet = {function() return \\"rickrolled\\" end}\\n})\\n\\t\\nlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\ntestNetwork:append(\\"property\\", testRemoteProperty)\\ntestNetwork:dispatch(Workspace)\\n\\t\\n-- Client\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\nlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\ntestNetwork.property:set(1)\\nprint(testNetwork.property.onUpdate:Wait()) --\x3e \\"rickrolled\\" (This ought to print 1, but our middleware returned a custom value!)\\n```\\n\\nYou can also return [RejectClientSetRequest] from a `clientSet` middleware callback, in order to reject the client\'s\\nrequest of setting a value for themselves in the remote property.\\n\\t\\nAdditionally, if more than 1 callback returns a value, then all those returned values will be packed into an array and *then* sent\\nback to the client. This is by design - as it isn\'t ideal to disregard all returned values for just 1. \\n\\nFor e.g:\\n\\t\\n```lua\\n-- Server\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\nlocal testRemoteProperty = network.Server.RemoteProperty.new(50, {\\n\\tclientSet = {\\n\\t\\tfunction() return \\"rickrolled\\" end,\\n\\t\\tfunction() return \\"oof\\" end,\\n\\t\\tfunction() return \\"hello\\" end\\n\\t}\\n})\\n\\t\\nlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\ntestNetwork:append(\\"property\\", testRemoteProperty)\\ntestNetwork:dispatch(Workspace)\\n\\t\\n-- Client\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\nlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\ntestNetwork.property:set(1)\\nprint(testNetwork.property.onUpdate:Wait()) --\x3e {\\"oofed\\", \\"rickrolled\\", \\"hello\\"} \\n```\\n\\nIf any of the `clientSet` middleware callbacks return [RejectClientSetRequest], then the client\'s\\nrequest of setting a value for themselves in the remote property, will be rejected.\\n:::\\n\\t\\n### clientGet\\n\\t\\nCallbacks in `clientGet` are called whenever the client tries to get the value of the remote property.\\n\\t\\nThe first argument passed to each callback is a reference to the remote property itself, which is followed by the client object.\\n\\t\\n```lua\\nlocal clientGetCallbacks = {\\n\\tfunction (remoteProperty, client)\\n\\t\\tprint(client:IsA(\\"Player\\")) --\x3e true\\n\\tend\\n}\\n---\\n```\\n\\n:::tip More control\\nA callback can return a non-nil value, which will then be returned to the client. This is useful in cases where you want to\\nhave more control over what values the client can retrieve from the remote property.\\n\\nFor e.g:\\n\\t\\n```lua\\n-- Server\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\nlocal testRemoteProperty = network.Server.RemoteProperty.new(5000, {\\n\\tclientGet = {function() return \\"rickrolled\\" end}\\n})\\n\\t\\nlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\ntestNetwork:append(\\"property\\", testRemoteProperty)\\ntestNetwork:dispatch(Workspace)\\n\\t\\n-- Client\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\nlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\nprint(testNetwork.property:get()) --\x3e \\"rickrolled\\" (This ought to print 5000, but our middleware returned a custom value!)\\n```\\n\\t\\nAdditionally, if more than 1 callback returns a value, then all those returned values will be packed into an array and *then* sent\\nback to the client. This is by design - as it isn\'t ideal to disregard all returned values for just 1. \\n\\nFor e.g:\\n\\t\\n```lua\\n-- Server\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\nlocal testRemoteProperty = network.Server.RemoteProperty.new(50, {\\n\\tclientGet = {\\n\\t\\tfunction() return \\"rickrolled\\" end,\\n\\t\\tfunction() return \\"oof\\" end,\\n\\t\\tfunction() return \\"hello\\" end\\n\\t}\\n})\\n\\t\\nlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\ntestNetwork:append(\\"property\\", testRemoteProperty)\\ntestNetwork:dispatch(Workspace)\\n\\t\\n-- Client\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\nlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\nprint(testNetwork.property:get()) --\x3e {\\"oofed\\", \\"rickrolled\\", \\"hello\\"} \\n```\\n:::\\n\\t","fields":[{"name":"clientSet","lua_type":"{ (client: Player, value: any) -> any }?,","desc":""},{"name":"clientGet","lua_type":"{ (client: Player) -> any }?,","desc":""}],"source":{"line":308,"path":"src/network/Server/RemoteProperty.luau"}}],"name":"RemoteProperty","desc":"A remote property in layman\'s terms is simply an  object which can store some global\\nvalue as well as values specific to players. ","realm":["Server"],"source":{"line":8,"path":"src/network/Server/RemoteProperty.luau"}}')}}]);