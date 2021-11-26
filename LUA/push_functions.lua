-- PushLua - Yet another Ableton Push Lua Framework
-- (c) 2021 - Mockba the Borg
-- This code is distributed under the "IDGAFAWYDWTCALAYGMPC" license, which means:
-- I Don't Give A Fuck About What You Do With This Code As Long As You Give Me Proper Credit
--

-- SysEx strings
-----------------------------------------------------
IdentityRequest = "\xF0\x7E\x00\x06\x01\xF7"
PushSysexHead = "\xF0\x47\x7F\x15"
PushSysexTail = "\xF7"
PushSetLive = "\x62\x00\x01\x00"
PushSetUser = "\x62\x00\x01\x01"
PushStripPB = "\x63\x00\x01\x05"
PushSetNoteAT = "\x5C\x00\x01\x00"
PushSetChannelAT = "\x5C\x00\x01\x01"

-- Default Pad colors
-----------------------------------------------------
ScaleColor = 45
BackColor = 3
NoteColor = 21
RelColor = 22

-- Octave offset (up / down)
-----------------------------------------------------
OctaveOffset = 0

-- Velocity and Curve of notes sent
SendVelocity = -1	-- -1 = As Input
SendCurve = 0		-- 0 = Linear

-- Note information
-----------------------------------------------------
NoteOffset = 35
NoteMin = 36
NoteMax = 99

PushBack = 4

GlobalNote = 1
GlobalScale = 1

-- Mode definitions
-----------------------------------------------------
Mode = 1
Modes = { "Scales", "Drums", "User" }

EditMode = false
EditingPad = 1
EditingNote = -1	-- None
EditingColor = 0 	-- Off

Duplicating = false
Deleting = false

-- Note definitions
-----------------------------------------------------
NoteNames = { "C","C#","D","D#","E","F","F#","G","G#","A","A#","B" }

-- Notes and Colors definitions
-----------------------------------------------------

-- Notes and colors on the pads
Notes = {}
Colors = {}

-- Notes and colors for the selected Scale
ScaleNotes = {}
ScaleColors = {}

-- Notes and colors for the selected Drum
DrumNotes = {}
DrumColors = {}
for i=1,64 do
	DrumNotes[i] = -1
	DrumColors[i] = 0
end

-- Notes and colors for the User mode
UserNotes = {}
UserColors = {}
for i=1,64 do
	UserNotes[i] = i + NoteOffset
	UserColors[i] = BackColor
end

-- Notes currently being played to prevent duplications
ActiveNotes = {}
for i=0,127 do
	ActiveNotes[i] = 0
end

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
		if string.sub(value, 1, 7) == "PushLua" then
			result = key
			return result
		end
	end
	return result
end

-- Create the default scales
function CreateScales()
	ScaleNames = {	"Major", "Natural Minor", "Harmonic Minor", "Melodic Minor", 
					"Major Blues", "Minor Blues", "Maj Pentatonic", "Min Pentatonic",
					"Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian",
					"Alt Pentatonic", "Alt Ionian #5", "Alt Dorian b2", "Alt Dorian b5", "Alt Phrygn b4",
					"Alt Lydian #2", "Alt Lydian b7", "Alt Aeolian b1", "Alt Locrian" }
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
	ScaleOffsets[18] = { 1, 2, 2, 2, 2, 1, 2 }
	ScaleOffsets[19] = { 2, 1, 2, 1, 3, 1, 2 }
	ScaleOffsets[20] = { 1, 3, 1, 2, 2, 1, 2 }
	ScaleOffsets[21] = { 2, 2, 2, 2, 1, 2, 1 }
	ScaleOffsets[22] = { 2, 2, 2, 1, 2, 1, 2 }
	ScaleOffsets[23] = { 2, 2, 1, 2, 1, 3, 1 }
	ScaleOffsets[24] = { 1, 2, 1, 2, 2, 2, 2 }
end

