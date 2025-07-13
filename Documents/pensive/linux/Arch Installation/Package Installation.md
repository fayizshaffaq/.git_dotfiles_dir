
# (Hyprland & Essentials)

This is a critical step where you install the core software for your system, including the graphical environment, drivers, and essential applications. The packages are installed in thematic groups across multiple commands to ensure a stable process and simplify troubleshooting.

> [!NOTE] Phased Installation Strategy
> Running these `pacman` commands separately is intentional. It allows `pacman` to resolve dependencies and download packages in manageable chunks. If one command fails, it's easier to identify the problematic package without halting the entire installation process.

### 1. Graphics Drivers & Core System Utilities 
This command installs essential drivers for Intel GPUs, Mesa for 3D graphics, Vulkan support, and key system tools for Btrfs and ZRAM.
- [ ] Status
```bash
pacman -S intel-media-driver mesa vulkan-intel mesa-utils intel-gpu-tools libva libva-utils vulkan-icd-loader vulkan-tools intel-ucode btrfs-progs zram-generator
```

> [!note] Only install this if you have an **intel** mobile chip between **5th gen and 11th gen** (hardware encoding/decoding)
>```bash
>pacman intel-media-sdk
> ```

### 2. Hyprland Window Manager & Wayland Components
Install the Hyprland compositor, Wayland compatibility layers, and the necessary GTK/Qt frameworks for application rendering.
- [ ] Status
```bash
pacman -S hyprland xorg-xwayland uwsm qt5-wayland qt6-wayland xdg-desktop-portal-gtk gtk3 gtk4 nwg-look qt5ct qt6ct qt6-svg qt6-multimedia-ffmpeg kvantum hyprpolkitagent
```

### 3. System Integration & Fonts
Install Polkit for permissions, XDG portals for Hyprland integration, and essential Nerd Fonts for icons and terminal aesthetics.
- [ ] Status
```bash
pacman -S xorg-xhost polkit xdg-desktop-portal-hyprland xdg-utils ttf-font-awesome ttf-jetbrains-mono-nerd
```

### 4. Hyprland Ecosystem & Desktop Utilities
Install core components for the Hyprland desktop experience, including the status bar, wallpaper manager, lock screen, and idle daemon.
- [ ] Status
```bash
pacman -S waybar libdbusmenu-qt5 socat swww inotify-tools sassc file libdbusmenu-glib fastfetch hyprlock hypridle hyprsunset swappy
```

### 5. Essential Applications & Network Tools
Install a base set of applications: a launcher, terminal, text editor, network management tools, and system monitors.
- [ ] Status
```bash
pacman -S rofi playerctl brightnessctl vsftpd fwupd featherpad networkmanager iwd nm-connection-editor compsize ncdu kitty pavucontrol unzip swayimg python-pipx
```

### 6. Audio (PipeWire) & Bluetooth Support
Set up the modern PipeWire audio server and install utilities for managing Bluetooth devices.
- [ ] Status
```bash
pacman -S pipewire wireplumber pipewire-pulse bluez bluez-utils blueman dosfstools sof-firmware gst-plugin-pipewire
```

### 7. System Management & Power Saving
Install tools for version control, file transfers, firewall, power management, and system monitoring.
- [ ] Status
```bash
pacman -S git wget curl xdg-user-dirs gvfs firewalld udisks2 udiskie tlp tlp-rdw thermald powertop 7zip usbutils usbmuxd gparted ntfs-3g acpid pacman-contrib nvtop btop inxi less
```

### 8. File Management & Productivity Tools
Install a file manager, clipboard manager, screenshot tools, and other productivity utilities.
- [ ] Status
```bash
pacman -S tealdeer iotop iftop ethtool httrack filezilla handbrake cliphist grim slurp wl-clipboard tree fzf thunar swaync compsize clang obsidian gnome-disk-utility
```

### 9. Optical Character Recognition (OCR)
Install the Tesseract OCR engine.
- [ ] Status
```bash
pacman -S tesseract
```

> [!TIP] Installing Tesseract Language Data
> After the command above completes, `pacman` will prompt you to select optional packages for language data. For English support, find `tesseract-data-eng` in the list, type its corresponding number, and press Enter to install it. (USUALLY 30TH)

### 10. Core Applications & Shell Enhancements
Install final applications like a web browser and media player, along with powerful shell tools like Zsh, Starship, and Bat.
- [ ] Status
```bash
pacman -S logrotate lshw ffmpeg mpv mpv-mpris firefox gnome-keyring libsecret yad yazi zellij zsh zsh-syntax-highlighting starship imagemagick bat krita uv mako rq jq bc zathura zathura-pdf-mupdf
```

---

### See Also
For alternative hardware or additional software, refer to these notes:
- - [ ] [[Nvidia Packages]]
- - [ ] [[Optional packages]]
