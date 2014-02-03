--[[
  this testing environment is ran inside luajit not lua - luajit was closer
  to a computercraft environment on my system.  YMMV - post patches ;)
]]

local inspect = require('inspect')
local utils = require('utils')

compareArray = utils.compareArray;
splitPath = utils.splitPath;
testArrays = utils.testArrays;

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
