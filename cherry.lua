-- Written by Rabia Alhaffar in 4/Octorber/2020
-- Cherry package manager source code!
-- VERSION: v0.4 (10/October/2020)
if not require("jit") then
  print("CHERRY >> ERROR: NOT POSSIBLE TO USE NON-LUAJIT COMPILER WITH CHERRY!")
  return false
end
local ffi = require("ffi")
local cherry = {
  _VERSION = 0.4,
  _URL = "https://github.com/Rabios/cherry",
  _PATH = string.gsub(debug.getinfo(1).short_src, "/", (ffi.os == "Windows" and [[\]] or "/")),
  _UPDATELINK = "https://github.com/Rabios/cherry/archive/master.zip",
  _AUTHOR = "steria773 (Rabia Alhaffar)",
}
print([[
============================================================
  _|_|_|  _|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|      _|  
_|        _|    _|  _|        _|    _|  _|    _|    _|  _|    
_|        _|_|_|_|  _|_|_|    _|_|_|    _|_|_|        _|      
_|        _|    _|  _|        _|    _|  _|    _|      _|      
  _|_|_|  _|    _|  _|_|_|_|  _|    _|  _|    _|      _|      
============================================================]])
print("Cherry v" .. cherry._VERSION .. " by " .. cherry._AUTHOR .. ", " .. cherry._URL)
print([[
==================
     COMMANDS
==================
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
]])

-- Polyfill for table.unpack
-- This function implemented from link below!
-- http://www.lua.org/pil/5.1.html
table.unpack = function(t, i)
  i = i or 1
  if (t[i] ~= nil) then
    return t[i], table.unpack(t, i + 1)
  end
end

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

cherry._DIR = cherry.dir(cherry._PATH)

function cherry.read_info(f)
  return dofile(f .. "/.cherry")
end

function cherry.valid(f)
  local k = (ffi.os == "Windows" and [[\]] or "/")
  cherry.print("CHERRY >> INFO: VALIDATING PACKAGE FROM " .. string.gsub(f, "/", k) .. "\n")
  local info = cherry.read_info(f)
  local t = { "_NAME", "_URL", "_AUTHOR", "_LICENSE", "_VERSION", "_CODENAME", "_BRANCH", "_APP", "description", "package" }
  
  -- Hack was done to keep compatibility!
  if info.lib and not info.package then
    t[11] = "lib"
    info.package = info.lib
  end
  
  if info.package.license and not info.package.licenses then
    info.package.licenses = { info.package.license }
  end
  
  for x in ipairs(t) do
    if not info[x] == nil then
      cherry.print("CHERRY >> ERROR: PACKAGE " .. (info._NAME or "FROM " .. string.gsub(f, "/", k)) .. " INVALID!\n")
      return false
    end
  end
  
  if not (info.package.src and info.package.main) then
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
  
  cherry.print("CHERRY >> INFO: DOWNLOADING PACKAGE " .. p .. " FROM " .. l .. "\n")
  local i = d .. k .. string.gsub(p, "/", ".") .. ".zip"
  if ffi.os == "Windows" then
    os.execute("start /B /wait curl " .. l .. " -L -o " .. i .. " & 7z x " .. i .. " -o" .. d .. " -y & del " .. i)
  else
    os.execute("curl " .. l .. " -L -o " .. i .. " && " .. "unzip " .. i .. " -d " .. d .. " && rm -rf " .. i)
  end
  cherry.print("CHERRY >> INFO: PACKAGE " .. p .. " DOWNLOADED SUCCESSFULLY!\n")
  
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
      cherry.print("CHERRY >> CONFIRM: DO YOU WANT TO INSTALL " .. (info._NAME or p) .. " RIGHT NOW [Y/N]? ")
      local w = io.read()
      if string.lower(w) == "y" then
        cherry.print("CHERRY >> CONFIRM: WHERE TO INSTALL " .. (info._NAME or p) .. "? (INPUT DIRECTORY!) ")
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

function cherry.uninstall(p)
  local k = (ffi.os == "Windows" and [[\]] or "/")
  if cherry.valid(p) then
    local info = cherry.read_info(p)
    cherry.print("CHERRY >> INFO: UNINSTALLING PACKAGE " .. info._NAME .. "...\n")
    os.execute(ffi.os == "Windows" and "rmdir /Q /S " .. string.gsub(p, "/", k) or "rm -r -f " .. string.gsub(p, "/", k))
    cherry.print("CHERRY >> INFO: PACKAGE " .. info._NAME .. " UNINSTALLED SUCCESSFULLY!\n")
  end
end

