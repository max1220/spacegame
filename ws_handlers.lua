local turbo = require("turbo")
local sessions = require("sessions")
local ws_handlers = {}



function ws_handlers:get_chunk(data)
	sessions.check_ws(self)
end



return ws_handlers
