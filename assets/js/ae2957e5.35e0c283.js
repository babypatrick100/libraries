"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[4895],{15038:n=>{n.exports=JSON.parse('{"functions":[{"name":"new","desc":"Create a new custom Component class.\\n\\n```lua\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\n```\\n\\nA full example might look like this:\\n\\n```lua\\nlocal MyComponent = Component.new({\\n\\ttag = \\"MyComponent\\",\\n\\tancestors = {workspace},\\n\\textensions = {Logger}, -- See Logger example within the example for the Extension type\\n})\\n\\nlocal AnotherComponent = require(somewhere.AnotherComponent)\\n\\n-- Optional if UpdateRenderStepped should use BindToRenderStep:\\nMyComponent.RenderPriority = Enum.RenderPriority.Camera.Value\\n\\nfunction MyComponent:construct()\\n\\tself.MyData = \\"Hello\\"\\nend\\n\\nfunction MyComponent:start()\\n\\tlocal another = self:component(AnotherComponent)\\n\\tanother:DoSomething()\\nend\\n\\nfunction MyComponent:stop()\\n\\tself.MyData = \\"Goodbye\\"\\nend\\n\\nfunction MyComponent:heartbeatUpdate(dt)\\nend\\n\\nfunction MyComponent:steppedUpdate(time, dt)\\nend\\n\\nfunction MyComponent:renderSteppedUpdate(dt)\\nend\\n```","params":[{"name":"config","desc":"","lua_type":"ComponentConfig"}],"returns":[{"desc":"","lua_type":"ComponentClass"}],"function_type":"static","tags":["Component"],"source":{"line":314,"path":"src/Component/init.luau"}},{"name":"all","desc":"Gets a table array of all existing component objects. For example,\\nif there was a component class linked to the \\"MyComponent\\" tag,\\nand three Roblox instances in your game had that same tag, then\\ncalling `all` would return the three component instances.\\n\\n```lua\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\n\\n-- ...\\n\\nlocal components = MyComponent:all()\\nfor _,component in components do\\n\\tcomponent:DoSomethingHere()\\nend\\n```","params":[],"returns":[{"desc":"","lua_type":"{Component}"}],"function_type":"method","tags":["Component Class"],"source":{"line":630,"path":"src/Component/init.luau"}},{"name":"fromInstance","desc":"Gets an instance of a component class from the given Roblox\\ninstance. Returns `nil` if not found.\\n\\n```lua\\nlocal MyComponent = require(somewhere.MyComponent)\\n\\nlocal myComponentInstance = MyComponent:fromInstance(workspace.SomeInstance)\\n```","params":[{"name":"instance","desc":"","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"Component?"}],"function_type":"method","tags":["Component Class"],"source":{"line":647,"path":"src/Component/init.luau"}},{"name":"waitForInstance","desc":"Resolves a promise once the component instance is present on a given\\nRoblox instance.\\n\\nAn optional `timeout` can be provided to reject the promi\\tse if it\\ntakes more than `timeout` seconds to resolve. If no timeout is\\nsupplied, `timeout` defaults to 60 seconds.\\n\\n```lua\\nlocal MyComponent = require(somewhere.MyComponent)\\n\\nMyComponent:waitForInstance(workspace.SomeInstance):andThen(function(myComponentInstance)\\n\\t-- Do something with the component class\\nend)\\n```","params":[{"name":"instance","desc":"","lua_type":"Instance"},{"name":"timeout","desc":"","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"Promise<ComponentInstance>"}],"function_type":"method","tags":["Component Class"],"source":{"line":670,"path":"src/Component/init.luau"}},{"name":"construct","desc":"`construct` is called before the component is started, and should be used\\nto construct the component instance.\\n\\n:::note Cancellation\\nIf this method has not yet finished when the component instance is stopped, then it will be forcefuly\\nstopped.\\n:::\\n\\n```lua\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\n\\nfunction MyComponent:construct()\\n\\tself.SomeData = 32\\n\\tself.OtherStuff = \\"HelloWorld\\"\\nend\\n```","params":[],"returns":[],"function_type":"method","tags":["Component Class"],"source":{"line":707,"path":"src/Component/init.luau"}},{"name":"start","desc":"`start` is called when the component is started, **and all other component instances of the instance bound to the component are ready**. At this point in time, it\\nis safe to grab other components also bound to the same instance.\\n\\n:::note Cancellation\\nIf this method has not yet finished when the component instance is stopped, then it will be forcefuly\\nstopped.\\n:::\\n\\n```lua\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\nlocal AnotherComponent = require(somewhere.AnotherComponent)\\n\\nfunction MyComponent:start()\\n\\t-- e.g., grab another component:\\n\\tlocal another = self:component(AnotherComponent)\\nend\\n```","params":[],"returns":[],"function_type":"method","tags":["Component Class"],"source":{"line":729,"path":"src/Component/init.luau"}},{"name":"stop","desc":"`stop` is called when the component is stopped. This occurs either when the\\nbound instance is removed from one of the whitelisted ancestors _or_ when\\nthe matching tag is removed from the instance. This also means that the\\ninstance _might_ be destroyed, and thus it is not safe to continue using\\nthe bound instance (e.g. `self.instance`) any longer.\\n\\nThis should be used to clean up the component.\\n\\n```lua\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\n\\nfunction MyComponent:stop()\\n\\tself.SomeStuff:destroy()\\nend\\n```","params":[],"returns":[],"function_type":"method","tags":["Component Class"],"source":{"line":749,"path":"src/Component/init.luau"}},{"name":"component","desc":"Retrieves another component instance bound to the same\\nRoblox instance.\\n\\n```lua\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\nlocal AnotherComponent = require(somewhere.AnotherComponent)\\n\\nfunction MyComponent:start()\\n\\tlocal another = self:component(AnotherComponent)\\nend\\n```","params":[{"name":"componentClass","desc":"","lua_type":"ComponentClass"}],"returns":[{"desc":"","lua_type":"Component?"}],"function_type":"method","tags":["Component Instance"],"source":{"line":768,"path":"src/Component/init.luau"}},{"name":"heartbeatUpdate","desc":"If this method is present on a component, then it will be\\nautomatically connected to `RunService.Heartbeat`.\\n\\n:::note Method\\nThis is a method, not a function. This is a limitation\\nof the documentation tool which should be fixed soon.\\n:::\\n\\n```lua\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\n\\nfunction MyComponent:heartbeatUpdate(dt)\\nend\\n```","params":[{"name":"dt","desc":"","lua_type":"number"}],"returns":[],"function_type":"static","tags":["Component Class"],"source":{"line":793,"path":"src/Component/init.luau"}},{"name":"steppedUpdate","desc":"If this method is present on a component, then it will be\\nautomatically connected to `RunService.Stepped`.\\n\\n:::note Method\\nThis is a method, not a function. This is a limitation\\nof the documentation tool which should be fixed soon.\\n:::\\n\\n```lua\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\n\\nfunction MyComponent:steppedUpdate(time, dt)\\nend\\n```","params":[{"name":"time","desc":"","lua_type":"number"},{"name":"dt","desc":"","lua_type":"number"}],"returns":[],"function_type":"static","tags":["Component Class"],"source":{"line":815,"path":"src/Component/init.luau"}},{"name":"renderSteppedUpdate","desc":"If this method is present on a component, then it will be\\nautomatically connected to `RunService.RenderStepped`. If\\nthe `[Component].RenderPriority` field is found, then the\\ncomponent will instead use `RunService:BindToRenderStep()`\\nto bind the function.\\n\\n:::note Method\\nThis is a method, not a function. This is a limitation\\nof the documentation tool which should be fixed soon.\\n:::\\n\\n```lua\\n-- Example that uses `RunService.RenderStepped` automatically:\\n\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\n\\nfunction MyComponent:renderSteppedUpdate(dt)\\nend\\n```\\n```lua\\n-- Example that uses `RunService:BindToRenderStep` automatically:\\n\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\n\\n-- Defining a RenderPriority will force the component to use BindToRenderStep instead\\nMyComponent.RenderPriority = Enum.RenderPriority.Camera.Value\\n\\nfunction MyComponent:renderSteppedUpdate(dt)\\nend\\n```","params":[{"name":"dt","desc":"","lua_type":"number"}],"returns":[],"function_type":"static","tags":["Component Class"],"realm":["Client"],"source":{"line":853,"path":"src/Component/init.luau"}}],"properties":[{"name":"started","desc":"Fired when a new instance of a component is started.\\n\\n```lua\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\n\\nMyComponent.started:Connect(function(component) end)\\n```","lua_type":"Signal","tags":["Event","Component Class"],"source":{"line":138,"path":"src/Component/init.luau"}},{"name":"stopped","desc":"Fired when an instance of a component is stopped.\\n\\n```lua\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\"})\\n\\nMyComponent.stopped:Connect(function(component) end)\\n```","lua_type":"Signal","tags":["Event","Component Class"],"source":{"line":153,"path":"src/Component/init.luau"}},{"name":"instance","desc":"A reference back to the _Roblox_ instance from within a _component_ instance. When\\na component instance is created, it is bound to a specific Roblox instance, which\\nwill always be present through the `Instance` property.\\n\\n```lua\\nMyComponent.started:Connect(function(component)\\n\\tlocal robloxInstance: Instance = component.instance\\n\\tprint(\\"Component is bound to \\" .. robloxInstance:GetFullName())\\nend)\\n```","lua_type":"Instance","tags":["Component Instance"],"source":{"line":170,"path":"src/Component/init.luau"}}],"types":[{"name":"ExtensionFn","desc":"","lua_type":"(component) -> ()","source":{"line":12,"path":"src/Component/init.luau"}},{"name":"ExtensionShouldFn","desc":"","lua_type":"(component) -> boolean","source":{"line":18,"path":"src/Component/init.luau"}},{"name":"Extension","desc":"An extension allows the ability to extend the behavior of\\ncomponents. This is useful for adding injection systems or\\nextending the behavior of components by wrapping around\\ncomponent lifecycle methods.\\n\\nThe `shouldConstruct` function can be used to indicate\\nif the component should actually be created. This must\\nreturn `true` or `false`. A component with multiple\\n`shouldConstruct` extension functions must have them _all_\\nreturn `true` in order for the component to be constructed.\\nThe `shouldConstruct` function runs _before_ all other\\nextension functions and component lifecycle methods.\\n\\nThe `shouldExtend` function can be used to indicate if\\nthe extension itself should be used. This can be used in\\norder to toggle an extension on/off depending on whatever\\nlogic is appropriate. If no `shouldExtend` function is\\nprovided, the extension will always be used if provided\\nas an extension to the component.\\n\\nAs an example, an extension could be created to simply log\\nwhen the various lifecycle stages run on the component:\\n\\n```lua\\nlocal Logger = {}\\nfunction Logger.constructing(component) print(\\"constructing\\", component) end\\nfunction Logger.constructed(component) print(\\"constructed\\", component) end\\nfunction Logger.starting(component) print(\\"starting\\", component) end\\nfunction Logger.started(component) print(\\"started\\", component) end\\nfunction Logger.stopping(component) print(\\"stopping\\", component) end\\nfunction Logger.stopped(component) print(\\"stopped\\", component) end\\n\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\", extensions = {Logger}})\\n```\\n\\nSometimes it is useful for an extension to control whether or\\nnot a component should be constructed. For instance, if a\\ncomponent on the client should only be instantiated for the\\nlocal player, an extension might look like this, assuming the\\ninstance has an attribute linking it to the player\'s UserId:\\n```lua\\nlocal player = game:GetService(\\"Players\\").LocalPlayer\\n\\nlocal OnlyLocalPlayer = {}\\nfunction OnlyLocalPlayer.shouldConstruct(component)\\n\\tlocal ownerId = component.instance:GetAttribute(\\"OwnerId\\")\\n\\treturn ownerId == player.UserId\\nend\\n\\nlocal MyComponent = Component.new({tag = \\"MyComponent\\", extensions = {OnlyLocalPlayer}})\\n```\\n\\nIt can also be useful for an extension itself to turn on/off\\ndepending on various contexts. For example, let\'s take the\\nLogger from the first example, and only use that extension\\nif the bound instance has a Log attribute set to `true`:\\n```lua\\nfunction Logger.shouldExtend(component)\\n\\treturn component.instance:GetAttribute(\\"Log\\") == true\\nend\\n```","fields":[{"name":"shouldExtend","lua_type":"ExtensionShouldFn?","desc":""},{"name":"shouldConstruct","lua_type":"ExtensionShouldFn?","desc":""},{"name":"constructing","lua_type":"ExtensionFn?","desc":""},{"name":"constructed","lua_type":"ExtensionFn?","desc":""},{"name":"starting","lua_type":"ExtensionFn?","desc":""},{"name":"started","lua_type":"ExtensionFn?","desc":""},{"name":"stopping","lua_type":"ExtensionFn?","desc":""},{"name":"stopped","lua_type":"ExtensionFn?","desc":""}],"source":{"line":94,"path":"src/Component/init.luau"}},{"name":"ComponentConfig","desc":"Component configuration passed to `Component.new`.\\n\\n- If no ancestors option is included, it defaults to `{workspace, game.Players}`.\\n- If no extensions option is included, it defaults to a blank table `{}`.","fields":[{"name":"tag","lua_type":"string","desc":"CollectionService tag to use"},{"name":"ancestors","lua_type":"{Instance}?","desc":"Optional array of ancestors in which components will be started"},{"name":"extensions","lua_type":"{Extension}?","desc":"Optional array of extension objects"}],"source":{"line":117,"path":"src/Component/init.luau"}}],"name":"Component","desc":"Bind components to Roblox instances using the Component class and CollectionService tags.\\n\\n:::note\\nThe Component class is made by `Sleitnick`, this version is just a slightly modified version of it.\\n:::\\n\\nTo avoid confusion of terms:\\n- `Component` refers to this module.\\n- `Component Class` (e.g. `MyComponent` through this documentation) refers to a class created via `Component.new`\\n- `Component Instance` refers to an instance of a component class.\\n- `Roblox Instance` refers to the Roblox instance to which the component instance is bound.\\n\\nMethods and properties are tagged with the above terms to help clarify the level at which they are used.","source":{"line":262,"path":"src/Component/init.luau"}}')}}]);