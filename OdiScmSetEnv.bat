@echo off
set OdiScmHome=%~dp0
set OdiScmHome=%OdiScmHome:~0,-1%
set ODI_SCM_HOME=%OdiScmHome%
echo INFO: setting ODI_SCM_HOME to ^<%ODI_SCM_HOME%^>
set PATH=%ODI_SCM_HOME%Configuration\Scripts;%PATH%