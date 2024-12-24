---
sidebar_position: 1
---

# Installation

The opsn sourced libraries for Roblox can be installed via [Wally](https://wally.run/).

## Wally Setup

Install [Wally](https://wally.run/) and once it is installed, run `wally init` on your project directory, and then add the various open-sourced libraries that you need
as wally dependencies. For e.g, the following may be a `wally.toml` file for a project that includes a `numberUtil` wally package:

```toml
[package]
name = "someuser/project"
version = "1.0.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
numberUtil = "bubshurb/numberutil@2"
```

Now, to install these dependencies, run `wally install` within your project. [Wally](https://wally.run/) will then create a package folder in your directory with the installed dependencies. Then use [Rojo](https://rojo.space/) to sync in the package folder to Studio.

## Usage Example

Once the above necessary steps are completed, the installed wally dependencies can now be used in code, for e.g:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local numberUtil = require(ReplicatedStorage.Packages.numberUtil)

print(numberUtil.factors(2)) --> {1, 2}
```
