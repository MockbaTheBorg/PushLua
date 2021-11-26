#!/bin/sh
cd AddOns/PushLua/bin
./pushlua ../LUA/main.lua >/tmp/PushLua.log 2>&1 &
