local inspect = require('inspect')

local function explode(div,str)
    if (div=='') then return false end
    local pos,arr = 0,{}
    for st,sp in function() return string.find(str,div,pos,true) end do
        table.insert(arr,string.sub(str,pos,st-1))
        pos = sp + 1
    end
    table.insert(arr,string.sub(str,pos))
    return arr
end

local function splitPath(path)
  --[[ this is a bit of a naive approach to getting path,
  but works for enough cases I'm happy with it ]]
  local split = explode("/", path)
  local result = {}
  for i, dir in ipairs(split) do
    if dir and #dir > 0 and dir ~= "." then
      if dir == ".." then
        if #result == 0 then
          error("Invalid Path", 2)
        else
          result[#result] = nil
        end
      else
        result[#result+1] = dir
      end
    end
  end
  return result
end

local function compareArray(obj1, obj2)
  -- hehe, oh this is dirty! but works!
  if obj1 == nil then
    return false
  end
  
  if obj2 == nil then
    return false
  end
  
  for k,v in ipairs(obj1) do
    if obj1[k] ~= obj2[k] then
      return false
    end
  end
  for k,v in ipairs(obj2) do
    if obj1[k] ~= obj2[k] then
      return false
    end
  end
  return true
end

local function testArrays(obj1, obj2)
  if not compareArray(obj1, obj2) then
    print("Object 1")
    print("---------------------------------------------------")
    print(inspect(obj1))
    print("Object 2")
    print("---------------------------------------------------")
    print(inspect(obj2))
    error("Array comparison Failed", 2)
  end
end

local function tail(arr, n)
  n = n or 1
  local result = {}
  for i, v in ipairs(arr) do
    if i > n then
      result[i-1] = v
    end
  end
  return result
end

local function walk(obj, keys)
  if #keys == 0 then
    return obj
  else
    if obj[keys[1]] then
      return walk(obj[keys[1]], tail(keys))
    end
  end   
  return nil
end

local function locals()
  local variables = {}
  local idx = 1
  while true do
    local ln, lv = debug.getlocal(2, idx)
    if ln ~= nil then
      variables[ln] = lv
    else
      break
    end
    idx = 1 + idx
  end
  return variables
end

local function keys(obj)
  local result = {}
  for k,v in pairs(obj) do
    result[#result+1] = k
  end
  return result
end

return {
  expode = explode,
  splitPath = splitPath,
  compareArray = compareArray,
  compareArray = compareArray,
  walk = walk,
  locals = locals,
  inspect = inspect,
  keys = keys,
  testArrays = testArrays
}
