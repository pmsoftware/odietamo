set IsBatchExit=%PIsBatchExit%
set BeVerbose=%PBeVerbose%

if "%BeVerbose%" == "FALSE" (
	set DiscardStdOut=1^>NUL
	set DiscardStdErr=2^>NUL
) else (
	set DiscardStdOut=
	set DiscardStdErr=
)