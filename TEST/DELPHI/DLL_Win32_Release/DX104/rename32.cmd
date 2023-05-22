set DLL=%1.DLL
if exist SICx32.DLL del SICx32.DLL
rename %DLL% SICx32.DLL
