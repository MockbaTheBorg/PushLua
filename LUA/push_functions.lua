-- PushLua v1.00

-- SysEx Strings
-----------------------------------------------------
IdentityRequest = "\xF0\x7E\x00\x06\x01\xF7"
PushSysexHead = "\xF0\x47\x7F\x15"
PushSysexTail = "\xF7"
PushSetLive = "\x62\x00\x01\x00"
PushSetUser = "\x62\x00\x01\x01"

-- Pad Colors
-----------------------------------------------------
ScaleColor = 45
BackColor = 3
NoteColor = 21

-- Note information
-----------------------------------------------------
NoteOffset = 35
NoteMin = 36
NoteMax = 99

PushBack = 4

GlobalNote = 1
GlobalScale = 1

-- Note definitions
-----------------------------------------------------
NoteNames = { "C","C#","D","D#","E","F","F#","G","G#","A","A#","B" }

-- Scale definitions
-----------------------------------------------------
ScaleNames = {	"Major", "Natural Minor", "Harmonic Minor", "Melodic Minor", 
				"Major Blues", "Minor Blues", "Maj Pentatonic", "Min Pentatonic",
				"Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian",
				"Alt Pentatonic", "Alt Ionian #5" }
ScaleOffsets = {}
ScaleOffsets[1] = { 2, 2, 1, 2, 2, 2, 1 }
ScaleOffsets[2] = { 2, 1, 2, 2, 1, 2, 2 }
ScaleOffsets[3] = { 2, 1, 2, 2, 1, 3, 1 }
ScaleOffsets[4] = { 2, 1, 2, 2, 2, 2, 1 }
ScaleOffsets[5] = { 2, 1, 1, 3, 2, 3 }
ScaleOffsets[6] = { 2, 1, 1, 3, 2, 3 }
ScaleOffsets[7] = { 2, 2, 3, 2, 3 }
ScaleOffsets[8] = { 3, 2, 2, 3, 2 }
ScaleOffsets[9] = { 2, 2, 1, 2, 2, 2, 1 }
ScaleOffsets[10] = { 2, 1, 2, 2, 2, 1, 2 }
ScaleOffsets[11] = { 1, 2, 2, 2, 1, 2, 2 }
ScaleOffsets[12] = { 2, 2, 2, 1, 2, 2, 1 }
ScaleOffsets[13] = { 2, 2, 1, 2, 2, 1, 2 }
ScaleOffsets[14] = { 2, 1, 2, 2, 1, 2, 2 }
ScaleOffsets[15] = { 1, 2, 2, 1, 2, 2, 2 }
ScaleOffsets[16] = { 1, 4, 2, 2, 3 }
ScaleOffsets[17] = { 2, 2, 1, 3, 1, 2, 1 }
ScaleSizes = {}
for i=1,#ScaleNames do
	ScaleSizes[i] = #ScaleOffsets[i]
end

Translation = {}
Colors = {}

-- Push functions
-----------------------------------------------------

-- Returns the input port number of Push
function GetDeviceInPort()
	local result = false
	local ports = GetMidiInList()
	for key,value in pairs(ports) do
		if string.sub(value, 1, 12) == "Ableton Push" then
			result = key
			return result
		end
	end
	return result
end

-- Returns the output port number of Push
function GetDeviceOutPort()
	local result = false
	local ports = GetMidiOutList()
	for key,value in pairs(ports) do
		if string.sub(value, 1, 12) == "Ableton Push" then
			result = key
			return result
		end
	end
	return result
end

-- Returns the output port number for MIDI
function GetMidiOutPort()
	local result = false
	local ports = GetMidiOutList()
	for key,value in pairs(ports) do
		if string.sub(value, 1, 7) == "LuaPush" then
			result = key
			return result
		end
	end
	return result
end

-- Clears a line (1-4) on the LCD
function ClearLine(Line)
	if Line < 1 then
		Line = 1
	end
	if Line > 4 then
		Line = 4
	end
	SendDeviceMessage(PushSysexHead..string.char(Line+27).."\x00\x00"..PushSysexTail)
