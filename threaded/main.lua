local config = require( "config" )
local console = require( "console" )

local sendChannel
local receiveChannel

function love.load()
  love.window.setMode( 1280, 720 )
  love.window.setTitle( "Lua IRC API" )
  
  love.graphics.setBackgroundColor( 102, 102, 102 )
  
  local IRCThread = love.thread.newThread( "poll.lua" )
  sendChannel = love.thread.getChannel( "IRCSend" )
  receiveChannel = love.thread.getChannel( "IRCReceive" )
  
  IRCThread:start()
  
  console:init( 0, 0, 560, 720 )
end

function love.update()

  local response = receiveChannel:pop()
  
  if response == nil then return end
  
  if string.find( response, "PING" ) then
    local sStart, sEnd = string.find( response, " " )
    print( "Recieved ping:" )
    print( response )
    local pongInfo = string.sub( response, sEnd + 1, -1 )
    sendChannel:push( "PONG " .. pongInfo .. "\r\n" )
    print( "Sent pong:" )
    print( "PONG " .. pongInfo )
  elseif string.find( response, "[%w_]+![%w_]+@[%w_]+%.tmi%.twitch%.tv PRIVMSG #[%w_]+ :" ) then
    local username = string.sub( response, string.find( response, "[%w_]+" ) )
    local sStart, sEnd = string.find( response, "[%w_]+![%w_]+@[%w_]+%.tmi%.twitch%.tv PRIVMSG #[%w_]+ :" )
    local message = string.sub( response, sEnd + 1 )
    console:print( username .. ": " .. message )
  else
    print( response )
  end
end

function love.draw()
  console:draw()
  love.graphics.setColor( 255, 255, 255 )
  love.graphics.print( love.timer.getDelta(), 570, 10 )
  
  for i = 1,9 do
    local coord = 72 * i
    love.graphics.line( 560 + coord, 0, 560 + coord, 720 )
    love.graphics.line( 560, coord, 1280, coord )
  end
end

function love.threaderror( thread, errStr )
  print( "Thread error:" )
  print( errStr )
end