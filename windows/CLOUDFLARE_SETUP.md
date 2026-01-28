# How to set up a Fixed Address (Cloudflare Named Tunnel)

By default, this project uses a "Quick Tunnel" which generates a random URL every time.
To get a fixed URL (e.g., `my-pc.yourdomain.com`), you need a free Cloudflare account.

## Prerequisites

1. A free account at [Cloudflare.com](https://dash.cloudflare.com/sign-up).
2. A domain name added to Cloudflare (e.g., `yourdomain.com`).

## Step 1: Create the Tunnel via Dashboard (Easiest)

1. Go to **Zero Trust Dashboard**: [one.dash.cloudflare.com](https://one.dash.cloudflare.com).
2. Go to **Networks** > **Tunnels**.
3. Click **Create a Tunnel**.
4. Choose **Cloudflared** connector.
5. Name it (e.g., "Home-PC").
6. **Copy the Token**: You will see a command like `cloudflared.exe service install eyJhIjoi...`.
    * **COPY ONLY THE LONG STRING** starting with `ey...`. This is your **Token**.

## Step 2: Configure Route

1. In the same Tunnel setup page, click **Next**.
2. **Public Hostname**:
    * Subdomain: `remote` (or whatever you want).
    * Domain: `yourdomain.com`.
3. **Service**:
    * Type: `HTTP`
    * URL: `127.0.0.1:6080` (This is where our Web VNC runs).
4. Click **Save Tunnel**.

## Step 3: Save Token on Windows

1. Open the `windows/` folder on your computer.
2. Create a new text file named `tunnel_token.txt`.
3. Paste the **Token** (the `ey...` string) inside it.
4. Save and close.

## Step 4: Restart

Run `CLICK_TO_START.bat` again.
The script will detect `tunnel_token.txt` and use your fixed address!
