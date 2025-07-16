### 1. *WiFi Connection*
```bash
iwctl
```
```bash
device list
```
*Replace wlo1 with your device name from above eg: wlan1*
```bash
station wlo1 scan
```
```bash
station wlo1 get-networks
```
```bash
station wlo1 connect "Near"
```
```bash
exit
```
```bash
ping -c 2 x.com
```
- [ ] Status

---

### 2. *SSH*
```bash
passwd
```
```bash
ip a
```
*client side (to connect to target machine)*
```bash
ssh root@192.168.xx
```
*only if you want to reset the key (troubleshooting)*
```bash
ssh-keygen -R 192.168.xx
```
- [ ] Status

---

### 3. *Setting a bigger Font*
```bash
setfont latarcyrheb-sun32
```
- [ ] Status

---

### 4. *Limiting Battery Charge to 60%*
```bash
echo 60 | sudo tee /sys/class/power_supply/BAT1/charge_control_end_threshold
```
- [ ] Status

---

### 5. *Pacman Packages Corruption Detection*
```bash
pacman-key --init
```
```bash
pacman-key --populate archlinux
```
- [ ] Status

---

### 6. *System Timezone*
```bash
timedatectl set-timezone Asia/Kolkata
```
```bash
timedatectl set-ntp true
```
- [ ] Status

---

### 7. *Identifying Target Drive*
```bash
lsblk
```
*Partitioning Target Drive*
```bash
cfdisk /dev/sdX
```
- [ ] Status

---

### 8. *Identifying Target Drive's Partitions*
```bash
lsblk /dev/sdX
```

*Formatting BOOT/ESP Partition*
```bash
mkfs.fat -F32 /dev/esp_partition
```

*Formatting ROOT Partition*
```bash
mkfs.btrfs -f /dev/root_partition
```
- [ ] Status

---

### 9. *Mounting Root Partition*
```bash
mount /dev/root_partition /mnt
```
- [ ] Status

---

### 10. **ROOT Partition** *Sub-Volume Creation*
```bash
btrfs subvolume create /mnt/@
```
```bash
btrfs subvolume create /mnt/@home
```
```bash
ls /mnt
```
*Un-Mounting Root Partition and it's newly created Sub-volumes*
```bash
umount -R /mnt
```
- [ ] Status

---

### 11. *Mounting Root Partition's*  **ROOT Sub-Volume** 
```bash
mount -o rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=@ /dev/root_partition /mnt
```
- [ ] Status

---

### 12. *Creating Directories to mount Home Sub-Vol & Boot/ESP Partition*
```bash
mkdir /mnt/home
```
```bash
mkdir /mnt/boot
```
```bash
ls /mnt
```
- [ ] Status

---

### 13. Again mounting the *Root Partition* but this time it's **HOME Sub-Volume** 
```bash
mount -o rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=@home /dev/root_partition /mnt/home
```
- [ ] Status

---

### 14. *Mounting the BOOT/ESP Partition*
```bash
mount /dev/esp_partition /mnt/boot
```
- [ ] Status

---

### 15. *Syncing Mirrors for faster Download Speeds*
```bash
reflector --country India --age 24 --sort rate --save /etc/pacman.d/mirrorlist
```
```bash
vim /etc/pacman.d/mirrorlist
```
- [ ] Status

---

### 16. *Installing Linux*
```bash
pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware nvim
```
- [ ] Status

---

### 17. *Fstab File Generation*
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```
```bash
cat /mnt/etc/fstab
```
- [ ] Status

---

### 18. *Chrooting*
```bash
arch-chroot /mnt
```
- [ ] Status

---

### 19. *Setting System Time*
```bash
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
```
```bash
hwclock --systohc
```
- [ ] Status

---

### 20. *Setting System Language*
```bash
nvim /etc/locale.gen
```
> [!note] **Un-Comment This **
> en_US.UTF-8 UTF-8
- [ ] Status

---

### 21. *Part of Setting System Language*
```bash
locale-gen
```
```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```
- [ ] Status

---

### 22. *Setting Hostname*
```bash
echo "your-hostname" > /etc/hostname
```
- [ ] Status

---

### 23. *Setting Root Password*
```bash
passwd
```
- [ ] Status

---

### 24. *Creating User Account* (replace with your username)
```bash
useradd -m -G wheel,input,audio,video,storage,optical,network,lp,power,games,rfkill your_username
```
*Setting User Password* (replace with your username)
```bash
passwd your_username
```
- [ ] Status

---

### 25. *Allowing Wheel Group to have root rights.*
```bash
EDITOR=nvim visudo
```
> [!note] **Un-Comment This **
>%wheel ALL=(ALL:ALL) ALL
- [ ] Status

---

### 26. *Installing Apps*
[[Package Installation]]
- [ ] Status

---

### 27. *Configuring Initiramfs config*
```bash
nvim /etc/mkinitcpio.conf
```
> [!note] Fill the empty brackets with 
> MODULES=(btrfs)
> BINARIES=(/usr/bin/btrfs)
- [ ] Status

---

### 28. *Generating Initramfs*
```bash
mkinitcpio -P
```
- [ ] Status

---

### 29. *Grub Packages*
```bash
pacman -S grub efibootmgr grub-btrfs os-prober
```
- [ ] Status

---

### 30. *Configuring Grub Config*
```bash
nvim /etc/default/grub
```

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=7 zswap.enabled=0 pcie_aspm=force"
```
> [!note] **Un-comment this **
> GRUB_DISABLE_OS_PROBER=false
- [ ] Status

---

### 31. *Installing Grub to the BOOT/ESP Partition. *
```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
```
- [ ] Status

---

### 32. *Generating Grub File for Boot*
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```
- [ ] Status

---

### 33. *Zram as Block device and Swap device (ZSTD compression)*
```bash
mkdir /mnt/zram1
```

```bash
sudo nvim /etc/systemd/zram-generator.conf
```

```ini
[zram0]
zram-size = ram - 2000
compression-algorithm = zstd

[zram1]
zram-size = ram - 2000
fs-type = ext2
mount-point = /mnt/zram1
compression-algorithm = zstd
options = rw,nosuid,nodev,discard,X-mount.mode=1777
```
- [ ] Status

---

### 34. *Optimizing System Swap Values for Zram SWAP*
```bash
sudo nvim /etc/sysctl.d/99-vm-zram-parameters.conf
```

```ini
vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
```
- [ ] Status

---

### 35. *System Services*
```bash
systemctl enable NetworkManager.service tlp.service udisks2.service thermald.service bluetooth.service firewalld.service fstrim.timer systemd-timesyncd.service acpid.service vsftpd.service
```

*UserSession Services*
```bash
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service hypridle.service
```

*Tlp-rdw services*
```bash
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
```
- [ ] Status

---

### 36. *Concluding*
```bash
exit
```


```bash
umount -R /mnt
```


```bash
shutdown now
```
- [ ] Status

---