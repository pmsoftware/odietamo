@echo off
setlocal enabledelayedexpansion
REM ===============================================
REM Show environment variables for the OdiScm configuration
REM that will be used by the system.
REM ===============================================
set FN=OdiScmGetEnv
set IM=!FN!: INFO:
set EM=!FN!: ERROR:

if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

set /a ISSUES=0

if "!ODI_SCM_INI!" == "" (
	echo !EM! OdiScm configuration INI file environment variable ODI_SCM_INI is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! OdiScm configuration INI file environment variable ODI_SCM_INI is set
	echo !IM! environment variable ODI_SCM_INI is set to ^<!ODI_SCM_INI!^>
	if exist "!ODI_SCM_INI!" (
		echo !IM! OdiScm configuration INI file ^<!ODI_SCM_INI!^> exists
	) else (
		echo !EM! OdiScm configuration INI file ^<!ODI_SCM_INI!^> does not exist
		set /a ISSUES=!ISSUES!+1
	)
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SCM_HOME!" == "" (
	echo !EM! OdiScm home directory environment variable ODI_SCM_HOME is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! OdiScm home directory environment variable ODI_SCM_HOME is set
	echo !IM! environment variable ODI_SCM_HOME is set to ^<!ODI_SCM_HOME!^>
	if exist "!ODI_SCM_HOME!" (
		echo !IM! OdiScm home directory exists
		if exist "!ODI_SCM_HOME!\Configuration" (
			echo !IM! OdiScm configuration directory ^<!ODI_SCM_HOME!\Configuration^> exists
			if exist "!ODI_SCM_HOME!\Configuration\Scripts" (
				echo !IM! OdiScm scripts directory ^<!ODI_SCM_HOME!\Configuration\Scripts^> exists
				if exist "!ODI_SCM_HOME!\Configuration\Scripts\OdiScmGet.bat" (
					echo !IM! OdiScm scripts detected in directory ^<!ODI_SCM_HOME!\Configuration\Scripts^>
				) else (
					echo !EM! OdiScm scripts not detected in directory ^<!ODI_SCM_HOME!\Configuration\Scripts^>
					set /a ISSUES=!ISSUES!+1
				)
			) else (
				echo !EM! OdiScm scripts directory ^<!ODI_SCM_HOME!\Configuration\Scripts^> does not exist
				set /a ISSUES=!ISSUES!+1
			)
		) else (
			echo !EM! OdiScm configuration directory ^<!ODI_SCM_HOME!\Configuration^> does not exist
			set /a ISSUES=!ISSUES!+1
		)
	) else (
		echo !EM! OdiScm home directory ^<!ODI_SCM_HOME!\Configuration^> does not exist
		set /a ISSUES=!ISSUES!+1
	)
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_HOME!" == "" (
	echo !EM! ODI home directory environment variable ODI_HOME is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI home directory environment variable ODI_HOME is set
	echo !IM! environment variable ODI_HOME is set to ^<!ODI_HOME!^>
	if exist "!ODI_HOME!" (
		echo !IM! ODI home directory ^<!ODI_HOME!^> exists
		if exist "!ODI_HOME!\bin" (
			echo !IM! ODI bin directory ^<!ODI_HOME!\bin^> exists
			if exist "!ODI_HOME!\bin\odiparams.bat" (
				echo !IM! ODI scripts detected in directory ^<!ODI_HOME!\bin^>
			) else (
				echo !IM! ODI scripts not detected in directory ^<!ODI_HOME!\bin^>
				set /a ISSUES=!ISSUES!+1
			)
		) else (
			echo !EM! ODI bin directory ^<!ODI_HOME!\bin^> does not exist
			set /a ISSUES=!ISSUES!+1
		)
		if exist "!ODI_HOME!\drivers" (
			echo !IM! ODI drivers directory ^<!ODI_HOME!\drivers^> exists
		) else (
			echo !EM! ODI drivers ^<!ODI_HOME!\drivers^> does not exist
			set /a ISSUES=!ISSUES!+1
		)
	) else (
		echo !EM! ODI home directory ^<!ODI_HOME!^> does not exist
		set /a ISSUES=!ISSUES!+1
	)
)
echo !IM! environment issues found so far ^<!ISSUES!^>

