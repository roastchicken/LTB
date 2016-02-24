local util = require( "util" )

local console = {}
local info

function console:init( xPos, yPos, xSize, ySize, bgColor, font )
  if console.initiated then return end
  
  console.initiated = true
  console.info = {}
  console.lines = {}
  
  console.info.xPos = xPos or 0
  console.info.yPos = yPos or 0
  console.info.xSize = xSize or love.graphics.getWidth()
  console.info.ySize = ySize or love.graphics.getHeight()
  console.info.bgColor = bgColor or util.Color( 0, 0, 0 )
  console.info.font = font or love.graphics.newFont(12)
end

function console:print( text )
  local width, wrapped = console.info.font:getWrap( text, console.info.xSize - 20 ) -- wrap the text, using the console width - 20 to take the padding into account
  for k, line in ipairs( wrapped ) do
    table.insert( console.lines, line )
  end
end

function console:draw()
  if not console.initiated then return end
  
  local bgColor = console.info.bgColor
  love.graphics.setColor( bgColor.r, bgColor.g, bgColor.b )
  love.graphics.rectangle( "fill", console.info.xPos, console.info.yPos, console.info.xSize, console.info.ySize )
  
  love.graphics.setColor( 255, 255, 255 )
  love.graphics.setFont( console.info.font )
  
  for line, text in ipairs( console.lines ) do -- draw the lines
    love.graphics.print( text, 10, 12 * line )
  end
end

return console