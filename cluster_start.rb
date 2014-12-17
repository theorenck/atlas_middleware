for port in 3001..3006 do
  system "start /min thin start -e production -a 127.0.0.1 -p #{port}"
end