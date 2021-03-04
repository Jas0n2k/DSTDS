#!/bin/bash

STEAMCMD_DIR="$HOME"									# Steamcmd Dir
DST_DIR="$HOME/dst"									    # DST Installed Dir
CLUSTER_NAME="Cluster_1"								# Cluster Name
CLUSTER_DIR="$HOME/.klei/DoNotStarveTogether"	        # Cluster Dir
SESSION_NAME="DST"
WINDOW_NAME="DST Dedicated Server"

function fail()
{
        echo "Error: $@" >&2			                # Redirect Errors to stderr
        exit 1									        # Exit Fail
}

function exists()
{
    if [ ! -e $1 ]; then						        # If the file or dir does not exist.
            fail "Missing file/dir: $1"
    fi
}

tmux has-session -t ${SESSION_NAME} 1>/dev/null 2>&1
if [ $? != 0 ]
then
cd "$STEAMCMD_DIR" || fail "Missing $STEAMCMD_DIR directory!"

exists "steamcmd"
exists "$SAVE_DIR/$CLUSTER_NAME/cluster.ini"
exists "$SAVE_DIR/$CLUSTER_NAME/cluster_token.txt"
exists "$SAVE_DIR/$CLUSTER_NAME/Master/server.ini"
exists "$SAVE_DIR/$CLUSTER_NAME/Caves/server.ini"
exists "$INSTALL_DIR/bin"

cd "$INSTALL_DIR/bin" || fail

# run_server is an array, using "+=" to append parameters.
# run_server+=(-monitor_parent_process $$)

# Create a new session
tmux new -s ${SESSION_NAME} -n "${WINDOW_NAME}" -d
tmux split-window -v -t ${SESSION_NAME}
# Send commands
tmux send-keys -t ${SESSION_NAME}:0.0 "cd ${INSTALL_DIR}/bin" C-m
tmux send-keys -t ${SESSION_NAME}:0.0 "./dontstarve_dedicated_server_nullrenderer -console -cluster ${CLUSTER_NAME} -shard Master" C-m
tmux send-keys -t ${SESSION_NAME}:0.1 "cd ${INSTALL_DIR}/bin" C-m
tmux send-keys -t ${SESSION_NAME}:0.1 "./dontstarve_dedicated_server_nullrenderer -console -cluster ${CLUSTER_NAME} -shard Caves" C-m
tmux attach -t ${SESSION_NAME}
exit 0
#
# User "${Array[@]}" to get all elements.
# User "sed" command to replace the stream.
#  "${run_server[@]}" | sed 's/^/Caves: /' &
#  "${run_server[@]}" Master | sed 's/^/Master: /'
else
	while true
	do
		read -r -p "${SESSION_NAME}:${WINDOW_NAME} is running. Attach, restart or restart? [A/R/kill]" input
		case $input in
		[aA][tT][tT][aA][cC][hH]|[aA])
			tmux attach -t ${SESSION_NAME}
			exit 0
			;;

		[kK][iI][lL][lL])
			echo "Killing the session ${SESSION_NAME}."
			tmux kill-session -t ${SESSION_NAME}
			exit 0
			;;
		[rR][eE][sS][tT][aA][rR][tT]|[rR])
			echo "Restart"
			tmux kill-session -t ${SESSION_NAME}
			exec "$ScriptLoc"
			;;
		*)
			echo "Invalid Input.Try Again."
			;;
	esac
done
fi

