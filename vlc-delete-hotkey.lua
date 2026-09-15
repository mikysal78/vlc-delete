--[[
	Copyright 2015-2026 surrim

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

-- VLC extensions can't register hotkeys, so this Lua interface script watches
-- the "key-pressed" variable and deletes the current file when HOTKEY is
-- pressed. It reuses the functions of the vlc-delete.lua extension, which must
-- be installed too.

-- Configuration:
-- Key that deletes the current file, for example "d", "Delete",
-- "Shift+Delete" or "Ctrl+Alt+x".
-- Note: by default VLC binds "d" to "Toggle deinterlacing". Clear that
-- binding in Tools -> Preferences -> Hotkeys, otherwise both actions run.
local HOTKEY = "d"

local POLL_INTERVAL = 50000 -- microseconds

local MODIFIERS = {
	alt = 0x01000000;
	shift = 0x02000000;
	ctrl = 0x04000000;
	meta = 0x08000000;
	command = 0x10000000;
}

local KEYS = {
	backspace = 0x08;
	tab = 0x09;
	enter = 0x0D;
	esc = 0x1B;
	space = 0x20;
	left = 0x00210000;
	right = 0x00220000;
	up = 0x00230000;
	down = 0x00240000;
	home = 0x00330000;
	["end"] = 0x00340000;
	insert = 0x00350000;
	delete = 0x00360000;
	menu = 0x00370000;
	["page up"] = 0x00390000;
	["page down"] = 0x003A0000;
}
for i = 1, 12 do
	KEYS["f" .. i] = 0x00260000 + i * 0x00010000
end

-- Converts a key name like "Shift+Delete" to a VLC key code
function parse_hotkey(hotkey)
	local parts = {}
	for part in string.gmatch(hotkey, "[^+]+") do
		table.insert(parts, part)
	end
	local key = table.remove(parts)
	if not key then
		return nil
	end

	local code = 0
	for _, modifier in ipairs(parts) do
		local mask = MODIFIERS[string.lower(modifier)]
		if not mask then
			return nil
		end
		code = code + mask
	end

	key = string.lower(key)
	if KEYS[key] then
		return code + KEYS[key]
	elseif #key == 1 then
		return code + string.byte(key)
	end
	return nil
end

function load_extension()
	local dirs = { vlc.config.userdatadir(), vlc.config.datadir() }
	local errors = {}
	for _, dir in ipairs(dirs) do
		local ok, err = pcall(dofile, dir .. "/lua/extensions/vlc-delete.lua")
		if ok then
			return true
		end
		table.insert(errors, tostring(err))
	end
	return nil, table.concat(errors, "; ")
end

function osd_message(text)
	pcall(vlc.osd.message, text, nil, "top-left", 3000000)
end

function on_hotkey()
	local file, err = delete_current_file()
	if file then
		osd_message("Deleted: " .. string.gsub(file, "^.*[/\\]", ""))
	else
		vlc.msg.err("[vlc-delete] error: " .. (err or "nil"))
		osd_message("VLC Delete: " .. (err or "error"))
	end
end

function run(hotkey)
	local libvlc = vlc.object.libvlc()
	while true do
		if vlc.var.get(libvlc, "key-pressed") == hotkey then
			-- reset the variable, so pressing the same key again is detected
			vlc.var.set(libvlc, "key-pressed", 0)
			on_hotkey()
		end
		vlc.misc.mwait(vlc.misc.mdate() + POLL_INTERVAL)
	end
end

local hotkey = parse_hotkey(HOTKEY)
local loaded, load_err = load_extension()
if not hotkey then
	vlc.msg.err("[vlc-delete] invalid HOTKEY: " .. HOTKEY)
elseif not loaded then
	vlc.msg.err("[vlc-delete] could not load vlc-delete.lua: " .. load_err)
else
	vlc.msg.info("[vlc-delete] hotkey enabled: " .. HOTKEY)
	local ok, err = pcall(run, hotkey)
	-- mwait raises "Interrupted." when VLC closes the interface
	if not ok and not string.find(tostring(err), "Interrupted") then
		vlc.msg.err("[vlc-delete] error: " .. tostring(err))
	end
end
