// PushLua - Yet another Ableton Push Lua Framework
// (c) 2021 - Mockba the Borg
// This code is distributed under the "IDGAFAWYDWTCALAYGMPC" license, which means:
// I Don't Give A Fuck About What You Do With This Code As Long As You Give Me Proper Credit
//
#pragma once

// This header implements Global Variables and Defines

#ifndef TRUE
#define FALSE 0
#define TRUE 1
#endif

typedef signed char     int8;
typedef signed short    int16;
typedef signed int      int32;
typedef unsigned char   uint8;
typedef unsigned short  uint16;
typedef unsigned int    uint32;

#define tohex(x)	((x) < 10 ? (x) + 48 : (x) + 87)
