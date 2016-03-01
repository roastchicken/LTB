local util = require( "util" )

local console = {}
local info

function console:init( xPos, yPos, xSize, ySize, bgColor, font )
  if console.initiated then return end
  
  console.initiated = true
  console.info = {}
  console.history = {}
  console.lines = {}
  
  console.info.xPos = xPos or 0
  console.info.yPos = yPos or 0
  console.info.xSize = xSize or love.graphics.getWidth()
  console.info.ySize = ySize or love.graphics.getHeight()
  console.info.bgColor = bgColor or util.Color( 0, 0, 0 )
  console.info.font = font or love.graphics.newFont(12)
  
  console.info.lineOffset = 1
  console.info.maxLines = math.floor( ( console.info.ySize - 20 ) / 12 )
end

local function refreshLines( offset )
  console.info.lineOffset = offset
  console.lines = {}
  for i = offset, offset + console.info.maxLines do
    if not console.history[i] then break end
    table.insert( console.lines, console.history[i] )
  end
end

function console:scroll( amount )
  if not console.initiated then return end
  local offset = console.info.lineOffset + amount
  if offset < 1 then
    offset = 1
  elseif offset > #console.history - console.info.maxLines then
    console:scrollToBottom()
    return
  end
  
  refreshLines( offset )
end

function console:scrollToBottom()
  if not console.initiated then return end
  local bottomOffset = #console.history - console.info.maxLines + 1
  if bottomOffset <= 0 then bottomOffset = 1 end
  refreshLines( bottomOffset )
end

function console:print( text )
  if not console.initiated then return end
  local width, wrapped = console.info.font:getWrap( text, console.info.xSize - 20 ) -- wrap the text, using the console width - 20 to take the padding into account
  for k, line in ipairs( wrapped ) do
    table.insert( console.history, line )
  end
  console:scrollToBottom()
end

function console:draw()
  if not console.initiated then return end
  
  local bgColor = console.info.bgColor
  love.graphics.setColor( bgColor.r, bgColor.g, bgColor.b )
  love.graphics.rectangle( "fill", console.info.xPos, console.info.yPos, console.info.xSize, console.info.ySize )
  
  love.graphics.setColor( 255, 255, 255 )
  love.graphics.setFont( console.info.font )
  
  for line, text in ipairs( console.lines ) do -- draw the lines
    love.graphics.print( text, 10, 12 * ( line - 1 ) + 10 )
  end
end

return console