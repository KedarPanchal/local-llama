#!/bin/bash

ctx="${1:-32768}"
threads="${2:-8}"
port="${3:-8080}"


if [[ ! "$ctx" =~ ^[0-9]+$ || ! "$threads" =~ ^[0-9]+$ || ! "$port" =~ ^[0-9]+$ ]]; then
    echo "Usage: $0 [ctx] [threads] [port]"
    exit 1
fi

docker compose up -d searxng
uvx mcp-proxy --named-server-config config.json --allow-origin "*" --port 8001 --stateless &
proxy_pid=$!

llama-server \
    -hf unsloth/gemma-4-E4B-it-GGUF:Q4_K_M \
    --alias gemma4-E4B-Q4_K_M \
    --host 127.0.0.1 \
    --webui-mcp-proxy \
    --port "$port" \
    --ctx-size "$ctx" \
    --threads "$threads" \
    --context-shift \
    -n -1 &
llama_pid=$!
trap "kill $llama_pid 2>/dev/null" INT
trap "kill $proxy_pid 2>/dev/null" INT
trap "docker compose down 2>/dev/null" INT

sleep 10
open "http://127.0.0.1:$port"

wait "$llama_pid"
