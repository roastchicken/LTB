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

local socket = require( "src.socket" )
local timer = require( "love.timer" )
local config = require( "config" )

local sendChannel = love.thread.getChannel( "IRCSend" )
local receiveChannel = love.thread.getChannel( "IRCReceive" )

local client = socket.tcp()

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
sendErrorParse( client, "USER " .. config.nick .. " " .. config.nick .. " " .. config.nick .. " :" .. config.nick .. " IRC\r\n", "Successfully sent user" )
sendErrorParse( client, "CAP REQ :twitch.tv/membership\r\n", "Successfully sent membership request" )
sendErrorParse( client, "JOIN " .. config.chan .. "\r\n", "Successfully sent join" )

while true do
  local toSend = sendChannel:pop()
  if toSend ~= nil then
    sendErrorParse( client, toSend, "Successfully sent message" )
  end
  local response = client:receive()
  if response ~= nil then
    receiveChannel:push( response )
  end
  timer.sleep( 20/30 )
end