REM echo !IM! total environment issues found is ^<!ISSUES!^>

if "!ODI_JAVA_HOME!" == "" (
	echo !EM! ODI JVM home directory environment variable ODI_JAVA_HOME is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI JVM home directory environment variable ODI_JAVA_HOME is set
	echo !IM! environment variable ODI_JAVA_HOME is set to ^<!ODI_JAVA_HOME!^>
	REM if exist "!ODI_JAVA_HOME!" (
		REM echo !IM! ODI JVM home directory ^<!ODI_JAVA_HOME!^> exists
		REM if exist "!ODI_JAVA_HOME!\bin" (
			REM echo !IM! ODI JVM bin directory ^<!ODI_JAVA_HOME!\bin^> exists
			REM if exist "!ODI_JAVA_HOME!\bin\java.exe" (
				REM echo !IM! ODI JVM binaries detected in directory ^<!ODI_JAVA_HOME!\bin^>
			REM ) else (
				REM echo !IM! ODI JVM binaries not detected in directory ^<!ODI_JAVA_HOME!\bin^>
				REM set /a ISSUES=!ISSUES!+1
			REM )
		REM ) else (
			REM echo !EM! ODI JVM bin directory ^<!ODI_JAVA_HOME!\bin^> does not exist
			REM set /a ISSUES=!ISSUES!+1
		REM )
	REM ) else (
		REM echo !EM! ODI JVM home directory ^<!ODI_HOME!^> does not exist
		REM set /a ISSUES=!ISSUES!+1
	REM )
)
echo !IM! environment issues found so far ^<!ISSUES!^>

