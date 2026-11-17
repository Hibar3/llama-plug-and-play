# llama-plug-and-play

A small Windows launcher for running a local [llama.cpp](https://github.com/ggerganov/llama.cpp) model, with an optional Caddy proxy and ngrok tunnel.

## Quickstart

### Requirements

- Windows
- `llama-server.exe` available on your `PATH` (it is not included in this repository)
- The Qwen2.5-Coder-7B-Instruct GGUF model at the path configured in `start.bat` (the model is not included)
- An ngrok account and auth token, if you want a public tunnel

### Configure

1. Open `start.bat` and check that the model path in the `llama-server -m` command matches your downloaded GGUF model. Adjust it if needed.
2. In `configs/Caddyfile`, replace `MY_SUPER_SECRET_KEY` with a strong, private bearer token.
3. If you want ngrok access, put your ngrok auth token in `configs/ngrok.yml` in place of `<Ngrok token>`. Do not commit real tokens or secrets.
4. Create the log directory if it does not already exist:

   ```bat
   if not exist logs mkdir logs
   ```

### Start

From the repository folder, run:

```bat
start.bat
```

The script starts llama.cpp on `http://127.0.0.1:8080`, Caddy on `http://127.0.0.1:8081`, then ngrok. Requests to Caddy must include the configured authorization header:

```text
Authorization: Bearer YOUR_SECRET_TOKEN
```

When ngrok is configured, its console displays the public HTTPS address. Use that address with the same authorization header.

### Stop

Run this from the repository folder:

```bat
stop.bat
```

## Notes

- `bin/` includes Caddy and ngrok executables; it does not include `llama-server.exe` or the model files.
- The llama.cpp server listens on localhost. Use the Caddy endpoint (`8081`) for requests requiring the bearer-token check.
- A public ngrok tunnel makes the service reachable from outside your computer. Use a strong secret, keep your ngrok token private, and stop the tunnel when you do not need it.
- The launcher uses fixed startup delays. If a service takes longer to start, check its console output and try starting it again.
