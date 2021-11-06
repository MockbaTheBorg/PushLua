-- PushLua - Yet another Ableton Push Lua Framework
-- (c) 2021 - Mockba the Borg
-- This code is distributed under the "IDGAFAWYDWTCALAYGMPC" license, which means:
-- I Don't Give A Fuck About What You Do With This Code As Long As You Give Me Proper Credit
--

-- Global variables
device = "push"	-- Must be defined to the device name (filename)

version = "1.01"

-- MIDI messages
midiNoteOff = 0x80
midiNoteOn = 0x90
midiNotePressure = 0xA0
midiControl = 0xB0
midiProgramChange = 0xC0
midiChannelPressure = 0xD0
midiPitchBend = 0xE0
midiSysEx = 0xF0

-- MIDI CC
midiCCSustain = 64

-- Button CCs
buttonNotes = 50
buttonOctDown = 54
buttonOctUp = 55
buttonScales = 58
buttonUser = 59
buttonDuplicate = 88
buttonDelete = 118
buttonUndo = 119

-- Knob CCs
knobTempo = 14
knobVolume = 15
knob1 = 71
knob2 = 72
knob3 = 73
knob4 = 74
knob5 = 75
knob6 = 76
knob7 = 77
knob8 = 78
knob9 = 79

-- Button lighting
off = 0
dim = 1
dimBlink = 2
dimBlinkFast = 3
lit = 4
litBlink = 5
litBlinkFast = 6

-- Other values
buttonPress = 127
