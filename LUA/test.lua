-- PushLua - Yet another Ableton Push Lua Framework
-- (c) 2021 - Mockba the Borg
-- This code is distributed under the "IDGAFAWYDWTCALAYGMPC" license, which means:
-- I Don't Give A Fuck About What You Do With This Code As Long As You Give Me Proper Credit
--

-- Other global variables
device = "Push"

-- Setting to collect the required modules from the right place
function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   str = str:gsub("%\\","/")
   return str:match("(.*/)")
end

package.path = script_path().."?.lua"

-- Require the modules
print("Script path = "..script_path())

require("functions")			-- Global generic Lua functions
require(device.."_functions")	-- Push specific Lua functions

-- Check for input port
deviceIn = GetDeviceInPort()
if deviceIn == false then
	die("No "..device.." input port detected.")
end
if _debug then
	printf(device.." input port is %d\n", deviceIn)
end

-- Check for output port
deviceOut = GetDeviceOutPort()
if deviceOut == false then
	die("No "..device.." output port detected.")
end
if _debug then
	printf(device.." output port is %d\n", deviceOut)
end

InitDevice()

line = 1
col = 1
for i=0,127 do
	WriteText(line, col, string.char(i))
	col = col + 1
	if col > 68 then
		line = line + 1
		col = 1
	end
end
Sleep(15000)