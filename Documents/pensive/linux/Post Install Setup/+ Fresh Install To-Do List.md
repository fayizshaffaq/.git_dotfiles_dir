# Fresh Arch Linux Installation Checklist

This checklist provides a structured overview of essential tasks to perform after a fresh Arch Linux installation. Follow these steps to configure your system, restore your environment, and set up your applications.

---

### 1. Core System & Environment Setup

This phase focuses on critical system files, user environment, and restoring your base configuration.

> [!IMPORTANT]
> The first two steps are critical after installing on a new machine or after reformatting drives, as hardware identifiers (UUIDs) will have changed.

- [ ] **Set Default Shell:** Change the default shell from `bash` to `zsh`.
- [ ] **Restore Dotfiles:** Deploy your `git` bare repository to restore configuration files.
- [ ] **Update `fstab`:** Edit `/etc/fstab` to reflect the new drive UUIDs.
- [ ] **Update Drive Unlock Script:** Change the UUID in your LUKS/drive unlocking script.
- [ ] **Configure Auto-Login:** Set up automatic login on TTY1.
- [ ] **Set up GNOME Keyring:** Configure GNOME Keyring with PAM for password management.
- [ ] **Configure Power Key:** Define the system's behavior when the power key is pressed.

---

### 2. Existing Asus specific config (remove if different pc)

Fine-tune your Hyprland compositor and shell environment. These steps are often machine-specific.

> [!CAUTION]
> The following steps involve hardware-specific settings. Adjust them carefully based on whether you are on a desktop or a laptop, and what GPU you are using.

- [ ] **Clean Environment Variables:**
    - [ ] **(If not on NVIDIA)** Remove NVIDIA-specific `env` variables.
    - [ ] **(If not on NVIDIA)** Remove the `aq_driver` variable.
    - [ ] Clear the `TOTAL_THREADS` variable from `.zshrc` file. 
    - [ ] Clear the `TOTAL_THREADS` variable from the uwsm environment variable file.
	
- [ ] **Asus misconfiguration for asusd D-bus:** :- follow the note for it if you have an asus laptop. 
- [ ] **Asus service for keybaord auto theme color pywal16:** :- 
```bash
sudo systemctl enable --now asusd
```
- [ ] **Copy the asusd directory for asusrelated configuration to /etc:** :- 
```bash
sudo cp ~/notes/setup/etc/asusd /etc/
```
- [ ] **Comment out Asus service for keybaord auto theme color pywal16 in :** :- 
```bash
nvim ~/user_scripts/waypaper/wallpaper_update.sh
```
>[!note]+ Comment out this part
>asus keyboard
>"~/user_scripts/asus/asus_keyboard_color_pywal16.sh"

- [ ] **Comment out anything beyond  the end line of zshrc to speed it up your terminal:** :- 
```bash
nvim ~/user_scripts/waypaper/wallpaper_update.sh
```

>[!note]+ Comment out beyond this part
> ===========================
> End of ~/.zshrc
> ============================


- [ ] **Comment out the asusd scritpt for non asus laptops in hyprland config :**:- 
```bash
nvim ~/.config/hypr/hyprland.conf
```
>[!note]+ Comment out this part
>Asus specific hardware script for keyboard light and fan control. 
>bindl = , XF86Launch3, exec, kitty -e sudo ~/user_scripts/asus/asus-control.sh

- [ ] **Configure Monitor Output:** In `hyprland.conf`, remove machine-specific display names (e.g., for an ASUS monitor) and uncomment the `auto` setting for portability.

- [ ] **Adjust `hyprland.conf` Settings:**
    - [ ] Disable the swapping of left/right mouse click buttons.
    - [ ] Remove the custom keybinds for changing refresh rate that are specific to asus laptops with 144 hz `Alt+6` and `Alt+7`.

---

### 3. Package Management & Software Installation

Install your AUR helper and the core software packages your workflow depends on.

- [ ] **Install `paru`:** Set up the `paru` AUR helper.
- [ ] **Install Core Applications:** Use `paru` to install your essential packages from the repositories and the AUR.
- [ ] **Install AI Tools:**
    - [ ] Install `ollama`.
    - [ ] Install `faster-whisper`.
- [ ] **Waydroid:**- android container. lightweight. 
- [ ] fix logratate by uncommenting size and compress in 
```bash
sudo nvim /etc/logrotate.conf
```

---

### 4. Theming & Desktop Customization

This section covers the visual setup of your desktop, from dynamic colors to fonts and terminal appearance.

- [ ] **Install `pywal16`:** Install the dynamic theming engine.
    ```bash
    pipx install pywal16
    ```
- [ ] **Generate Initial Theme:** Run `wal` with your desired wallpaper to create the first color palette.
    ```bash
    # Example: wal -i /path/to/your/wallpaper.jpg
    ```
- [ ] **Configure Kitty Theme:** Edit `kitty.conf` to source its colors directly from `pywal`'s cache.
- [ ] **Install & Configure Fonts:** Install your preferred system and terminal fonts.
- [ ] **Configure Thunar:** Set up the right-click "Open Terminal Here" custom action.

---


### 5. Services & Networking

Enable essential background services and disable ones you don't need.

- [ ] **Enable Polkit Agent:** Start and enable the Hyprland Polkit service for permissions management.
- [ ] **Optimize Network Services:** Disable any extra NetworkManager services that are not required.
- [ ] **Configure `tlp-rdw` (If Used):** For improved Wi-Fi power management with TLP, mask the `systemd-rfkill` services.
    ```bash
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket
    ```
- [ ] **Set up FTP:** Configure your FTP client or server as needed.

---

### 6. Application Configuration

Finalize the setup for individual applications.

- [ ] **`mpv`:** Set up your `mpv.conf` for video playback.
- [ ] **`firefox`:** Apply your custom `userChrome.css` for the side-panel modifications., hardware acceleration and smoothscrooling and other stuff refer to [[Firefox]]
- [ ] fix being locked out if you enter incorrect password [[Incorrect Password Attempt Timeout]]
- [ ] **`spotify`:** without adds script
- [ ] **`yazi`:** Deploy your configuration files for the `yazi` terminal file manager.
