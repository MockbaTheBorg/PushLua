// PushLua - Yet another Ableton Push Lua Framework
// (c) 2021 - Mockba the Borg
// This code is distributed under the "IDGAFAWYDWTCALAYGMPC" license, which means:
// I Don't Give A Fuck About What You Do With This Code As Long As You Give Me Proper Credit
//

#include <stdio.h>
#include <signal.h>

#include "Globals.h"

#if defined(__WINDOWS_MM__)
	#include <conio.h>
	#include <windows.h>
#else // Unix variants
	#include <stdlib.h>
	#include <ncurses.h>
	#include <poll.h>
	#include <termios.h>
	#include <unistd.h>
	#include "posix_console.h"
#endif

#include "Console.h"
#include "Texts.h"

#include "RtMidi/RtMidi.h"

RtMidiIn* devicein = 0;
RtMidiIn* midiin = 0;
RtMidiOut* deviceout = 0;
RtMidiOut* midiout = 0;

bool bailout = false;
bool needsReset;

extern "C" {
#include "lua/lua.h"
#include "lua/lualib.h"
#include "lua/lauxlib.h"
}
lua_State* L;

// Platform-dependent sleep routines.
#if defined(__WINDOWS_MM__)
	void usleep(__int64 usec) {
		HANDLE timer;
		LARGE_INTEGER ft;
	
		ft.QuadPart = -(10 * usec);
	
		timer = CreateWaitableTimer(NULL, TRUE, NULL);
		if (timer != 0) {
			SetWaitableTimer(timer, &ft, 0, NULL, NULL, 0);
			WaitForSingleObject(timer, INFINITE);
			CloseHandle(timer);
		}
	}
	
	BOOL WINAPI CtrlHandler(DWORD signal) {
		if (signal == CTRL_C_EVENT) {
			_puts("Caught ctrl-c\n");
			if (bailout)
				exit(1);
			bailout = true;
		}
		return(TRUE);
	}
#else
	void CtrlHandler(int signal) {
		if (signal == SIGINT) {
			_puts("Caught ctrl-c\n");
			if (bailout)
				exit(1);
			bailout = true;
		}
	}
#endif

// Read lstring from Lua
std::string StringFromLua(lua_State* L, int stackIx) {
	size_t len;
	const char* str = lua_tolstring(L, stackIx, &len);
	return std::string(str, len);
}

// OS information
int _GetOS(lua_State* L) {
#if defined(__WINDOWS_MM__)
	lua_pushstring(L, "windows");
#else
	lua_pushstring(L, "linux");
#endif
	return(1);
}

// Sleep milliseconds
int _Sleep(lua_State* L) {
	long long m = static_cast<long long> (luaL_checknumber(L, 1));
	usleep(m * 1000);
	return 0;
}

// Request termination
int _Terminate(lua_State* L) {
	bailout = TRUE;
	return 0;
}

// Must be called when a device is initialized, so we know we need to reset
int _Init(lua_State* L) {
	needsReset = TRUE;
	return 0;
}

// MIDI Port count
int _GetMidiInCount(lua_State* L) {
	unsigned int result = devicein->getPortCount();
	lua_pushinteger(L, result);
	return(1);
}

int _GetMidiOutCount(lua_State* L) {
	unsigned int result = deviceout->getPortCount();
	lua_pushinteger(L, result);
	return(1);
}

// MIDI Port list
int _GetMidiInList(lua_State* L) {
	unsigned int nPorts = devicein->getPortCount();
	lua_createtable(L, 0, nPorts);
	for (unsigned int i = 0; i < nPorts; i++) {
		lua_pushnumber(L, i);
		lua_pushstring(L, devicein->getPortName(i).c_str());
		lua_settable(L, -3);
	}
	return(1);
}

int _GetMidiOutList(lua_State* L) {
	unsigned int nPorts = deviceout->getPortCount();
	lua_createtable(L, 0, nPorts);
	for (unsigned int i = 0; i < nPorts; i++) {
		lua_pushnumber(L, i);
		lua_pushstring(L, deviceout->getPortName(i).c_str());
		lua_settable(L, -3);
	}
	return(1);
}

// Device ports
int _OpenDeviceInPort(lua_State* L) {
	unsigned int port = (unsigned int)luaL_checkinteger(L, 1);
	try {
		devicein->openPort(port, "Push In");
	}
	catch (RtMidiError& error) {
		error.printMessage();
		exit(EXIT_FAILURE);
	}

	return(0);
}

int _CloseDeviceInPort(lua_State* L) {
	devicein->closePort();
	return(0);
}

int _OpenDeviceOutPort(lua_State* L) {
	unsigned int port = (unsigned int)luaL_checkinteger(L, 1);
	try {
		deviceout->openPort(port, "Push Out");
	}
	catch (RtMidiError& error) {
		error.printMessage();
		exit(EXIT_FAILURE);
	}
	return(0);
}

int _CloseDeviceOutPort(lua_State* L) {
	deviceout->closePort();
	return(0);
}

