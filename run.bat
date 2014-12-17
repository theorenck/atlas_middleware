@ECHO OFF

SET CLUSTERED=%1
IF NOT DEFINED CLUSTERED SET CLUSTERED=n

IF %CLUSTERED% == c (
  ruby cluster_start.rb
) ELSE (
  thin start -e production -a 127.0.0.1 -p 3000 
) 