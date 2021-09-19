-- PushLua - Yet another Ableton Push Lua Framework
-- (c) 2021 - Mockba the Borg
-- This code is distributed under the "IDGAFAWYDWTCALAYGMPC" license, which means:
-- I Don't Give A Fuck About What You Do With This Code As Long As You Give Me Proper Credit
--

-- Debug global to print additional information
_debug = true

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

-- Main program
printf("main.lua started.\n")
if _debug then
	printf("Lua version is %s\n", _VERSION)
	printf("Number of MIDI Out ports = %d\n", GetMidiInCount())
	print_r(GetMidiInList())
	printf("Number of MIDI Out ports = %d\n", GetMidiOutCount())
	print_r(GetMidiOutList())
end

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

-- Load the configuration if exists, otherwise creates
if file_exists("config.json") then
	LoadConfig()
end

-- Initialize OS specific elements
InitOS()

-- Initialize device operation
InitDevice()

-- Initialize PushLua parameters
InitPushLua()

-- Main loop function
function loop()
	local stamp,message = ReadDeviceMessage()
	if #message > 0 then
		byte1 = message:byte(1,1)
		byte2 = message:byte(2,2)
		byte3 = message:byte(3,3)
		midiType = byte1 & 0xF0
		midiChannel = (byte1 & 0x0F) + 1

		printf("Message %02x ",midiType)

		-- Turn note on with speed 0 into note off
		if midiType == 0x90 and byte3 == 0 then
			midiType = 0x80
		end

		-- Work on the MIDI events
		if(midiType == 0x80) then 
			ProcessNoteOff(byte2, byte3)
		elseif(midiType == 0x90) then 
			ProcessNoteOn(byte2, byte3)
		elseif(midiType == 0xA0) then 
			ProcessNotePressure(byte2, byte3)
		elseif(midiType == 0xB0) then
			ProcessCC(byte2, byte3)
		elseif(midiType == 0xC0) then 
			printf("Program Change %d %d\n", byte2, byte3)
		elseif(midiType == 0xD0) then 
			ProcessChannelPressure(byte2)
		elseif(midiType == 0xE0) then
			printf("Pitchbend %d %d\n", byte2, byte3)
			SendMidiMessage("\xE0"..string.char(byte2)..string.char(byte3))
		elseif(midiType == 0xF0) then
			printf("Sysex\n")
			for i=1,#message do
				printf("%02x ", message:byte(i,i))
			end
			printf("\n")
		else
			printf("Message %02x %d %d\n", byte1, byte2, byte3)
		end
	end
end