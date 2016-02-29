local handle = {}

local handlers =
{
  chat = function( msg, console ) handleChat( msg, console ) end,
  ping = function( msg, console ) handlePing( msg ) end
}

function handle.message( msg, msgType, console )
  if handlers[msgType] then
    local send = handlers[msgType]( msg, console ) -- get the return value from the handler to know what to send
    if send then
      return send
    end
  elseif msgType == "unknown" then -- if the message type is unknown then do nothing
  else
    print( "ERROR: message type " .. msgType .. " for message <" .. msg .. "> does not have a handler." )
  end
end

function handleChat( msg, console )
  local username = string.sub( msg, string.find( msg, "[%w_]+" ) )
  local sStart, sEnd = string.find( msg, "[%w_]+![%w_]+@[%w_]+%.tmi%.twitch%.tv PRIVMSG #[%w_]+ :" )
  local chatMsg = string.sub( msg, sEnd + 1 )
  console:print( username .. ": " .. chatMsg )
end

function handlePing( pingMsg )
  local pongMsg = string.gsub( pingMsg, "PING", "PONG" ) -- replace the string "PING" with "PONG" in the ping message
  return pongMsg -- send the pong message back to handle.message so it can send it to main.lua for sending to IRC
end

return handle