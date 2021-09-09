device = "Push"

-- Setting to collect the required modules from the right place
function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   str = str:gsub("%\\","/")
   return str:match("(.*/)")
end

package.path = script_path().."?.lua"

require("functions")			-- Global generic Lua functions
require(device.."_functions")	-- Push specific Lua functions

printf("Lua version is %s\n", _VERSION)
printf("Number of MIDI Out ports = %d\n", GetMidiInCount())
print_r(GetMidiInList())
printf("Number of MIDI Out ports = %d\n", GetMidiOutCount())
print_r(GetMidiOutList())