-- Load the scales from a json file
function LoadScales()
	printf("Loading Scales ... ")
	local json = loadfile("../LUA/json.lua")()
	local file = assert(io.open("scales.json", "r"))
	str = file:read("*a")
	file:close()

	local scales = json.decode(str)
	ScaleNames = scales["ScaleNames"]
	ScaleOffsets = scales["ScaleOffsets"]
	printf("ok.\n")
end

-- Save the scales to a json file
function SaveScales()
	local json = loadfile("../LUA/json.lua")()
	local scales = {}
	scales["ScaleNames"] = ScaleNames
	scales["ScaleOffsets"] = ScaleOffsets

	local file = assert(io.open("scales.json", "w"))
	file:write(json.encode(scales))
	file:close()
end

-- Load the configuration from json
function LoadConfig()
	printf("Loading Config ... ")
	local json = loadfile("../LUA/json.lua")()
	local file = assert(io.open("config.json", "r"))
	str = file:read("*a")
	file:close()

	local config = json.decode(str)
	ScaleColor = config["ScaleColor"]
	BackColor = config["BackColor"]
	NoteColor = config["NoteColor"]
	RelColor = config["RelColor"]
	printf("ok.\n")

	printf("Loading Drums ... ")
	local file = assert(io.open("drums.json", "r"))
	str = file:read("*a")
	file:close()
	local drums = json.decode(str)
	DrumNotes = drums["DrumNotes"]
	DrumColors = drums["DrumColors"]
	printf("ok.\n")

	printf("Loading User ... ")
	local file = assert(io.open("user.json", "r"))
	str = file:read("*a")
	file:close()
	local user = json.decode(str)
	UserNotes = user["UserNotes"]
	UserColors = user["UserColors"]
	printf("ok.\n")
end

-- Save the configuration onto json
function SaveConfig()
	local json = loadfile("../LUA/json.lua")()
	local config = {}
	config["ScaleColor"] = ScaleColor
	config["BackColor"] = BackColor
	config["RelColor"] = RelColor
	config["NoteColor"] = NoteColor
	local file = assert(io.open("config.json", "w"))
	file:write(json.encode(config))
	file:close()

	local drums = {}
	drums["DrumNotes"] = DrumNotes
	drums["DrumColors"] = DrumColors
	local file = assert(io.open("drums.json", "w"))
	file:write(json.encode(drums))
	file:close()

	local user = {}
	user["UserNotes"] = UserNotes
	user["UserColors"] = UserColors
	local file = assert(io.open("user.json", "w"))
	file:write(json.encode(user))
	file:close()
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
	Sleep(20)
	local stamp,message = ReadDeviceMessage()
	printf("Done!\n")
	printf("%s version [%d.%02d]\n", device, message:byte(12,12), message:byte(13,13))
	printf("%s serial  [%s]\n", device, message:sub(19,32));

	-- Set Push into Live mode (clears display)
	printf("Initializing %s ... ", device)
	SendDeviceMessage(PushSysexHead..PushSetUser..PushSysexTail)
	Sleep(20)
	SendDeviceMessage(PushSysexHead..PushSetLive..PushSysexTail)
	Sleep(20)
	local stamp,message = ReadDeviceMessage()
	Sleep(20)
	SendDeviceMessage(PushSysexHead..PushSetChannelAT..PushSysexTail)
	Sleep(20)
	local stamp,message = ReadDeviceMessage()
	Sleep(20)
	SendDeviceMessage(PushSysexHead..PushStripPB..PushSysexTail)
	Sleep(20)
	local stamp,message = ReadDeviceMessage()
	printf("Done!\n")

	Init()	-- Alerts the C code of the initialization
end

-- Close device
function ResetDevice()
	printf("\nClosing %s ... ", device)

	-- Turn off User button
	SetButtonColor(59, 0)

	-- Set Push into User mode
	SendDeviceMessage(PushSysexHead..PushSetUser..PushSysexTail)

	printf("Done!\n")
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

