# 🦊 Managing Firefox Data on Arch Linux

This guide provides essential commands and procedures for managing your Firefox user data on Arch Linux. It covers backing up your profile, performing a complete data wipe, and using symbolic links for portable configurations.

---

## 1. Backing Up and Restoring Your Firefox Profile

Your Firefox profile contains all your personal data, including saved logins, bookmarks, history, extensions, and settings. Backing up this profile is crucial for migrating to a new system or recovering your setup.

### Locating Your Profile Directory

The entire configuration is stored within a single hidden folder in your home directory: `~/.mozilla`.

1.  Open Firefox and type `about:profiles` into the address bar.
2.  Under the default profile in use, find the **Root Directory** line and click the **Open Directory** button.
3.  Your file manager will open inside a specific profile folder (e.g., `xxxxxxxx.default-release`).
4.  Navigate **up two levels** in your file manager. You will land in your home directory and see the `.mozilla` folder.

> [!NOTE] The Golden Folder
> The `~/.mozilla` directory is all you need. To back it up, simply copy this entire folder to a safe location (like an external drive or cloud storage). To restore, close Firefox, delete the existing `~/.mozilla` folder on the new system, and replace it with your backup.

---

## 2. Completely Wiping Firefox Data

If you need to reset Firefox to a factory-fresh state, you must remove its profile and cache files.

> [!WARNING] Destructive Action
> The following commands will permanently delete all your Firefox data, including passwords, bookmarks, and history. This action cannot be undone. Proceed with caution.

To completely wipe all traces of Firefox user data, execute the following commands in your terminal:

```bash
# Removes the primary Firefox profile data
rm -rf ~/.mozilla/firefox/

# Removes the parent .mozilla directory, catching all related data
rm -rf ~/.mozilla

# Clears the application cache for Firefox
rm -rf ~/.cache/mozilla
```

You can run these commands one by one or combine them for a quicker process:
```bash
rm -rf ~/.mozilla/firefox/ ~/.mozilla ~/.cache/mozilla
```

---

## 3. Using a Symbolic Link for a Portable Profile

A symbolic link (or symlink) can redirect Firefox to use a profile stored in a different location, such as on a separate partition or an external USB drive. This is an excellent way to maintain a portable setup or save space on your primary drive.

For a detailed explanation of how symbolic links work, see the [[General Tips]] note.

### How to Create the Symbolic Link

1.  **Move Your Profile:** First, ensure Firefox is closed. Then, move your existing `~/.mozilla` folder to the desired new location (e.g., an external drive).
2.  **Create the Link:** Use the `ln -s` command to create the link. The structure is `ln -s /path/to/real/folder /path/to/link`.

> [!TIP]
> Before creating the link, make sure the original `~/.mozilla` folder in your home directory has been moved or deleted. You cannot create a link if a file or folder with the same name already exists at the destination.

Here is the command from your notes, generalized for any user and location:

```bash
# Syntax: sudo ln -s <TARGET_DIRECTORY> <LINK_LOCATION>
sudo ln -s /path/to/your/external/drive/.mozilla ~/.mozilla
```

**Example from your notes:**
This command links the `.mozilla` folder from an external drive mounted at `/run/media/fayiz/firefox/` to the location where Firefox expects to find it in the user's home directory.

```bash
sudo ln -s /run/media/fayiz/firefox/.mozilla /home/fayiz/.mozilla
```