// Device messages
int _SendDeviceMessage(lua_State* L) {
	std::vector<unsigned char> message;
	std::string src = StringFromLua(L, 1);
	unsigned int len = (unsigned int)src.length();
	if (len > 0) {
		for (unsigned int i = 0; i < len; i++) {
			message.push_back(src.at(i));
		}
		deviceout->sendMessage(&message);
	}
	return(0);
}

int _ReadDeviceMessage(lua_State* L) {
	std::vector<unsigned char> message;
	double stamp = devicein->getMessage(&message);
	std::string src(message.begin(), message.end());
	lua_pushnumber(L, stamp);
	lua_pushlstring(L, src.c_str(), src.size());
	return(2);
}

// MIDI ports
int _OpenMidiOutPort(lua_State* L) {
	int port = (int)luaL_checkinteger(L, 1);
	try {
		if (port == -1) {
			midiout->openVirtualPort("PushLua Out");
		}
		else {
			midiout->openPort(port, "PushLua Out");
		}
	}
	catch (RtMidiError& error) {
		error.printMessage();
		exit(EXIT_FAILURE);
	}
	return(0);
}

int _CloseMidiOutPort(lua_State* L) {
	midiout->closePort();
	return(0);
}

// MIDI messages
int _SendMidiMessage(lua_State* L) {
	std::vector<unsigned char> message;
	std::string src = StringFromLua(L, 1);
	unsigned int len = (unsigned int)src.length();
	if (len > 0) {
		for (unsigned int i = 0; i < len; i++) {
			message.push_back(src.at(i));
		}
		midiout->sendMessage(&message);
	}
	return(0);
}

void _InitLua() {
	L = luaL_newstate();
	luaL_openlibs(L);

	// Register Lua functions
	lua_register(L, "GetOS", _GetOS);
	lua_register(L, "Sleep", _Sleep);
	lua_register(L, "Terminate", _Terminate);
	lua_register(L, "Init", _Init);

	lua_register(L, "GetMidiInCount", _GetMidiInCount);
	lua_register(L, "GetMidiOutCount", _GetMidiOutCount);
	lua_register(L, "GetMidiInList", _GetMidiInList);
	lua_register(L, "GetMidiOutList", _GetMidiOutList);

	lua_register(L, "OpenDeviceInPort", _OpenDeviceInPort);
	lua_register(L, "CloseDeviceInPort", _CloseDeviceInPort);
	lua_register(L, "OpenDeviceOutPort", _OpenDeviceOutPort);
	lua_register(L, "CloseDeviceOutPort", _CloseDeviceOutPort);
	lua_register(L, "SendDeviceMessage", _SendDeviceMessage);
	lua_register(L, "ReadDeviceMessage", _ReadDeviceMessage);

	lua_register(L, "OpenMidiOutPort", _OpenMidiOutPort);
	lua_register(L, "CloseMidiOutPort", _CloseMidiOutPort);
	lua_register(L, "SendMidiMessage", _SendMidiMessage);
}

int main(int argc, char** argv) {
#if defined(__WINDOWS_MM__)
	SetConsoleCtrlHandler(CtrlHandler, TRUE);
#else
	signal(SIGINT, CtrlHandler);
#endif
	_puts("\n");
	_puts(APP_NAME " - v" APP_VERSION " - build: " BUILD "\n");
	_puts(SEPARATOR);

	if (argc < 2) {
		_puts("Usage: PushLua <main.lua>\n");
		exit(1);
	}
	try {
		devicein = new RtMidiIn();
	}
	catch (RtMidiError& error) {
		error.printMessage();
		exit(EXIT_FAILURE);
	}
	devicein->ignoreTypes(false, true, true);

	try {
		deviceout = new RtMidiOut();
	}
	catch (RtMidiError& error) {
		error.printMessage();
		exit(EXIT_FAILURE);
	}

	try {
		midiout = new RtMidiOut();
	}
	catch (RtMidiError& error) {
		error.printMessage();
		exit(EXIT_FAILURE);
	}

	_InitLua();

	// Load the script onto the state
	int result = luaL_loadfile(L, argv[1]);
	if (result) {
		_puts(lua_tostring(L, -1));
		bailout = TRUE;
	}

	// Run the script
	result = lua_pcall(L, 0, LUA_MULTRET, 0);
	if (result) {
		_puts(lua_tostring(L, -1));
		bailout = TRUE;
	}

	// Call the loop function forever (if one exists)
	if (lua_getglobal(L, "loop")) {
		while (!bailout) {
			lua_getglobal(L, "loop");
			int result = lua_pcall(L, 0, LUA_MULTRET, 0);
			if (result) {
				_puts(lua_tostring(L, -1));
				bailout = TRUE;
			}
		}
	}

	int stackSize = lua_gettop(L);
	lua_pop(L, stackSize);

	if (needsReset) {
		lua_getglobal(L, "ResetDevice");
		lua_pcall(L, 0, LUA_MULTRET, 0);
	}

	lua_close(L);

	delete devicein;
	delete deviceout;
	delete midiout;

	exit(0);
}
