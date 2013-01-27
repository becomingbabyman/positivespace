# only start redis if it is not already running
pong=$(redis-cli ping)
if [[ $pong == 'PONG' ]] ; then
	echo "redis-server is already running"
else
	echo "starting redis-server"
	redis-server &
fi

echo "starting foreman"
foreman start -p 3000 -f Procfile_Dev

# TODO: shutdown redis on close of foreman
# redis-cli shutdown