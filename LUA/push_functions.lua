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

-- Scale definitions
-----------------------------------------------------
ScaleNames = {	"Major", "Natural Minor", "Harmonic Minor", "Melodic Minor", 
				"Major Blues", "Minor Blues", "Maj Pentatonic", "Min Pentatonic",
				"Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian",
				"Alt Pentatonic", "Alt Ionian #5", "Alt Dorian b2", "Alt Dorian b5", "Alt Phrygn b4",
				"Alt Lydian #2", "Alt Lydian b7", "Alt Aeolian b1", "Alt Locrian", "Holt" }
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
ScaleOffsets[25] = { 3, 2, 2, 2, 2, 1 }

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
	WriteText(1, 1, "PushLua v1.00")
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
		if(Colors[i] > -1) then
			SetPadColor(i, Colors[i])
		end
	end
end

-- Redraw buttons
function RedrawButtons()
	if _debug then
		printf("Redrawing Buttons\n")
	end
	if EditMode then
		SetButtonColor(50, 3)
		if Duplicating then
			SetButtonColor(88, 6)
		else
			SetButtonColor(88, 1)
		end
		if Deleting then
			SetButtonColor(118, 6)
		else
			SetButtonColor(118, 1)
		end
	else
		SetButtonColor(50, 1)
		SetButtonColor(88, 0)
		SetButtonColor(118, 0)
	end
	if Mode == 1 then
		SetButtonColor(58, 5)
		SetButtonColor(59, 4)
		SetButtonColor(50, 0)		
	end
	if Mode == 2 then
		SetButtonColor(58, 4)
		SetButtonColor(59, 4)
	end
	if Mode == 3 then
		SetButtonColor(58, 4)
		SetButtonColor(59, 5)
	end
	if OctaveOffset == 0 then
		SetButtonColor(54, 4)
		SetButtonColor(55, 4)
	end
	if OctaveOffset == 12 then
		SetButtonColor(54, 4)
		SetButtonColor(55, 5)
	end
	if OctaveOffset == 24 then
		SetButtonColor(54, 4)
		SetButtonColor(55, 6)
	end
	if OctaveOffset == -12 then
		SetButtonColor(54, 5)
		SetButtonColor(55, 4)
	end
	if OctaveOffset == -24 then
		SetButtonColor(54, 6)
		SetButtonColor(55, 4)
	end
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

-- Close device
function ResetDevice()
	printf("\nClosing %s ... ", device)

	-- Turn off User button
	SetButtonColor(59, 0)

	-- Set Push into User mode
	SendDeviceMessage(PushSysexHead..PushSetUser..PushSysexTail)

	printf("Done!\n")
end

-- Processes NoteOn messages
function ProcessNoteOn(Note, Velocity)
	local Pad = Note - NoteOffset
	local newVelocity = math.floor(SendVelocity)
	if newVelocity > -1 then
		Velocity = newVelocity
	end
	if not (Note < NoteMin or Note > NoteMax) then
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
		local newNote = Notes[Pad]
		if newNote > -1 then
			for i=1,64 do
				if(Notes[i] == newNote) then
					SetPadColor(i, NoteColor)
				end
			end
			newNote = newNote + OctaveOffset
			local newCurve = math.floor(SendCurve)
			if newCurve ~= 0 then
				if newCurve < 0 then
					newCurve = newCurve / 10
				end
				local newV = Velocity / 127
				newV = newV / (1 + (1 - newV) * newCurve)
				Velocity = math.floor(newV * 127)
			end
			printf("Note %d on Velocity %d\n", newNote, Velocity)
			SendMidiMessage("\x90"..string.char(newNote)..string.char(Velocity))
		else
			printf("Pad empty\n")
		end
	else
		printf("Note %d on Velocity %d\n", Note, Velocity)
	end
end

-- Processes NoteOff messages
function ProcessNoteOff(Note, Velocity)
	local Pad = Note - NoteOffset
	if not (Note < NoteMin or Note > NoteMax) then
		local newNote = Notes[Pad]
		if newNote > -1 then
			for i=1,64 do
				if(Notes[i] == newNote) then
					SetPadColor(i, Colors[i])
				end
			end
			newNote = newNote + OctaveOffset
			printf("Note %d off\n", newNote)
			SendMidiMessage("\x80"..string.char(newNote)..string.char(Velocity))
		end
	else
		printf("Note %d off\n", Note)
	end
	if Note == 0 or Note == 1 then
		GeneratePadsScale()
		RedrawPads()
	end
end

-- Processes NotePressure messages
function ProcessNotePressure(Note, Pressure)
	local Pad = Note - NoteOffset
	if not (Note < NoteMin or Note > NoteMax) then
		newNote = Notes[Pad] + OctaveOffset
		if newNote > -1 then
			printf("Note Pressure %d %d\n", newNote, Pressure)
			SendMidiMessage("\xA0"..string.char(newNote)..string.char(Pressure))
		end
	else
		printf("Note Pressure %d %d\n", Note, Pressure)
	end
end