end

-- Writes a text to the LCD
function WriteText(Line, Col, Text)
	if Line < 1 then
		Line = 1
	end
	if Line > 4 then
		Line = 4
	end
	if Col < 1 then
		Col = 1
	end
	if Col > 68 then
		Col = 68
	end
	local Len = #Text
	SendDeviceMessage(PushSysexHead..string.char(Line+23).."\x00"..string.char(Len+1)..string.char(Col-1)..Text..PushSysexTail)
end

-- Seta the color of a pad
function SetPadColor(Pad, Color)
	local Note = Pad + NoteOffset
	SendDeviceMessage("\x90"..string.char(Note)..string.char(Color))
end

-- Draws all the pads according to Note/Scale
function UpdatePadsScale()
	local Note = GlobalNote
	local Scale = GlobalScale
	if _debug then
		printf("Setting scale to %s %s\n", NoteNames[Note], ScaleNames[Scale])
	end
	local ScaleSize = ScaleSizes[Scale]
	local Pos = 1
	local Note = Note + NoteOffset
	local Index = 1
	for i=1,8 do
		for j=1,8 do
			if Pos == 1 then
				Color = ScaleColor
			else
				Color = BackColor
			end
			SetPadColor(Index, Color)
			Translation[Index] = Note
			Colors[Index] = Color
			Index = Index + 1
			Note = Note + ScaleOffsets[Scale][Pos]
			Pos = Pos + 1
			if Pos > ScaleSize then
				Pos = 1
			end
		end
		Note = Translation[Index - (PushBack + 1)] 
		Pos = Pos - (PushBack + 1)
		if Pos < 1 then
			Pos = Pos + ScaleSize
		end
	end
end

-- OS specific initializations
function InitOS()
	local MyOS = GetOS()

	if MyOS == "windows" then
		printf("Running on %s\n", "Windows")
		-- Check for midi output port
		printf("Getting MIDI out port ... ")
		local midiOut = GetMidiOutPort()
		printf("Done!\n")
		if midiOut == false then
			die("No MIDI output port detected.")
		end
		if _debug then
			printf("Midi output port is %d\n", midiOut)
		end
		printf("Opening MIDI out port ... ")
		OpenMidiOutPort(midiOut)
		printf("Done!\n")
	else
		printf("Running on %s\n", "Linux")
		if _debug then
			printf("Midi output port is virtual\n")
		end
		OpenMidiOutPort(-1)	-- Create virtual port
	end
end

-- Device specific initializations
function InitDevice()
	printf("Opening %s ports ... ", device)
	OpenDeviceInPort(deviceIn)
	OpenDeviceOutPort(deviceOut)
	printf("Done!\n")

	-- Get Push information
	printf("Identifying %s ... ", device)
	SendDeviceMessage(IdentityRequest)
	Sleep(10)
	local stamp,message = ReadDeviceMessage()
	printf("Done!\n")
	printf("%s version [%d.%02d]\n", device, message:byte(12,12), message:byte(13,13))
	printf("%s serial  [%s]\n", device, message:sub(19,32));

	-- Set Push into Live mode (clears display)
	printf("Initializing %s ... ", device)
	SendDeviceMessage(PushSysexHead..PushSetLive..PushSysexTail)
	Sleep(10)
	local stamp,message = ReadDeviceMessage()
	UpdatePadsScale()
	printf("Done!\n")

	Init()
end

-- PushLua specific initializations
function InitPushLua()
	WriteText(1, 1, "PushLua v1.00")
	WriteText(2, 1, "by MockbaTheBorg")
	WriteText(3, 1, "Loading...")
	Sleep(2000)
	ClearLine(1)
	ClearLine(2)
	ClearLine(3)

	UpdateGlobalNote()
	UpdateGlobalScale()
end

