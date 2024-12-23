"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[6456],{27793:a=>{a.exports=JSON.parse('{"functions":[{"name":"matchingRowsValue","desc":"Searches `matrix` row-wise, and returns a value in a row that matches with\\nthe rest of the values of that row. E.g:\\n\\n```lua\\nlocal matrix = {\\n    {1, 1, 1},\\n    {5, 5, 2}, \\n    {0, 0, 2},\\n}\\n\\nprint(matrixUtil.matchingRowsValue(matrix)) --\x3e 1 (The first row is equally matched (all 1s))\\n```\\n\\nAdditionally, you can specify `depth` if you want to control how far the \\nmethod should check each row. For e.g: \\n\\n```lua\\nlocal matrix = {\\n    {1, 2, 3, 4}, \\n    {5, 6, 7, 8}, \\n    {1, 1, 1, 0}, \\n}\\n\\nprint(matrixUtil.matchingRowsValue(matrix, 3)) --\x3e 1  (The last row\'s first 3 values (1s) are equally matched)\\nprint(matrixUtil.matchingRowsValue(matrix, 4)) --\x3e nil  (No row\'s first 4 values are equally matched)\\n```","params":[{"name":"matrix","desc":"","lua_type":"{ { T } }"},{"name":"depth","desc":"","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"T?\\n"}],"function_type":"static","source":{"line":46,"path":"src/matrixUtil/init.luau"}},{"name":"matchingDiagonalColumnsValue","desc":"Searches `matrix` diagonally, and returns a value that matches with the \\nrest of the values of the arrays in `matrix`. \\n\\nE.g:\\n\\n```lua\\nlocal matrix = {\\n    {5, 0, 0},\\n    {0, 5, 0},\\n    {0, 0, 5},\\n}\\n\\nprint(matrixUtil.matchingDiagonalColumnsValue(matrix)) --\x3e 1 (A column has matching values diagonally (just 5s))\\n```\\n\\nAdditionally, you can specify `depth` if you want to control how far the \\nmethod should search `matrix` diagonally. For e.g: \\n\\n```lua\\nlocal matrix = {\\n    {2, 0, 0, 0},\\n    {0, 2, 0, 0},\\n    {0, 0, 2, 0},\\n    {0, 0, 0, 0},\\n}\\n\\nprint(matrix.matchingDiagonalColumnsValue(matrix, 3)) --\x3e 2 (A column has FIRST 3 matching values diagonally (just 2s))\\n```","params":[{"name":"matrix","desc":"","lua_type":"{ { T } }"},{"name":"depth","desc":"","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"T?\\n"}],"function_type":"static","source":{"line":101,"path":"src/matrixUtil/init.luau"}},{"name":"matchingColumnsValue","desc":"Searches `matrix` column-wise and returns a value of a column that matches \\nwith the rest of the values of that column. E.g:\\n\\n```lua\\nlocal matrix = {\\n    {5, 0, 0},\\n    {5, 1, 0},\\n    {5, 0, 1},\\n}\\n\\nprint(matrixUtil.matchingColumnsValue(matrix)) --\x3e 5 (A column has ALL equally matching values (just 5s))\\n```\\n\\nAdditionally, you can specify `depth` if you want to control how far the \\nmethod should check each column. For e.g: \\n\\n```lua\\nlocal matrix = {\\n    {5, 0, 0},\\n    {5, 0, 0},\\n    {2, 1, 1},\\n}\\n\\nprint(matrixUtil.matchingColumnsValue(matrix, 2)) --\x3e 5 (A column has FIRST 2 matching values (just 5s))\\n```","params":[{"name":"matrix","desc":"","lua_type":"{ { T } }"},{"name":"depth","desc":"","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"T?\\n"}],"function_type":"static","source":{"line":168,"path":"src/matrixUtil/init.luau"}}],"properties":[],"types":[],"name":"matrixUtil","desc":"An utility module for working with matrixes. A matrix is simply an array \\nconsisting of arrays, for e.g:\\n\\n```lua\\nlocal matrix = {\\n    {1, 1, 2},\\n    {1, 1, 1},\\n    {3, 3, 3},\\n}\\n```","source":{"line":15,"path":"src/matrixUtil/init.luau"}}')}}]);