-- PushLua specific initializations
function InitPushLua()
	WriteText(1, 1, "PushLua "..version)
	WriteText(2, 1, "by MockbaTheBorg")
	WriteText(3, 1, "Loading...")
	Sleep(1500)

	ClearLine(1)
	ClearLine(2)
	ClearLine(3)
	ClearLine(4)

	GeneratePadsScale()
	UpdateMode()
	UpdateGlobalNote()
	UpdateGlobalScale()
	UpdateSendVelocity()
	UpdateSendCurve()
	RedrawPads()
	RedrawButtons()
end

-- Generate the Scale note translations according to Note/Scale
function GeneratePadsScale()
	if Mode == 1 then
		if _debug then
			printf("Generating Scale notes\n")
		end
		local Note = math.floor(GlobalNote)
		local Scale = math.floor(GlobalScale)
		if _debug then
			printf("Setting scale to %s %s\n", NoteNames[Note], ScaleNames[Scale])
		end
		local ScaleSize = #ScaleOffsets[Scale]
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
				Notes[Index] = Note
				Colors[Index] = Color
				Index = Index + 1
				Note = Note + ScaleOffsets[Scale][Pos]
				Pos = Pos + 1
				if Pos > ScaleSize then
					Pos = 1
				end
			end
			Note = Notes[Index - (PushBack + 1)] 
			Pos = Pos - (PushBack + 1)
			if Pos < 1 then
				Pos = Pos + ScaleSize
			end
		end
	end
	if Mode == 2 then
		if _debug then
			printf("Generating Drum notes\n")
		end
		for i=1,64 do
			Notes[i] = DrumNotes[i]
			Colors[i] = DrumColors[i]
		end
	end
	if Mode == 3 then
		if _debug then
			printf("Generating User notes\n")
		end
		for i=1,64 do
			Notes[i] = UserNotes[i]
			Colors[i] = UserColors[i]
		end
	end
end

-- Updates the Mode on screen
function UpdateMode()
	WriteText(1, 1, "Mode:       ")
	WriteText(1, 7, Modes[Mode])
end

-- Updates the Global Note on screen
function UpdateGlobalNote()
	local Note = math.floor(GlobalNote)
	WriteText(2, 1, string.format("%-2s", NoteNames[Note]))
end

-- Updates the Global Scale on screen
function UpdateGlobalScale()
	local Scale = math.floor(GlobalScale)
	WriteText(2, 4, string.format("%-14s", ScaleNames[Scale]))
end

-- Updates the Send Velocity on screen
function UpdateSendVelocity()
	local Velocity = math.floor(SendVelocity)
	WriteText(1, 35, "Velocity")
	if Velocity == -1 then
		WriteText(2, 35, "As Input")
	else
		WriteText(2, 35, string.format("%5d   ", Velocity))
	end
end

-- Updates the Velocity Curve on screen
function UpdateSendCurve()
	local Curve = math.floor(SendCurve)
	WriteText(1, 46, "Curve")
	if Curve == 0 then
		WriteText(2, 46, "Linear")
	else
		WriteText(2, 46, string.format("%5d ", Curve))
	end
end

-- Sets the color of a pad
function SetPadColor(Pad, Color)
	local Note = Pad + NoteOffset
	SendDeviceMessage("\x90"..string.char(Note)..string.char(Color))
end

-- Sets the color of a button
function SetButtonColor(Button, Color)
	if _debug then
		printf("Setting button %d color to %d\n", Button, Color)
	end
	SendDeviceMessage("\xB0"..string.char(Button)..string.char(Color))
end

-- Redraw all the pads
function RedrawPads()
	if _debug then
		printf("Redrawing Pads\n")
	end
	for i=1,64 do
		if Colors[i] > -1 then
			SetPadColor(i, Colors[i])
		end
	end
end

