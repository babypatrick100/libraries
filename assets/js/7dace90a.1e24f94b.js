"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[4248],{46753:n=>{n.exports=JSON.parse('{"functions":[{"name":"new","desc":" \\nCreates and returns a new custom animator object.","params":[{"name":"animator","desc":"","lua_type":"Animator | AnimationController"}],"returns":[{"desc":"","lua_type":"CustomAnimator\\r\\n"}],"function_type":"static","source":{"line":31,"path":"src/CustomAnimator/init.luau"}},{"name":"animationTrack","desc":" \\nReturns the given loaded animation track from the animation, if found.","params":[{"name":"animation","desc":"","lua_type":"Animation"}],"returns":[{"desc":"","lua_type":"AnimationTrack?\\r\\n"}],"function_type":"method","source":{"line":52,"path":"src/CustomAnimator/init.luau"}},{"name":"onAnimationLoadPromise","desc":" \\nReturns a promise which is resolved once the given animation is loaded via [CustomAnimator:loadAnimation].","params":[{"name":"animation","desc":"","lua_type":"Animation"}],"returns":[],"function_type":"method","source":{"line":60,"path":"src/CustomAnimator/init.luau"}},{"name":"loadAnimation","desc":" \\nLoads in the animation as an animation track.","params":[{"name":"animation","desc":"","lua_type":"Animation"}],"returns":[{"desc":"","lua_type":"AnimationTrack\\r\\n"}],"function_type":"method","source":{"line":74,"path":"src/CustomAnimator/init.luau"}},{"name":"playAnimation","desc":" \\nPlays the given animation, if it has been loaded into the animator object via [CustomAnimator:loadAnimation].\\n\\n:::tip\\nYou can also setup attributes for `fadeTime`, `weight`, and `speed` in the animation object, \\nwhich will be used incase the arguments aren\'t specified.\\n\\n- `fadeTime` -> `FadeTime`\\n- `weight` -> `Weight`\\n- `speed` -> `Speed`\\n:::","params":[{"name":"animation","desc":"","lua_type":"Animation"},{"name":"fadeTime","desc":"","lua_type":"number?"},{"name":"weight","desc":"","lua_type":"number?"},{"name":"speed","desc":"","lua_type":"number?\\r\\n"}],"returns":[{"desc":"","lua_type":"AnimationTrack\\r\\n"}],"function_type":"method","source":{"line":94,"path":"src/CustomAnimator/init.luau"}},{"name":"stopAnimation","desc":" \\nStops the given animation, if it has been loaded into the animator object via [CustomAnimator:loadAnimation].\\n\\n:::tip\\nYou can also setup an attribute for `fadeTime` in the animation object, which will be used incase the argument isn\'t specified.\\n\\n- `fadeTime` -> `FadeTime`\\n:::","params":[{"name":"animation","desc":"","lua_type":"Animation"},{"name":"fadeTime","desc":"","lua_type":"number?\\r\\n"}],"returns":[{"desc":"","lua_type":"AnimationTrack\\r\\n"}],"function_type":"method","source":{"line":124,"path":"src/CustomAnimator/init.luau"}},{"name":"stopAll","desc":" \\nStops all loaded animations by calling [CustomAnimator:stopAnimation] on each loaded animation.","params":[{"name":"fadeTime","desc":"","lua_type":"number?"}],"returns":[],"function_type":"method","source":{"line":143,"path":"src/CustomAnimator/init.luau"}},{"name":"all","desc":" \\nReturns a read only array of all animations loaded into the animator object.","params":[],"returns":[{"desc":"","lua_type":"{ [Animation]: AnimationTrack }\\r\\n"}],"function_type":"method","source":{"line":153,"path":"src/CustomAnimator/init.luau"}},{"name":"cleanupAnimationTrack","desc":" \\nStops the given animation track if loaded, and destroys it. ","params":[{"name":"animation","desc":"","lua_type":"Animation"}],"returns":[],"function_type":"method","source":{"line":161,"path":"src/CustomAnimator/init.luau"}},{"name":"animator","desc":" \\nReturns the animator associated to the animator object.","params":[],"returns":[{"desc":"","lua_type":"Animator\\r\\n"}],"function_type":"method","source":{"line":176,"path":"src/CustomAnimator/init.luau"}},{"name":"destroy","desc":" \\nDestroys the custom animator object and renders it unusuable. Additionally, [CustomAnimator:cleanupAnimationTrack] is called\\non all loaded animation tracks too.","params":[],"returns":[],"function_type":"method","source":{"line":185,"path":"src/CustomAnimator/init.luau"}}],"properties":[],"types":[{"name":"CustomAnimator","desc":" ","lua_type":"CustomAnimator","source":{"line":17,"path":"src/CustomAnimator/init.luau"}}],"name":"CustomAnimator","desc":" \\n\\nA simple class for working with animations.\\n\\n```lua\\nlocal playerHumanoidCustomAnimator = CustomAnimator.new(humanoidAnimator)\\nlocal track = playerHumanoidCustomAnimator:loadAnimation(animation)\\ntrack:Play()\\n```","source":{"line":12,"path":"src/CustomAnimator/init.luau"}}')}}]);