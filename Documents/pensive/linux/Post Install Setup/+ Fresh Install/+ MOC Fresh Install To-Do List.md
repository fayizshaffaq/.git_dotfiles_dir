# Fresh Arch Linux Installation Checklist

This checklist provides a structured overview of essential tasks to perform after a fresh Arch Linux installation. Follow these steps to configure your system, restore your environment, and set up your applications.

---

### 1. Core System & Environment Setup

This phase focuses on critical system files, user environment, and restoring your base configuration.

> [!IMPORTANT]+
> Steps to be followed Sequentially.

- [ ] **Set Default Shell:** Change the default shell from `bash` to `zsh` [[Changing Shell to Zsh]].

- [ ] **Connect to the internet**: depending on what you use, ie tethered or wifi. [[Network Manager]]

- [ ] **Set zsh alias**: in preparation for deploying git, an alias is to be set. [[Restore Backup On a Fresh Install]] *do not clone the git..YET*

- [ ] **Reboot** : reboot. 

- [ ] **Restore Dotfiles:** Deploy your `git` bare repository to checkout -f the configuration files [[Restore Backup On a Fresh Install]].
- [ ] after deploying the files to your pc with 'git_dotfiles checkout -f' and after you've confirmed files to have populated on your system, delete the bare repo in preperation for setting up a new bare repo for backup later. 
```bash
rm -r ~/.git_dotfiles_dir
```

- [ ] **Comment out anything beyond  the end line of zshrc, if there is anything there,  to speed up your terminal:** :- 
```bash
nvim ~/.zshrc
```
>[!note]- Comment out beyond this part
> ===========================
> End of ~/.zshrc
> ============================

- [ ] **Link Restored Vault files to Obsidian** : open and link to existing vault. 

- [ ] **TLP config** : copy the tlp config to /etc/tlp.conf [[+ MOC tlp config]]

- [ ] **Reboot** :reboot

- [ ] **Set up GNOME Keyring:** Configure GNOME Keyring with PAM for password management. [[Gnome Keyring PAM]]

- [ ] **Free up storage by clearing pacman Cache**
	```bash
	sudo pacman -Scc
	```

- [ ] **Install `paru`:** Set up the `paru` AUR helper. [[Installing an AUR Helper]]

- [ ] **Install Core Applications:** Use `paru` to install your essential packages from the repositories and the AUR. [[AUR Packages]]

- [ ] **Enable Aur packages' services** [[AUR Package services]]
	```bash
	sudo systemctl enable --now fwupd.service warp-svc.service asusd.service 
	```

- [ ] **Enable polkitagent for the usersession. 
	```bash
	systemctl --user enable --now hyprpolkitagent.service
	```

