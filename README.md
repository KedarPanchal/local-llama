# Local Llama LLM Workflow

A powerful, self-contained local environment for running Large Language Models (LLMs) with integrated search capabilities and Model Context Protocol (MCP) support. This project combines `llama.cpp`, `SearXNG`, and `mcp-proxy` to provide a seamless, private AI experience.

## Quick Start

1. **Ensure Prerequisites are installed** (see below).
2. **Make the script executable**:
    ```bash
    chmod +x local-llama.sh
    ```
    - This requires the `zsh` shell, as the bash shell on macOS is too old for some of the features utilized.
3. **Run the workflow**:
    ```bash
    ./local-llama.sh
    ```

---

## Dependencies

To run this project, you need the following tools installed on your system:

### 1. Docker & Docker Compose
Used to orchestrate the SearXNG search engine and its MCP wrapper.
- **Install**: [Docker Desktop](https://www.docker.com/products/docker-desktop/) (macOS/Windows) or Docker Engine (Linux).

### 2. uv
A fast Python package installer and resolver. It is used to run `mcp-proxy` on the fly.
- **Install**:
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```

### 3. llama.cpp (llama-server)
The core engine that runs the GGUF models. You need the `llama-server` executable in your system PATH.
- **Install via Homebrew (macOS)**:
  ```bash
  brew install llama.cpp
  ```
- **Build from source**: Follow instructions at [github.com/ggerganov/llama.cpp](https://github.com/ggerganov/llama.cpp).

---

## Installation & Setup

1. **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd localllama
    ```

2. **Configure SearXNG**:
    The project comes with a pre-configured `searxng` directory. Ensure the permissions allow Docker to read/write to the `cache` and `config` folders.

3. **Verify `llama-server`**:
    Ensure you can run `llama-server --version` in your terminal.

---

## Running the Project

The `local-llama.sh` script automates the entire startup process:

1. **Starts SearXNG**: Launches the search engine via Docker Compose.
2. **Starts MCP Proxy**: Runs `mcp-proxy` using `uvx`, loading the configuration from `config.json`.
3. **Launches llama-server**: Downloads (if necessary) and runs the `Gemma-4-E4B` model from Hugging Face.
4. **Opens Web UI**: Automatically opens `http://127.0.0.1:8080` in your default browser.

### Script Arguments
You can customize the execution by passing arguments:
```bash
./local-llama.sh [model] [context_size] [threads] [port]
```
- `model`: Default is `gemma4-E4B-Q4_K_M`
- `context_size`: Default is `32768`.
- `threads`: Default is `8`.
- `port`: Default is `8080`.

---

## Connecting MCP Servers

Model Context Protocol (MCP) allows the LLM to interact with external tools and data. This project uses `mcp-proxy` to manage these connections.

### How to connect an MCP Server:

MCP servers are defined in the `config.json` file.
However, they are not automatically connected to the `llama.cpp` instance.
When you run the `local-llama.sh` script, it will output a lot of debug information.
In that output, there are URLs to connect the MCP servers to the `llama.cpp` instance.
The format of the URL is `http://127.0.0.1:8001/servers/{server_name}/sse`.

For example, the format of the `searxng` server (used to give the LLM web search capabilities) is `http://127.0.0.1:8001/servers/searxng/sse`.

To add these servers, on the browser tab opened by the script, follow these steps:

1. Click the settings icon (gear) in the top right corner.
2. Click on the "MCP" section.
3. Click "Add New Server".
4. Paste the URL for the server you want to connect (given by the script output), but replace the `sse` at the end of the URL with `mcp`.
    - For example, for the `searxng` server, you would paste `http://127.0.0.1:8001/servers/searxng/mcp`.
5. Click "Add".
6. Click "Save Settings" at the bottom of the settings menu.

After following these steps, the MCP server will be connected to the `llama.cpp` instance and the LLM will be able to use it to enhance its responses.

---

## Configuration

- **`config.json`**: Defines the MCP servers available to the proxy.
- **`docker-compose.yml`**: Manages the SearXNG service and its MCP bridge.
- **`local-llama.sh`**: The orchestration script. You can modify the model alias or Hugging Face path here if you wish to use a different model.
