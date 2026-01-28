# ClickTop-Linux (Oracle Linux / RHEL / Fedora)

This module enables browser-based remote desktop access for Oracle Linux (or other dnf/yum based systems).

## Dependencies

- **x11vnc**: VNC server for X11 (Available via EPEL).
- **noVNC**: HTML5 VNC client.
- **Cloudflared**: Secure tunneling.
- **Python 3**: Required by Websockify.

## Installation

1. Run `./setup_tools.sh` to download necessary binaries and clone repositories.
2. Install system dependencies:

    ```bash
    sudo dnf install -y oracle-epel-release-el9  # or appropriate version
    sudo dnf install -y x11vnc git python3
    ```

## Usage

Run the start script:

```bash
./start.sh
```

Follow the on-screen instructions to set a password (first time only). Typically, you will not need to install `cloudflared` or `noVNC` locally as `setup_tools.sh` handles standalone binaries/clones.
