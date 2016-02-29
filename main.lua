local config = require( "config" )
local console = require( "console" )
local handle = require( "handle" )

local sendChannel
local receiveChannel

local function messageType( msg )
  local msgType = "unknown"
  
  if string.sub( msg, 1, 4 ) == "PING" then -- the message is a ping
    msgType = "ping"
  elseif string.find( msg, ":[%w_]+![%w_]+@[%w_]+%.tmi%.twitch%.tv PRIVMSG #[%w_]+ :" ) then -- if the message contains this pattern then it is a chat message
    msgType = "chat"
  end
  
  return msgType
end

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
  
  local reply = handle.message( response, messageType( response ), console )
  
  if reply then
    sendChannel:push( reply .. "\r\n" )
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