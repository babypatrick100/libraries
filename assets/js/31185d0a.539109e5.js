"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[4904],{65719:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"","params":[{"name":"remoteEvent","desc":"","lua_type":"sharedTypes.RemoteEventOrUnreliable"}],"returns":[{"desc":"","lua_type":"ClientRemoteSignal\\r\\n"}],"function_type":"static","private":true,"source":{"line":26,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"is","desc":"Returns a boolean indicating if `self` is a client remote signal or not.","params":[{"name":"self","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","source":{"line":40,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"connect","desc":"Connects `callback` to the client remote signal so that it is called whenever \\nthe serverside remote signal (to which the client remote signal is connected to) \\ndispatches some data to the client. Additionally, `callback` will be passed all the arguments \\nsent by the server.","params":[{"name":"callback","desc":"","lua_type":"(...any) -> ()"}],"returns":[{"desc":"","lua_type":"RBXScriptConnection\\r\\n"}],"function_type":"method","tags":["ClientRemoteSignal instance"],"source":{"line":53,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"once","desc":"Works almost exactly the same as [ClientRemoteSignal:connect], except the \\nconnection returned is  disconnected immediately upon `callback` being called.","params":[{"name":"callback","desc":"","lua_type":"(...any) -> ()"}],"returns":[{"desc":"","lua_type":"RBXScriptConnection\\r\\n"}],"function_type":"method","tags":["ClientRemoteSignal instance"],"source":{"line":75,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"fireServer","desc":"Fires `...` arguments to the serverside remote signal (to which the client\\nremote signal is connected to).","params":[{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["ClientRemoteSignal instance"],"source":{"line":88,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"wait","desc":"Yields the current thread until the serverside remote signal (to which the client \\nremote signal is connected to) dispatches some data to the client. The yielded thread \\nis resumed once the server fires some data to the client, with the arguments sent by the \\nserver.\\n\\n```lua\\n-- Server\\nremoteSignal:fireAllClients(\\"Hi\\")\\n\\n-- Client\\nprint(clientRemoteSignal:wait()) --\x3e \\"Hi\\"\\n```","params":[],"returns":[{"desc":"","lua_type":"...any\\r\\n"}],"function_type":"method","tags":["ClientRemoteSignal instance","yields"],"source":{"line":110,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"destroy","desc":"Destroys the client remote signal and renders it unusable.","params":[],"returns":[],"function_type":"method","tags":["ClientRemoteSignal instance"],"source":{"line":120,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"_init","desc":"","params":[],"returns":[],"function_type":"method","private":true,"source":{"line":128,"path":"src/network/client/ClientRemoteSignal.luau"}},{"name":"__tostring","desc":"","params":[],"returns":[],"function_type":"method","private":true,"source":{"line":138,"path":"src/network/client/ClientRemoteSignal.luau"}}],"properties":[],"types":[{"name":"ClientRemoteSignal","desc":" ","lua_type":"ClientRemoteSignal","source":{"line":12,"path":"src/network/client/ClientRemoteSignal.luau"}}],"name":"ClientRemoteSignal","desc":"The clientside counterpart of [RemoteSignal]. A client remote signal in \\nlayman\'s terms is just an object connected to a serverside remote signal.","source":{"line":7,"path":"src/network/client/ClientRemoteSignal.luau"}}')}}]);