#!/bin/bash
LOG_FILE=$HOME/.ringracers/latest-log.txt
ADDON_DIR=$HOME/.ringracers/addons

current_date() {
	echo "$(date "+%Y-%m-%d %H:%M:%S")"
}

start_server() {
	tmux new-session -d -s ringracers
	tmux send-keys "$HOME/ringracers -dedicated -port $RR_PORT +advertise $ADVERTISE -file $(get_addons); exit" C-m
}

get_addons() {
	local ADDON_LIST=""
	for addon in $(find $ADDON_DIR \( -name "*.lua" -o -name "*.pk3" -o -name "*.wad" \) -printf '%f\n');
	do
		ADDON_LIST="$ADDON_LIST $addon"
	done
	echo "$ADDON_LIST"
}

cleanup_logs() {
	find . -atime +30 -name "*log.txt" -delete
}

rotate_logs() {
	if [ -f $LOG_FILE ]; then
		save_log_file=$(date +%Y%m%d%H%M%S).log.txt
		echo "$(current_date) - Log rotation -> $save_log_file"
		mv $LOG_FILE $HOME/.ringracers/$save_log_file
	fi
	echo "" > $LOG_FILE
}

monitor() {
	tmux ls > /dev/null 2>&1
	if [ $? -eq 1 ]; then
		echo "$(current_date) - Server crashed ! - Restarting..." >> $LOG_FILE
		# rotate_logs >> $LOG_FILE
		start_server
	fi
}

case $1 in
	"monitor")
		monitor
		;;
	*)
		# rotate_logs
		cleanup_logs
		start_server
		tail --follow=name --retry $LOG_FILE
		;;
esac
