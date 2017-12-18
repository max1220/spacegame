#!/usr/bin/env lua

local spaces
local infiles = {}
for k,v in ipairs(arg) do
	local _spaces = tonumber(v:match("%-s=(%d+)"))
	if _spaces then
		spaces = _spaces
	else
		if spaces then
			table.insert(infiles, {spaces = spaces, path = v})
		else
			print("Specified a file without -s before!")
			os.exit(1)
		end
	end
end
