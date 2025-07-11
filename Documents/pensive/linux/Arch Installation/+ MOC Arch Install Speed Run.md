*wifi connection*
```bash
iwctl
```
```bash
device list
```
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

*SSH*
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

*Setting a bigger Font*
```bash
setfont latarcyrheb-sun32
```
- [ ] Status

---

*Limiting Battery Charge to 60%*
```bash
echo 60 | sudo tee /sys/class/power_supply/BAT1/charge_control_end_threshold
```
- [ ] Status

---

*pacman packages corruption detection*
```bash
pacman-key --init
```
```bash
pacman-key --populate archlinux
```
- [ ] Status

---

*System Timezone*
```bash
timedatectl set-timezone Asia/Kolkata
```
```bash
timedatectl set-ntp true
```
- [ ] Status

---

*Identifying Target Drive*
```bash
lsblk
```
*Formatting Target Drive*
```bash
cfdisk /dev/sdX
```
- [ ] Status

---

*Identifying Target Drive's Partitions*
```bash
lsblk /dev/sdX
```

*BOOT/ESP Partition*
```bash
mkfs.fat -F32 /dev/esp_partition
```

*ROOT Partition*
```bash
mkfs.btrfs -f /dev/root_partition
```
- [ ] Status

---

*Mounting the Root Partition*
```bash
mount /dev/root_partition /mnt
```
- [ ] Status

---

**ROOT Partition** *Sub-Volume Creation*
```bash
btrfs subvolume create /mnt/@
```
```bash
btrfs subvolume create /mnt/@home
```
```bash
ls /mnt
```
```bash
umount -R /mnt
```
- [ ] Status

---

*Mounting Root Partition's*  **ROOT Sub-Volume** 
```bash
mount -o rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=@ /dev/root_partition /mnt
```
- [ ] Status

---

*Creating Directories to mount home sub-vol & boot partition*
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

Again mounting the *Root Partition* but this time it's **HOME Sub-Volume** 
```bash
mount -o rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=@home /dev/root_partition /mnt/home
```
- [ ] Status

---

*Mounting the BOOT/ESP Partition*
```bash
mount /dev/esp_partition /mnt/boot
```
- [ ] Status

---

```bash
reflector --country India --age 24 --sort rate --save /etc/pacman.d/mirrorlist
```
```bash
vim /etc/pacman.d/mirrorlist
```
- [ ] Status

---

*Installing Linux*
```bash
pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware nvim
```
- [ ] Status

---

*fstab file generation*
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```
```bash
cat /mnt/etc/fstab
```
- [ ] Status

---

*Chrooting*
```bash
arch-chroot /mnt
```
- [ ] Status

---

*Setting System Time*
```bash
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
```
```bash
hwclock --systohc
```
- [ ] Status

---

*Setting System Language*
```bash
nvim /etc/locale.gen
```
> [!note] **Un-Comment This **
> en_US.UTF-8 UTF-8
- [ ] Status

---

*Part of Setting System Language*
```bash
locale-gen
```
```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```
- [ ] Status

---

*Setting Hostname*
```bash
echo "your-hostname" > /etc/hostname
```
- [ ] Status

---

*Setting Root Password*
```bash
passwd
```
- [ ] Status

---

*Creating User Account* (replace with your username)
```bash
useradd -m -G wheel,input,audio,video,storage,optical,network,lp,power,games,rfkill your_username
```
*Setting User Password* (replace with your username)
```bash
passwd your_username
```
- [ ] Status

---

*Allowing Wheel Group to have root rights.*
```bash
EDITOR=nvim visudo
```
> [!note] **Un-Comment This **
>%wheel ALL=(ALL:ALL) ALL
- [ ] Status

---

*Installing Apps*
[[Package Installation]]
- [ ] Status

---

*Configuring Initiramfs config*
```bash
nvim /etc/mkinitcpio.conf
```
> [!note] Fill the empty brackets with 
> MODULES=(btrfs)
> BINARIES=(/usr/bin/btrfs)
- [ ] Status

---

*Generating Initramfs*
```bash
mkinitcpio -P
```
- [ ] Status

---

*Grub Packages*
```bash
pacman -S grub efibootmgr grub-btrfs os-prober
```
- [ ] Status

---

*Configuring Grub Config*
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

*Installing Grub to the BOOT/ESP Partition. *
```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
```
- [ ] Status

---

*Generating Grub File for Boot*
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```
- [ ] Status

---

*Zram as both Block device and as Swap device*
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

*Optimizing System Swap Values for Zram*
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

*System Services*
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

*Concluding*
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