-- Redraw buttons
function RedrawButtons()
	if _debug then
		printf("Redrawing Buttons\n")
	end
	-- Edit mode
	if EditMode then
		SetButtonColor(buttonNotes, dimBlinkFast)
		SetButtonColor(buttonUndo, dimBlinkFast)
		if Duplicating then
			SetButtonColor(buttonDuplicate, litBlinkFast)
		else
			SetButtonColor(buttonDuplicate, dim)
		end
		if Deleting then
			SetButtonColor(buttonDelete, litBlinkFast)
		else
			SetButtonColor(buttonDelete, dim)
		end
	else
		SetButtonColor(buttonNotes, dim)
		SetButtonColor(buttonUndo, off)
		SetButtonColor(buttonDuplicate, off)
		SetButtonColor(buttonDelete, off)
	end
	-- Mode buttons
	if Mode == 1 then
		SetButtonColor(buttonScales, litBlink)
		SetButtonColor(buttonUser, lit)
		SetButtonColor(buttonNotes, off)
	end
	if Mode == 2 then
		SetButtonColor(buttonScales, lit)
		SetButtonColor(buttonUser, lit)
	end
	if Mode == 3 then
		SetButtonColor(buttonScales, lit)
		SetButtonColor(buttonUser, litBlink)
	end
	-- Octave offset
	if Mode == 2 then
		SetButtonColor(buttonOctDown, off)
		SetButtonColor(buttonOctUp, off)
	else
		if OctaveOffset == 0 then
			SetButtonColor(buttonOctDown, lit)
			SetButtonColor(buttonOctUp, lit)
		end
		if OctaveOffset == 12 then
			SetButtonColor(buttonOctDown, lit)
			SetButtonColor(buttonOctUp, litBlink)
		end
		if OctaveOffset == 24 then
			SetButtonColor(buttonOctDown, lit)
			SetButtonColor(buttonOctUp, litBlinkFast)
		end
		if OctaveOffset == -12 then
			SetButtonColor(buttonOctDown, litBlink)
			SetButtonColor(buttonOctUp, lit)
		end
		if OctaveOffset == -24 then
			SetButtonColor(buttonOctDown, litBlinkFast)
			SetButtonColor(buttonOctUp, lit)
		end
	end
end


-- Changes the Send Velocity
function ChangeVelocity(Value)
	SendVelocity = SendVelocity + (Value / 10)
	if SendVelocity < -1 then
		SendVelocity = -1
	end
	if SendVelocity > 127 then
		SendVelocity = 127
	end
	UpdateSendVelocity()
end

-- Changes the Velocity Curve
function ChangeCurve(Value)
	SendCurve = SendCurve + (Value / 10)
	if SendCurve < -9 then
		SendCurve = -9
	end
	if SendCurve > 9 then
		SendCurve = 9
	end
	UpdateSendCurve()
end

-- Changes the Global Note
function ChangeGlobalNote(Value)
	GlobalNote = GlobalNote + (Value / 10)
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
	GlobalScale = GlobalScale + (Value / 10)
	if GlobalScale < 1 then
		GlobalScale = 1
	end
	if GlobalScale > #ScaleNames then
		GlobalScale = #ScaleNames
	end
	UpdateGlobalScale()
end

-- Changes the edited Pad's Note
function ChangeEditedNote(Value)
	EditingNote = EditingNote + (Value / 10)
	if EditingNote < -1 then
		EditingNote = -1
	end
	if EditingNote > 127 then
		EditingNote = 127
	end
	UpdateEditingNote()
end

-- Changes the edited Pad's Color
function ChangeEditedColor(Value)
	EditingColor = EditingColor + (Value / 10)
	if EditingColor < 0 then
		EditingColor = 0
	end
	if EditingColor > 127 then
		EditingColor = 127
	end
	UpdateEditingColor()
end

-- Sets current mode to Scales
function SetModeScales()
	Mode = 1
	UpdateMode()
	UpdateGlobalNote()
	UpdateGlobalScale()
	SetButtonColor(buttonScales, litBlink)
	SetButtonColor(buttonUser, lit)
	GeneratePadsScale()
	RedrawPads()
