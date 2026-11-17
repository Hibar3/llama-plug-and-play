# llama-plug-and-play

A small Windows launcher for running a local [llama.cpp](https://github.com/ggerganov/llama.cpp) model behind a Caddy bearer-token check, with an optional ngrok tunnel for remote access.

## Quickstart

### 1. Prerequisites

- **Windows 10/11, 64-bit.** The launcher is a `.bat` file and the included Caddy/ngrok binaries are Windows executables.
- **llama.cpp with `llama-server.exe`.** Install or download a Windows build that includes `llama-server.exe`, then make `llama-server` available on `PATH`. Verify in Command Prompt with:

  ```bat
  where llama-server
  llama-server --version
  ```

  This repository does not include llama.cpp or the model files.
- **A compatible GGUF model** and enough system memory for that model and its context. The example configuration uses Qwen2.5-Coder-7B-Instruct in Q4_K_M quantization; check the model page for its license and hardware requirements before downloading.
- **An ngrok account and authtoken** only if you want to make the server reachable remotely. For local-only use, you can skip ngrok setup and disable its launch as described below.

### 2. Download and configure a local model

The launcher is configured for the [Qwen2.5-Coder-7B-Instruct-GGUF model](https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF). Download the Q4_K_M GGUF files from that model page. This is a split model: download **both** shard files and keep them together in the same folder. The first shard's filename ends in `-00001-of-00002.gguf`; the second ends in `-00002-of-00002.gguf`.

1. Create a model folder in the repository, for example:

   ```bat
   mkdir models\qwen2.5-coder-7b-instruct
   ```

2. Put both downloaded Q4_K_M shard files in that folder. Model files are excluded from Git by `.gitignore`.
3. Open `start.bat`. In the `llama-server -m` command, change the path after `-m` to the first shard, for example:

   ```text
   models\qwen2.5-coder-7b-instruct\qwen2.5-coder-7b-instruct-q4_k_m-00001-of-00002.gguf
   ```

   Keep the second shard beside it. If you choose a different model or quantization, use its first GGUF file path instead. The model path currently in `start.bat` points into a Hugging Face cache and may not exist on your machine.

### 3. Set the service access key

This project does **not** use an external AI-provider API key. Caddy checks a bearer token before forwarding requests to the local model server; this token is the credential your API client must send.

1. Open `configs/Caddyfile` and replace `MY_SUPER_SECRET_KEY` in the `Authorization` check with a long, unique secret. Keep the `Bearer ` prefix in the Caddyfile rule.
2. Save the file. Do not share or commit your real secret.

Requests to Caddy at `http://127.0.0.1:8081` must include this header (replace the example value with the same secret you set in the Caddyfile):

```text
Authorization: Bearer YOUR_SECRET_TOKEN
```

The llama.cpp server itself listens on `127.0.0.1:8080`; use the Caddy address when you want the bearer-token check applied.

### 4. Configure ngrok (optional, for remote access)

1. Create or sign in to an account at [ngrok](https://ngrok.com/) and copy your **authtoken** from the ngrok dashboard.
2. Open `configs/ngrok.yml` and replace `<Ngrok token>` with that token, keeping it private. For example:

   ```yaml
   agent:
     authtoken: "YOUR_NGROK_AUTHTOKEN"
   ```

   Keep the existing `version` and `tunnels` settings; the `llama` tunnel forwards to Caddy on port `8081`.
3. If you do **not** want ngrok, open `start.bat` and comment out the ngrok launch line by adding `REM ` at the start of the command:

   ```bat
   REM start "ngrok" "%~dp0bin\ngrok.exe" start --all --config "%~dp0configs\ngrok.yml"
   ```

When enabled, ngrok displays a public HTTPS URL in its console. Requests to that URL still need the same `Authorization: Bearer YOUR_SECRET_TOKEN` header. Only enable a public tunnel when needed, use a strong unique secret, and never publish either credential.

### 5. Start and stop

Caddy writes its access log to `logs/access.log`. Create the log directory before starting if it does not exist:

```bat
if not exist logs mkdir logs
```

Run from the repository folder:

```bat
start.bat
```

The launcher starts llama.cpp on port `8080`, Caddy on port `8081`, and then ngrok if its launch line is enabled. To stop the processes:

```bat
stop.bat
```

## Troubleshooting

- **`llama-server` is not recognized:** install a llama.cpp build containing `llama-server.exe` and add its folder to `PATH`, or update the command in `start.bat` to use the executable's full path.
- **Model not found / failed to load:** verify the `-m` path in `start.bat` and make sure both Q4_K_M shard files are present in the same folder.
- **Caddy fails to start:** ensure the `logs` folder exists and port `8081` is available.
- **ngrok fails to start:** verify the authtoken in `configs/ngrok.yml`, or comment out the ngrok launch line to run locally without a tunnel.
- **401 Unauthorized:** send the exact bearer token configured in `configs/Caddyfile` in the `Authorization` header.
