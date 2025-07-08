NVIDIA

	Installing the NVIDIA Driver and blacklisting/Handling Nouveau
	make sure any previously proprietary driver is removoved if you installed them. 
	3050 Ti is supported by the main nvidia package. However, to handle kernel updates automatically, it's strongly recommended to use the DKMS version.
	make sure your kernal-headers are installed first.
sudo pacman -S linux-headers linux-lts-headers (ltsheaders only if that kernal is also instlaled.)
	install nvidia-dkms and other stuff
sudo pacman -S nvidia-dkms nvidia-utils nvidia-settings
	(it'll install the following packages and dependencies Packages (7) dkms-3.1.8-1  egl-gbm-1.1.2.1-1  egl-x11-1.0.1-1  libxnvctrl-570.144-1  nvidia-dkms-570.144-3  nvidia-settings-570.144-1  nvidia-utils-570.144-3)
	nvidia-dkms: Installs the driver source and uses DKMS to automatically rebuild the kernel module when you update your kernel.
	nvidia-utils: Provides essential libraries and utilities like nvidia-smi.
	nvidia-settings: A graphical tool for configuration (some features might be limited under Wayland).
	Blacklist Nouveau: The nvidia-dkms package should automatically install a file (/usr/lib/modprobe.d/nvidia.conf or similar) that blacklists the open-source nouveau driver. You can verify this:
grep nouveau /usr/lib/modprobe.d/nvidia*.conf
	If it shows a line like blacklist nouveau, you're set. If not, or to be absolutely sure, create a file:
sudo nano /etc/modprobe.d/blacklist-nouveau.conf
	Add the following line:
blacklist nouveau
	Enable NVIDIA Kernel Mode Setting (KMS): This is crucial for Wayland and a smooth graphical boot. You need to add nvidia_drm.modeset=1 to your kernel parameters.
	How to add kernel parameters: This depends on your bootloader (e.g., GRUB, systemd-boot).
GRUB: Edit /etc/default/grub. Find the line starting with GRUB_CMDLINE_LINUX_DEFAULT= and add nvidia_drm.modeset=1 inside the quotes, separated by spaces from other options (e.g., GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1"). Then, run sudo grub-mkconfig -o /boot/grub/grub.cfg.
systemd-boot: Edit the relevant entry file in /boot/loader/entries/ (e.g., linux..xyz.conf). Append nvidia_drm.modeset=1 to the options line.
	Rebuild the Initramfs: After installing drivers and potentially modifying modprobe files or kernel parameters, you need to regenerate the initial RAM disk image:
sudo mkinitcpio -P
	Reboot: A reboot is necessary for the new driver, blacklisting, and KMS setting to take effect.
sudo reboot

 envycontrol: Another popular tool for Optimus laptops.
Install it (check Arch Wiki/AUR: yay -S envycontrol).
Check current status: sudo envycontrol -q
Switch to Integrated: sudo envycontrol -s integrated (Reboot required)
Switch to Hybrid: sudo envycontrol -s hybrid (Reboot required)
Switch to NVIDIA: sudo envycontrol -s nvidia (Reboot required)


(Advanced/Fallback) acpi_call: Manually turns off the GPU via ACPI calls. This is more complex and requires finding the specific command for your laptop model. Use this only if BIOS options and tools like supergfxctl/envycontrol fail. See the NVIDIA Optimus Arch Wiki page for details. Requires acpi_call-dkms.
Using Hybrid Mode (PRIME Render Offload):

4. Wayland Considerations (Hyprland/GNOME)
nvidia_drm.modeset=1: Essential, as configured in step 1.
PRIME Render Offload: This is the standard way to use the dGPU under Wayland in Hybrid mode. prime-run works well.
Hyprland: Check the Hyprland Wiki NVIDIA page for any specific environment variables or settings recommended (e.g., WLR_NO_HARDWARE_CURSORS=1 might sometimes help, or specific LIBVA_DRIVER_NAME settings if using hardware video acceleration).
--------------------
one can list all the PCI display controllers available
lspci -d ::03xx

hyprland which gpu being used from hyprland wiki multiple gpus
	to see which card is which (Do not use the card1 symlink indicated here. It is dynamically assigned at boot and is subject to frequent change)
ls -l /dev/dri/by-path

telling hyprland to use a certain GPU
	After determining which “card” belongs to which GPU, we can now tell Hyprland which GPUs to use by setting the AQ_DRM_DEVICES environment variable.
	
If you would like to use another GPU, or the wrong GPU is picked by default, set AQ_DRM_DEVICES to a :-separated list of card paths, e.g.

env = AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1

Here, we tell Hyprland which GPUs it’s allowed to use, in order of priority. For example, card0 will be the primary renderer, but if it isn’t available for whatever reason, then card1 is primary.

Do note that if you have an external monitor connected to, for example card1, that card must be included in AQ_DRM_DEVICES for the monitor to work, though it doesn’t have to be the primary renderer.

You should now be able to use an integrated GPU for lighter GPU loads, including Hyprland, or default to your dGPU if you prefer.

uwsm users are advised to export the AQ_DRM_DEVICES variable inside ~/.config/uwsm/env-hyprland, instead. This method ensures that the variable is properly exported to the systemd environment without conflicting with other compositors or desktop environments.

export AQ_DRM_DEVICES="/dev/dri/card0:/dev/dri/card1"

(how to tell which one is which: The lspci output shows the PCI address (0000:00:02.0 for Intel, 0000:01:00.0 for NVIDIA). The ls -l /dev/dri/by-path output links these exact PCI addresses (e.g., pci-0000:00:02.0) to the device files (/dev/dri/cardX, /dev/dri/renderDX). You match the PCI address from lspci to the path in /dev/dri/by-path.)
	
	to export for uwsm users like me
nvim ~/.bash_profile

	add this line but note which card is for which gpu card1 or card0 and then just enter that card without brackets. (Use the arrow keys to navigate, type the line, then press Ctrl + X to exit, Y to confirm saving, and Enter to confirm the filename).
export AQ_DRM_DEVICES=/dev/dri/<card>
---------
