mkdir C:\Temp\New2
mkdir C:\Temp\New3

for /f %%g in ('grep -il OdiSvn *') do (
	REM copy %%g c:\temp\%%g
	cat %%g|sed "s/OdiSvn/OdiScm/g" > C:\Temp\new_%%g
	cat C:\Temp\new_%%g|sed "s/ODISVN/ODISCM/g" > C:\Temp\New2_%%g
	cat C:\Temp\New2_%%g|sed "s/odisvn/odiscm/g" > C:\Temp\New3_%%g
	copy C:\Temp\New3_%%g %%g
)
