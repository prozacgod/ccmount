local io = require('io')

local MonitorPeripheral = {}
local MonitorPeripheral_mt = { __index = MonitorPeripheral }

function MonitorPeripheral.new(width, height)
  local instance = setmetatable({}, MonitorPeripheral_mt)
  instance.init(instance, width, height)
  
  return instance
end

function MonitorPeripheral:init(width, height)
  self.setSize(width, height)
  self.cursorX = 1
  self.cursorY = height
end

function MonitorPeripheral:setSize(width, height)
  self.width = width
  self.height = height
  self.redraw()
end

function MonitorPeripheral:setReal(ofsX, ofsY)
  self.isReal = true

  self.offset_X = ofsX or 0
  self.offset_Y = ofsY or 0
end

--[[
Esc[ValueA	Move cursor up n lines	CUU
Esc[ValueB	Move cursor down n lines	CUD
Esc[ValueC	Move cursor right n lines	CUF
Esc[ValueD	Move cursor left n lines	CUB
]]

m = MonitorPeripheral.new(80, 25)
m:setReal()
