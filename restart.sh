PID=`cat shared/pids/unicorn.pid`
kill $PID
unicorn -c config/unicorn.rb -E test -D
echo 'done'
