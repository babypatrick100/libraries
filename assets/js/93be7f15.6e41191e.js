"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[7491],{57872:e=>{e.exports=JSON.parse('{"functions":[{"name":"cosec","desc":"Returns the reciprocal of `math.sign(number)`.\\n\\n```lua\\nprint(numberUtil.cosec(1)) --\x3e 1.1883951057781212\\n```","params":[{"name":"number","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/cosec.luau"}},{"name":"minutesToHours","desc":"Returns a number which is `minutes` converted to hours.\\n\\n```lua\\nprint(numberUtil.minutesToHours(60)) --\x3e 1\\n```","params":[{"name":"minutes","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":12,"path":"src/numberUtil/methods/minutesToHours.luau"}},{"name":"toHM","desc":"Returns a string which is just `number` formatted to the HM (Hour, Minutes) format.\\n\\n```lua\\nprint(numberUtil.toHM(2 * 3600)) --\x3e 02:00\\n```","params":[{"name":"number","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"string\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/toHM.luau"}},{"name":"minutesToSeconds","desc":"Returns a number which is `minutes` converted to seconds.\\n\\n```lua\\nprint(numberUtil.minutesToSeconds(1)) --\x3e 60\\n```","params":[{"name":"minutes","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":12,"path":"src/numberUtil/methods/minutesToSeconds.luau"}},{"name":"mode","desc":"From a set of numbers `...`, returns the number which is the most frequent.\\n\\n```lua\\nprint(numberUtil.mode(1, 2, 3, 3)) --\x3e 3\\nprint(numberUtil.mode(1, 2, 3)) --\x3e nil (no numbers repeat)\\n```","params":[{"name":"...","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number?\\r\\n"}],"function_type":"static","source":{"line":11,"path":"src/numberUtil/methods/mode.luau"}},{"name":"comb","desc":"Returns the number of ways picking `k` unordered outcomes from `number` possibilities, without repetition.\\n\\n:::note\\nIf the value of `k` is greater than `number`, then the method will return `0`.\\n:::\\n\\n```lua\\nprint(numberUtil.comb(2, 1)) --\x3e 2\\n```","params":[{"name":"number","desc":"","lua_type":"number"},{"name":"k","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":16,"path":"src/numberUtil/methods/comb.luau"}},{"name":"commas","desc":"Returns a string formatted with commas.\\n\\n```lua\\nprint(numberUtil.commas(15000)) --\x3e 15,000\\n```","params":[{"name":"target","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"string\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/commas.luau"}},{"name":"average","desc":"Returns the average of `...` numbers against `sum`.\\n\\n```lua\\nprint(numberUtil.average(100, 50, 25)) --\x3e 0.75\\n```","params":[{"name":"sum","desc":"","lua_type":"number"},{"name":"...","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/average.luau"}},{"name":"secondsToHours","desc":"  \\nReturns a number which is `seconds` converted to hours.\\n\\n```lua\\nprint(numberUtil.secondsToHours(3600)) --\x3e 1\\n```","params":[{"name":"seconds","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":12,"path":"src/numberUtil/methods/secondsToHours.luau"}},{"name":"secondsToMinutes","desc":"Returns a number which is `seconds` converted to minutes.\\n\\n```lua\\nprint(numberUtil.secondsToMinutes(60)) --\x3e 1\\n```","params":[{"name":"seconds","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":12,"path":"src/numberUtil/methods/secondsToMinutes.luau"}},{"name":"close","desc":"Returns a boolean indicating if the difference between `number` and `to` is lower than or equal to `eplsion`.\\n\\n```lua\\nprint(numberUtil.close(0.1 + 0.2, 0.3)) --\x3e true\\nprint(numberUtil.close(0.1 + 0.2, 0.3, 0)) --\x3e false\\n```\\n\\n- If `eplison` is not specified, then it will default to `1e-2`.","params":[{"name":"number","desc":"","lua_type":"number"},{"name":"to","desc":"","lua_type":"number"},{"name":"eplison","desc":"","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","source":{"line":15,"path":"src/numberUtil/methods/close.luau"}},{"name":"toHMS","desc":"Returns a string which is just `number` formatted to the HMS (Hour, Minutes, Seconds) format.\\n\\n```lua\\nprint(numberUtil.toHMS(21600)) --\x3e 06:00:00\\n```","params":[{"name":"number","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"string\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/toHMS.luau"}},{"name":"suffix","desc":"Return a string as the formatted version of `number`. \\n\\n:::warning Cannot format extremely large numbers\\nThis method will struggle to format numbers larger than approximately `10^68`. \\n\\n```lua\\nprint(numberUtil.suffix(10^70)) --\x3e 10 (no formatting...)\\n```\\n:::\\n\\n```lua\\nprint(numberUtil.suffix(1650)) --\x3e \\"1.65K\\"\\n```\\n\\nAdditionally, if `number` is lower than `1`, then this method will just return `number` (stringified).","params":[{"name":"number","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"string\\r\\n"}],"function_type":"static","source":{"line":45,"path":"src/numberUtil/methods/suffix.luau"}},{"name":"quadraticLerp","desc":"Quadraticly interpolates `number` to `goal`, with `alpha` being the multiplier.\\n\\n```lua\\nprint(numberUtil.quadraticLerp(2, 5, 0.7)) --\x3e 4.1\\n```","params":[{"name":"number","desc":"","lua_type":"number"},{"name":"goal","desc":"","lua_type":"number"},{"name":"alpha","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/quadraticLerp.luau"}},{"name":"sphericalLerp","desc":"Returns a result on based on [spherical linear interpolation](https://en.wikipedia.org/wiki/Slerp).\\n\\n```lua\\nprint(numberUtil.sphericalLerp(1, 1, 1, 1, 1, 1, 1, 1, 1, 1)) --\x3e 2.3\\n```","params":[{"name":"t","desc":"","lua_type":"number"},{"name":"w0","desc":"","lua_type":"number"},{"name":"x0","desc":"","lua_type":"number"},{"name":"y0","desc":"","lua_type":"number"},{"name":"z0","desc":"","lua_type":"number"},{"name":"w1","desc":"","lua_type":"number"},{"name":"x1","desc":"","lua_type":"number"},{"name":"y1","desc":"","lua_type":"number"},{"name":"z1","desc":"","lua_type":"number"},{"name":"d","desc":"","lua_type":"number\\r\\n"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/sphericalLerp.luau"}},{"name":"exponentialLerp","desc":"Exponentially lerps `number` to `goal`, with `alpha` being the multiplier.\\n\\n```lua\\nprint(numberUtil.exponentialLerp(1, 5, 3)) --\x3e 125\\n```","params":[{"name":"number","desc":"","lua_type":"number"},{"name":"goal","desc":"","lua_type":"number"},{"name":"alpha","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":9,"path":"src/numberUtil/methods/exponentialLerp.luau"}},{"name":"secondsToDays","desc":"Returns a number which is `seconds` converted to days.\\n\\n```lua\\nprint(numberUtil.secondsToDays(86400)) --\x3e 1\\n```","params":[{"name":"seconds","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":12,"path":"src/numberUtil/methods/secondsToDays.luau"}},{"name":"cubicBezier","desc":"Returns the cubic bezier from the arguments.\\n\\n```lua\\nprint(cubicBezier(2, 0.15, 0, 0.1, 0)) --\x3e -1.35\\n```","params":[{"name":"t","desc":"","lua_type":"number"},{"name":"p0","desc":"","lua_type":"number"},{"name":"p1","desc":"","lua_type":"number"},{"name":"p2","desc":"","lua_type":"number"},{"name":"p3","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/cubicBezier.luau"}},{"name":"min","desc":"Returns the minimum value.\\n\\n```lua\\nprint(numberUtil.min(10,9,8,7,6,5,4,3,2,1)) --\x3e 1\\n```","params":[{"name":"...","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":9,"path":"src/numberUtil/methods/min.luau"}},{"name":"logarithmicLerp","desc":"Logarithmicly lerps `number` to `goal`, with `alpha` being the multiplier.\\n\\n```lua\\nprint(numberUtil.logarithmicLerp(1, 2, 3)) --\x3e 0.125\\n```","params":[{"name":"number","desc":"","lua_type":"number"},{"name":"goal","desc":"","lua_type":"number"},{"name":"alpha","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/logarithmicLerp.luau"}},{"name":"factorial","desc":"Returns the factorial of `number`.\\n\\n```lua\\nprint(numberUtil.factorial(3)) --\x3e 6\\n```","params":[{"name":"number","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/factorial.luau"}},{"name":"max","desc":"Returns the maximum value.\\n\\n```lua\\nprint(numberUtil.max(10,9,8,7,6,5,4,3,2,1)) --\x3e 10\\n```","params":[{"name":"...","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":9,"path":"src/numberUtil/methods/max.luau"}},{"name":"root","desc":"Returns the `root` of `number`.\\n\\n```lua\\nprint(numberUtil.root(2, 3)) --\x3e 1.2599210498948732 (same as cube root of 2)\\nprint(numberUtil.root(2, 2)) --\x3e 1.4142135623730951 (same as square root of 2)\\n```","params":[{"name":"number","desc":"","lua_type":"number"},{"name":"root","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":11,"path":"src/numberUtil/methods/root.luau"}},{"name":"cotan","desc":"A trigonometric function that in a right-angled triangle is the ratio of the length of the adjacent side to\\nthat of the opposite side; the reciprocal of tangent.\\n\\n```lua\\nprint(numberUtil.cotan(1)) --\x3e 0.6420926159343306\\n```","params":[{"name":"number","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":11,"path":"src/numberUtil/methods/cotan.luau"}},{"name":"quadraticBezier","desc":"Returns the quadratic bezier from the arguments.\\n\\n```lua\\nprint(numberUtil.quadraticBezier(0, 0.5, 3, 5)) --\x3e 0.5\\n```","params":[{"name":"t","desc":"","lua_type":"number"},{"name":"p0","desc":"","lua_type":"number"},{"name":"p1","desc":"","lua_type":"number"},{"name":"p2","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":9,"path":"src/numberUtil/methods/quadraticBezier.luau"}},{"name":"nan","desc":"Returns a boolean indicating if `number` is NaN (Not A Number). \\n\\n```lua\\nprint(numberUtil.nan(0 / 0)) --\x3e true\\n```","params":[{"name":"number","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/nan.luau"}},{"name":"map","desc":"Maps `number` between `inMin` and `inMax`, and `outMin` and `outMax`.\\n\\n```lua\\nprint(numberUtil.map(1,2,3,4,5)) --\x3e 3\\n```","params":[{"name":"number","desc":"","lua_type":"number"},{"name":"inMin","desc":"","lua_type":"number"},{"name":"inMax","desc":"","lua_type":"number"},{"name":"outMin","desc":"","lua_type":"number"},{"name":"outMax","desc":"","lua_type":"number\\r\\n"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/map.luau"}},{"name":"lerp","desc":"Interpolates `number` to `goal`, with `alpha` being the multiplier.\\n\\n```lua\\nprint(numberUtil.lerp(2, 5, 0.7)) --\x3e 4.1\\n```","params":[{"name":"number","desc":"","lua_type":"number"},{"name":"goal","desc":"","lua_type":"number"},{"name":"alpha","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/lerp.luau"}},{"name":"factors","desc":"Returns an array of all factors of `number`.\\n\\n```lua\\nprint(numberUtil.factors(2)) --\x3e {1, 2}\\n```","params":[{"name":"number","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"{ number }\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/factors.luau"}},{"name":"secant","desc":"The ratio of the hypotenuse to the shorter side adjacent to an acute angle (in a right-angled triangle); the reciprocal of a cosine.\\n\\n```lua\\nprint(numberUtil.secant(1)) --\x3e 1.8508157176809255\\n```","params":[{"name":"number","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/secant.luau"}},{"name":"median","desc":"Returns the median of the set of numbers `...`.\\n\\n```lua\\nprint(numberUtil.median(2, 2)) --\x3e 4\\n```","params":[{"name":"...","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":9,"path":"src/numberUtil/methods/median.luau"}},{"name":"inverseLerp","desc":"Inverse lerp is the inverse operation of the lerp node. It can be used to determine what the input to a lerp was \\nbased on its output. \\n\\n```lua\\nprint(numberUtil.inverseLerp(2, 5, 0.7)) --\x3e -0.43333333333333335\\n```","params":[{"name":"min","desc":"","lua_type":"number"},{"name":"max","desc":"","lua_type":"number"},{"name":"alpha","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":11,"path":"src/numberUtil/methods/inverseLerp.luau"}},{"name":"mean","desc":"Returns the mean of the set of numbers `...`.\\n\\n```lua\\nprint(numberUtil.mode(1, 2, 4)) --\x3e 2.3\\n```","params":[{"name":"...","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":9,"path":"src/numberUtil/methods/mean.luau"}},{"name":"hoursToMinutes","desc":"Returns a number which is `hours` converted to minutes.\\n\\n```lua\\nprint(numberUtil.hoursToMinutes(1)) --\x3e 60\\n```","params":[{"name":"hours","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":12,"path":"src/numberUtil/methods/hoursToMinutes.luau"}},{"name":"clampTo","desc":"Clamps `number` to `clamp`, if `number` is greater than `max` or lower than `min`.\\n\\n```lua\\nprint(numberUtil.clampTo(1, 2, 5, 150)) --\x3e 150\\n```","params":[{"name":"number","desc":"","lua_type":"number"},{"name":"min","desc":"","lua_type":"number"},{"name":"max","desc":"","lua_type":"number"},{"name":"clamp","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/clampTo.luau"}},{"name":"toMS","desc":"Returns a string which is just `number` formatted to the MS (Minutes, Seconds) format.\\n\\n```lua\\nprint(numberUtil.toMS(21600)) --\x3e 10:00\\n```","params":[{"name":"number","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"string\\r\\n"}],"function_type":"static","source":{"line":10,"path":"src/numberUtil/methods/toMS.luau"}},{"name":"to24H","desc":"Returns the given hour formatted to the 12 hour clock.\\n\\n```lua\\nprint(numberUtil.to24H(12, \\"am\\")) --\x3e 0\\nprint(numberUtil.to24H(5, \\"pm\\")) --\x3e 17\\nprint(numberUtil.to24H(12, \\"pm\\")) --\x3e 12\\nprint(numberUtil.to24H(11, \\"pm\\")) --\x3e 23\\nprint(numberUtil.to24H(11, \\"am\\")) --\x3e 11\\n```","params":[{"name":"hour","desc":"","lua_type":"number"},{"name":"preset","desc":"","lua_type":"\\"am\\" | \\"pm\\""}],"returns":[{"desc":"","lua_type":"number\\r\\n"}],"function_type":"static","source":{"line":17,"path":"src/numberUtil/methods/to24H.luau"}},{"name":"to12H","desc":"Returns the given hour formatted to the 12 hour clock.\\n\\n```lua\\nprint(numberUtil.to12H(24)) --\x3e 12\\nprint(numberUtil.to12H(17)) --\x3e 5\\n```","params":[{"name":"hour","desc":"","lua_type":"number"}],"returns":[],"function_type":"static","source":{"line":11,"path":"src/numberUtil/methods/to12H.luau"}}],"properties":[{"name":"e","desc":" \\n\\nA mathematical constant, also known as Euler\'s number. ","lua_type":"number <2.7182818284590>","tags":["Read only"],"source":{"line":19,"path":"src/numberUtil/init.luau"}},{"name":"phi","desc":" \\n\\nA mathematical constant, also known as the golden ratio.","lua_type":"number <1.618033988749895>","tags":["Read only"],"source":{"line":27,"path":"src/numberUtil/init.luau"}},{"name":"tau","desc":" \\n\\nA mathematical constant, it is the circle constant representing the ratio between circumference and radius.","lua_type":"number <6.283185307179586>","tags":["Read only"],"source":{"line":35,"path":"src/numberUtil/init.luau"}},{"name":"g","desc":" \\n\\nA mathematical constant, used in calculating the gravitational attraction between two objects.","lua_type":"number <6.6743e-11>","tags":["Read only"],"source":{"line":43,"path":"src/numberUtil/init.luau"}},{"name":"ga","desc":" \\n\\nA mathematical constant (the golden angle), which is the smaller of the two angles created by\\nsectioning the circumference of a circle.","lua_type":"number <137.5>","tags":["Read only"],"source":{"line":52,"path":"src/numberUtil/init.luau"}},{"name":"ec","desc":" \\n\\nA mathematical constant (also known as Euler\'s constant - **not** to be confused with Euler\'s *number* i.e `e`\\nwhich approximately equals to `2.718`).","lua_type":"number <0.577215664901>","tags":["Read only"],"source":{"line":61,"path":"src/numberUtil/init.luau"}}],"types":[],"name":"numberUtil","desc":" \\n\\nAn utility module for working with numbers.\\n \\n```lua\\nprint(numberUtil.e) --\x3e 2.7182818284590\\nprint(numberUtil.nan(3)) --\x3e false\\n```","source":{"line":11,"path":"src/numberUtil/init.luau"}}')}}]);