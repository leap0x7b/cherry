# Errors

Errors might happen in cherry in some cases, They are divided into 2 types:

1. [Usage Errors](#)
2. [Installation Errors](#)

### Usage Errors

These errors might happen when using cherry and have nothing to do with installation errors...

1. `YOUR VERSION OF LUA REQUIRES FFI!`

This error happens when there is no `ffi` on your version of Lua, This could be solved by installing luaffi or using LuaJIT instead...

### Installation Errors

When validating/installing a cherry package, Some errors might happen for a lot of reasons...

1. `PACKAGE <name> FROM <loc> IS INVALID!`

This happens when validating package and `.cherry` file of the package miss important properties...

2. `FAILED TO INSTALL PACKAGE! (0)`

This happens when created/used directory to install package to is invalid or unavailable...

3. `FAILED TO INSTALL PACKAGE! (1)`

This can happen if OS or CPU architecture is incompatible...

4. `FAILED TO INSTALL PACKAGE! (2)`

This can happen if Lua version or cherry version is incompatible...

5. `FAILED TO INSTALL PACKAGE! (3)`

This can happen if there is no `src` info inside `.cherry` of the package...

6. `PACKAGE <name> IS LIBRARY!`

This can happen if you are trying to use `cherry run` to run package and it's not application...
