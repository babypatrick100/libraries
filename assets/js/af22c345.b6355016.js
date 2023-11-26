"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[1120],{89039:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Creates and returns a new remote property with the value of `initialValue`.\\n\\t\\n- If the 2nd parameter `middleware` is not specified, then it will default to [DefaultRemotePropertyMiddleware] instead.\\n\\n- If the 3rd parameter `config` is not specified, then it will default to [DefaultRemotePropertyConfig] instead. \\n\\t","params":[{"name":"initialValue","desc":"","lua_type":"T"},{"name":"middleware","desc":"","lua_type":"RemotePropertyMiddleware<T>?"},{"name":"config","desc":"","lua_type":"RemotePropertyConfig?\\n"}],"returns":[{"desc":"","lua_type":"RemoteProperty<T>\\n"}],"function_type":"static","source":{"line":390,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"is","desc":"Returns a boolean indicating if `self` is a remote property or not.\\n\\t","params":[{"name":"self","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"boolean\\n"}],"function_type":"static","source":{"line":427,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"get","desc":"\\t\\nReturns a shallow copy of the current value set for the remote property.\\n\\t","params":[],"returns":[{"desc":"","lua_type":"any"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":438,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"valuePromise","desc":"\\t\\nReturns a promise which is resolved with a non-nil value of the remote property.\\n\\t\\n```lua\\nremoteProperty:valuePromise():andThen(function(value)\\n\\tprint(value) \\nend)\\n```\\n\\t\\n`valuePredicate` (an optional predicate), allows you to filter out values:\\n\\t\\n```lua\\nremoteProperty:valuePromise(function(newValue, oldValue) \\n\\tprint(newValue, oldValue)\\n\\treturn oldValue == 1\\nend):andThen(function(value)\\n\\tprint(value) \\nend)\\n\\t\\nremoteProperty:set(1) \\nremoteProperty:set(2) \\n\\t\\n-- Output:\\n-- 1, nil\\n-- 2, 1\\n-- 2\\n```\\n\\t","params":[{"name":"valuePredicate","desc":"","lua_type":"RemotePropertyValuePredicate?"}],"returns":[{"desc":"","lua_type":"Promise<any>"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":474,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"setRateLimitForClientSettingValue","desc":"\\t\\nRate limits the given client setting their own value by `rateLimit` seconds.\\n\\t\\n:::note\\nThis specific rate limit set for this client will be **removed**\\nonce the client leaves the game.\\n:::\\n\\t\\n```lua\\n-- Server\\nremoteProperty:setRateLimitForClientSettingValue(client, 30) -- 30 seconds\\n\\t\\n-- Client\\nclientRemoteProperty.onUpdate:Connect(function(newValue)\\n\\tprint(newValue) \\nend)\\n\\t\\n-- Spam the setting of value for the client, so we ought for the value of the \\n-- client stored in the remote property (finally) to be `100`, but instead\\n-- it will be `1`, as subsequent calls after the first one will be ignored\\n-- due to the rate limit imposed.\\nfor index = 1, 100 do\\n\\tclientRemoteProperty:set(index)\\nend\\n\\t\\n--\x3e 1 \\n```\\n\\t","params":[{"name":"client","desc":"","lua_type":"Player"},{"name":"rateLimit","desc":"","lua_type":"number"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":509,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"setForClients","desc":"\\t\\nCalls [RemoteProperty:setForClient] for all clients in `clients`.\\n\\t","params":[{"name":"clients","desc":"","lua_type":"{ Player }"},{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":519,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"bulkSetForClients","desc":"\\t\\nCalls [RemoteProperty:bulkSetForClient] for all clients in `clients`.\\n\\t","params":[{"name":"clients","desc":"","lua_type":"{ Player }"},{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":531,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"setForClient","desc":"\\t\\nSets the value of the remote property for `client` *specifically*, to `value`. This client\\nwill now no longer be receiving updates of the value *of the* remote property, and thus will only\\nbe receiving updates of their own specific value set in the remote property.\\n\\t\\n:::warning Precaution!\\n- Setting the value for `client` to `nil` will **not** remove the client\'s value - call [RemoteProperty:removeForClient]\\nto do that.\\n:::\\n\\t\\n:::warning Potential Memory Leak!\\n- A new internal [Property]() object will be created for the given client to house this specific\\nvalue - make sure to call [RemoteProperty:removeForClient] -- (when the client leaves the game or when\\nyou no longer need the specific value), for memory cleaning.\\n\\t\\n- This method will throw an error if you attempt to set a value for the client who are not present anymore\\nin the server (i.e not a descendant of [Players](https://create.roblox.com/docs/reference/engine/classes/Players))  - this is done to avoid memory leaks.\\n:::\\n\\t","params":[{"name":"client","desc":"","lua_type":"Player"},{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":559,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"bulkSetForClient","desc":"\\t\\nWorks the same as [RemoteProperty.setForClient], but does not inform the client of this new value\\nset for them (this **does not** mean the client will not have access to this new value, but instead\\nthe client will not receive a signal that their value updated - they can still access this value manually\\nthrough [ClientRemoteProperty:get].\\n\\t\\n:::warning Precaution!\\nSetting the value for `client` to `nil` will **not** remove the client\'s value - call [RemoteProperty:removeForClient]\\nto do that.\\n:::\\n\\t\\n:::warning Potential Memory Leak!\\n- A new internal [Property]() object will be created for the given client to house this specific\\nvalue - make sure to call [RemoteProperty:removeForClient] -- (when the client leaves the game or when\\nyou no longer need the specific value), for memory cleaning.\\n\\t\\n- This method will throw an error if you attempt to set a value for the client who are not present anymore\\nin the server (i.e not a descendant of [Players](https://create.roblox.com/docs/reference/engine/classes/Players)) - this is done to avoid memory leaks.\\n:::\\n\\t","params":[{"name":"client","desc":"","lua_type":"Player"},{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":597,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"removeForClient","desc":"\\t\\nRemoves the value stored for `client` *specifically* in the remote property. This client will\\nnow be informed of the current value *of the* remote property and will now no longer be\\nreceiving updates of their specific value (that was previously set in the remote property, as\\nit has been removed), instead the client will start receiving updates of the value of the remote\\nproperty itself.\\n\\t","params":[{"name":"client","desc":"","lua_type":"Player"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":622,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"removeForClients","desc":"\\t\\nIterates through `clients` and calls [RemoteProperty:removeForClient] for each client.\\n\\t","params":[{"name":"clients","desc":"","lua_type":"{ Player }"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":645,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"clientHasValueSet","desc":"\\t\\nReturns a boolean indicating if there is a specific value stored for `client` \\nin the remote property.\\n\\t","params":[{"name":"client","desc":"","lua_type":"Player"}],"returns":[{"desc":"","lua_type":"boolean\\n"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":658,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"clientValue","desc":"\\t\\nReturns a shallow copy of value stored *specifically* for `client` in the remote property. \\n\\t","params":[{"name":"client","desc":"","lua_type":"Player"}],"returns":[{"desc":"","lua_type":"any\\n"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":668,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"clientValuePromise","desc":"\\t\\nReturns a promise which is resolved with a non-nil value of the value stored for the client in the remote property.\\n\\t\\n```lua\\nremoteProperty:clientValuePromise(client):andThen(function(value)\\n\\tprint(value) \\nend)\\n```\\n\\t\\n`valuePredicate` (an optional predicate), allows you to filter out values:\\n\\t\\n```lua\\nremoteProperty:clientValuePromise(client, function(newValue, oldValue) \\n\\tprint(newValue, oldValue)\\n\\treturn oldValue == 1\\nend):andThen(function(value)\\n\\tprint(value) \\nend)\\n\\t\\nremoteProperty:setForClient(client, 1) \\nremoteProperty:setForClient(client, 2) \\n\\t\\n-- Output:\\n-- 1, nil\\n-- 2, 1\\n-- 2\\n```\\n\\t","params":[{"name":"client","desc":"","lua_type":"Player"},{"name":"valuePredicate","desc":"","lua_type":"RemotePropertyValuePredicate?\\n"}],"returns":[{"desc":"","lua_type":"Promise<any>"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":705,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"set","desc":"\\t\\nSets the value of the remote property to `value`. Clients who have a specific value set\\nwill not be informed of this new value of this remote property.\\n\\t","params":[{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":720,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"bulkSet","desc":"\\t\\nWorks the same as [RemoteProperty:set] but does not fire off any on update signals.\\n\\t","params":[{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":730,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"clientValueOnUpdateSignalForClient","desc":"\\t\\nReturns a signal that is fired whenever a value is set for the client, or the client\'s\\nspecific value is updated in the remote property.\\n\\t\\n```lua\\nremoteProperty:clientValueOnUpdateSignalForClient(somePlayer):Connect(function(newValue, oldValue)\\n\\tprint(newValue, oldValue) \\t\\t\\t\\t\\t\\t\\t\\nend)\\n\\t\\nremoteProperty:setForClient(somePlayer, 1)\\n--\x3e nil, nil\\n--\x3e 1, nil\\n```\\n\\t","params":[{"name":"client","desc":"","lua_type":"Player"}],"returns":[{"desc":"","lua_type":"Signal"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":752,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"observeClientValue","desc":"\\t\\nObserves the value of the given client stored in the remote property.\\n\\t\\n```lua\\nremoteProperty:observeClientValue(somePlayer, function(newValue, oldValue)\\n\\tprint(newValue, oldValue) --\x3e 1, nil\\nend)\\n\\t\\nremoteProperty:setForClient(somePlayer, 1)\\n--\x3e nil, nil\\n--\x3e 1, nil\\n```\\n\\t","params":[{"name":"client","desc":"","lua_type":"Player"},{"name":"callback","desc":"","lua_type":"RemotePropertyOnUpdateCallback\\n"}],"returns":[{"desc":"","lua_type":"RBXScriptConnection"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":774,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"observe","desc":"\\t\\nObserves the value of the remote property. \\n\\t\\n```lua\\nlocal remoteProperty = RemoteProperty.new()\\nremoteProperty:observe(function(newValue, oldValue)\\n\\tprint(newValue, oldValue)\\nend)\\n\\t\\nremoteProperty:set(1)\\n--\x3e nil, nil\\n--\x3e 1, nil\\n```\\n\\t","params":[{"name":"callback","desc":"","lua_type":"RemotePropertyOnUpdateCallback"}],"returns":[{"desc":"","lua_type":"RBXScriptConnection"}],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":800,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"destroy","desc":"Destroys the remote property and renders it unusable. All clients who have a specific value\\nset for themselves in the remote property will be removed through [RemoteProperty:removeForClient].\\n\\t","params":[],"returns":[],"function_type":"method","tags":["RemoteProperty instance"],"source":{"line":811,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"dispatch","desc":"\\t","params":[{"name":"name","desc":"","lua_type":"string"},{"name":"parent","desc":"","lua_type":"Instance"}],"returns":[],"function_type":"method","private":true,"source":{"line":819,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"_bulkSetForClientRaw","desc":"\\t","params":[{"name":"client","desc":"","lua_type":"Player"},{"name":"value","desc":"","lua_type":"any"},{"name":"rawData","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","private":true,"source":{"line":942,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"_clientProperty","desc":"\\t","params":[{"name":"client","desc":"","lua_type":"Player"}],"returns":[],"function_type":"method","private":true,"source":{"line":955,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"_init","desc":"\\t","params":[],"returns":[],"function_type":"method","private":true,"source":{"line":978,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"__tostring","desc":"","params":[],"returns":[],"function_type":"method","private":true,"source":{"line":1001,"path":"src/network/Server/RemoteProperty.luau"}}],"properties":[{"name":"RejectClientSetRequest","desc":" \\n\\nA marker that can be passed from a callback specified in the `clientSet` middleware of a remote property,\\nto reject the client\'s request of setting some value (for themselves in the remote property).","lua_type":"string","tags":["Read only"],"source":{"line":16,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"onUpdate","desc":" \\n\\t\\nA [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the value \\nof the remote property is set to a new one. The signal is only passed the new value as the only argument.\\n\\t","lua_type":"Signal <newValue: any, oldValue: any?>","tags":["Read only","Signal","RemoteProperty Instance"],"source":{"line":135,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"clientValueOnUpdate","desc":" \\n\\t\\nA [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the value \\nof `player` specifically in the remote property is set to a new one. The signal is passed the player \\nas the first argument, and the new specific value of `player` set in the remote property, as the second argument. \\n\\t","lua_type":"Signal <client: Player, newValue: any, oldValue: any?>","tags":["Read only","Signal","RemoteProperty Instance"],"source":{"line":147,"path":"src/network/Server/RemoteProperty.luau"}}],"types":[{"name":"DefaultRemotePropertyConfig","desc":" ","fields":[{"name":"automaticArgumentSerializationAndDeserializationEnabled","lua_type":"true","desc":""}],"source":{"line":22,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"DefaultRemotePropertyMiddleware","desc":"By default, `clientSet` contains a function which always returns [RejectClientSetRequest], in\\norder to reject the client\'s request of setting a value for themselves in the remote property, as this is a \\nsecurity risk, if by default, this behavior is allowed. Additionally, a warn is also produced in the output \\nto let you know of this.\\n\\nThe default middleware template is defined as follows:\\n\\n```lua\\nlocal DEFAULT_MIDDLEWARE_TEMPLATE = {\\n\\tclientSet = {\\n\\t\\tfunction(remoteProperty, client: Player, newValue) \\n\\t\\t\\twarn(\\n\\t\\t\\t\\tstring.format(\\n\\t\\t\\t\\t\\t\'[%s]: Client \\"%s\\" attempted to set their value (new value: %s). Request has been rejected for security, please specify a \\"clientSet\\" middleware containing at least 1 function to allow this.\',\\n\\t\\t\\t\\t\\t\\ttostring(remoteProperty),\\n\\t\\t\\t\\t\\t\\tclient.Name,\\n\\t\\t\\t\\t\\t\\ttostring(newValue)\\n\\t\\t\\t\\t\\t)\\n\\t\\t\\t\\t)\\n\\t\\t\\t\\treturn REJECT_CLIENT_SET_REQUEST_MARKER\\n\\t\\t\\tend\\n\\t\\t},\\n\\t\\tclientGet = {}\\n\\t}\\n\\t```\\n\\n\\tIn order to allow clients to request the server to set their value, then you must define a middleware where `clientSet` contains\\n\\t**at least** 1 function, for e.g;\\n\\n\\t```lua\\n\\tlocal remoteProperty = RemoteProperty.new({\\n\\t\\tclientSet = {\\n\\t\\t\\tfunction(_, _, valueFromClient) \\n\\t\\t\\t\\treturn valueFromClient\\n\\t\\t\\tend\\n\\t\\t}\\n\\t})\\n\\t```","fields":[{"name":"clientSet","lua_type":"{...}","desc":""},{"name":"clientGet","lua_type":"{}","desc":""}],"source":{"line":68,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"RemotePropertyConfig","desc":" \\n\\t\\n- `automaticArgumentSerializationAndDeserializationEnabled` -> `true`\\n\\t- Arguments and values sent across the network by the remote property \\n\\twill be automatically serialized and deserialized respectively, with the\\n\\thelp of an internal library, i.e [serializerUtil](https://bubshurb.github.io/libraries/api/serializerUtil/).\\n\\t\\n\\t::note Serialization and deserialization limitations!\\n\\tWhile the serializer utility used to accomplish this supports a variety of data types, do keep in mind that not all data types\\n\\tcan be supported on the go for serialization and deserialization - check the above hyperlink to the serializer utility on how\\n\\tmany data types it supports.\\n\\t::::\\n\\t\\n\\t**See the type of the value of the remote property being `TweenInfo` on the client**:\\n\\t\\n\\t```lua\\n\\t-- Server\\n\\tlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\n\\tlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\n\\tlocal remoteProperty = network.Server.RemoteProperty.new(TweenInfo.new())\\n\\ttestNetwork:append(\\"remoteProperty\\",  remoteProperty) \\n\\ttestNetwork:dispatch(Workspace)\\n\\t\\n\\t-- Client\\n\\tlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\n\\tlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\n\\tprint(typeof(testNetwork.remoteProperty:get())) --\x3e \\"TweenInfo\\"\\n\\t```\\n- `automaticArgumentSerializationAndDeserializationEnabled` -> `false`\\n\\t- Arguments and values sent across the network will not be internally serialized\\n\\tand deserialized. Using the same example as above:\\n\\t\\n\\t**See the type of the value of the remote property being `table` on the client instead of `TweenInfo`**:\\n\\t\\n\\t```lua\\n\\t-- Server\\n\\tlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\n\\tlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\n\\tlocal remoteProperty = network.Server.RemoteProperty.new(TweenInfo.new())\\n\\ttestNetwork:append(\\"remoteProperty\\",  remoteProperty) \\n\\ttestNetwork:dispatch(Workspace)\\n\\t\\n\\t-- Client\\n\\tlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\n\\tlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\n\\tprint(typeof(testNetwork.remoteProperty:get())) --\x3e \\"table\\"\\n\\t```\\n\\t","fields":[{"name":"automaticArgumentSerializationAndDeserializationEnabled","lua_type":"boolean","desc":"determines whether or not values sent to clients by the remote signal be internally serialized/deserialized or not."}],"source":{"line":124,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"RemoteProperty","desc":" \\n\\t","lua_type":"RemoteProperty<T>","source":{"line":152,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"RemotePropertyOnUpdateCallback","desc":" \\n\\t","lua_type":"(newValue: any, oldValue: any) -> ()","source":{"line":157,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"RemotePropertyValuePredicate","desc":" \\n\\t","lua_type":"(newValue: any, oldValue: any) -> boolean","source":{"line":162,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"RemotePropertyMiddleware","desc":"\\t\\n`clientSet` and `clientGet` must be an array of callbacks, if specified.\\n\\t\\n:::warning Yielding in middleware callbacks is not allowed\\nMiddleware callbacks aren\'t allowed to yield. If they do so, their thread will be closed via\\n[coroutine.close](https://create.roblox.com/docs/reference/engine/libraries/coroutine#close) and an\\nerror will be outputted in the console.\\n\\t\\nYielding, (especially in network-related code) results in weird bugs and behavior which can be hard to track down!\\n:::\\n\\t\\n### clientSet\\n\\t\\nCallbacks in `clientSet` are called whenever the client tries to set the value of the remote property\\n*for themselves specifically*.\\n\\t\\nThe first argument passed to each callback is a reference to the remote property itself,\\nwhich is followed by the client object and the value the client is trying to set.\\n\\t\\n```lua\\nlocal clientSetCallbacks = {\\n\\tfunction (remoteProperty, client, value)\\n\\t\\tprint(RemoteProperty.is(remoteProperty)) --\x3e true\\n\\t\\tprint(client:IsA(\\"Player\\")) --\x3e true \\n\\tend\\n}\\n---\\n```\\n\\t\\n:::tip More control\\nA `clientSet` callback can return a **non-nil** value, which will then be set as the value for the client in the remote property.\\nThis is useful in cases where you want to have more control over what values the client can set for themseves in the remote\\nproperty.\\n\\nFor e.g:\\n\\t\\n```lua\\n-- Server\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\nlocal testRemoteProperty = network.Server.RemoteProperty.new(50, {\\n\\tclientSet = {function() return \\"rickrolled\\" end}\\n})\\n\\t\\nlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\ntestNetwork:append(\\"property\\", testRemoteProperty)\\ntestNetwork:dispatch(Workspace)\\n\\t\\n-- Client\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\nlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\ntestNetwork.property:set(1)\\nprint(testNetwork.property.onUpdate:Wait()) --\x3e \\"rickrolled\\" (This ought to print 1, but our middleware returned a custom value!)\\n```\\n\\nYou can also return [RejectClientSetRequest] from a `clientSet` middleware callback, in order to reject the client\'s\\nrequest of setting a value for themselves in the remote property.\\n\\t\\nAdditionally, if more than 1 callback returns a value, then all those returned values will be packed into an array and *then* sent\\nback to the client. This is by design - as it isn\'t ideal to disregard all returned values for just 1. \\n\\nFor e.g:\\n\\t\\n```lua\\n-- Server\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\nlocal testRemoteProperty = network.Server.RemoteProperty.new(50, {\\n\\tclientSet = {\\n\\t\\tfunction() return \\"rickrolled\\" end,\\n\\t\\tfunction() return \\"oof\\" end,\\n\\t\\tfunction() return \\"hello\\" end\\n\\t}\\n})\\n\\t\\nlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\ntestNetwork:append(\\"property\\", testRemoteProperty)\\ntestNetwork:dispatch(Workspace)\\n\\t\\n-- Client\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\nlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\ntestNetwork.property:set(1)\\nprint(testNetwork.property.onUpdate:Wait()) --\x3e {\\"oofed\\", \\"rickrolled\\", \\"hello\\"} \\n```\\n\\nIf any of the `clientSet` middleware callbacks return [RejectClientSetRequest], then the client\'s\\nrequest of setting a value for themselves in the remote property, will be rejected.\\n:::\\n\\t\\n### clientGet\\n\\t\\nCallbacks in `clientGet` are called whenever the client tries to get the value of the remote property.\\n\\t\\nThe first argument passed to each callback is a reference to the remote property itself, which is followed by the client object.\\n\\t\\n```lua\\nlocal clientGetCallbacks = {\\n\\tfunction (remoteProperty, client)\\n\\t\\tprint(client:IsA(\\"Player\\")) --\x3e true\\n\\tend\\n}\\n---\\n```\\n\\n:::tip More control\\nA callback can return a non-nil value, which will then be returned to the client. This is useful in cases where you want to\\nhave more control over what values the client can retrieve from the remote property.\\n\\nFor e.g:\\n\\t\\n```lua\\n-- Server\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\nlocal testRemoteProperty = network.Server.RemoteProperty.new(5000, {\\n\\tclientGet = {function() return \\"rickrolled\\" end}\\n})\\n\\t\\nlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\ntestNetwork:append(\\"property\\", testRemoteProperty)\\ntestNetwork:dispatch(Workspace)\\n\\t\\n-- Client\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\nlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\nprint(testNetwork.property:get()) --\x3e \\"rickrolled\\" (This ought to print 5000, but our middleware returned a custom value!)\\n```\\n\\t\\nAdditionally, if more than 1 callback returns a value, then all those returned values will be packed into an array and *then* sent\\nback to the client. This is by design - as it isn\'t ideal to disregard all returned values for just 1. \\n\\nFor e.g:\\n\\t\\n```lua\\n-- Server\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\nlocal testRemoteProperty = network.Server.RemoteProperty.new(50, {\\n\\tclientGet = {\\n\\t\\tfunction() return \\"rickrolled\\" end,\\n\\t\\tfunction() return \\"oof\\" end,\\n\\t\\tfunction() return \\"hello\\" end\\n\\t}\\n})\\n\\t\\nlocal testNetwork = network.Server.new(\\"TestNetwork\\")\\ntestNetwork:append(\\"property\\", testRemoteProperty)\\ntestNetwork:dispatch(Workspace)\\n\\t\\n-- Client\\nlocal Workspace = game:GetService(\\"Workspace\\")\\n\\t\\nlocal testNetwork = network.client.fromParent(\\"TestNetwork\\", Workspace):expect()\\nprint(testNetwork.property:get()) --\x3e {\\"oofed\\", \\"rickrolled\\", \\"hello\\"} \\n```\\n:::\\n\\t","fields":[{"name":"clientSet","lua_type":"{ (client: Player, value: any) -> any }?,","desc":""},{"name":"clientGet","lua_type":"{ (client: Player) -> any }?,","desc":""}],"source":{"line":329,"path":"src/network/Server/RemoteProperty.luau"}},{"name":"DefaultRemoteSignalConfig","desc":" ","fields":[{"name":"automaticArgumentSerializationAndDeserializationEnabled","lua_type":"true","desc":""},{"name":"globalRateLimit","lua_type":"0","desc":""},{"name":"useUnreliableRemoteEvent","lua_type":"false","desc":""}],"source":{"line":16,"path":"src/network/Server/RemoteSignal.luau"}}],"name":"RemoteProperty","desc":"A remote property in layman\'s terms is simply an  object which can store some value for \\nall players as well as store in values specific to players. ","source":{"line":7,"path":"src/network/Server/RemoteProperty.luau"}}')}}]);