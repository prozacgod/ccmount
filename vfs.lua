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

if TEST then
  TEST.cc_splitPath = cc_splitPath
end

local cc_fs = {}
cc_fs = {
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
		return 512*1024
	end,
	
	makeDir = function(path)
		if cc_fs.isReadOnly(path) then
		  error("Access Denied", 2)
		end				
		local path = cc_splitPath(path)
		local current_ref = cc_fake_root
		for i, dir in ipairs(path) do
		  if current_ref[dir] then
		    if type(current_ref[dir]) ~= 'table' then
		      error("File exists", 2)
		    else
		      current_ref = current_ref[dir]
		    end
		  else
		    current_ref[dir] = {}
		  end
		end
	end,
	
	move = function(fromPath, toPath)
		-- fromPath/toPath should not be read-only

		if cc_fs.isReadOnly(fromPath) then
		  error("Access Denied", 2)
		end				

		if cc_fs.isReadOnly(toPath) then
		  error("Access Denied", 2)
		end				

		toPath = cc_splitPath(toPath)
		
  	-- toPath should not exit!		
  	local destination = toPath[#toPath]
		local toRef = utils.walk(cc_fake_root, toPath)		
		if toRef ~= nil then
		  error("File exists", 2)
		end
		toPath[#toPath] = nil

		toRef = utils.walk(cc_fake_root, toPath)
		--[[ CC has an issue here, so I'm answering a bit differently! ]]
		if toRef == nil then
		  error("Invalid Destination", 2)
		end
		
   	-- fromPath should exist!
		fromPath = cc_splitPath(fromPath)
		local fromRef = utils.walk(cc_fake_root, fromPath)
		
		if fromRef == nil then
		  error("No such file", 2) 
		end
		
		local source = fromPath[#fromPath]
		fromPath[#fromPath] = nil
		
		fromRef = utils.walk(cc_fake_root, fromPath)
		
		toRef[destination] = fromRef[source]
		fromRef[source] = nil
	end,
	
	copy = function(fromPath, toPath)
		-- toPath should not be read-only
		if cc_fs.isReadOnly(toPath) then
		  error("Access Denied", 2)
		end				

		toPath = cc_splitPath(toPath)
  	
  	-- toPath should not exits!
  	local destination = toPath[#toPath]
		local toRef = utils.walk(cc_fake_root, toPath)		
		if toRef ~= nil then
		  error("File exists", 2)
		end
		toPath[#toPath] = nil

		toRef = utils.walk(cc_fake_root, toPath)
		--[[ CC has an issue here, so I'm answering a bit differently! ]]
		if toRef == nil then
		  error("Invalid Destination", 2)
		end
		
   	-- fromPath should exist!
		fromPath = cc_splitPath(fromPath)
		local fromRef = utils.walk(cc_fake_root, fromPath)
		
		if fromRef == nil then
		  error("No such file", 2) 
		end
		
		local source = fromPath[#fromPath]
		fromPath[#fromPath] = nil
		
		fromRef = utils.walk(cc_fake_root, fromPath)
		
		toRef[destination] = fromRef[source]
		fromRef[source] = nil
	end,
	
	delete = function(path)
		return fs._original.delete(path)
	end,
	
	open = function(path, mode)
		return fs._original.open(path, mode)
	end,
}

return cc_fs