function cherry.remove(p, d)
  local k = (ffi.os == "Windows" and [[\]] or "/")
  local info = dofile(string.gsub(d .. "/" .. p .. ".files", "/", k))
  cherry.print("CHERRY >> INFO: REMOVING PACKAGE " .. p .. " FROM " .. d .. "\n")
  for f in ipairs(info) do
    os.execute("erase " .. string.gsub(d, "/", k) .. k .. info[f])
  end
  os.execute("erase " .. string.gsub(d .. "/" .. p .. ".files", "/", k))
  cherry.print("CHERRY >> INFO: PACKAGE " .. p .. " REMOVED SUCCESSFULLY!\n")
end

function cherry.install(s, d)
  local info = cherry.read_info(s)
  
  -- Hack was done to keep compatibility!
  if not info.package then
    info.package = info.lib or nil
  end
  
  if info.package.license and not info.package.licenses then
    info.package.licenses = { info.package.license }
  end
  
  os.execute("mkdir " .. d)
  if not cherry.valid(s) then
    cherry.print("CHERRY >> ERROR: FAILED TO INSTALL PACKAGE! (0)\n")
    return false
  end
  cherry.print("CHERRY >> INFO: INSTALLING PACKAGE " .. (info._NAME or "FROM " .. s) .. " TO " .. d .. "\n")
  
  local c = (ffi.os == "Windows" and "copy /Y " or "cp ")
  local k = (ffi.os == "Windows" and "\\" or "/")
  local pf = io.open(d .. "/" .. info._NAME .. ".files", "w")
  pf:write("return { ")
  
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
  
  if info.package.src then
    if #info.package.src > 0 then
      for f in ipairs(info.package.src) do
        if string.match(info.package.src[f], ".lua") then
          if not cherry.dir(info.package.src[f]) == info.package.src[f] then
            os.execute("mkdir " .. cherry.dir(d .. k .. info.package.src[f]))
          end
          os.execute(c .. string.gsub(s, "/", k) .. k .. string.gsub(info.package.src[f], "/", k) .. " " .. d)
          pf:write('"' .. string.gsub(info.package.src[f], "/", k) .. '"' .. ", ")
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
  
  if info.package.shared then
    if #info.package.shared > 0 then
      for f in ipairs(info.package.shared) do
        if string.match(info.package.shared[f], ".so") or string.match(info.package.shared[f], ".dll") or string.match(info.package.shared[f], ".dylib") or string.match(info.package.shared[f], ".a") or string.match(info.package.shared[f], ".o") or string.match(info.package.shared[f], ".lib") then
          if not cherry.dir(info.package.shared[f]) == info.package.shared[f] then
            os.execute("mkdir " .. cherry.dir(d .. k .. info.package.shared[f]))
          end
          pf:write('"' .. string.gsub(info.package.shared[f], "/", k) .. '"' .. ", ")
          os.execute(c .. string.gsub(s, "/", k) .. k .. string.gsub(info.package.shared[f], "/", k) .. " " .. d)
        end
      end
    end
  end
  
  if info.package.resources then
    if #info.package.resources > 0 then
      for f in ipairs(info.package.resources) do
        if not (string.match(info.package.resources[f], ".lua") and string.match(info.package.resources[f], ".so") and string.match(info.package.resources[f], ".dll") and string.match(info.package.resources[f], ".dylib") and string.match(info.package.resources[f], ".a") and string.match(info.package.resources[f], ".o") and string.match(info.package.resources[f], ".lib")) then
          if not cherry.dir(info.package.resources[f]) == info.package.resources[f] then
            os.execute("mkdir " .. cherry.dir(d .. k .. info.package.resources[f]))
          end
          pf:write('"' .. string.gsub(info.package.resources[f], "/", k) .. '"' .. ", ")
          os.execute(c .. string.gsub(s, "/", k) .. k .. string.gsub(info.package.resources[f], "/", k) .. " " .. d)
        end
      end
    end
  end
    
  if info.package.licenses then
    if #info.package.licenses > 0 then
      for f in ipairs(info.package.licenses) do
        if not cherry.dir(info.package.licenses[f]) == info.package.licenses[f] then
          os.execute("mkdir " .. cherry.dir(d .. k .. info.package.licenses[f]))
        end
        pf:write('"' .. string.gsub(string.gsub(info.package.licenses[f], "LICENSE", info._NAME .. "-LICENSE"), "/", k) .. '"' .. ", ")
        os.execute(c .. string.gsub(s, "/", k) .. k .. info.package.licenses[f] .. " " .. d .. k .. string.gsub(string.gsub(info.package.licenses[f], "LICENSE", info._NAME .. "-LICENSE"), "/", k))
      end
    end
  end
  
  if info.package.readme then
    if not cherry.dir(info.package.readme) == info.package.readme then
      os.execute("mkdir " .. cherry.dir(d .. k .. info.package.readme))
    end
    pf:write('"' .. string.gsub(info._NAME .. "-" .. info.package.readme, "/", k) .. '"' .. ", ")
    os.execute(c .. string.gsub(s, "/", k) .. k .. info.package.readme .. " " .. d .. k .. info._NAME .. "-" .. info.package.readme)
  end
  
  if info.package.external_files then
    if not #info.package.external_files > 0 then
      for f in ipairs(info.package.external_files) do
        cherry.print("CHERRY >> INFO: DOWNLOADING " .. info.package.external_files[f])
        if ffi.os == "Windows" then
          os.execute("start /B /wait curl " .. info.package.external_files[f] .. " -L -o " .. d)
        else
          os.execute("curl " .. info.package.external_files[f] .. " -L -o " .. d)
        end
        pf:write('"' .. info.package.external_files[f] .. '"' .. ", ")
      end
    end
  end
  
  if info.package.dependencies then
    if #info.package.dependencies > 0 then
      for f in ipairs(info.package.dependencies) do
        cherry.print("CHERRY >> INFO: DOWNLOADING DEPENDENCIES (" .. info.package.dependencies[f][1] .. ")\n")
        os.execute("cherry add " .. info.package.dependencies[f][1] .. " " .. d .. " " .. (info.package.dependencies[f][2] or "master") .. " " .. (info.package.dependencies[f][3] or "github"))
      end
    end
  end
  
  pf:write("}")
  pf:close()
  cherry.print("CHERRY >> INFO: PACKAGE " .. info._NAME .. " INSTALLED SUCCESSFULLY!\n")
  os.execute(ffi.os == "Windows" and "rmdir /Q /S " .. string.gsub(s, "/", k) or "rm -r -f " .. string.gsub(s, "/", k))
  if info.package.on_install then
    if type(info.package.on_install) == "function" then
      info.package.on_install()
    elseif type(info.package.on_install) == "string" then
      os.execute(info.package.on_install)
    end
  end
  return true
