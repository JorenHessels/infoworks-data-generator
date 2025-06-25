@echo off
set bit=64
set script=export_graph.rb
if %bit%==32 (set "path=C:\Program Files (x86)")
if %bit%==64 (set "path=C:\Program Files")
"%path%\Autodesk\InfoWorks ICM Ultimate 2025\ICMExchange.exe" "%~dp0%script%" ICM %*