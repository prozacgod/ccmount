TEST = {}
--[[
  this testing environment is ran inside luajit not lua - luajit was closer
  to a computercraft environment on my system.  YMMV - post patches ;)
]]

local inspect = require('inspect')
local utils = require('utils')

local compareArray = utils.compareArray
local splitPath = utils.splitPath
local testArrays = utils.testArrays

assert(compareArray({"a","b"}, {"b","a"}))
assert(not compareArray({"b","a"}, {"a","a"}))
assert(not compareArray({"b","c"}, {"a","a"}))
assert(not compareArray({"b","a","d"}, {"a","a"}))


function assertError(func, expected, ...)
  ok, response = pcall(func, ...)
  if ok then
    error("Expected error", 2)
  else
    if response == expected then
      return true
    else
      print ("Expected: ", expected)
      print ("Recieved: ", response)
      error("Unexpected response")
    end
  end
end


testArrays(splitPath(""), {})
testArrays(splitPath("/"), {})
testArrays(splitPath("rom"), {"rom"})
testArrays(splitPath("/rom"), {"rom"})
testArrays(splitPath("/rom/apis"), {"rom", "apis"})
testArrays(splitPath("/rom/../rom/"), {"rom"})
testArrays(splitPath("//rom//programs/"), {"rom", "programs"})

local vfs = require('vfs')

testArrays(
  vfs.list(""), 
  {"foo", "rom", "disk"}
);

testArrays(
  vfs.list("/rom"), 
  {"apis", "programs"}
);

testArrays(
  vfs.list("/rom/programs"), 
  {"list"}
);

assert(vfs.exists("/rom/programs"))
assert(vfs.exists("/rom/programs/list"))
assert(not vfs.exists("/rom/god"))
assert(vfs.isDir("/"))
assert(vfs.isDir("/rom/programs"))
assert(not vfs.isDir("/rom/programs/list"))

assert(vfs.isReadOnly("/rom/programs/list"))
assert(not vfs.isReadOnly("/nonexistant"))
assert(not vfs.isReadOnly("/disk/test"))
assert(not vfs.isReadOnly("foo"))


assert(vfs.getDrive("/rom/programs") == "rom")
assert(vfs.getDrive("/foo") == "hdd")
assert(vfs.getDrive("") == "hdd")
assert(vfs.getDrive("/foo") == "hdd")

assert(vfs.getSize("rom") == 0)
assert(vfs.getSize("/foo") == 13)


vfs.makeDir("/test")

testArrays(
  vfs.list(""), 
  {"test", "foo", "rom", "disk"}
);

assert(vfs.isDir("/test"))

assertError(vfs.makeDir, "File exists", "/foo")
assertError(vfs.makeDir, "Access Denied", "/rom/test")

--[[TODO: move files!!]]

vfs.makeDir("/adir")
vfs.makeDir("/bdir")
assert(vfs.isDir("/adir"))
assert(vfs.isDir("bdir"))

assertError(vfs.move, "File exists", "adir", "/bdir")

vfs.move("adir", "bdir/adir")

assert(not vfs.isDir("adir"))
assert(vfs.isDir("/bdir"))
assert(vfs.isDir("/bdir/adir"))

vfs.move("/foo", "bdir/adir/fud")
assert(vfs.getSize("bdir/adir/fud") == 13)
vfs.move("bdir/adir/fud", "/foo")
assert(vfs.getSize("foo") == 13)

print("all tests passed!")

--[[
local cc_peripheral = {
  wrap = function(side) 
    -- always returns a fake modem object
    return {
      
    }
  end
}

function clone(obj)
-- creates a shallow clone of obj
  local result = {}
  for k,v in pairs(obj) do
    result[k] = v
  end
  return result
end

function cc_print(...)
  print("CC:", ...)
end


local f = assert(loadfile("ccmount"))

setfenv(f, {
  fs = cc_fs,
  pairs = pairs,
  ipairs = ipairs,
  print = cc_print
})

f()

]]
