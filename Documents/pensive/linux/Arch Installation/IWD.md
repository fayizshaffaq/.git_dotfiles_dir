
#  Connect to the Internet with `iwd`

This guide outlines connecting to a wireless network using the `iwd` (iNet wireless daemon) utility. This is a crucial step to download packages for the Arch Linux installation.

### Step 1: Launch the `iwd` Interactive Prompt

First, enter the `iwd` interactive shell to manage your wireless connections.

```bash
iwctl
```

You will now be inside the `[iwd]#` prompt for the following steps.

### Step 2: Identify Your Wireless Device

List all available network devices to find the name of your wireless adapter (e.g., `wlan0`).

```bash
[iwd]# device list
```

> [!TIP]
> The output will show a list of devices. Note the name of your wireless device (it usually starts with `wlan`), as you will need it for the subsequent commands.

### Step 3: Scan for Networks

Use your device name to scan for nearby wireless networks.

```bash
[iwd]# station <device_name> scan
```

**Example:**
```bash
[iwd]# station wlan0 scan
```

### Step 4: List Available Networks

After the scan completes, display the list of detected networks to find your SSID.

```bash
[iwd]# station <device_name> get-networks
```

**Example:**
```bash
[iwd]# station wlan0 get-networks
```

### Step 5: Connect to a Network

Connect to your chosen network using its SSID (network name).

```bash
[iwd]# station <device_name> connect "<Your_SSID>"
```

> [!NOTE]
> - Replace `<device_name>` with your actual device name (e.g., `wlan0`).
> - Replace `<Your_SSID>` with the name of your Wi-Fi network. **Keep the quotes.**
> - You will be prompted to enter the network password after running this command.

**Example:**
```bash
[iwd]# station wlan0 connect "MyWiFiNetwork"
```

### Step 6: Exit `iwd`

Once connected, you can leave the `iwd` interactive prompt.

```bash
[iwd]# exit
```

### Step 7: Verify Internet Connectivity

Finally, confirm that you have a working internet connection by pinging a reliable server.

```bash
ping -c 2 google.com
```

> [!SUCCESS]
> If you see replies from the server, your internet connection is working correctly.
>
> [!WARNING]
> If you get an error like `ping: google.com: Name or service not known`, there might be an issue with your connection or DNS settings. Double-check the previous steps.
