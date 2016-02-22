local config = require( "config" )

local function sendErrorParse( client, sendString, okayMsg )
  connected, err = client:send( sendString )
  
  if connected ~= nil then
    print( okayMsg )
  else
    print( connected )
    print( "Error: " )
    print( err )
  end
end

function love.load()
  love.window.setMode( 1080, 720 )
  love.window.setTitle( "Lua IRC API" )
  
  love.graphics.setBackgroundColor( 102, 102, 102 )
  
  socket = require( "src.socket" )
  
  client = socket.tcp()
  
  client:settimeout( 0.1 )
  
  print( "Connecting to server " .. config.host .. ":" .. config.port )

  local connected, err = client:connect( config.host, config.port )
  
  if connected == 1 then
    print( "Successfully connected to server." )
  else
    print( connected )
    print( err )
  end
  
  print( "Logging in as " .. config.nick )

  sendErrorParse( client, "PASS " .. config.pass .. "\r\n", "Successfully sent password" )
  sendErrorParse( client, "NICK " .. config.nick .. "\r\n", "Successfully sent nickname" )
  sendErrorParse( client, "USER " .. config.nick .. " " .. config.nick .. " " .. config.nick .. " :" .. config.nick .. " IRC\r\n", "Successfully sent nickname" )
  sendErrorParse( client, "JOIN " .. config.chan .. "\r\n", "Successfully sent join" )
  
end

function love.update()

  local response = client:receive()
  
  if response == nil then return end
  
  if string.find( response, "PING" ) then
    local sStart, sEnd = string.find( response, " " )
    print( "Recieved ping:" )
    print( response )
    local pongInfo = string.sub( response, sEnd + 1, -1 )
    client:send( "PONG " .. pongInfo .. "\r\n" )
    print( "Sent pong:" )
    print( "PONG " .. pongInfo )
  elseif string.find( response, "[%w_]+![%w_]+@[%w_]+%.tmi%.twitch%.tv PRIVMSG #[%w_]+ :" ) then
    local username = string.sub( response, string.find( response, "[%w_]+" ) )
    local sStart, sEnd = string.find( response, "[%w_]+![%w_]+@[%w_]+%.tmi%.twitch%.tv PRIVMSG #[%w_]+ :" )
    local message = string.sub( response, sEnd + 1 )
    print( username .. ": " .. message )
  else
    print( response )
  end
end

function love.draw()
  love.graphics.print( love.timer.getDelta(), 10, 10 )
end