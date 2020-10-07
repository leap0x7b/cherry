-- Written by Rabia Alhaffar in 4/Octorber/2020
-- Cherry package manager source code!
-- VERSION: v0.1 (7/October/2020)
if not require("jit") then
  print("CHERRY >> ERROR: NOT POSSIBLE TO USE NON-LUAJIT COMPILER WITH CHERRY!")
  return false
end
local ffi = require("ffi")
local cherry = {
  _VERSION = 0.1,
  _URL = "https://github.com/Rabios/cherry",
  _PATH = string.gsub(debug.getinfo(1).short_src, "/", (ffi.os == "Windows" and [[\]] or "/")),
  _UPDATELINK = "https://raw.githubusercontent.com/Rabios/cherry/master/cherry.lua",
  _AUTHOR = "steria773 (Rabia Alhaffar)",
}
print([[
=============================================================
  _|_|_|  _|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|      _|  
_|        _|    _|  _|        _|    _|  _|    _|    _|  _|    
_|        _|_|_|_|  _|_|_|    _|_|_|    _|_|_|        _|      
_|        _|    _|  _|        _|    _|  _|    _|      _|      
  _|_|_|  _|    _|  _|_|_|_|  _|    _|  _|    _|      _|      
=============================================================]])
print("Cherry " .. cherry._VERSION .. " by " .. cherry._AUTHOR .. ", " .. cherry._URL)
print([[
==================
     COMMANDS
==================
cherry -v or --version                    Returns cherry version
cherry get package dir [branch] [channel] Downloads cherry package as archive from channel with branch to directory
cherry install src dir                    Installs cherry package from folder to directory
cherry valid dir                          Validate cherry package from directory
cherry new dir                            Setup a new cherry package in directory
cherry run dir                            Run package with LuaJIT in case it's app
cherry add package dir                    Same as cherry get command but installs package directly in same directory
cherry update                             Updates cherry package manager
]])

-- https://stackoverflow.com/a/7153689/10896648
local write = io.write
function cherry.print(...)
  local n = select("#",...)
  for i = 1,n do
    local v = tostring(select(i,...))
    write(v)
    if i~=n then write'\t' end
  end
end

function cherry.lua_version_num()
  local s = string.gsub(_G._VERSION, "Lua ", "")
  return tonumber(s)
end

function cherry.print_version()
  cherry.print("CHERRY >> INFO: CHERRY VERSION IS v" .. cherry._VERSION .. "\n")
  return true
end

-- https://stackoverflow.com/a/9102300/10896648
function cherry.getPath(str, sep)
  sep = sep or "/"
  return str:match("(.*" .. sep .. ")")
end

function cherry.dir(s)
  return ffi.os == "Windows" and cherry.getPath(s, "\\") or cherry.getPath(s)
end

function cherry.read_info(f)
  return dofile(f .. "/.cherry")
end

function cherry.valid(f)
  local k = (ffi.os == "Windows" and [[\]] or "/")
  cherry.print("CHERRY >> INFO: VALIDATING PACKAGE FROM " .. string.gsub(f, "/", k) .. "\n")
  local info = cherry.read_info(f)
  local t = { "_NAME", "_URL", "_AUTHOR", "_LICENSE", "_VERSION", "_CODENAME", "_BRANCH", "_APP", "description", "lib" }
  
  for x in ipairs(t) do
    if not info[x] == nil then
      cherry.print("CHERRY >> ERROR: PACKAGE " .. (info._NAME or "FROM " .. string.gsub(f, "/", k)) .. " INVALID!\n")
      return false
    end
  end
  
  if not (info.lib.src and info.lib.main) then
    cherry.print("CHERRY >> ERROR: PACKAGE " .. (info._NAME or "FROM " .. string.gsub(f, "/", k)) .. " INVALID!\n")
    return false
  end
  
  cherry.print("CHERRY >> INFO: PACKAGE " .. (info._NAME or "FROM " .. string.gsub(f, "/", k)) .. " VALID!\n")
  return true
end

