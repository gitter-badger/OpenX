-- OpenGraphics alpha 0.1.1 by CrazedProgrammer
-- Licensed under MIT: http://opensource.org/licenses/mit-license.php
-- Available on GitHub: https://github.com/CrazedProgrammer/OpenGraphics
-- You can load this API with dofile or you can put it directly into your program.

-- Don't delete this.
local graphics, canvas, _table_concat, _math_floor, _math_abs, _math_min, _math_max, _math_sin, _math_cos, _colors = { }, { }, table.concat, math.floor, math.abs, math.min, math.max, math.sin, math.cos, {[1]="0",[2]="1",[4]="2",[8]="3",[16]="4",[32]="5",[64]="6",[128]="7",[256]="8",[512]="9",[1024]="a",[2048]="b",[4096]="c",[8192]="d",[16384]="e",[32768]="f"}
graphics.canvas = canvas

-- Main functions (gets returned to the user), you can delete these.
function graphics.createCanvas(width, height, backcolor, char, textcolor)
	local canvas = setmetatable({ }, {__index = graphics.canvas})
	canvas.width, canvas.height, canvas.x1, canvas.y1, canvas.x2, canvas.y2, canvas.overwrite, canvas.buffer = width, height, 1, 1, width, height, false, { }
	if backcolor then
		for i=1,width*height*3,3 do
			canvas.buffer[i] = backcolor
		end
	end
	if char then
		for i=2,width*height*3,3 do
			canvas.buffer[i] = char
		end
	end
	if textcolor then
		for i=3,width*height*3,3 do
			canvas.buffer[i] = textcolor
		end
	end
	return canvas
end

function graphics.loadCanvas(filestr, isstr)
	local canvas = setmetatable({ }, {__index = graphics.canvas})
	canvas.overwrite = false
	canvas.buffer = { }
	local str = filestr
	if not isstr then
		local f = fs.open(filestr, "r")
		str = f.readAll()
		f.close()
	end
	if str:byte(1) == 30 then
	elseif str:byte(1) == 95 then
		canvas.width = tonumber(str:sub(2, 5), 16)
		canvas.height = tonumber(str:sub(6, 9), 16)
		local n = 10
		for j=1,canvas.height do
			for i=1,canvas.width do
				if str:byte(n) ~= 95 then
					canvas.buffer[((j - 1) * canvas.width + i) * 3 - 1] = string.char(tonumber(str:sub(n, n + 1), 16))
				end
				if str:byte(n + 2) ~= 95 then
					canvas.buffer[((j - 1) * canvas.width + i) * 3 - 2] = 2 ^ tonumber(str:sub(n + 2, n + 2), 16)
				end
				if str:byte(n + 3) ~= 95 then
					canvas.buffer[((j - 1) * canvas.width + i) * 3] = 2 ^ tonumber(str:sub(n + 3, n + 3), 16)
				end
				n = n + 4
			end
		end
	else
	end
	canvas.x1 = 1
	canvas.y1 = 1
	canvas.x2 = canvas.width
	canvas.y2 = canvas.height
	return canvas
end

