#!/bin/zsh

declare -A models=(
    ["gemma4-E4B-Q4_K_M"]="unsloth/gemma-4-E4B-it-GGUF:Q4_K_M"
    ["gemma4-E2B-Q4_K_M"]="unsloth/gemma-4-E2B-it-GGUF:Q4_K_M"
)
model="${1:-gemma4-E4B-Q4_K_M}"
ctx="${2:-32768}"
threads="${3:-8}"
port="${4:-8080}"

if [[ -z "${models[$model]}" || ! "$ctx" =~ ^[0-9]+$ || ! "$threads" =~ ^[0-9]+$ || ! "$port" =~ ^[0-9]+$ ]]; then
    echo "Usage: $0 [model_name] [context_size] [threads] [port]"
    echo "Available models:" 
    for key in "${(@k)models}"; do
        echo "  $key"
    done
    exit 1
fi

docker compose up -d searxng
uvx mcp-proxy --named-server-config config.json --allow-origin "*" --port 8001 --stateless &
proxy_pid=$!

llama-server \
    -hf "${models[$model]}" \
    --alias "$model" \
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
wait "$proxy_pid"
