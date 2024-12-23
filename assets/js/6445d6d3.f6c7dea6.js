"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[2361],{55709:e=>{e.exports=JSON.parse('{"functions":[{"name":"is","desc":"Returns a boolean indicating if `self` is a client remote signal or not.","params":[{"name":"self","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"boolean\\n"}],"function_type":"static","source":{"line":32,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"connect","desc":"Connects `callback` to the client remote signal so that it is called whenever \\nthe remote signal dispatches some data to the client. Additionally, `callback` will be passed all the arguments \\nsent by the server.","params":[{"name":"callback","desc":"","lua_type":"(...any) -> ()"}],"returns":[{"desc":"","lua_type":"RBXScriptConnection\\n"}],"function_type":"method","tags":["ClientRemoteSignal instance"],"source":{"line":44,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"once","desc":"Works almost exactly the same as [ClientRemoteSignal:connect], except the \\nconnection returned is  disconnected immediately upon `callback` being called.","params":[{"name":"callback","desc":"","lua_type":"(...any) -> ()"}],"returns":[{"desc":"","lua_type":"RBXScriptConnection\\n"}],"function_type":"method","tags":["ClientRemoteSignal instance"],"source":{"line":64,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"fireServer","desc":"Fires `...` arguments to the remote signal.","params":[{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["ClientRemoteSignal instance"],"source":{"line":76,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"wait","desc":"Yields the current thread until the remote signal dispatches some data to the client.\\nThe yielded thread is resumed once the server fires some data to the client,  with the\\narguments sent by the server.\\n\\n```lua\\n-- Server\\nremoteSignal:fireAllClients(\\"Hi\\")\\n\\n-- Client\\nprint(clientRemoteSignal:wait()) --\x3e \\"Hi\\"\\n```","params":[],"returns":[{"desc":"","lua_type":"...any\\n"}],"function_type":"method","tags":["ClientRemoteSignal instance","yields"],"source":{"line":97,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"destroy","desc":"Destroys the client remote signal and renders it unusable.","params":[],"returns":[],"function_type":"method","tags":["ClientRemoteSignal instance"],"source":{"line":107,"path":"src/network/client/ClientRemoteSignal.luau"}}],"properties":[],"types":[{"name":"ClientRemoteSignal","desc":" ","lua_type":"ClientRemoteSignal","source":{"line":13,"path":"src/network/client/ClientRemoteSignal.luau"}}],"name":"ClientRemoteSignal","desc":"The clientside counterpart of [RemoteSignal]. A client remote signal in layman\'s terms is just an object\\nconnected to a remote signal.","realm":["Client"],"source":{"line":8,"path":"src/network/client/ClientRemoteSignal.luau"}}')}}]);