cd %SystemRoot%\system32\WindowsPowerShell\v1.0
powershell Set-ExecutionPolicy Unrestricted
powershell "& C:\MOI_TEST\MOIPOC\Configuration\Powershell\DeleteFile.ps1 deleteFile -Param1 'c:\test1.xml' "
powershell "& C:\MOI_TEST\MOIPOC\Configuration\Powershell\DeleteFile.ps1 deleteFile -Param1 'c:\test2.xml' "
powershell "& C:\MOI_TEST\MOIPOC\Configuration\Powershell\DeleteFile.ps1 deleteFile -Param1 'c:\test3.xml' "
powershell "& C:\MOI_TEST\MOIPOC\Configuration\Powershell\DeleteFile.ps1 deleteFile -Param1 'c:\test4.xml' "

powershell Set-ExecutionPolicy Restricted
pause
