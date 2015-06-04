-- OpenGraphics alpha 0.0.1 by CrazedProgrammer
-- Licensed under MIT: http://opensource.org/licenses/mit-license.php
-- Available on GitHub: https://github.com/CrazedProgrammer/OpenGraphics
-- Please load this API with dofile or put it directly into your program.

-- Local variables and lookups, don't delete these.
local _table_concat, _colors = table.concat, {[1]="0",[2]="1",[4]="2",[8]="3",[16]="4",[32]="5",[64]="6",[128]="7",[256]="8",[512]="9",[1024]="a",[2048]="b",[4096]="c",[8192]="d",[16384]="e",[32768]="f"}

-- Canvas functions, you can delete these.
local _canvas =
{
render = function(canvas, display, x, y, x1, y1, x2, y2)
	display, x, y, x1, y1, x2, y2 = display or term, x or 1, y or 1, x1 or 1, y1 or 1, x2 or canvas.width, y2 or canvas.height
	if x1 > x2 then
		local temp = x1
		x1, x2 = x2, temp
	end
	if y1 > y2 then
		local temp = y1
		y1, y2 = y2, temp
	end
	if x2 < 1 or x1 > canvas.width or y2 < 1 or y1 > canvas.height then return end
	if x1 < 1 then x = x + x1 - 1 x1 = 1 end
	if x2 > canvas.width then x2 = canvas.width end
	if y1 < 1 then y = y + y1 - 1 y1 = 1 end
	if y2 > canvas.height then y2 = canvas.height end
	if not display.blit then
		local back, char, text = { }, { }, { }
		for j=y1,y2 do
			display.setCursorPos(x - x1 + 1, j - y1 + y)
			for i=x1,x2 do
				back[i - x1 + 1] = _colors[canvas.buffer[((j - 1) * canvas.width + i) * 3 - 2] or 32768]
				char[i - x1 + 1] = canvas.buffer[((j - 1) * canvas.width + i) * 3 - 1] or " "
				text[i - x1 + 1] = _colors[canvas.buffer[((j - 1) * canvas.width + i) * 3] or 1]
			end
			display.blit(_table_concat(char), _table_concat(text), _table_concat(back))
		end
		return (y2 - y1 + 1) * 2
	else
		local cmd, char, back, text, lchar, lback, ltext, c, a = { }, { }, 0, 0
		for j=y1,y2 do
			cmd[#cmd + 1], cmd[#cmd + 2] = 1, y + j - y1
			for i=x1,x2 do
				lchar, lback, ltext = canvas.buffer[((j - 1) * canvas.width + i) * 3 - 1] or " ", canvas.buffer[((j - 1) * canvas.width + i) * 3 - 2] or 32768, canvas.buffer[((j - 1) * canvas.width + i) * 3] or 1
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
end;
}

-- Main graphics functions (gets returned to the user), you can delete these.
local _graphics =
{
createCanvas = function(width, height, backcolor, char, textcolor)
	local canvas = setmetatable({ }, {__index = _canvas})
	canvas.width = width
	canvas.height = height
	canvas.x1 = 1
	canvas.y1 = 1
	canvas.x2 = width
	canvas.y2 = height
	canvas.overwrite = false
	canvas.buffer = { }
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
}

return _graphics