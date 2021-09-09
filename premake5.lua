workspace "PushLua"
	location "VStudio"
	configurations { "Release", "Debug" }
	platforms { "X64" }
	startproject "controller"
	pic "On"
	characterset "ASCII"

project "pushlua"
	kind "ConsoleApp"
	targetname "pushlua"
	language "C++"
	targetdir "Binary"
	includedirs { "Source/Lua" }
	files { "Source/**" }
	removefiles { "Source/Lua/lua.c", "Source/Lua/luac.c", "LUA/**" }
	vpaths {
		["Headers/*"] = { "**.hpp", "**.h" }
	}
	links { "winmm" }
	filter "configurations:Release"
		defines { "NDEBUG", "__WINDOWS_MM__" }
		optimize "On"
	filter "configurations:Debug"
		defines { "DEBUG", "__WINDOWS_MM__" }
		symbols "On"

-- Cleanup
if _ACTION == "clean" then
	os.rmdir("VStudio");
	os.rmdir("Binary");
end
