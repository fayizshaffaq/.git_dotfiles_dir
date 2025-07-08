# Waydroid: Rooting & Advanced Configuration

This guide covers advanced configuration for Waydroid on Arch Linux, including rooting, folder sharing, and network troubleshooting.

> [!NOTE] Related Guides
> For initial setup, please refer to the [[Waydroid Setup]] note.

---

## 1. Rooting Waydroid with Magisk

The most straightforward method for rooting your Waydroid container is by using the `waydroid_script`. This script automates the process of downloading and integrating Magisk.

> [!TIP] Why Use a Script?
> The rooting process and required tools can change over time. Following the official script repository ensures you are always using the most current and effective method.

You can find the script and its complete instructions on GitHub:
[**casualsnek/waydroid_script**](https://github.com/casualsnek/waydroid_script)

Follow the instructions provided in the repository to root your installation.

## 2. Post-Root: Enabling Zygisk

After rooting with Magisk, you may want to enable Zygisk for certain modules. Enabling this feature requires a full system reboot, not just a container restart.

> [!IMPORTANT] Host Reboot Required
> Waydroid shares its kernel with your host operating system. When Magisk or Zygisk requires a "reboot" to apply changes, it is referring to the underlying kernel. Therefore, you must reboot your entire computer, not just the Waydroid session.

**Procedure:**
1.  Enable Zygisk within the Magisk app inside Waydroid.
2.  Close the Waydroid session.
3.  Reboot your host machine. A soft-reboot may be sufficient and is faster to try first.

```bash
# Try this first
sudo systemctl soft-reboot
```
If Waydroid still doesn't recognize the changes after a soft-reboot, perform a full system reboot.

## 3. Sharing Host Folders

You can share a directory from your host system with Waydroid using a `bind mount`. This makes the host directory appear as if it were part of Waydroid's internal storage.

#### To Create a Share

Use the `mount --bind` command to link a host directory to a directory inside the Waydroid container.

> [!NOTE]
> In this example, we share the host's `/mnt/zram1` directory to Waydroid's `Pictures` folder. Replace `/mnt/zram1` with the path to your desired host folder.

```bash
sudo mount --bind /mnt/zram1 ~/.local/share/waydroid/data/media/0/Pictures
```

#### Maintaining the Share

Bind mounts are not persistent and must be re-established after reboots or session restarts.

| Scenario | Action Required |
| :--- | :--- |
| **Waydroid Session Restart** | Unmount, then re-bind the directory. |
| **Host System Reboot** | The mount is gone; simply re-bind. |

**Commands for Managing the Mount:**

```bash
# To unmount the directory (required before re-binding after a session restart)
sudo umount -R ~/.local/share/waydroid/data/media/0/Pictures

# To re-bind the directory
sudo mount --bind /mnt/zram1 ~/.local/share/waydroid/data/media/0/Pictures
```

## 4. Network & Firewall Configuration

If Waydroid cannot access the internet, you may need to add a firewall rule to permit traffic through its virtual network interface.

#### For `firewalld` Users

The following commands will add the `waydroid0` interface to your trusted zone, allowing it to bypass restrictions.

```bash
# Add the firewall rule permanently
sudo firewall-cmd --zone=trusted --add-interface=waydroid0 --permanent

# Reload the firewall to apply the new rule
sudo firewall-cmd --reload
```

## 5. Troubleshooting

### File Permission Errors in Shared Folders

**Problem:** Files and folders shared via a bind mount are visible in Waydroid but cannot be read or written to.

**Solution:** This is typically caused by restrictive file permissions on the host directory. You can grant open permissions to the directory and all its contents.

> [!WARNING] Security Implication of `chmod 777`
> The command `chmod 777 -R` grants read, write, and execute permissions to **all users** on your system for the specified directory and everything inside it. This is a potential security risk. Use it with caution, primarily on directories that do not contain sensitive data.

```bash
# Grant read/write/execute permissions to the shared host folder
sudo chmod 777 -R /mnt/zram1
```