-- Close device
function ResetDevice()
	printf("\nClosing %s ... ", device)

	-- Set Push into User mode
	SendDeviceMessage(PushSysexHead..PushSetUser..PushSysexTail)

	printf("Done!\n")
end

-- Processes NoteOn messages
function ProcessNoteOn(Note, Speed)
	printf("Note %d on speed %d\n", Note, Speed)
	local Pad = Note - NoteOffset
	if not (Note < NoteMin or Note > NoteMax) then
		local newNote = Translation[Pad]
		for i=1,64 do
			if(Translation[i] == newNote) then
				SetPadColor(i, NoteColor)
			end
		end
		SendMidiMessage("\x90"..string.char(newNote)..string.char(Speed))
	end
end

-- Processes NoteOff messages
function ProcessNoteOff(Note, Speed)
	printf("Note %d off\n", Note)
	local Pad = Note - NoteOffset
	if not (Note < NoteMin or Note > NoteMax) then
		local newNote = Translation[Pad]
		for i=1,64 do
			if(Translation[i] == newNote) then
				SetPadColor(i, Colors[i])
			end
		end
		SendMidiMessage("\x80"..string.char(newNote)..string.char(Speed))
	end
	if Note == 0 or Note == 1 then
		UpdatePadsScale()
	end
end

-- Processes NotePressure messages
function ProcessNotePressure(Note, Pressure)
	printf("Note Pressure %d %d\n", Note, Pressure)
	local Pad = Note - NoteOffset
	if not (Note < NoteMin or Note > NoteMax) then
		newNote = Translation[Pad]
		SendMidiMessage("\xA0"..string.char(newNote)..string.char(Pressure))
	end
end

-- Processes CC messages
function ProcessCC(CC, Value)
	if CC == 14 or CC == 15 or (CC > 70 and CC < 80) then
		if Value > 63 then
			Value = Value - 128
		end
	end
	printf("CC %d to %d\n", CC, Value)
	if CC == 71 then
		ChangeGlobalNote(Value)
	end
	if CC == 72 then
		ChangeGlobalScale(Value)
	end
end

-- Changes the Global Note
function ChangeGlobalNote(Value)
	GlobalNote = GlobalNote + Value
	if GlobalNote < 1 then
		GlobalNote = 1
	end
	if GlobalNote > 12 then
		GlobalNote = 12
	end
	UpdateGlobalNote()
end

-- Changes the Global Scale
function ChangeGlobalScale(Value)
	GlobalScale = GlobalScale + Value
	if GlobalScale < 1 then
		GlobalScale = 1
	end
	if GlobalScale > #ScaleNames then
		GlobalScale = #ScaleNames
	end
	UpdateGlobalScale()
end

-- Updates the Global Note on screen
function UpdateGlobalNote()
	WriteText(1, 1, string.format("%-2s", NoteNames[GlobalNote]))
end

-- Updates the Global Scale on screen
function UpdateGlobalScale()
	WriteText(1, 4, string.format("%-14s", ScaleNames[GlobalScale]))
end

-- Save the configuration onto json
function SaveConfig()
	local json = loadfile("../LUA/json.lua")()
	local config = {}
	config["ScaleNames"] = ScaleNames
	config["ScaleOffsets"] = ScaleOffsets
	config["ScaleColor"] = ScaleColor
	config["BackColor"] = BackColor
	config["NoteColor"] = NoteColor

	local file = assert(io.open("config.json", "w"))
	file:write(json.encode(config))
	file:close()
end

-- Load the configuration from json
function LoadConfig()
	local json = loadfile("../LUA/json.lua")()
	local file = assert(io.open("config.json", "r"))
	str = file:read()
	file:close()

	local config = json.decode(str)
	ScaleNames = config["ScaleNames"]
	ScaleOffsets = config["ScaleOffsets"]
	ScaleColor = config["ScaleColor"]
	BackColor = config["BackColor"]
	NoteColor = config["NoteColor"]
end