function cherry.get(p, d, b, q, add)
  local l = ""
  local u = ""
  local v = true
  local k = (ffi.os == "Windows" and [[\]] or "/")
  os.execute("mkdir " .. d)
  if q == "github" then
    l = "https://github.com/" .. p .. "/archive/" .. b .. ".zip"
  elseif q == "gitlab" then
    for x = 1, #p, 1 do
      if (string.char(string.byte(p, x - 1)) == "/") then v = true end
      if (v) then u = u .. (string.char(string.byte(p, x))) end
    end
    l = "https://gitlab.com/" .. p .. "/-/archive/" .. b .. "/" .. u .. "-" .. b .. ".zip"
  elseif q == "mercurial" then
    for x = 1, #p, 1 do
      if (string.char(string.byte(p, x)) == "/") then break end
      u = u .. (string.char(string.byte(p, x)))
    end
    l = "https://hg." .. string.lower(u) .. ".org/" .. p .. "/archive/" .. b .. ".zip"
  elseif q == "bitbucket" then
    l = "https://bitbucket.org/" .. p .. "/get/" .. b .. ".zip"
  end
  
  local i = d .. k .. string.gsub(p, "/", ".") .. ".zip"
  if ffi.os == "Windows" then
    os.execute("start /B /wait curl " .. l .. " -L -o " .. i .. " & 7z x " .. i .. " -o" .. d .. " -y & del " .. i)
  else
    os.execute("curl " .. l .. " -L -o " .. i .. " && " .. "unzip " .. i .. " -d " .. d .. " && rm -rf " .. i)
  end
  
  local j = ""
  local g = false
  for z = 1, #p, 1 do
    if (string.char(string.byte(p, z - 1)) == "/") then
      g = true
    end
    if g then
      j = j .. string.char(string.byte(p, z))
    end
  end
  local r = d .. "/" .. j .. "-" .. b
  if cherry.valid(r) then
    local info = cherry.read_info(d)
    if add then
      cherry.install(r, d)
    else
      cherry.print("CHERRY >> CONFIRMATION: DO YOU WANT TO INSTALL " .. (info._NAME or p) .. " RIGHT NOW [Y/N]? ")
      local w = io.read()
      if string.lower(w) == "y" then
        cherry.print("CHERRY >> CONFIRMATION: WHERE TO INSTALL " .. (info._NAME or p) .. "? (INPUT DIRECTORY!) ")
        local kk = io.read()
        cherry.install(r, kk)
      elseif string.lower(w) == "n" then
        cherry.print("CHERRY >> INFO: DIRECT INSTALLATION NOT CONFIRMED!\n")
      end
    end
  else
    cherry.print("CHERRY >> ERROR: PACKAGE " .. (info._NAME or "FROM " .. string.gsub(p, "/", k)) .. " INVALID!\n")
    return false
  end
  return true
end