end

function cherry.run(d, a)
  local k = (ffi.os == "Windows" and [[\]] or "/")
  local o = (ffi.os == "Windows" and "&" or "&&")
  local info = cherry.read_info(string.gsub(d, "/", k))
  
  -- Hack was done to keep compatibility!
  if not info.package then
    info.package = info.lib or nil
  end
  
  if info.package.license and not info.package.licenses then
    info.package.licenses = { info.package.license }
  end
  
  if cherry.valid(d) then
    if info._APP then
      for i in ipairs(info.package.src) do
        if (string.match(info.package.src[i], info.package.main)) then
          cherry.print("CHERRY >> INFO: RUNNING PACKAGE " .. info._NAME .. " AS APP...\n")
          os.execute("cd " .. d .. " " .. o .. " luajit " .. info.package.main .. " " .. (unpack(a) or ""))
          cherry.print("CHERRY >> INFO: PACKAGE " .. info._NAME .. " RAN AS APP SUCCESSFULLY!\n")
          break
        end
      end
    else
      cherry.print("CHERRY >> ERROR: PACKAGE " .. info._NAME .. " IS LIBRARY!\n")
      return false
    end
  end
end

function cherry.info(d)
  if cherry.valid(d) then
    local info = cherry.read_info(d)
    local p = info._NAME
    cherry.print("CHERRY >> INFO: COLLECTING INFO FROM " .. p .. "...\n")
    local t1 = { "_URL", "_AUTHOR", "_LICENSE", "_VERSION", "_CODENAME", "_BRANCH", "description" }
    local t2 = { "src", "shared", "resources", "licenses" }
    local t3 = { "main", "_LUA", "_OS", "_ARCH", "_CHERRY", "readme" }
    for x in ipairs(t1) do
      cherry.print("CHERRY >> INFO: " .. p .. " " .. string.lower(string.gsub(t1[x], "_", "")) .. ": " .. info[t1[x]] .. "\n")
    end
    for y in ipairs(t2) do
      local z = info["package"][t2[y]]
      if z ~= nil then
        for w in ipairs(z) do
          cherry.print("CHERRY >> INFO: " .. p .. " " .. string.gsub(t2[w], "src", "files") .. ": " .. table.unpack(z) .. "\n")
        end
      end
    end
    for q in ipairs(t3) do
      local x = info["package"][t3[q]]
      local r = (x or "NOT FOUND!")
      cherry.print("CHERRY >> INFO: " .. p .. " " .. string.lower(string.gsub(t3[q], "_", "LIMIT ")) .. ": " .. r .. "\n")
    end
    cherry.print("CHERRY >> INFO: IS PACKAGE " .. p .. " APP: " .. (info._APP and "YES" or "NO") .. "\n")
    cherry.print("CHERRY >> INFO: PACKAGE " .. p .. " INFORMATION COLLECTED SUCCESSFULLY!\n")
  end
end

