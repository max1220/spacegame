#!/usr/bin/env luajit
TURBO_SSL = true
local turbo = require("turbo")
local config = require("config")
local json = require("cjson")
local ws_handlers = require("ws_handlers")
local sessions = require("sessions")
local app
local cioloop



local ws_handler = class("ws_handler", turbo.websocket.WebSocketHandler)
function ws_handler:on_message(msg)
	local ok, data = pcall(json.decode, msg)
	if ok then
		local session = sessions.get_by_token(data.token)
	
		if ws_handlers[action] then
			ws_handlers[action](self, data)
		else
			self:send_message(json.encode({
				type = "error",
				msg = "Unknow action"
			}))
		end
	else
		self:send_message(json.encode({
			type = "error",
			msg = "Invalid JSON"
		}))
	end
end



local login_handler = class("login_handler", turbo.web.RequestHandler)
function login_handler:post()
    local username = self:get_argument("username")
    local temporary = self:get_argument("temporary")
    local token
    if temporary == "off" then
		token = sessions.web_login(username, password)
		local password = self:get_argument("password")
		if not token then
			error("Username/passwor combination wrong!")
		end
	else
		token = sessions.web_login_temporary(username)
		if not token then
			error("Username can't be used for temporary login!")
		end
	end
	if token then
		self:redirect("/")
	else
		self:redirect("/login")
	end
end



function on_startup()
	turbo.log.success("Started server on port " .. config.port)
end



app = turbo.web.Application({
	{"^/index$", turbo.web.StaticFileHandler, "static/play.html"},
    {"^/play$", turbo.web.StaticFileHandler, "static/play.html"},
    {"^/login$", turbo.web.StaticFileHandler, "static/login.html"},
    {"^/login_post$", login_handler},
    {"^/static/(.*)$", turbo.web.StaticFileHandler, "static/"},
    {"/ws", ws_handler}
})



app:listen(config.port)
cioloop = turbo.ioloop.instance()
cioloop:add_callback(on_startup)
cioloop:start()
