@echo off
cls
echo Welcome to the EgeAI
echo I will answer your questions based on an online server
echo Type "exit" to end the conversation.
echo.
echo Now I am getting ready...
echo.
timeout /t 3 /nobreak > nul

:: Set the window title based on the GitHub version.txt content
call :set_window_title

:: Check if there is an internet connection
call :check_internet
if %internet_status%==0 (
    echo AI: Cannot connect to the internet. Please check your network connection.
    pause
    goto exit
)

:main_loop
set /p user_input=You: 
if /i "%user_input%"=="exit" goto exit

call :find_answer "%user_input%"
goto main_loop

:find_answer
setlocal enabledelayedexpansion
set "found=0"

:: Fetch and process the content of the qa.txt file directly from the web using curl
for /f "delims=" %%a in ('curl -s https://raw.githubusercontent.com/helles43/EgeAI/main/qa.txt') do (
    set "line=%%a"
    for /f "tokens=1,* delims=:" %%b in ("!line!") do (
        set "question=%%b"
        set "answer=%%c"
        
        :: Trim spaces from the question and answer
        call :trim_spaces "!question!"
        set "question=!trimmed_input!"
        
        call :trim_spaces "!answer!"
        set "answer=!trimmed_input!"

        :: Compare user input with the question
        if /i "!user_input!"=="!question!" (
            echo AI: !answer!
            set found=1
        )
    )
)

:: If no match was found, return a default response
if !found! == 0 (
    echo AI: Sorry, I don't understand that question. Please try again.
)

endlocal
goto :eof

:: Check if the internet is available by pinging a known reliable server (Google DNS server)
:check_internet
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    set internet_status=0
) else (
    set internet_status=1
)
goto :eof

:: Fetch the version.txt file from GitHub and set the window title to its content
:set_window_title
setlocal enabledelayedexpansion

:: Fetch version.txt and set the window title to the first line of the file
for /f "delims=" %%a in ('curl -s https://raw.githubusercontent.com/helles43/EgeAI/main/version.txt') do (
    set "line=%%a"
    title !line!
    goto :eof
)

:: If version.txt is empty or cannot be fetched, set a default title
title Cannot fetch version.
goto :eof

:: Trim spaces from the beginning and end of a string
:trim_spaces
set "input=%~1"
for /f "tokens=* delims= " %%b in ("!input!") do set "trimmed_input=%%b"
goto :eof

:exit
echo AI: Goodbye!
exit