function cherry.patch(d)
  if cherry.valid(d) then
    local info = cherry.read_info(d)
    local k = (ffi.os == "Windows" and "\\" or "/")
    
    -- Hack was done to keep compatibility!
    if not info.package then
      info.package = info.lib or nil
    end
    if info.package.license and not info.package.licenses then
      info.package.licenses = { info.package.license }
    end
    
    cherry.print("CHERRY >> INFO: WRITING FILES LIST FOR " .. info._NAME .. "...\n")
    local pf = io.open(d .. "/" .. info._NAME .. ".files", "w")
    pf:write("return { ")
    
    if info.package.src then
      if #info.package.src > 0 then
        for f in ipairs(info.package.src) do
          if string.match(info.package.src[f], ".lua") then
            pf:write('"' .. string.gsub(info.package.src[f], "/", k) .. '"' .. ", ")
          end
        end
      end
    end
  
    if info.package.shared then
      if #info.package.shared > 0 then
        for f in ipairs(info.package.shared) do
          if string.match(info.package.shared[f], ".so") or string.match(info.package.shared[f], ".dll") or string.match(info.package.shared[f], ".dylib") or string.match(info.package.shared[f], ".a") or string.match(info.package.shared[f], ".o") or string.match(info.package.shared[f], ".lib") then
            pf:write('"' .. string.gsub(info.package.shared[f], "/", k) .. '"' .. ", ")
          end
        end
      end
    end
  
    if info.package.resources then
      if #info.package.resources > 0 then
        for f in ipairs(info.package.resources) do
          if not (string.match(info.package.resources[f], ".lua") and string.match(info.package.resources[f], ".so") and string.match(info.package.resources[f], ".dll") and string.match(info.package.resources[f], ".dylib") and string.match(info.package.resources[f], ".a") and string.match(info.package.resources[f], ".o") and string.match(info.package.resources[f], ".lib")) then
            pf:write('"' .. string.gsub(info.package.resources[f], "/", k) .. '"' .. ", ")
          end
        end
      end
    end
    
    if info.package.licenses then
      if #info.package.licenses > 0 then
        for f in ipairs(info.package.licenses) do
          pf:write('"' .. string.gsub(string.gsub(info.package.licenses[f], "LICENSE", info._NAME .. "-LICENSE"), "/", k) .. '"' .. ", ")
        end
      end
    end
  
    if info.package.readme then
      pf:write('"' .. string.gsub(info._NAME .. "-" .. info.package.readme, "/", k) .. '"' .. ", ")
    end
  
    if info.package.external_files then
      if not #info.package.external_files > 0 then
        for f in ipairs(info.package.external_files) do
          pf:write('"' .. info.package.external_files[f] .. '"' .. ", ")
        end
      end
    end
  
    pf:write("}")
    pf:close()
    cherry.print("CHERRY >> INFO: FILES LIST FOR " .. info._NAME .. " WRITTEN SUCCESSFULLY!\n")
  end
end

function cherry.create(d, l, a)
  local k = (ffi.os == "Windows" and [[\]] or "/")
  os.execute("mkdir " .. string.gsub(d, "/", k))
  cherry.print("CHERRY >> CONFIRM: WHAT NAME OF MAIN LUA FILE? (INPUT!) ")
  local t = l or io.read()
  cherry.print("CHERRY >> CONFIRM: IS PACKAGE AN APP? [Y/N] ")
  local u = a or io.read()
  local q = string.lower(u) == "y" and "true" or string.lower(u) == "n" and "false"
  cherry.print("CHERRY >> INFO: CREATING PACKAGE IN DIRECTORY " .. d .. "\n")
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
  package = {
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
  cherry.print("CHERRY >> INFO: PACKAGE IN DIRECTORY " .. d .. " CREATED SUCCESSFULLY!\n")
	cherry.print("CHERRY >> NOTE: WHEN YOU DISTRIBUTE YOUR PACKAGE, MAKE SURE YOU EDIT PACKAGE PROPERTIES VIA FILE CALLED .cherry (IN DIRECTORY OF PACKAGE)\n")
  return true
end

function cherry.update()
  cherry.print("CHERRY >> INFO: UPDATING CHERRY...\n")
  cherry.get("Rabios/cherry", cherry._DIR, "master", "github", true)
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
  elseif arg[a] == "info" then
    local d = arg[a + 1]
    cherry.info(d)
  elseif arg[a] == "patch" then
    local d = arg[a + 1]
    cherry.patch(d)
  elseif arg[a] == "uninstall" then
    local p = arg[a + 1]
    cherry.uninstall(p)
  elseif arg[a] == "remove" then
    local p = arg[a + 1]
    local d = arg[a + 2]
    cherry.remove(p, d)
  elseif arg[a] == "install" then
    local s = arg[a + 1]
    local d = arg[a + 2]
    cherry.install(s, d)
  elseif arg[a] == "valid" then
    local f = arg[a + 1]
    cherry.valid(f)
  end
end
