-- this is the chunk handling. It loads and caches chunks, and is responsible for saving a map.
-- In the future this the chunk generation will be done as a server, and this will implement the
-- client. To ensure consistency with the save file(and later multiplayer), after modifying chunk-data,
-- call chunk_data:update() or chunk.update_chunk(chunk_x,chunk_y,chunk_z, new_data)
local chunks = {}



-- this is a list of chunks. Each chunk has a set of chunk coordinates,
-- an accessed counter and the chunk-data. The chunk-data is a 3D array.
-- e.g. chunk_data[z][y][x]
local cache = {}



-- The size of all chunks.
local chunk_w = 8
local chunk_h = 8
local chunk_d = 8



-- Get the chunks in an area. This is used in the game to render all screens.
function chunks.get_area(x,y,z,w,h,d)

	local chunk_x,chunk_y,chunk_z = chunks.cords_to_chunk_cords(x, y, z)
	
	-- make a list of chunk coordinates
	local chunk_cords = {}
	for z=chunk_z, chunk_z+math.ceil(d/chunk_d) do
		for y=chunk_y, chunk_y+math.ceil(h/chunk_h) do
			for x=chunk_x, chunk_x+math.ceil(w/chunk_w) do
				table.insert(chunk_cords, {x=x,y=y,z=z})
			end
		end
	end
	
	-- obtain all chunks that match one in the chunk coordinate list
	local area = {}
	for _,_chunk in ipairs(cache) do
		for _, cords in ipairs(chunk_cords) do
			if (cords.x == _chunk.x) 
			and (cords.y == _chunk.y) 
			and (cords.z == _chunk.z) then
				table.insert(area, _chunk)
				cords.found = true
			end
		end
	end
	
	-- load not already cached chunks
	for _, cords in ipairs(chunk_cords) do
		if not cords.found then
			local _chunk = chunks.new_chunk(cords.x, cords.y, cords.z)
			_chunk:generate()
			table.insert(area, _chunk)
		end
	end
	
	return area
	
end



-- checks if a chunk is cached
function chunks.check_cached(chunk_x,chunk_y,chunk_z)

	for _,_chunk in ipairs(cache) do
		if (cords.x == _chunk.x) 
		and (cords.y == _chunk.y) 
		and (cords.z == _chunk.z) then
		
			return true
			
		end
	end
	
	return false
	
end



-- generate an empty chunk(chunk has function to fill itself)
function chunks.new_chunk(chunk_x,chunk_y,chunk_z)

	-- write chunk-data to file
	-- the chunk data is stored as a 3D bytearray
	local function chunk_write_to_file(self)
		local chunk_data = self.chunk_data
		local f = io.open(self.filename, "wb")
		for z=1, chunk_d do
			for y=1, chunk_h do
				for x=1, chunk_w do
					f:write(chunk_data[z][y][x])
				end
			end
		end
		f:close()
		self.tainted = false
	end
	
	-- read chunk-data from file
	local function chunk_read_from_file(self)
		local chunk_data = {}
		local f = io.open(self.filename, "rb")
		for z=1, chunk_d do
			local c_plane = {}
			for y=1, chunk_h do
				local c_line = {}
				for x=1, chunk_w do
					local celem = string.byte(f:read(1))
				end
				c_plane[y] = c_line
			end
			chunk_data[z] = c_plane
		end
		f:close()
		self.tainted = false
		self.chunk_data = chunk_data
	end

	-- generate a chunk-data using a noise-function(TODO: seed!)
	local function chunk_generate(self)
		local chunk_data = {}	
		for z=1, chunk_d do
			local c_plane = {}
			for y=1, chunk_h do
				local c_line = {}
				for x=1, chunk_w do
					local nx = chunk_w * chunk_x + x
					local ny = chunk_h * chunk_y + y
					local nz = chunk_d * chunk_z + z
          local v = love.math.noise(nx/10,ny/10,nz/10)
					--print(v)
					if v > 0.7 then
						--print("!!!")
						c_line[x] = 1
					else
						c_line[x] = 0
					end
				end
				c_plane[y] = c_line
			end
			chunk_data[z] = c_plane
		end
		self.tainted = false
		self.chunk_data = chunk_data
	end
	
	-- the actual chunk object
	local _chunk = {
		x = chunk_x,
		y = chunk_y,
		z = chunk_z,
		accessed = 0,
		data = nil,
		filename = ("chunks/%.4d_%.4d_%.4d.dat"):format(chunk_x, chunk_y, chunk_z),
		read_from_file = chunk_read_from_file,
		write_to_file = chunk_write_to_file,
		generate = chunk_generate,
		tainted = false,
		update = function(self) self.tainted = true end
	}
	
	return _chunk
end



-- convert from chunk coordinates to tile coordinates
-- the origin is the first tile in that chunk(x,y,z = 1)
function chunks.chunk_cords_to_cords(chunk_x, chunk_y, chunk_z)

	local x = chunk_x * chunk_w
	local y = chunk_y * chunk_h
	local z = chunk_z * chunk_d
	
	return x,y,z
	
end



-- convert from tile coordinates to chunk coordinates
function chunks.cords_to_chunk_cords(x, y, z)

	local chunk_x = math.floor(x / chunk_w)
	local chunk_y = math.floor(y / chunk_h)
	local chunk_z = math.floor(z / chunk_d)
	
	return chunk_x,chunk_y,chunk_z
	
end



return chunk
