#!/bin/zsh

llama-server \
    --host 127.0.0.1 \
    --port "8080" \
    --models-preset "preset.ini" &
llama_pid=$!
trap "kill $llama_pid 2>/dev/null" INT

while [[ -z $(curl -sf http://127.0.0.1:8080/health | grep -E "\"status\"\s*:\s*\"ok\"") ]]; do
    echo "Waiting for server to be healthy..."
    sleep 1
done

open "http://127.0.0.1:8080"

wait "$llama_pid"