end

-- Sets current mode to Drums
function SetModeDrums()
	Mode = 2
	UpdateMode()
	WriteText(2, 1, "                 ")
	GeneratePadsScale()
	RedrawPads()
end

-- Sets current mode to User
function SetModeUser()
	Mode = 3
	UpdateMode()
	WriteText(2, 1, "                 ")
	GeneratePadsScale()
	RedrawPads()
end

-- Starts Edit Mode
function StartEdit()
	EditMode = true
	WriteText(1, 18, "Editing Pad    ")
	WriteText(2, 18, "Note  Color")
	UpdateEditingPad()
	UpdateEditingNote()
	UpdateEditingColor()
end

-- Stops Edit Mode
function StopEdit(CC)
	EditMode = false
	WriteText(1, 18, "              ")
	WriteText(2, 18, "              ")
	WriteText(3, 18, "              ")
	if CC ~= buttonUndo then
		SaveConfig()
	else
		LoadConfig()
		GeneratePadsScale()
		RedrawPads()
		printf("Edit mode cancelled\n")
	end
	EditingPad = 1
end

-- Checks if CC is a knob
function IsKnob(CC)
	if CC == knobTempo or CC == knobVolume or (CC > 70 and CC < 80) then
		return true
	else
		return false
	end
end

-- Updates the editing Pad on screen
function UpdateEditingPad()
	WriteText(1, 30, string.format("%-2d", EditingPad))
	if Mode == 2 then
		EditingNote = DrumNotes[EditingPad]
		EditingColor = DrumColors[EditingPad]
	else
		EditingNote = UserNotes[EditingPad]
		EditingColor = UserColors[EditingPad]
	end
	UpdateEditingNote()
	UpdateEditingColor()
end

-- Updates the editing Note on screen
function UpdateEditingNote()
	local EditingNote = math.floor(EditingNote)
	if EditingNote == -1 then
		WriteText(3, 18, "Off")
		EditingColor = 0
		UpdateEditingColor()
	else
		WriteText(3, 18, string.format("%-3d", EditingNote))
	end
	if Mode == 2 then
		DrumNotes[EditingPad] = EditingNote
	else
		UserNotes[EditingPad] = EditingNote
	end
	Notes[EditingPad] = EditingNote
end

-- Updates the editing Color on screen
function UpdateEditingColor()
	local EditingColor = math.floor(EditingColor)
	WriteText(3, 24, string.format("%-3d", EditingColor))
	if Mode == 2 then
		DrumColors[EditingPad] = EditingColor
	else
		UserColors[EditingPad] = EditingColor
	end
	SetPadColor(EditingPad, EditingColor)
	Colors[EditingPad] = EditingColor
end

-- Sends a note on message
function SendNoteOn(Pad, Note, Velocity)
	local newVelocity = math.floor(SendVelocity)
	if newVelocity > -1 then
		Velocity = newVelocity
	end
	local newNote = Notes[Pad]
	if newNote > -1 then
		ActiveNotes[newNote] = ActiveNotes[newNote] + 1
		if ActiveNotes[newNote] > 1 then
			return
		end
		for i=1,64 do
			if Notes[i] == newNote then
				if i == Pad then
					SetPadColor(i, NoteColor)
				else
					SetPadColor(i, RelColor)
				end
			end
		end
		newNote = newNote + OctaveOffset
		local newCurve = math.floor(SendCurve) * -1
		if newCurve ~= 0 then
			if newCurve < 0 then
				newCurve = newCurve / 10
			end
			local newV = Velocity / 127
			newV = newV / (1 + (1 - newV) * newCurve)
			Velocity = math.floor(newV * 127)
		end
		SendMidiMessage("\x90"..string.char(newNote)..string.char(Velocity))
	end
end

