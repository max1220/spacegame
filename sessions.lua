local sessions = {}
sessions._by_token = {}



function generate_token(len)
	local chars = "qwertzuiopasdfghjklyxcvbnmQWERTZUIOPASDFGHJKLYXCVBNM0123456789"
	local token = {}
	for i=1, 64 do
		local r = math.random(1, #chars)
		token[#token + 1] = chars:sub(r,r)
	end
	return table.concat(token)
end



function generate_session(username, permanent)
	local session = {
		username = username,
		token = generate_token(),
		login_time = os.time(),
		permanent = permanent
	}
	sessions._by_token[session.token] = session
	return session
end



function sessions.web_login(username, password)
	if username == "max" and password == "test" then -- placeholder
		return generate_session(username, true)
	else
		error("Username/Password combination wrong")
	end
end



function sessions.web_login_temporary(username)
	if username ~= "max" then -- placeholder
		return generate_session(username, false)
	else
		error("Username already in use!")
	end
end



function sessions.by_token(token)
	return sessions.by_token[token]
end



return sessions