-- Processes ChannelPressure messages
function ProcessChannelPressure(Pressure)
	local newPressure = math.floor(Pressure * 1.3 - 38.1)
	if newPressure < 0 then
		newPressure = 0
	end
	printf("Channel Pressure %d\n", newPressure)
	if newPressure > 0 then
		SendMidiMessage("\xD0"..string.char(newPressure))
	end
end

-- Send CC (passthru)
function SendCC(cc, value)
	SendMidiMessage("\xB0"..string.char(cc)..string.char(value))
end

-- Sets current mode to Scales
function SetModeScales()
	Mode = 1
	UpdateMode()
	UpdateGlobalNote()
	UpdateGlobalScale()
	SetButtonColor(58, 5)
	SetButtonColor(59, 4)	
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
function StopEdit()
	EditMode = false
	WriteText(1, 18, "              ")
	WriteText(2, 18, "              ")
	WriteText(3, 18, "              ")
	SaveConfig()
	EditingPad = 1
end

-- Processes CC messages
function ProcessCC(CC, Value)
	if CC == 64 then	-- Sustain pedal (passthru)
		SendCC(CC, Value)
		return
	end
	local Knob = false
	if CC == 14 or CC == 15 or (CC > 70 and CC < 80) then
		Knob = true
		if Value > 63 then
			Value = Value - 128
		end
	end
	printf("CC %d to %d\n", CC, Value)
	if Knob then	-- CC is a Knob
		if CC == 71 then	-- Note knob
			if Mode == 1 then
				ChangeGlobalNote(Value)
			end
		end
		if CC == 72 then	-- Scale knob
			if Mode == 1 then
				ChangeGlobalScale(Value)
			end
		end
		if CC == 73 then	-- Edit Note knob
			if Mode > 1 and EditMode then
				ChangeEditedNote(Value)
			end
		end
		if CC == 74 then	-- Edit Color knob
			if Mode > 1 and EditMode then
				ChangeEditedColor(Value)
			end
		end
		if CC == 75 then	-- Note Velocity knob
			ChangeVelocity(Value)
		end
		if CC == 76 then	-- Velocity Curve knob
			ChangeCurve(Value)
		end
	else			-- CC is a Button
		if Value == 127 then
			if CC == 50 then	-- Edit mode
				if Mode > 1 then
					if EditMode then
						StopEdit()
					else
						StartEdit()
					end
					RedrawButtons()
				end
			else
				if CC ~= 64 and CC ~= 88 and CC ~= 118 then
					StopEdit()
					RedrawButtons()
				end
			end
			if CC == 54 then	-- Octave down
				OctaveOffset = OctaveOffset - 12
				if OctaveOffset < -24 then
					OctaveOffset = -24
				end
				printf("OctaveOffset set to %d\n", OctaveOffset);
				RedrawButtons()
			end
			if CC == 55 then	-- Octave up
				OctaveOffset = OctaveOffset + 12
				if OctaveOffset > 24 then
					OctaveOffset = 24
				end
				printf("OctaveOffset set to %d\n", OctaveOffset);
				RedrawButtons()
			end
			if CC == 58 then	-- Scale mode
				if Mode == 1 then
					SetModeDrums()
				else
					SetModeScales()
				end
				RedrawButtons()
			end
			if CC == 59 then	-- User mode
				SetModeUser()
				RedrawButtons()
			end
			if CC == 88 then
				if Deleting then
					Deleting = false
				end
				Duplicating = not Duplicating
				RedrawButtons()
			end
			if CC == 118 then
				if Duplicating then
					Duplicating = false
				end
				Deleting = not Deleting
				RedrawButtons()
			end
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

-- Updates the Mode on screen
function UpdateMode()
	WriteText(1, 1, "Mode:       ")
	WriteText(1, 7, Modes[Mode])
end

-- Duplicates a Pad
function Duplicate(Pad)
	if Mode == 2 then
		DrumNotes[Pad] = DrumNotes[EditingPad]
		DrumColors[Pad] = DrumColors[EditingPad]
	else
		UserNotes[Pad] = UserNotes[EditingPad]
		UserColors[Pad] = UserColors[EditingPad]
	end
	Duplicating = false
	RedrawButtons()
end

-- Deletes a Pad
function Delete(Pad)
	if Mode == 2 then
		DrumNotes[Pad] = -1
		DrumColors[Pad] = 0
	else
		UserNotes[Pad] = Pad + NoteOffset
		UserColors[Pad] = BackColor
	end
	Deleting = false
	RedrawButtons()
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

-- Save the configuration onto json
function SaveConfig()
	local json = loadfile("../LUA/json.lua")()
	local config = {}
	config["ScaleNames"] = ScaleNames
	config["ScaleOffsets"] = ScaleOffsets
	config["ScaleColor"] = ScaleColor
	config["BackColor"] = BackColor
	config["NoteColor"] = NoteColor
	config["DrumNotes"] = DrumNotes
	config["DrumColors"] = DrumColors
	config["UserNotes"] = UserNotes
	config["UserColors"] = UserColors

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
	DrumNotes = config["DrumNotes"]
	DrumColors = config["DrumColors"]
	UserNotes = config["UserNotes"]
	UserColors = config["UserColors"]
end