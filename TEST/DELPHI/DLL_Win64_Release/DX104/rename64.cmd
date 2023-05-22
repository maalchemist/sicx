set DLL=%1.DLL
if exist SICx64.DLL del SICx64.DLL
rename %DLL% SICx64.DLL