function cherry.install(s, d)
  local info = cherry.read_info(s)
  os.execute("mkdir " .. d)
  if not cherry.valid(s) then
    cherry.print("CHERRY >> ERROR: FAILED TO INSTALL PACKAGE! (0)\n")
    return false
  end
  cherry.print("CHERRY >> INFO: INSTALLING PACKAGE " .. (info._NAME or "FROM " .. s) .. " TO " .. d .. "\n")
  
  local c = (ffi.os == "Windows" and "copy /Y " or [[\cp ]])
  local k = (ffi.os == "Windows" and "\\" or "/")
  
  if info._OS then
    if not info._OS == "global" then
      if not ffi.os == info._OS then
        cherry.print("CHERRY >> ERROR: FAILED TO INSTALL PACKAGE! (1)\n")
        os.execute(ffi.os == "Windows" and "rmdir /Q /S " .. string.gsub(s, "/", k) or "rm -r -f " .. string.gsub(s, "/", k))
        return false
      end
    end
  end
  
  if info._ARCH then
    if not info._ARCH == "global" then
      if not ffi.arch == info._ARCH then
        cherry.print("CHERRY >> ERROR: FAILED TO INSTALL PACKAGE! (1)\n")
        os.execute(ffi.os == "Windows" and "rmdir /Q /S " .. string.gsub(s, "/", k) or "rm -r -f " .. string.gsub(s, "/", k))
        return false
      end
    end
  end
  
  if info._CHERRY then
    if not info._CHERRY == "global" then
      if not cherry._VERSION >= info._CHERRY then
        cherry.print("CHERRY >> ERROR: FAILED TO INSTALL PACKAGE! (2)\n")
        os.execute(ffi.os == "Windows" and "rmdir /Q /S " .. string.gsub(s, "/", k) or "rm -r -f " .. string.gsub(s, "/", k))
        return false
      end
    end
  end
  
  if info._LUA then
    if not info._LUA == "global" then
      if not cherry._LUA >= cherry.lua_version_num() then
        cherry.print("CHERRY >> ERROR: FAILED TO INSTALL PACKAGE! (2)\n")
        os.execute(ffi.os == "Windows" and "rmdir /Q /S " .. string.gsub(s, "/", k) or "rm -r -f " .. string.gsub(s, "/", k))
        return false
      end
    end
  end
  
  if info.lib.src then
    if #info.lib.src > 0 then
      for f in ipairs(info.lib.src) do
        if string.match(info.lib.src[f], ".lua") then
          os.execute("mkdir " .. d .. k .. cherry.dir(info.lib.src[f]))
          os.execute(c .. string.gsub(s, "/", k) .. k .. string.gsub(info.lib.src[f], "/", k) .. " " .. d)
        end
      end
    else
      cherry.print("CHERRY >> ERROR: FAILED TO INSTALL PACKAGE! (3)\n")
      return false
    end
  else
    cherry.print("CHERRY >> ERROR: FAILED TO INSTALL PACKAGE! (3)\n")
    return false
  end
  
  if info.lib.shared then
    if #info.lib.shared > 0 then
      for f in ipairs(info.lib.shared) do
        if string.match(info.lib.shared[f], ".so") or string.match(info.lib.shared[f], ".dll") or string.match(info.lib.shared[f], ".dylib") or string.match(info.lib.shared[f], ".a") or string.match(info.lib.shared[f], ".o") or string.match(info.lib.shared[f], ".lib") then
          os.execute("mkdir " .. d .. k .. cherry.dir(info.lib.shared[f]))
          os.execute(c .. s .. k .. string.gsub(info.lib.shared[f], "/", k) .. " " .. d)
        end
      end
    end
  end
  
  if info.lib.resources then
    if #info.lib.resources > 0 then
      for f in ipairs(info.lib.resources) do
        if not (string.match(info.lib.resources[f], ".lua") or string.match(info.lib.resources[f], ".so") or string.match(info.lib.resources[f], ".dll") or string.match(info.lib.resources[f], ".dylib") or string.match(info.lib.resources[f], ".a") or string.match(info.lib.resources[f], ".o") or string.match(info.lib.resources[f], ".lib")) then
          os.execute("mkdir " .. d .. k .. cherry.dir(info.lib.resources[f]))
          os.execute(c .. s .. k .. string.gsub(info.lib.resources[f], "/", k) .. " " .. d)
        end
      end
    end
  end
    
  if info.lib.license then
    os.execute("mkdir " .. d .. k .. cherry.dir(info.lib.license))
    os.execute(c .. s .. k .. info.lib.license .. " " .. d .. k .. info._NAME .. "-" .. info.lib.license)
  end
  
  if info.lib.readme then
    os.execute("mkdir " .. d .. k .. cherry.dir(info.lib.readme))
    os.execute(c .. s .. k .. info.lib.readme .. " " .. d .. k .. info._NAME .. "-" .. info.lib.readme)
  end
  
  if info.lib.external_files then
    if not #info.lib.external_files > 0 then
      for f in ipairs(info.lib.external_files) do
        cherry.print("CHERRY >> INFO: DOWNLOADING " .. info.lib.external_files[f])
        if ffi.os == "Windows" then
          os.execute("start /B /wait curl " .. info.lib.external_files[f] .. " -L -o " .. d)
        else
          os.execute("curl " .. info.lib.external_files[f] .. " -L -o " .. d)
        end
      end
    end
  end
  
  if info.lib.dependencies then
    if #info.lib.dependencies > 0 then
      for f in ipairs(info.lib.dependencies) do
        cherry.print("CHERRY >> INFO: DOWNLOADING DEPENDENCIES (" .. info.lib.dependencies[f][1] .. ")\n")
        os.execute("cherry add " .. info.lib.dependencies[f][1] .. " " .. d .. " " .. (info.lib.dependencies[f][2] or "master") .. " " .. (info.lib.dependencies[f][3] or "github"))
      end
    end
  end
  
  cherry.print("CHERRY >> INFO: PACKAGE " .. info._NAME .. " INSTALLED SUCCESSFULLY!\n")
  os.execute(ffi.os == "Windows" and "rmdir /Q /S " .. string.gsub(s, "/", k) or "rm -r -f " .. string.gsub(s, "/", k))
  if type(info.lib.on_install) == "function" then
    info.lib.on_install()
  elseif type(info.lib.on_install) == "string" then
    os.execute(info.lib.on_install)
  end
  return true