-- Sends a note off message
function SendNoteOff(Pad, Note, Velocity)
	local newNote = Notes[Pad]
	if newNote > -1 then
		ActiveNotes[newNote] = ActiveNotes[newNote] - 1
		if ActiveNotes[newNote] < 0 then
			ActiveNotes[newNote] = 0
		end
		if ActiveNotes[newNote] > 0 then
			return
		end
		for i=1,64 do
			if Notes[i] == newNote then
				SetPadColor(i, Colors[i])
			end
		end
		newNote = newNote + OctaveOffset
		SendMidiMessage("\x80"..string.char(newNote)..string.char(Velocity))
	end
end

-- Processes note/scale knobs
function ScaleKnobs(CC, Value)
	if CC == knob1 then	-- Note knob
		ChangeGlobalNote(Value)
		return
	end
	if CC == knob2 then	-- Scale knob
		ChangeGlobalScale(Value)
	end
end

-- Processes velocity/curve knobs
function DynamicsKnobs(CC, Value)
	if CC == knob5 then	-- Note Velocity knob
		ChangeVelocity(Value)
		return
	end
	if CC == knob6 then	-- Velocity Curve knob
		ChangeCurve(Value)
	end
end

-- Processes edit knobs
function EditKnobs(CC, Value)
	if CC == knob3 then	-- Edit Note knob
		if EditMode then
			ChangeEditedNote(Value)
		end
		return
	end
	if CC == knob4 then	-- Edit Color knob
		if EditMode then
			ChangeEditedColor(Value)
		end
	end
end

-- Processes edit buttons
function EditButtons(CC)
	if CC == buttonNotes then	-- Edit mode
		if EditMode then
			StopEdit(CC)
		else
			StartEdit()
		end
		RedrawButtons()
		return
	else
		if CC ~= midiCCSustain and CC ~= buttonDuplicate and CC ~= buttonDelete then
			StopEdit(CC)
			RedrawButtons()
			return
		end
	end
	if CC == buttonDuplicate then
		if Deleting then
			Deleting = false
		end
		Duplicating = not Duplicating
		RedrawButtons()
		return
	end
	if CC == buttonDelete then
		if Duplicating then
			Duplicating = false
		end
		Deleting = not Deleting
		RedrawButtons()
	end
end

-- Processes octave buttons
function OctaveButtons(CC)
	if CC == buttonOctDown then	-- Octave down
		OctaveOffset = OctaveOffset - 12
		if OctaveOffset < -24 then
			OctaveOffset = -24
		end
		printf("OctaveOffset set to %d\n", OctaveOffset);
		RedrawButtons()
		return
	end
	if CC == buttonOctUp then	-- Octave up
		OctaveOffset = OctaveOffset + 12
		if OctaveOffset > 24 then
			OctaveOffset = 24
		end
		printf("OctaveOffset set to %d\n", OctaveOffset);
		RedrawButtons()
	end
end

-- Scales Mode
-----------------------------------------------------
function processScalesMode(message)
	local msg = message:byte(1,1)
	-- Note on with velocity 0 becomes note off
	if msg == midiNoteOn and message:byte(3,3) == 0 then
		msg = midiNoteOff
	end
	if msg == midiNoteOn then
		local Note = message:byte(2,2)
		if not (Note < NoteMin or Note > NoteMax) then
			local Pad = Note - NoteOffset
			local Velocity = message:byte(3,3)
			SendNoteOn(Pad, Note, Velocity)
		end		
	elseif msg == midiNoteOff then
		local Note = message:byte(2,2)
		if not (Note < NoteMin or Note > NoteMax) then
			local Pad = Note - NoteOffset
			local Velocity = message:byte(3,3)
			SendNoteOff(Pad, Note, Velocity)
		end
		if Note == 0 or Note == 1 then
			GeneratePadsScale()
			RedrawPads()
		end
	elseif msg == midiControl then
		local CC = message:byte(2,2)
		local Value = message:byte(3,3)
		if IsKnob(CC) then	-- CC is a Knob
			-- Correct CC value for knobs
			if Value > 63 then
				Value = Value - 128
			end
			ScaleKnobs(CC, Value)
			DynamicsKnobs(CC, Value)
		else			-- CC is a Button
			if Value == buttonPress then
				OctaveButtons(CC)
				if CC == buttonScales then	-- Drums mode
					SetModeDrums()
					RedrawButtons()
				end
				if CC == buttonUser then	-- User mode
					SetModeUser()
					RedrawButtons()
				end
			end
		end
	end