- [ ] **Create Disk Swap** [[Disk Swap]] (optional/ and if already done in chroot while installing, don't repeat)

- [ ] **Create Directories** for Block device mount points.
	```bash
	sudo mkdir /mnt/browser /mnt/media /mnt/media /mnt/fast /mnt/slow
	```

- [ ] **Update `fstab`:** Edit the fstab to reflect the new drives' UUIDs. [[fstab reference]]
	```bash
	lsblk -f
	```
	```bash 
	sudo nvim /etc/fstab
	```

- [ ] **Update Drive Unlock Script:** Change the UUID in your LUKS/drive unlocking script.
- [ ] **Configure Auto-Login:** Set up automatic login on TTY1. [[+ MOC Auto Login]]

- [ ] **Configure Power Key:** Define the system's behavior when the power key is pressed. [[Power Key Behaviour]]

- [ ] Fix logratate by uncommenting size and compress in 
	```bash
	sudo nvim /etc/logrotate.conf
	```

- [ ] fix being locked out if you enter incorrect password [[Incorrect Password Attempt Timeout]]

---

### 2. Existing Asus specific config (remove if different pc)

Fine-tune your Hyprland compositor and shell environment. These steps are often machine-specific.

> [!CAUTION]+
> The following steps involve hardware-specific settings. Adjust them carefully based on whether you are on Asus tuf 15 or another pc  and what GPU you are using.

## For non Asus tuf f15 laptops

- [ ] **Clean Environment Variables:**
    - [ ] **(If not on NVIDIA)** Remove NVIDIA-specific `env` variables.
    - [ ] **(If not on NVIDIA)** Remove the `aq_driver` variable.
    - [ ] Clear the `TOTAL_THREADS` variable from `.zshrc` file. 
    - [ ] Clear the `TOTAL_THREADS` variable from the uwsm environment variable file.

- [ ] **Comment out Asus service for keybaord auto theme color pywal16 in :** :- 
```bash
nvim ~/user_scripts/waypaper/wallpaper_update.sh
```
>[!note]+ Comment out this part
>asus keyboard
>"~/user_scripts/asus/asus_keyboard_color_pywal16.sh"

- [ ] Comment out this line from mpv's config if you don't have an av1 encoder. can be checked by running vaapi
```bash
nvim ~/.config/mpv/mpv.conf
```
> [!note]+ Comment out this part
> hwdec-codecs=av1

- [ ] **Comment out the asusd scritpt for non asus laptops in hyprland config :**:- 
```bash
nvim ~/.config/hypr/hyprland.conf
```
>[!note]+ Comment out this part
>Asus specific hardware script for keyboard light and fan control. 
>bindl = , XF86Launch3, exec, kitty -e sudo ~/user_scripts/asus/asus-control.sh

- [ ] **Configure Monitor Output:** In `hyprland.conf`, remove machine-specific display names (e.g., for an ASUS monitor's line) and un-comment the `auto` setting for compatibility.

- [ ] **Adjust `hyprland.conf` Settings:**
    - [ ] Disable the swapping of left/right mouse click buttons.
    - [ ] Remove the custom keybinds for changing refresh rate that are specific to asus laptops with 144 hz `Alt+6` and `Alt+7`.

## Only for Asus tuf f15 

- [ ] **Asus misconfiguration for asusd D-bus:** :- follow the note for it if you have an asus laptop. [[Asusd Dbus Misconfiguration]]

- [ ] *Optional* **Copy the asusd directory for asusrelated configuration to /etc:** :- 
	```bash
	sudo cp ~/notes/setup/etc/asusd /etc/
	```

---

### 3. (Optional) Package Management & Software Installation

- [ ] **Install AI Tools:**
    - [ ] Install `ollama`. [[+ MOC Ollama]]
    - [ ] Install `faster-whisper`. [[Faster Whisper]]
	- [ ] Install `kokoro` [[Kokoro Rust]]

- [ ] **Waydroid:**- Android container. lightweight. [[+ MOC Waydroid]]

---

### 4. Theming & Desktop Customization

This section covers the visual setup of your desktop, from dynamic colors to fonts and terminal appearance.

- [ ] **Install `pywal16`:** Install the dynamic theming engine. [[pywal16]]
    ```bash
    pipx install pywal16
    ```

- [ ] **Generate Initial Theme:** Run `wal` with your desired wallpaper to create the first color palette. Eg: command
    ```bash
    wal -i Pictures/wallpapers/nature-3082832_1920.jpg 
    ```

- [ ] **Configure Kitty Theme:** Edit `kitty.conf` to source its colors directly from `pywal`'s cache. [[General Theming]]

- [ ] **Decay-Green theme** [[General Theming]] 

- [ ] **Install & Configure Fonts:** Install your preferred system and terminal fonts. [[+ MOC Fonts]]

- [ ] **Configure Thunar:** Set up the right-click "Open Terminal Here" custom action.

---


### 5. Services & Networking

Enable essential background services and disable ones you don't need.

- [ ] **Optimize Network Services:** Disable any extra NetworkManager services that are not required. [[Network Manager]]
	```bash
	sudo systemctl disable NetworkManager-wait-online.service
	```

- [ ] **Configure `tlp-rdw` (If Used):** For improved Wi-Fi power management with TLP, mask the `systemd-rfkill` services.

	```bash
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket
    ```

- [ ] **Set up FTP:** Configure your FTP client or server as needed. [[+ MOC FTP]]

---

### 6. Application Configuration

Finalize the setup for individual applications.

- [ ] **`mpv`:** Set up your `mpv.conf` for video playback. [[MPV]]

- [ ] **`firefox`:** Apply your custom `userChrome.css` for the side-panel modifications., hardware acceleration and smoothscrooling and other stuff refer to [[Firefox]]

- [ ] **`spotify`:** without adds script [[Spotify]]

- [ ] **`yazi`:** Deploy your configuration files for the `yazi` terminal file manager.

### 7. Re-Link exisiting github repo to continue backing up to it. 
- [ ] Follow these steps after you've already checked out and restored all the files from the github repo using git_dotfiles checkout -f  [[Relink to my existing github repo for backup after Fresh Install]]

or
- [ ] create  a new github repo to start backing up. [[git_bare_repo_setup]]