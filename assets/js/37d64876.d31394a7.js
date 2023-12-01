"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[6e3],{58320:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"","params":[{"name":"remoteFunction","desc":"","lua_type":"RemoteFunction"}],"returns":[{"desc":"","lua_type":"ClientRemoteProperty<T>\\r\\n"}],"function_type":"static","private":true,"source":{"line":46,"path":"src/network/client/ClientRemoteProperty.luau"}},{"name":"is","desc":"Returns a boolean indicating if `self` is a client remote property or not.","params":[{"name":"self","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","source":{"line":65,"path":"src/network/client/ClientRemoteProperty.luau"}},{"name":"get","desc":"Returns the value of the client stored in the remote property. If there is no value stored specifically for the client, \\nthen the remote property\'s current value will be returned instead.","params":[],"returns":[{"desc":"","lua_type":"any"}],"function_type":"method","tags":["ClientRemoteProperty instance"],"source":{"line":77,"path":"src/network/client/ClientRemoteProperty.luau"}},{"name":"observe","desc":"Observes the value of the client remote property. \\n\\n```lua\\nclientRemoteProperty:observe(function(newValue, oldValue)\\n\\t\\nend)\\n```","params":[{"name":"callback","desc":"","lua_type":"(newValue: any, oldValue: any) -> ()"}],"returns":[],"function_type":"method","tags":["ClientRemoteProperty instance"],"source":{"line":93,"path":"src/network/client/ClientRemoteProperty.luau"}},{"name":"valuePromise","desc":"Returns a promise which is resolved with a non-nil value of the client remote property, given\\nthat `valuePredicate` is not passed as an argument.\\n\\n```lua\\nclientRemoteProperty:valuePromise():andThen(function(value)\\n\\tprint(value) \\nend)\\n```\\n\\n`valuePredicate` can ALSO be passed, which allows you to filter out values. If it returns\\nexactly `true`, only then will the promise resolve with the new value.\\n\\n```lua\\nclientRemoteProperty:valuePromise(function(newValue, oldValue) \\n\\tprint(newValue, oldValue)\\n\\treturn oldValue == 1\\nend):andThen(function(value)\\n\\tprint(value) \\nend)\\n\\nclientRemoteProperty:set(1) \\nclientRemoteProperty:set(2) \\n\\n-- Output:\\n-- 1, nil\\n-- 2, 1\\n-- 2\\n```","params":[{"name":"valuePredicate","desc":"","lua_type":"((newValue: any, oldValue: any) -> boolean)?\\r\\n"}],"returns":[],"function_type":"method","tags":["ClientRemoteProperty instance"],"source":{"line":130,"path":"src/network/client/ClientRemoteProperty.luau"}},{"name":"set","desc":"Invokes the remote property, to set the value for the client to `value`.\\n\\n:::warning Possible rate limit\\nIt is possible that the client may be rate limited by the server (see [RemoteProperty:setRateLimitForClientSettingValue]), and thus\\nrequests to the server to set the value for the client can possibly be ignored by the server.\\n\\n```lua\\n-- Server\\nremoteProperty:setRateLimitForClientSettingValue(client, 30) -- 30 seconds\\n\\n-- Client\\nclientRemoteProperty.onUpdate:Connect(function(newValue)\\n\\tprint(newValue) \\nend)\\n\\n-- Spam the setting of value for the client, so we ought for the value of the \\n-- client stored in the remote property (finally) to be `100`, but instead\\n-- it will be `1`, as subsequent calls after the first one will be ignored\\n-- due to the rate limit imposed.\\nfor index = 1, 100 do\\n\\tclientRemoteProperty:set(index)\\nend\\n\\n--\x3e 1 \\n```\\n:::\\n\\n:::warning Possible Value Set Request Rejection From Server\\nThe server can decline the client\'s request of setting the value for the client in the remote property. This behavior\\nwill be seen by default, if the remote property has no `clientSet` middleware - see [DefaultRemotePropertyMiddleware] \\nand [RemotePropertyMiddleware] for more info.\\n:::","params":[{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["ClientRemoteProperty instance"],"source":{"line":173,"path":"src/network/client/ClientRemoteProperty.luau"}},{"name":"setPromise","desc":"Works the same as [ClientRemoteProperty:set], but returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved once\\nthe server has set the value for the client to `value`. \\n\\n:::note\\nCalling this method for the same exact value **again** before the old promise has settled \\nwill simply result in the old promise to return. This is to avoid sending unnecessary\\nrequests to the server.\\n\\n```lua\\nlocal promiseA = clientRemoteProperty:setPromise(10) \\nlocal promiseB = clientRemoteProperty:setPromise(10) -- Will not send another request to the server, old promise is returned\\n\\nprint(promiseA:getStatus()) --\x3e \\"Started\\"\\nprint(promiseA == promiseB) --\x3e true\\n```\\n:::\\n\\n:::warning Possible Promise rejection\\nThis promise can also be rejected **with a nil value** if the server declines the client\'s request of setting the value for the client\\nin the remote property. This behavior will be seen by default, if the remote property  has  no `clientSet`\\nmiddleware - see [DefaultRemotePropertyMiddleware] and [RemotePropertyMiddleware] for more info.\\n:::\\n\\n```lua\\n-- Client\\nclientRemoteProperty:setPromise(10):andThen(function()\\n\\t-- Success!\\n\\tprint(clientRemoteProperty:get()) --\x3e 10\\nend):catch(function()\\n\\t-- Server rejected the request\\nend)\\n```","params":[{"name":"value","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"Promise"}],"function_type":"method","tags":["ClientRemoteProperty instance","Advanced"],"source":{"line":220,"path":"src/network/client/ClientRemoteProperty.luau"}},{"name":"destroy","desc":"Destroys the client remote property and renders it unusable.","params":[],"returns":[],"function_type":"method","tags":["ClientRemoteProperty instance"],"source":{"line":264,"path":"src/network/client/ClientRemoteProperty.luau"}},{"name":"_init","desc":"","params":[],"returns":[],"function_type":"method","private":true,"source":{"line":272,"path":"src/network/client/ClientRemoteProperty.luau"}},{"name":"__tostring","desc":"","params":[],"returns":[],"function_type":"method","private":true,"source":{"line":319,"path":"src/network/client/ClientRemoteProperty.luau"}}],"properties":[{"name":"onUpdate","desc":" \\n\\nA [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired, whenever the value \\nof the remote property (or the value of the client stored in the remote property)\\nis updated.\\n\\nIncase the client has a specific value set for them in the remote property, then this signal\\nwill only fire if *that* value has been updated.","lua_type":"Signal <newValue: any, oldValue: any>","tags":["Read only","Signal","ClientRemoteProperty instance"],"source":{"line":23,"path":"src/network/client/ClientRemoteProperty.luau"}}],"types":[{"name":"ClientRemoteProperty","desc":" ","lua_type":"ClientRemoteProperty","source":{"line":28,"path":"src/network/client/ClientRemoteProperty.luau"}}],"name":"ClientRemoteProperty","desc":"The clientside counterpart of [RemoteProperty]. A client remote property \\nin layman\'s terms is just an object connected to a remote property.","realm":["Client"],"source":{"line":8,"path":"src/network/client/ClientRemoteProperty.luau"}}')}}]);