end

-- Drums Mode
-----------------------------------------------------
function processDrumsMode(message)
	local msg = message:byte(1,1)
	-- Note on with velocity 0 becomes note off
	if msg == midiNoteOn and message:byte(3,3) == 0 then
		msg = midiNoteOff
	end
	if msg == midiNoteOn then
		local Note = message:byte(2,2)
		if not (Note < NoteMin or Note > NoteMax) then
			local Pad = Note - NoteOffset
			if EditMode then
				if Duplicating then
					Duplicate(Pad)
				end
				if Deleting then
					Delete(Pad)
				end
				EditingPad = Pad
				UpdateEditingPad()
			end
			local Velocity = message:byte(3,3)
			SendNoteOn(Pad, Note, Velocity)
		end		
	elseif msg == midiNoteOff then
		local Note = message:byte(2,2)
		if not (Note < NoteMin or Note > NoteMax) then
			local Pad = Note - NoteOffset
			local Velocity = message:byte(3,3)
			SendNoteOff(Pad, Note, Velocity)
		end
	elseif msg == midiControl then
		local CC = message:byte(2,2)
		local Value = message:byte(3,3)
		if IsKnob(CC) then	-- CC is a Knob
			-- Correct CC value for knobs
			if Value > 63 then
				Value = Value - 128
			end
			EditKnobs(CC, Value)
			DynamicsKnobs(CC, Value)
		else			-- CC is a Button
			if Value == buttonPress then
				EditButtons(CC)
				if CC == buttonScales then	-- Scales mode
					SetModeScales()
					RedrawButtons()
				end
				if CC == buttonUser then	-- User mode
					SetModeUser()
					RedrawButtons()
				end
			end
		end
	end
end

-- User Mode
-----------------------------------------------------
function processUserMode(message)
	local msg = message:byte(1,1)
	-- Note on with velocity 0 becomes note off
	if msg == midiNoteOn and message:byte(3,3) == 0 then
		msg = midiNoteOff
	end
	if msg == midiNoteOn then
		local Note = message:byte(2,2)
		if not (Note < NoteMin or Note > NoteMax) then
			local Pad = Note - NoteOffset
			if EditMode then
				if Duplicating then
					Duplicate(Pad)
				end
				if Deleting then
					Delete(Pad)
				end
				EditingPad = Pad
				UpdateEditingPad()
			end
			local Velocity = message:byte(3,3)
			SendNoteOn(Pad, Note, Velocity)
		end		
	elseif msg == midiNoteOff then
		local Note = message:byte(2,2)
		if not (Note < NoteMin or Note > NoteMax) then
			local Pad = Note - NoteOffset
			local Velocity = message:byte(3,3)
			SendNoteOff(Pad, Note, Velocity)
		end
	elseif msg == midiControl then
		local CC = message:byte(2,2)
		local Value = message:byte(3,3)
		if IsKnob(CC) then	-- CC is a Knob
			-- Correct CC value for knobs
			if Value > 63 then
				Value = Value - 128
			end
			EditKnobs(CC, Value)
			DynamicsKnobs(CC, Value)
		else			-- CC is a Button
			if Value == buttonPress then
				OctaveButtons(CC)
				EditButtons(CC)
				if CC == buttonScales then	-- Scales mode
					SetModeScales()
					RedrawButtons()
				end
				if CC == buttonUser then	-- Drums mode
					SetModeDrums()
					RedrawButtons()
				end
			end
		end
	end
end
