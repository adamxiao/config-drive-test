@echo off
net stop win-agent
C:\win-agent\win-agent.exe delete
rd /s /q C:\win-agent
FOR %%i IN (1 2 3 4) do (
  if exist C:\win-agent (
    ping -n %%i 127.0.0.1
    rd /s /q C:\win-agent
  ) else (
    echo delsuccess
  )
)
