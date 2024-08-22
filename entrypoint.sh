#!/bin/bash
current_date() {
	echo "$(date "+%Y-%m-%d %H:%M:%S")"
}

start_server() {
	tmux new-session -d -s ringracers
	tmux send-keys "$HOME/ringracers \
	-dedicated \
	-port $RR_PORT \
	+advertise $ADVERTISE \
	-file $(find $ADDON_DIR \( -name "*.lua" -o -name "*.pk3" -o -name "*.wad" \) -printf '%f '); exit" C-m
}

cleanup_logs() {
	find . -atime +30 -name "*log.txt" -delete
}

monitor() {
	tmux ls > /dev/null 2>&1
	if [ $? -eq 1 ]; then
		echo "$(current_date) - Server crashed ! - Restarting..." >> $LOG_FILE
		start_server
	fi
}

case $1 in
	"monitor")
		monitor
		;;
	*)
		cleanup_logs
		start_server
		tail --follow=name --retry $LOG_FILE
		;;
esac
