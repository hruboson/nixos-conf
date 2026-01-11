#!/usr/bin/env bash

if eww active-windows | grep -q dock_window ; then
	eww close dock_window
else
	eww open dock_window
fi
