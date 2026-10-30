#!/bin/bash

# Shell tmux script to start application

# use local development environment if it exists
if [ -f ./bin/dev.local.sh ]; then
   source ./bin/dev.local.sh
   exit
fi

# create the session with the first pane (will become pane 0 = npm)
tmux new-session -d -s seazitdiver

# split vertically to create the second pane (pane 1 = django)
tmux split-window -v

# run commands
tmux send-keys -t 0 "conda activate seazit && cd project && npm start" enter
tmux send-keys -t 1 "conda activate seazit && cd project && python manage.py runserver" enter

# attach to session
tmux select-pane -t 0
tmux attach-session -t seazitdiver