end

function cherry.run(d, a)
  local k = (ffi.os == "Windows" and [[\]] or "/")
  local o = (ffi.os == "Windows" and "&" or "&&")
  local info = cherry.read_info(string.gsub(d, "/", k))
  if cherry.valid(d) then
    if info._APP then
      for i in ipairs(info.lib.src) do
        if (string.match(info.lib.src[i], info.lib.main)) then
          os.execute("cd " .. d .. " " .. o .. " luajit " .. d .. k .. info.lib.main .. " " .. (unpack(a) or ""))
          break
        end
      end
    else
      cherry.print("CHERRY >> ERROR: PACKAGE IS LIBRARY!\n")
      return false
    end
  end
end

function cherry.create(d, l, a)
  local k = (ffi.os == "Windows" and [[\]] or "/")
  os.execute("mkdir " .. string.gsub(d, "/", k))
  cherry.print("CHERRY >> CONFIRMATION: WHAT NAME OF MAIN LUA FILE? (INPUT!) ")
  local t = l or io.read()
  cherry.print("CHERRY >> CONFIRMATION: IS PACKAGE AN APP? [Y/N] ")
  local u = a or io.read()
  local q = string.lower(u) == "y" and "true" or string.lower(u) == "n" and "false"
  local c = io.open(string.gsub(d, "/", k) .. k .. string.gsub("/.cherry", "/", k), "w")
  c:write([[return {
  _NAME = "package-name",
  _URL = "https://github.com/user/package-repo",
  _LICENSE = "package-license",
  _CODENAME = "package-codename",
  _AUTHOR = "package-author",
  _VERSION = "package-version-string",
  _BRANCH = "master",
  _APP = ]] .. q .. "," .. [[
  
  description = "package-description",
  lib = {
    src = {
      ]] .. '"' .. t .. '"' .. "\n" .. [[
    },
    main = ]] .. '"' .. t .. '"' .. [[,
  }
}]])
  c:close()
  local m = io.open(d .. string.gsub("/" .. t, "/", k), "w")
  m:write("-- TODO: Code!")
  m:close()
  cherry.print("CHERRY >> INFO: PACKAGE " .. d .. " CREATED SUCCESSFULLY!\n")
  return true
end

function cherry.update()
  local k = (ffi.os == "Windows" and [[\]] or "/")
  local f = string.gsub(debug.getinfo(1).short_src, "/", k)
  local l = cherry._UPDATELINK
  cherry.print("CHERRY >> INFO: UPDATING CHERRY...\n")
  if ffi.os == "Windows" then
    return os.execute("start /B /wait curl " .. l .. " -L -o " .. f)
  else
    return os.execute("curl " .. l .. " -L -o " .. f)
  end
end

local arg = { ... }
for a in ipairs(arg) do
  if arg[a] == "-v" or arg[a] == "--version" then
    cherry.print_version()
  elseif arg[a] == "new" then
    local d = arg[a + 1]
    cherry.create(d)
  elseif arg[a] == "run" then
    local d = arg[a + 1]
    local a = arg
    table.remove(a, 1)
    cherry.run(d, a)
  elseif arg[a] == "update" then
    cherry.update()
  elseif arg[a] == "get" then
    local p = arg[a + 1]
	  local d = arg[a + 2]
    local b = arg[a + 3] or "master"
    local q = arg[a + 4] or "github"
    local add = false
    cherry.get(p, d, b, q, add)
  elseif arg[a] == "add" then
    local p = arg[a + 1]
	  local d = arg[a + 2]
    local b = arg[a + 3] or "master"
    local q = arg[a + 4] or "github"
    local add = true
    cherry.get(p, d, b, q, add)
  elseif arg[a] == "install" then
    local s = arg[a + 1]
    local d = arg[a + 2]
    cherry.install(s, d)
  elseif arg[a] == "valid" then
    local f = arg[a + 1]
    cherry.valid(f)
  end
end