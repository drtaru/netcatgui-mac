# NetCat GUI

A native macOS GUI for sending arbitrary file payloads over raw TCP (netcat protocol).

Enter a target IP and port, select a file, and send — identical to `nc host port < file`.

<img width="789" height="416" alt="image" src="https://github.com/user-attachments/assets/4a8944c1-e3dc-4b9d-9b0f-1dec6c7c9265" />



## Requirements

- macOS 13.0 (Ventura) or later
- Xcode Command Line Tools (`xcode-select --install`)

## Build & Run

```sh
cd swift
make run
```

This compiles the app, generates the icon, bundles `NetcatGUI.app`, and opens it.

### Other targets

| Command | Action |
|---|---|
| `make` | Build app bundle |
| `make run` | Build and launch |
| `make clean` | Remove app bundle and build artifacts |

## Usage

1. Enter the target **IP address** and **port**
2. Click **…** to select a file
3. Click **Inject Payload**

Status turns green on success, red on error.

## License

GPL-2.0 — see [COPYING](COPYING)
