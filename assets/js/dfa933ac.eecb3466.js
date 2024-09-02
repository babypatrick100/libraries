"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[1165],{59406:e=>{e.exports=JSON.parse('{"functions":[{"name":"dataCachePerInstance","desc":"Returns the data cache for the given `instance`, which is automatically cleaned up once `instance` is destroyed. \\n\\nIf the data cache for the given `instance` does not exist, it will be initialized with an empty table.\\n\\n:::tip Uniqueness\\nInstance data caches are stored per each instance, uniquely keyed by script names. This means a given \\ninstance\'s cache will always be unique when accessed from different scripts.\\n\\nFor e.g:\\n\\n```lua\\n-- Script 1:\\nlocal cache = perInstanceDataCacheUtil.dataCachePerInstance(instance)  \\n-- `cache` is an empty table\\n\\ncache.test = 1\\n\\nprint(cache) --\x3e {test = 1}\\n\\n\\n-- Script 2:\\nlocal cache = perInstanceDataCacheUtil.dataCachePerInstance(instance)  \\n-- `cache` is an empty table\\n\\ncache.opper = 5\\nprint(cache) --\x3e {opper = 5} \\n```\\n:::\\n\\n:::warning\\nThis method will throw an error if `instance` is not present in game.\\n:::","params":[{"name":"instance","desc":"","lua_type":"Instance"}],"returns":[],"function_type":"static","source":{"line":45,"path":"src/perInstanceDataCacheUtil/init.luau"}}],"properties":[],"types":[],"name":"perInstanceDataCacheUtil","desc":" \\n\\nA very simple utility module for storing data unique to every instance in an unique way.","source":{"line":6,"path":"src/perInstanceDataCacheUtil/init.luau"}}')}}]);