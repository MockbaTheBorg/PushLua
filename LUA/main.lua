-- PushLua - Yet another Ableton Push Lua Framework
-- (c) 2021 - Mockba the Borg
-- This code is distributed under the "IDGAFAWYDWTCALAYGMPC" license, which means:
-- I Don't Give A Fuck About What You Do With This Code As Long As You Give Me Proper Credit
--

-- Debug global to print additional information
_debug = false

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
require("globals")				-- Global variables
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

-- Load the scales file
if file_exists("scales.json") then
	LoadScales()
else
	CreateScales()
	SaveScales()
end

-- Load the configuration if exists, otherwise creates it
if file_exists("config.json") then
	LoadConfig()
else
	SaveConfig()
end

-- Initialize OS specific elements
InitOS()

-- Initialize device operation
InitDevice()

-- Initialize PushLua parameters
InitPushLua()

printf("PushLua Ready!\n")

-- Main loop function
function Loop()
	local stamp,message = ReadDeviceMessage()
	if #message > 0 then
		local byte1 = message:byte(1,1)
		local byte2 = message:byte(2,2)
		local byte3 = message:byte(3,3)
		local midiType = byte1 & 0xF0

		-- Turn note on with velocity 0 into note off
		if midiType == midiNoteOn and byte3 == 0 then
			midiType = midiNoteOff
		end

		-- Print the MIDI events
		if _debug then
			printf("Msg %02x ", midiType)
			if midiType == midiNoteOff then 
				printf("Note Off %d\n", byte2)
			elseif midiType == midiNoteOn then 
				printf("Note On  %d %d\n", byte2, byte3)
			elseif midiType == midiNotePressure then 
				printf("Note Pressure: %d %d\n", byte2, byte3)
			elseif midiType == midiControl then
				printf("Control %d %d\n", byte2, byte3)
			elseif midiType == midiProgramChange then 
				printf("Program Change %d %d\n", byte2, byte3)
			elseif midiType == midiChannelPressure then 
				printf("Channel Pressure %d\n", byte2)
			elseif midiType == midiPitchBend then
				printf("Pitchbend %d %d\n", byte2, byte3)
			elseif midiType == midiSysEx then
				printf("Sysex\n")
				for i=1,#message do
					printf("%02x ", message:byte(i,i))
				end
				printf("\n")
			else
				printf("Message %02x %d %d\n", byte1, byte2, byte3)
			end
		end

		-- Always forward PitchBend
		if midiType == midiPitchBend then
			SendMidiMessage("\xE0"..string.char(byte2)..string.char(byte3))
		end

		-- Always forward Sustain
		if midiType == midiControl and byte2 == midiCCSustain then
			SendCC(byte2, byte3)
		end

		-- Process the MIDI events according to the mode
		if Mode == 1 then
			processScalesMode(message)
		elseif Mode == 2 then
			processDrumsMode(message)
		else
			processUserMode(message)
		end
	else
		Sleep(10)
	end
end
