# cherry API (cherry interface)

You can also use cherry as module, It provides following functions to be used within cherry!

```lua
local cherry = require("cherry")
cherry.valid("D:\\cherry-test")  --> true/false
```

### Variables

```lua
cherry._VERSION     --> returns cherry version
cherry._URL         --> returns cherry repository link
cherry._AUTHOR      --> returns cherry author
cherry._PATH        --> returns file path of cherry
cherry._UPDATELINK  --> returns cherry update link
```

### `cherry.print(s)`

This provides custom version of `print` function, But it does not write a new line after writing string!

### `cherry.lua_version_num()`

Returns Lua version as number (Used to compare if package specifies a custom Lua version).

### `cherry.print_version()`

Prints version of cherry package manager.

### `cherry.dir(s)`

Returns directory from string contains full path of a file as string.

### `cherry.read_info(f)`

Reads package info and stores it in value if assigned to!

### `cherry.valid(f)`

Checks if package is valid to use.

### `cherry.get(p, d, b, q, add)`

Gets package with name `p` in directory `d`, With branch `b` and channel `q`, With option to auto install in directory `d` as boolean `add` (true/false)

### `cherry.install(s, d)`

Installs cherry package from source directory `s` to project/package directory `d`.

### `cherry.run(d, a)`

Runs package from directory `d`, With arguments `a`.

### `cherry.create(d, l, a)`

Creates new cherry package in directory `d`, With main Lua file with name `l`, And with `a` as app or not (true, false).

### `cherry.update()`

Updates cherry package manager from source code online.

> NOTES: Paths are formatted depending on OS.
