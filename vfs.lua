local utils = require('utils')

local cc_fake_root = {
  rom = {
    apis = {
      turtle = {
      },
      
      parallel = "",
      
      textutils = ""
    },
    programs = {
      list = "print('list program')"
    }
  },
  
  disk = {
    test = "This is a test file"
  },
  
  foo = "Another file!"
}

local function cc_splitPath(path)
  ok, result = pcall(utils.splitPath, path)
  if ok then
    return result
  else
    error(result, 3)
  end
  return path
end

local cc_fs = {
  list = function(path)
    path = cc_splitPath(path)
    local start = utils.walk(cc_fake_root, path)
    return utils.keys(start)
  end,
  
	exists = function(path)
    path = cc_splitPath(path)
    local start = utils.walk(cc_fake_root, path)
		return start ~= nil
	end,

	isDir = function(path)
    path = cc_splitPath(path)
    local start = utils.walk(cc_fake_root, path)
    return type(start) == "table"
	end,

	isReadOnly = function(path)
    path = cc_splitPath(path)
    if not path then
      return false
    end
        
    if #path == 0 then
      return false
    end
    return path[1] == "rom"
	end,

	getDrive = function(path)
  	path = cc_splitPath(path)
    if not path then
      return nil
    end

    if #path == 0 then
      return "hdd"
    end
    
    if path[1] == "rom" then
      return "rom"
    end

    if path[1] == "disk" then    
      return "left"
    end
    
    return "hdd"
	end,
	
	getSize = function(path)
		path = cc_splitPath(path)
		local ref = utils.walk(cc_fake_root, path)
		
		if ref == nil then
		  error("No such file", 2)
		end

		if type(ref) == "table" then
      return 0
    end
    
    return #ref
	end,
	
	getFreeSpace = function(path)
		return fs._original.getFreeSpace(path)
	end,
	
	makeDir = function(path)
		return fs._original.makeDir(path)
	end,
	
	move = function(fromPath, toPath)
		return fs._original.move(fromPath, toPath)
	end,
	
	copy = function(fromPath, toPath)
		return fs._original.copy(fromPath, toPath)
	end,
	
	delete = function(path)
		return fs._original.delete(path)
	end,
	
	open = function(path, mode)
		return fs._original.open(path, mode)
	end,
}

return cc_fs
