# cherry

Cherry or cherry (You name it) is package manager made for LuaJIT, Started since 6/October/2020 in goal of bringing a solution for LuaJIT projects and bindings, Also it can be used to distribute Lua command-line based apps from source!

### Brief

LuaRocks has awesome history when it comes to Lua programming, However there are few points that makes LuaRocks not the best option:

- Hard to install on Windows.
- You need a C compiler (Which is not ideal especially for FFI users like me).
- Not suitable for LuaJIT users.

### Features

- No need for C compiler as you would use LuaJIT FFI.
- You can download repos from GitHub, GitLab, Bitbucket, Or even Mercurial!
- Small but great for building projects!
- Better distribution platform for LuaJIT bindings.
- You can use cherry functions into your projects as interface!
- Command-Line apps distribution made easy!
- Backward-Compatible with old versions!

### Installation and requirements

- LuaJIT compiler, In this case you can get one from [ufo](https://github.com/malkia/ufo) or [ULua](https://ulua.io).
- [curl](https://curl.haxx.se) (For downloading files!).
- Extraction tool: `unzip` for Linux, On Windows you need [7-Zip](https://www.7-zip.org)!

> If you are using Microsoft Windows, Make sure you added 7-Zip and luajit directories to PATH environment variable!

Then clone cherry in folder and add the folder to PATH on windows or add it so you can run `cherry.cmd` or `cherry.sh` depending on your OS.

### Commands

```
cherry -v or --version                          Returns cherry version
cherry get package dir [branch] [channel]       Downloads cherry package as archive from channel with branch to directory
cherry install src dir                          Installs cherry package from folder to directory
cherry valid dir                                Validate cherry package from directory
cherry new dir                                  Setup a new cherry package in directory
cherry run dir                                  Run package with LuaJIT in case it's app
cherry info dir                                 Gives info about cherry package if valid
cherry patch dir                                Creates files list for cherry package from cherry package config in directory
cherry add package dir                          Downloads and installs cherry package directly in same directory
cherry uninstall package-dir                    If cherry package in directory is valid then remove it
cherry remove package-name package-dir          Removes cherry package from directory of another cherry package
cherry update                                   Updates cherry package manager
```

### Real example

You can test features using `cherry-test`, Simple get it via following commands

```
cherry new D:\cherry-app
cherry add Rabios/cherry-test D:\cherry-app
```

> NOTE: If you asked by cherry if `cherry-app` package would be app then input Y for yes.

We will assume you use `cherry-test` as library, Simple when you created cherry package `cherry-app`, require package in the main Lua file you provided to `cherry-app` package.

```lua
local t = require("test")
print(t.add(10, 20))  --> 30
```

Then run your package `cherry-app` as it's app via `cherry run D:\cherry-app` to run it as app.

> NOTE: If you use Unix paths make sure to change slashes in paths seen in tutorial when doing this tutorial (Except for package name which is Rabios/cherry-test)

### Writing packages

Here is a config for package that it should be!

```lua
return {
  _NAME = "package-name",
  _URL = "https://github.com/user/package-repo",
  _LICENSE = "package-license",
  _CODENAME = "package-codename",
  _AUTHOR = "package-author",
  _VERSION = "package-version-string",
  _BRANCH = "master",
  _APP = false,
  description = [[
    package-description
  ]],
  package = {
    src = {
      "test.lua"
    },
    main = "test.lua",
  }
}
```

> Documentation on working with packages is available [here!](https://github.com/Rabios/cherry/blob/master/packages.md)


### Using cherry inside Lua

When you do commands with cherry, Actually cherry uses built-in functions in source code so can use them in your project!

If you want to know more info about this see [here!](https://github.com/Rabios/cherry/blob/master/api.md)

### License

See [`LICENSE.txt`](https://github.com/Rabios/cherry/blob/master/LICENSE.txt) for cherry's license and [`LICENSES.txt`](https://github.com/Rabios/cherry/blob/master/LICENSES.txt) for third party licenses.