-- Canvas functions, you can delete these.
function canvas:render(display, x, y, x1, y1, x2, y2)
	display, x, y, x1, y1, x2, y2 = display or term, x or 1, y or 1, x1 or 1, y1 or 1, x2 or self.width, y2 or self.height
	if x1 > x2 then
		x1, x2 = x2, x1
	end
	if y1 > y2 then
		y1, y2 = y2, y1
	end
	if x2 < 1 or x1 > self.width or y2 < 1 or y1 > self.height then return end
	if x1 < 1 then x = x - x1 + 1 x1 = 1 end
	if x2 > self.width then x2 = self.width end
	if y1 < 1 then y = y - y1 + 1 y1 = 1 end
	if y2 > self.height then y2 = self.height end
	if display.blit then
		local back, char, text = { }, { }, { }
		for j=y1,y2 do
			display.setCursorPos(x, y + j - y1)
			for i=x1,x2 do
				back[i - x1 + 1] = _colors[self.buffer[((j - 1) * self.width + i) * 3 - 2] or 32768]
				char[i - x1 + 1] = self.buffer[((j - 1) * self.width + i) * 3 - 1] or " "
				text[i - x1 + 1] = _colors[self.buffer[((j - 1) * self.width + i) * 3] or 1]
			end
			display.blit(_table_concat(char), _table_concat(text), _table_concat(back))
		end
		return (y2 - y1 + 1) * 2
	else
		local cmd, char, back, text, lchar, lback, ltext, c, a = { }, { }, 0, 0
		for j=y1,y2 do
			cmd[#cmd + 1], cmd[#cmd + 2] = 1, y + j - y1
			for i=x1,x2 do
				lchar, lback, ltext = self.buffer[((j - 1) * self.width + i) * 3 - 1] or " ", self.buffer[((j - 1) * self.width + i) * 3 - 2] or 32768, self.buffer[((j - 1) * self.width + i) * 3] or 1
				if back ~= lback then
					if #char > 0 then
						cmd[#cmd + 1], cmd[#cmd + 2] = 4, _table_concat(char)
						c = #char
						for i=1,c do
							char[i] = nil
						end
					end
					back = lback
					cmd[#cmd + 1], cmd[#cmd + 2] = 2, back
				end
				if text ~= ltext then
					if #char > 0 then
						cmd[#cmd + 1], cmd[#cmd + 2] = 4, _table_concat(char)
						c = #char
						for i=1,c do
							char[i] = nil
						end
					end
					text = ltext
					cmd[#cmd + 1], cmd[#cmd + 2] = 3, text
				end
				char[#char + 1] = lchar
			end
			if #char > 0 then
				cmd[#cmd + 1], cmd[#cmd + 2] = 4, _table_concat(char)
				c = #char
				for i=1,c do
					char[i] = nil
				end
			end
		end
		for i=1,#cmd,2 do
			c, a = cmd[i], cmd[i + 1]
			if c == 1 then
				display.setCursorPos(x, a)
			elseif c == 2 then
				display.setBackgroundColor(a)
			elseif c == 3 then
				display.setTextColor(a)
			else
				display.write(a)
			end
		end
		return #cmd / 2
	end
end

function canvas:setBounds(x1, y1, x2, y2, inside)
	if inside then
		if x1 < self.x1 then x1 = self.x1 end
		if x2 > self.x2 then x2 = self.x2 end
		if y1 < self.y1 then y1 = self.y1 end
		if y2 > self.x2 then y2 = self.x2 end
		self.x1, self.y1, self.x2, self.y2 = x1, y1, x2, y2
	else
		if x1 < 1 then x1 = 1 end
		if x2 > self.width then x2 = self.width end
		if y1 < 1 then y1 = 1 end
		if y2 > self.height then y2 = self.height end
		self.x1, self.y1, self.x2, self.y2 = x1, y1, x2, y2
	end
	return self
end

function canvas:getBounds()
	return self.x1, self.y1, self.x2, self.y2
end

function canvas:clear(backcolor, char, textcolor)
	for j=self.y1,self.y2 do
		for i=self.x1,self.x2 do
			self.buffer[((j - 1) * self.width + i) * 3 - 2] = backcolor
			self.buffer[((j - 1) * self.width + i) * 3 - 1] = textcolor
			self.buffer[((j - 1) * self.width + i) * 3] = char
		end
	end
end

function canvas:drawPixel(x, y, backcolor, char, textcolor)
	if x < self.x1 or x > self.x2 or y < self.y1 or y > self.y2 then return self end
	if backcolor or self.overwrite then
		self.buffer[((y - 1) * self.width + x) * 3 - 2] = backcolor
	end
	if char or self.overwrite then
		self.buffer[((y - 1) * self.width + x) * 3 - 1] = char
	end
	if textcolor or self.overwrite then
		self.buffer[((y - 1) * self.width + x) * 3] = textcolor
	end
	return self
end

function canvas:getPixel(x, y)
	if x < self.x1 or x > self.x2 or y < self.y1 or y > self.y2 then return end
	return self.buffer[((y - 1) * self.width + x) * 3 - 2], self.buffer[((y - 1) * self.width + x) * 3 - 1], self.buffer[((y - 1) * self.width + x) * 3]
end

function canvas:drawText(text, x, y, backcolor, textcolor)
	local ox = x
	for i=1,#text do
		if text:sub(i, i) ~= "\n" then
			if not (x < self.x1 or x > self.x2 or y < self.y1 or y > self.y2) then
				self.buffer[((y - 1) * self.width + x) * 3 - 1] = text:sub(i, i)
				if backcolor or self.overwrite then
					self.buffer[((y - 1) * self.width + x) * 3 - 2] = backcolor
				end
				if textcolor or self.overwrite then
					self.buffer[((y - 1) * self.width + x) * 3] = textcolor
				end
			end
		else
			x = ox - 1
			y = y + 1
		end
		x = x + 1
	end
end

function canvas:drawLine(x1, y1, x2, y2, backcolor, char, textcolor)
	if x1 == x2 then
		if y1 > y2 then
			y1, y2 = y2, y1
		end
		if x1 < self.x1 or x1 > self.x2 or y2 < self.y1 or y1 > self.y2 then return self end
		if y1 < self.y1 then y1 = self.y1 end
		if y2 > self.y2 then y2 = self.y2 end
		if backcolor or self.overwrite then
			for j=y1,y2 do
				self.buffer[((j - 1) * self.width + x1) * 3 - 2] = backcolor
			end
		end
		if char or self.overwrite then
			for j=y1,y2 do
				self.buffer[((j - 1) * self.width + x1) * 3 - 1] = char
			end
		end
		if textcolor or self.overwrite then
			for j=y1,y2 do
				self.buffer[((j - 1) * self.width + x1) * 3] = textcolor
			end
		end
	elseif y1 == y2 then
		if x1 > x2 then
			x1, x2 = x2, x1
		end
		if y1 < self.y1 or y1 > self.y2 or x2 < self.x1 or x1 > self.x2 then return self end
		if x1 < self.x1 then x1 = self.x1 end
		if x2 > self.x2 then x2 = self.x2 end
		if backcolor or self.overwrite then
			for i=x1,x2 do
				self.buffer[((y1 - 1) * self.width + i) * 3 - 2] = backcolor
			end
		end
		if char or self.overwrite then
			for i=x1,x2 do
				self.buffer[((y1 - 1) * self.width + i) * 3 - 1] = char
			end
		end
		if textcolor or self.overwrite then
			for i=x1,x2 do
				self.buffer[((y1 - 1) * self.width + i) * 3] = textcolor
			end
		end
	else
		local delta_x = x2 - x1
		local ix = delta_x > 0 and 1 or -1
		delta_x = 2 * _math_abs(delta_x)
		local delta_y = y2 - y1
		local iy = delta_y > 0 and 1 or -1
		delta_y = 2 * _math_abs(delta_y)
		if not (x1 < self.x1 or x1 > self.x2 or y1 < self.y1 or y1 > self.y2) then
			if backcolor or self.overwrite then
				self.buffer[((y1 - 1) * self.width + x1) * 3 - 2] = backcolor
			end
			if char or self.overwrite then
				self.buffer[((y1 - 1) * self.width + x1) * 3 - 1] = char
			end
			if textcolor or self.overwrite then
				self.buffer[((y1 - 1) * self.width + x1) * 3] = textcolor
			end
		end
		if delta_x >= delta_y then
			local error = delta_y - delta_x / 2
			while x1 ~= x2 do
				if (error >= 0) and ((error ~= 0) or (ix > 0)) then
					error = error - delta_x
					y1 = y1 + iy
				end
				error = error + delta_y
				x1 = x1 + ix
				if not (x1 < self.x1 or x1 > self.x2 or y1 < self.y1 or y1 > self.y2) then
					if backcolor or self.overwrite then
						self.buffer[((y1 - 1) * self.width + x1) * 3 - 2] = backcolor
					end
					if char or self.overwrite then
						self.buffer[((y1 - 1) * self.width + x1) * 3 - 1] = char
					end
					if textcolor or self.overwrite then
						self.buffer[((y1 - 1) * self.width + x1) * 3] = textcolor
					end
				end
			end
		else
			local error = delta_x - delta_y / 2
			while y1 ~= y2 do
				if (error >= 0) and ((error ~= 0) or (iy > 0)) then
					error = error - delta_y
					x1 = x1 + ix
				end
				error = error + delta_x
				y1 = y1 + iy
				if not (x1 < self.x1 or x1 > self.x2 or y1 < self.y1 or y1 > self.y2) then
					if backcolor or self.overwrite then
						self.buffer[((y1 - 1) * self.width + x1) * 3 - 2] = backcolor
					end
					if char or self.overwrite then
						self.buffer[((y1 - 1) * self.width + x1) * 3 - 1] = char
					end
					if textcolor or self.overwrite then
						self.buffer[((y1 - 1) * self.width + x1) * 3] = textcolor
					end
				end
			end
		end
	end
	return self
end

function canvas:drawRect(x1, y1, x2, y2, backcolor, char, textcolor)
	if x1 > x2 then
		x1, x2 = x2, x1
	end
	if y1 > y2 then
		y1, y2 = y2, y1
	end
	if x2 < self.x1 or x1 > self.x2 or y2 < self.y1 or y1 > self.y2 then return end
	if x1 < self.x1 then x1 = self.x1 end
	if x2 > self.x2 then x2 = self.x2 end
	if y1 < self.y1 then y1 = self.y1 end
	if y2 > self.y2 then y2 = self.y2 end
	if backcolor or self.overwrite then
		for y=y1,y2 do
			for x=x1,x2 do
				self.buffer[((y - 1) * self.width + x) * 3 - 2] = backcolor
			end
		end
	end
	if char or self.overwrite then
		for y=y1,y2 do
			for x=x1,x2 do
				self.buffer[((y - 1) * self.width + x) * 3 - 1] = char
			end
		end
	end
	if textcolor or self.overwrite then
		for y=y1,y2 do
			for x=x1,x2 do
				self.buffer[((y - 1) * self.width + x) * 3] = textcolor
			end
		end
	end
	return self
end

function canvas:drawTri(x1, y1, x2, y2, x3, y3, backcolor, char, textcolor)
	local minx, miny, maxx, maxy, buffer, lines = _math_min(x1, x2, x3), _math_min(y1, y2, y3), _math_max(x1, x2, x3), _math_max(y1, y2, y3), { }, { }
	local width, height = maxx - minx + 1, maxy - miny + 1
	lines[1], lines[2], lines[3], lines[4], lines[5], lines[6], lines[7], lines[8], lines[9], lines[10], lines[11], lines[12] = x1 - minx + 1, y1 - miny, x2 - minx + 1, y2 - miny, x1 - minx + 1, y1 - miny, x3 - minx + 1, y3 - miny, x2 - minx + 1, y2 - miny, x3 - minx + 1, y3 - miny
	for i=1,9,4 do
		local delta_x = lines[i + 2] - lines[i]
		local ix = delta_x > 0 and 1 or -1
		delta_x = 2 * _math_abs(delta_x)
		local delta_y = lines[i + 3] - lines[i + 1]
		local iy = delta_y > 0 and 1 or -1
		delta_y = 2 * _math_abs(delta_y)
		buffer[lines[i + 1] * width + lines[i]] = true
		if delta_x >= delta_y then
			local error = delta_y - delta_x / 2
			while lines[i] ~= lines[i + 2] do
				if (error >= 0) and ((error ~= 0) or (ix > 0)) then
					error = error - delta_x
					lines[i + 1] = lines[i + 1] + iy
				end
				error = error + delta_y
				lines[i] = lines[i] + ix
				buffer[lines[i + 1] * width + lines[i]] = true
			end
		else
			local error = delta_x - delta_y / 2
			while lines[i + 1] ~= lines[i + 3] do
				if (error >= 0) and ((error ~= 0) or (iy > 0)) then
					error = error - delta_y
					lines[i] = lines[i] + ix
				end
				error = error + delta_x
				lines[i + 1] = lines[i + 1] + iy
				buffer[lines[i + 1] * width + lines[i]] = true
			end
		end
	end
	local min, max
	for j=1,height do
		min, max = nil
		for i=1,width do
			if buffer[(j - 1) * width + i] then
				min = min and min or i
				max = i
			end
		end
		local x1, x2, y1 = min + minx - 1, max + minx - 1, j + miny - 1
		if not (y1 < self.y1 or y1 > self.y2 or x2 < self.x1 or x1 > self.x2) then
			if x1 < self.x1 then x1 = self.x1 end
			if x2 > self.x2 then x2 = self.x2 end
			if backcolor or self.overwrite then
				for i=x1,x2 do
					self.buffer[((y1 - 1) * self.width + i) * 3 - 2] = backcolor
				end
			end
			if char or self.overwrite then
				for i=x1,x2 do
					self.buffer[((y1 - 1) * self.width + i) * 3 - 1] = char
				end
			end
			if textcolor or self.overwrite then
				for i=x1,x2 do
					self.buffer[((y1 - 1) * self.width + i) * 3] = textcolor
				end
			end
		end
	end
	return self
end

function canvas:drawCanvas(canvas, x, y, x1, y1, x2, y2)
	x1, y1, x2, y2 = x1 or 1, y1 or 1, x2 or canvas.width, y2 or canvas.height
	if x1 > x2 then
		x1, x2 = x2, x1
	end
	if y1 > y2 then
		y1, y2 = y2, y1
	end
	if x2 < 1 or x1 > canvas.width or y2 < 1 or y1 > canvas.height then return end
	if x1 < 1 then x = x - x1 + 1 x1 = 1 end
	if x2 > canvas.width then x2 = canvas.width end
	if y1 < 1 then y = y - y1 + 1 y1 = 1 end
	if y2 > canvas.height then y2 = canvas.height end
	if x + (x2 - x1) < self.x1 or x > self.x2 or y + (y2 - y1) < self.y1 or y > self.y2 then return self end
	if x < self.x1 then x1 = x1 + -x + self.x1 x = self.x1 end
	if y < self.y1 then y1 = y1 + -y + self.y1 y = self.y1 end
	if x + (x2 - x1) > self.x2 then x2 = self.x2 - x + 1 end
	if y + (y2 - y1) > self.y2 then y2 = self.y2 - y + 1 end
	local sx, sy, backcolor, char, textcolor
	for j=y1,y2 do
		for i=x1,x2 do
			sx, sy, backcolor, char, textcolor = x + i - x1, y + j - y1, canvas.buffer[((j - 1) * canvas.width + i) * 3 - 2], canvas.buffer[((j - 1) * canvas.width + i) * 3 - 1], canvas.buffer[((j - 1) * canvas.width + i) * 3]
			if backcolor or self.overwrite then
				self.buffer[((sy - 1) * self.width + sx) * 3 - 2] = backcolor
			end
			if char or self.overwrite then
				self.buffer[((sy - 1) * self.width + sx) * 3 - 1] = char
			end
			if textcolor or self.overwrite then
				self.buffer[((sy - 1) * self.width + sx) * 3] = textcolor
			end
		end
	end
	return self
end

function canvas:drawCanvasScaled(canvas, x1, y1, x2, y2)
	local x, width, xinv, y, height, yinv
	if x1 <= x2 then
		x = x1
		width = x2 - x1 + 1
	else
		x = x2
		width = x1 - x2 + 1
		xinv = true
	end
	if y1 <= y2 then
		y = y1
		height = y2 - y1 + 1
	else
		y = y2
		height = y1 - y2 + 1
		yinv = true
	end
	local xscale, yscale, px, py, sx, sy, backcolor, char, textcolor = width / canvas.width, height / canvas.height
	for j=1,height do
		for i=1,width do
			sx, sy = x + i - 1, y + j - 1
			if not (sx < self.x1 or sx > self.x2 or sy < self.y1 or sy > self.y2) then
				px, py = xinv and _math_floor((width - i + 0.5) / xscale) + 1 or _math_floor((i - 0.5) / xscale) + 1, yinv and _math_floor((height - j + 0.5) / yscale) + 1 or _math_floor((j - 0.5) / yscale) + 1
				backcolor, char, textcolor = canvas.buffer[((py - 1) * canvas.width + px) * 3 - 2], canvas.buffer[((py - 1) * canvas.width + px) * 3 - 1], canvas.buffer[((py - 1) * canvas.width + px) * 3]
				if backcolor or self.overwrite then
					self.buffer[((sy - 1) * self.width + sx) * 3 - 2] = backcolor
				end
				if char or self.overwrite then
					self.buffer[((sy - 1) * self.width + sx) * 3 - 1] = char
				end
				if textcolor or self.overwrite then
					self.buffer[((sy - 1) * self.width + sx) * 3] = textcolor
				end
			end
		end
	end
	return self
end

function canvas:drawCanvasRotated(canvas, angle, x, y, ox, oy)
	ox, oy = ox or 1, oy or 1
	local cos, sin, range, px, py, sx, sy, backcolor, char, textcolor = _math_cos(angle), _math_sin(angle), _math_floor(math.sqrt(canvas.width * canvas.width + canvas.height * canvas.height))
	x, y = x - _math_floor(cos * (ox - 1) + sin * (oy - 1) + 0.5), y - _math_floor(cos * (oy - 1) - sin * (ox - 1) + 0.5)
	for j=-range,range do
		for i=-range,range do
			px, py, sx, sy = _math_floor(i * cos - j * sin + 0.5), _math_floor(i * sin + j * cos + 0.5), x + i, y + j
			if px >= 0 and px < canvas.width and py >= 0 and py < canvas.height and not (sx < self.x1 or sx > self.x2 or sy < self.y1 or sy > self.y2) then
				backcolor, char, textcolor = canvas.buffer[(py * canvas.width + px) * 3 + 1], canvas.buffer[(py * canvas.width + px) * 3 + 2], canvas.buffer[(py * canvas.width + px) * 3 + 3]
				if backcolor or self.overwrite then
					self.buffer[((sy - 1) * self.width + sx) * 3 - 2] = backcolor
				end
				if char or self.overwrite then
					self.buffer[((sy - 1) * self.width + sx) * 3 - 1] = char
				end
				if textcolor or self.overwrite then
					self.buffer[((sy - 1) * self.width + sx) * 3] = textcolor
				end
			end
		end
	end
end

return graphics