REM echo !IM! total environment issues found is ^<!ISSUES!^>
REM if "!JAVA_HOME!" == "" (
	REM echo !EM! JVM home directory environment variable JAVA_HOME is not set
	REM set /a ISSUES=!ISSUES!+1
REM ) else (
	REM echo !IM! JVM home directory environment variable JAVA_HOME is set
	REM echo !IM! environment variable JAVA_HOME is set to ^<!JAVA_HOME!^>
	REM if exist "!JAVA_HOME!" (
		REM echo !IM! JVM home directory ^<!JAVA_HOME!^> exists
		REM if exist "!JAVA_HOME!\bin" (
			REM echo !IM! JVM bin directory ^<!JAVA_HOME!\bin^> exists
			REM if exist "!JAVA_HOME!\bin\java.exe" (
				REM echo !IM! JVM binaries detected in directory ^<!JAVA_HOME!\bin^>
			REM ) else (
				REM echo !IM! JVM binaries not detected in directory ^<!JAVA_HOME!\bin^>
				REM set /a ISSUES=!ISSUES!+1
			REM )
		REM ) else (
			REM echo !EM! JVM bin directory ^<!JAVA_HOME!\bin^> does not exist
			REM set /a ISSUES=!ISSUES!+1
		REM )
	REM ) else (
		REM echo !EM! JVM home directory ^<!JAVA_HOME!^> does not exist
		REM set /a ISSUES=!ISSUES!+1
	REM )
REM )
REM echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SCM_JISQL_HOME!" == "" (
	echo !EM! Jisql home directory environment variable ODI_SCM_JISQL_HOME is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! Jisql home directory environment variable ODI_SCM_JISQL_HOME is set
	echo !IM! environment variable ODI_SCM_JISQL_HOME is set to ^<!ODI_SCM_JISQL_HOME!^>
	if exist "!ODI_SCM_JISQL_HOME!" (
		echo !IM! Jisql home directory ^<!ODI_SCM_JISQL_HOME!^> exists
		if exist "!ODI_SCM_JISQL_HOME!\runit.bat" (
			echo !IM! Jisql binaries detected in directory ^<!ODI_SCM_JISQL_HOME!\bin^>
		) else (
			echo !IM! Jisql binaries not detected in directory ^<!ODI_SCM_JISQL_HOME!\bin^>
			set /a ISSUES=!ISSUES!+1
		)
	) else (
		echo !EM! Jisql home directory ^<!ODI_SCM_JISQL_HOME!^> does not exist
		set /a ISSUES=!ISSUES!+1
	)
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SCM_JISQL_JAVA_HOME!" == "" (
	echo !EM! Jisql JVM home directory environment variable ODI_SCM_JISQL_JAVA_HOME is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! Jisql JVM home directory environment variable ODI_SCM_JISQL_JAVA_HOME is set
	echo !IM! environment variable ODI_SCM_JISQL_JAVA_HOME is set to ^<!ODI_SCM_JISQL_JAVA_HOME!^>
	if exist "!ODI_SCM_JISQL_JAVA_HOME!" (
		echo !IM! Jisql JVM home directory ^<!ODI_SCM_JISQL_JAVA_HOME!^> exists
		if exist "!ODI_SCM_JISQL_JAVA_HOME!\bin" (
			echo !IM! Jisql JVM bin directory ^<!ODI_SCM_JISQL_JAVA_HOME!\bin^> exists
			if exist "!ODI_SCM_JISQL_JAVA_HOME!\bin\java.exe" (
				echo !IM! Jisql JVM binaries detected in directory ^<!ODI_SCM_JISQL_JAVA_HOME!\bin^>
			) else (
				echo !IM! Jisql JVM binaries not detected in directory ^<!ODI_SCM_JISQL_JAVA_HOME!\bin^>
				set /a ISSUES=!ISSUES!+1
			)
		) else (
			echo !EM! Jisql JVM bin directory ^<!ODI_SCM_JISQL_JAVA_HOME!\bin^> does not exist
			set /a ISSUES=!ISSUES!+1
		)
	) else (
		echo !EM! Jisql JVM home directory ^<!ODI_SCM_JISQL_JAVA_HOME!^> does not exist
		set /a ISSUES=!ISSUES!+1
	)
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ORACLE_HOME!" == "" (
	echo !EM! Oracle home directory environment variable ORACLE_HOME is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! Oracle home directory environment variable ORACLE_HOME is set
	echo !IM! environment variable ORACLE_HOME is set to ^<!ORACLE_HOME!^>
	if exist "!ORACLE_HOME!" (
		echo !IM! Oracle home directory ^<!ORACLE_HOME!^> exists
		if exist "!ORACLE_HOME!\bin" (
			echo !IM! Oracle bin directory ^<!ORACLE_HOME!\bin^> exists
			if exist "!ORACLE_HOME!\bin\exp.exe" (
				echo !IM! Oracle binaries detected in directory ^<!ORACLE_HOME!\bin^>
			) else (
				echo !IM! Oracle binaries not detected in directory ^<!ORACLE_HOME!\bin^>
				set /a ISSUES=!ISSUES!+1
			)
		) else (
			echo !IM! Oracle bin directory ^<!ORACLE_HOME!\bin^ does not exist
			set /a ISSUES=!ISSUES!+1
		)
	) else (
		echo !EM! Oracle home directory ^<!ODI_SCM_JISQL_HOME!^> does not exist
		set /a ISSUES=!ISSUES!+1
	)
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SECU_DRIVER!" == "" (
	echo !EM! ODI master repository JDBC driver class name environment variable ODI_SECU_DRIVER is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI master repository JDBC driver class name environment variable ODI_SECU_DRIVER is set
	echo !IM! environment variable ODI_SECU_DRIVER is set to ^<!ODI_SECU_DRIVER!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SECU_URL!" == "" (
	echo !EM! ODI master repository JDBC URL environment variable ODI_SECU_URL is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI master repository JDBC URL environment variable ODI_SECU_URL is set
	echo !IM! environment variable ODI_SECU_URL is set to ^<!ODI_SECU_URL!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SECU_ENCODED_PASS!" == "" (
	echo !EM! ODI master repository encoded password environment variable ODI_SECU_ENCODED_PASS is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI master repository encoded password environment variable ODI_SECU_ENCODED_PASS is set
	echo !IM! environment variable ODI_SECU_ENCODED_PASS is set to ^<!ODI_SECU_ENCODED_PASS!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SECU_PASS!" == "" (
	echo !EM! ODI master repository password environment variable ODI_SECU_PASS is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI master repository password environment variable ODI_SECU_PASS is set
	echo !IM! environment variable ODI_SECU_PASS is set to ^<!ODI_SECU_PASS!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SECU_USER!" == "" (
	echo !EM! ODI master repository user name environment variable ODI_SECU_USER is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI master repository user name environment variable ODI_SECU_USER is set
	echo !IM! environment variable ODI_SECU_USER is set to ^<!ODI_SECU_USER!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SECU_WORK_REP!" == "" (
	echo !EM! ODI master repository user name environment variable ODI_SECU_WORK_REP is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI work repository name environment variable ODI_SECU_WORK_REP is set
	echo !IM! environment variable ODI_SECU_WORK_REP is set to ^<!ODI_SECU_WORK_REP!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_USER!" == "" (
	echo !EM! ODI user name environment variable ODI_USER is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI user name environment variable ODI_USER is set
	echo !IM! environment variable ODI_USER is set to ^<!ODI_USER!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_ENCODED_PASS!" == "" (
	echo !EM! ODI encoded password environment variable ODI_ENCODED_PASS is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI encoded password environment variable ODI_ENCODED_PASS is set
	echo !IM! environment variable ODI_ENCODED_PASS is set to ^<!ODI_ENCODED_PASS!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SECU_URL_HOST!" == "" (
	echo !EM! ODI master repository JDBC URL host environment variable ODI_SECU_URL_HOST is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI master repository JDBC URL host environment variable ODI_SECU_URL_HOST is set
	echo !IM! environment variable ODI_SECU_URL_HOST is set to ^<!ODI_SECU_URL_HOST!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SECU_URL_PORT!" == "" (
	echo !EM! ODI master repository JDBC URL port environment variable ODI_SECU_URL_PORT is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI master repository JDBC URL port environment variable ODI_SECU_URL_PORT is set
	echo !IM! environment variable ODI_SECU_URL_PORT is set to ^<!ODI_SECU_URL_PORT!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SECU_URL_SID!" == "" (
	echo !EM! ODI master repository JDBC URL SID environment variable ODI_SECU_URL_SID is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! ODI master repository JDBC URL SID environment variable ODI_SECU_URL_SID is set
	echo !IM! environment variable ODI_SECU_URL_SID is set to ^<!ODI_SECU_URL_SID!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SCM_GENERATE_OUTPUT_TAG!" == "" (
	echo !EM! build output tab environment variable ODI_SCM_GENERATE_OUTPUT_TAG is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! build notification user environment variable ODI_SCM_GENERATE_OUTPUT_TAG is set
	echo !IM! environment variable ODI_SCM_GENERATE_OUTPUT_TAG is set to ^<!ODI_SCM_GENERATE_OUTPUT_TAG!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SCM_NOTIFY_USER_NAME!" == "" (
	echo !EM! build notification user environment variable ODI_SCM_NOTIFY_USER_NAME is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! build notification user environment variable ODI_SCM_NOTIFY_USER_NAME is set
	echo !IM! environment variable ODI_SCM_NOTIFY_USER_NAME is set to ^<!ODI_SCM_NOTIFY_USER_NAME!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS!" == "" (
	echo !EM! build notification email address environment variable ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! build notification email address environment variable ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS is set
	echo !IM! environment variable ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS is set to ^<!ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

if "!ODI_SCM_NOTIFY_SMTP_SERVER!" == "" (
	echo !EM! build notification SMTP server environment variable ODI_SCM_NOTIFY_SMTP_SERVER is not set
	set /a ISSUES=!ISSUES!+1
) else (
	echo !IM! build notification SMTP server environment variable ODI_SCM_NOTIFY_SMTP_SERVER is set
	echo !IM! environment variable ODI_SCM_NOTIFY_SMTP_SERVER is set to ^<!ODI_SCM_NOTIFY_SMTP_SERVER!^>
)
echo !IM! environment issues found so far ^<!ISSUES!^>

echo !IM!
echo !IM! total number of environment issues found is ^<!ISSUES!^>

if !ISSUES! EQU 0 (
	exit !IsBatchExit! 0
) else (
	exit !IsBatchExit! 1
)