local turbo = require("turbo")
local sessions = require("sessions")
local chunks = require("chunks")
local ws_handlers = {}


function check_session(data)
  return assert(sessions.by_token[data.token], "Session token invalid")
end



function ws_handlers:get_chunk(data)
	local session = check_session(data)
end



function ws_handlers:get_area(data)
  local session = check_session(data)
  local x = assert(tonumber(data.x))
  local x = assert(tonumber(data.y))
  local x = assert(tonumber(data.z))
  local w = assert(tonumber(data.w))
  local h = assert(tonumber(data.h))
  local d = assert(tonumber(data.d))
  local chunks = chunks.get_area(x,y,z,w,h,d)
end



return ws_handlers
