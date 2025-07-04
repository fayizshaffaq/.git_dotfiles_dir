#!/bin/bash

# Script to manage a simple vsftpd FTP server on Fedora 42 Gnome
# Allows local user authentication, shares a user-specified directory,
# persists across reboots, and includes enable/disable/status/remove options.

# --- Configuration ---
SERVICE_NAME="vsftpd"
CONFIG_FILE="/etc/vsftpd/vsftpd.conf"
STATE_FILE="/etc/vsftpd/ftp_script.state" # Stores chosen FTP root and ports
FIREWALL="firewalld"
PASV_MIN_PORT="40000"
PASV_MAX_PORT="40100"

# --- Helper Functions ---

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "❌ This script must be run as root. Use 'sudo ./manage_ftp.sh'"
        exit 1
    fi
}

# Function to install vsftpd if not present
install_vsftpd() {
    echo "⚙️ Checking for ${SERVICE_NAME}..."
    if ! rpm -q ${SERVICE_NAME} &>/dev/null; then
        echo "   ${SERVICE_NAME} not found. Installing..."
        if sudo dnf install -y ${SERVICE_NAME}; then
            echo "✅ ${SERVICE_NAME} installed successfully."
        else
            echo "❌ Failed to install ${SERVICE_NAME}. Aborting."
            exit 1
        fi
    else
        echo "✅ ${SERVICE_NAME} is already installed."
    fi
}

# Function to configure vsftpd.conf
# Takes the desired FTP root directory as an argument
configure_vsftpd() {
    local ftp_root_dir="$1"

    echo "⚙️ Configuring ${CONFIG_FILE}..."

    # Backup existing config just in case
    sudo cp ${CONFIG_FILE} ${CONFIG_FILE}.bak_$(date +%F_%T)

    # Create the configuration content
    # WARNING: This configuration allows ANY local user to log in and access
    # the specified ftp_root_dir. It does NOT jail users to their own home dirs.
    cat << EOF | sudo tee ${CONFIG_FILE} > /dev/null
# --- vsftpd configuration generated by manage_ftp.sh ---
# Allow local users to log in using their system credentials
local_enable=YES
# Allow writing/uploading files (if permissions allow)
write_enable=YES
# Prevent anonymous login
anonymous_enable=NO
# Display directory messages
dirmessage_enable=YES
# Activate logging
xferlog_enable=YES
# Use standard log format
xferlog_std_format=YES
# Use port 20 (ftp-data) for active mode connections
connect_from_port_20=YES
# Set default umask
local_umask=022
# Listen on IPv4
listen=YES
# Disable listening on IPv6 (simplifies firewall)
listen_ipv6=NO
# PAM service name
pam_service_name=vsftpd
# Enable Passive Mode (recommended for NAT/firewalls)
pasv_enable=YES
pasv_min_port=${PASV_MIN_PORT}
pasv_max_port=${PASV_MAX_PORT}
# Optimize transfer speed (uses kernel sendfile)
use_sendfile=YES
# --- IMPORTANT: Set the root directory for ALL logged-in local users ---
# This overrides individual home directories for FTP sessions.
local_root=${ftp_root_dir}
# --- End of configuration ---
EOF

    # Ensure the state file directory exists
    sudo mkdir -p "$(dirname ${STATE_FILE})"

    # Save the chosen path and port range to the state file
    echo "FTP_ROOT=${ftp_root_dir}" | sudo tee ${STATE_FILE} > /dev/null
    echo "PASV_PORTS=${PASV_MIN_PORT}-${PASV_MAX_PORT}" | sudo tee -a ${STATE_FILE} > /dev/null


    echo "✅ ${CONFIG_FILE} configured for FTP root: ${ftp_root_dir}"
    echo "   Passive ports set to: ${PASV_MIN_PORT}-${PASV_MAX_PORT}"
    echo "⚠️ IMPORTANT: Any local user logging in via FTP will access '${ftp_root_dir}'."
}

# Function to configure the firewall
configure_firewall() {
     echo "⚙️ Configuring ${FIREWALL}..."
     if ! systemctl is-active --quiet ${FIREWALL}; then
         echo "   ${FIREWALL} is not active. Starting and enabling it..."
         sudo systemctl start ${FIREWALL}
         sudo systemctl enable ${FIREWALL}
     fi

     # Add FTP service (port 21)
     sudo firewall-cmd --permanent --add-service=ftp
     # Add Passive Port Range
     sudo firewall-cmd --permanent --add-port=${PASV_MIN_PORT}-${PASV_MAX_PORT}/tcp

     # Reload firewall to apply changes
     echo "   Reloading ${FIREWALL} rules..."
     sudo firewall-cmd --reload

     echo "✅ Firewall configured to allow FTP (port 21) and passive ports (${PASV_MIN_PORT}-${PASV_MAX_PORT})."
}

# Function to enable and start the service
enable_service() {
    echo "⚙️ Enabling and starting ${SERVICE_NAME} service..."
    sudo systemctl enable ${SERVICE_NAME}
    sudo systemctl start ${SERVICE_NAME}
    if systemctl is-active --quiet ${SERVICE_NAME}; then
        echo "✅ ${SERVICE_NAME} service enabled and started."
    else
        echo "❌ Failed to start ${SERVICE_NAME}. Check logs with 'journalctl -u ${SERVICE_NAME}'."
    fi
}

# Function to disable and stop the service
disable_service() {
    echo "⚙️ Stopping and disabling ${SERVICE_NAME} service..."
    sudo systemctl stop ${SERVICE_NAME}
    sudo systemctl disable ${SERVICE_NAME}
    if ! systemctl is-active --quiet ${SERVICE_NAME} && ! systemctl is-enabled --quiet ${SERVICE_NAME}; then
        echo "✅ ${SERVICE_NAME} service stopped and disabled."
    else
        echo "⚠️ Could not fully stop or disable ${SERVICE_NAME}. Please check manually."
    fi
}

# Function to check the status
check_status() {
    echo "--- ${SERVICE_NAME} Service Status ---"
    sudo systemctl status ${SERVICE_NAME} --no-pager
    echo ""
    echo "--- Firewall Status (${FIREWALL}) ---"
    local ftp_rule=$(sudo firewall-cmd --list-services --permanent | grep ftp)
    local pasv_ports_rule=""
     if [[ -f "${STATE_FILE}" ]]; then
        # Source state file safely to get variables
        local current_pasv_ports=$(grep '^PASV_PORTS=' ${STATE_FILE} | cut -d'=' -f2)
        if [[ -n "$current_pasv_ports" ]]; then
             pasv_ports_rule=$(sudo firewall-cmd --list-ports --permanent | grep "${current_pasv_ports}/tcp")
        fi
    else
        echo "   State file ${STATE_FILE} not found. Cannot check passive port rule accurately."
    fi


    if [[ -n "$ftp_rule" ]]; then
        echo "✅ Permanent rule for FTP service (port 21) exists."
    else
        echo "❌ Permanent rule for FTP service (port 21) NOT found."
    fi

    if [[ -n "$pasv_ports_rule" ]]; then
        echo "✅ Permanent rule for Passive Ports (${current_pasv_ports}) exists."
    elif [[ -n "$current_pasv_ports" ]]; then
         echo "❌ Permanent rule for Passive Ports (${current_pasv_ports}) NOT found."
    fi


    echo "   Current active services: $(sudo firewall-cmd --list-services)"
    echo "   Current active ports: $(sudo firewall-cmd --list-ports)"

    echo ""
    echo "--- Configuration Info ---"
    if [[ -f "${STATE_FILE}" ]]; then
        local current_ftp_root=$(grep '^FTP_ROOT=' ${STATE_FILE} | cut -d'=' -f2)
         local current_pasv_ports=$(grep '^PASV_PORTS=' ${STATE_FILE} | cut -d'=' -f2)
        echo "   Configured FTP Root (from ${STATE_FILE}): ${current_ftp_root:-Not Set}"
         echo "   Configured Passive Ports (from ${STATE_FILE}): ${current_pasv_ports:-Not Set}"
    else
        echo "   State file ${STATE_FILE} not found. Configuration details unavailable."
    fi
     if [[ -f "${CONFIG_FILE}" ]]; then
         echo "   Check full config at: ${CONFIG_FILE}"
     else
         echo "   Config file ${CONFIG_FILE} not found."
     fi

}

# Function to remove the FTP server completely
remove_vsftpd() {
    echo "⚠️ WARNING: This will completely remove ${SERVICE_NAME}, its configuration,"
    echo "   firewall rules, and the state file created by this script."
    read -p "   Are you sure you want to proceed? (y/N): " confirm
    if [[ "${confirm,,}" != "y" ]]; then
        echo "   Aborting removal."
        return
    fi

    echo "⚙️ Removing ${SERVICE_NAME}..."

    # 1. Stop and disable the service
    disable_service

    # 2. Remove firewall rules
    echo "⚙️ Removing firewall rules..."
    local pasv_ports_to_remove=""
    if [[ -f "${STATE_FILE}" ]]; then
        pasv_ports_to_remove=$(grep '^PASV_PORTS=' ${STATE_FILE} | cut -d'=' -f2)
    fi

    sudo firewall-cmd --permanent --remove-service=ftp
    if [[ -n "$pasv_ports_to_remove" ]]; then
        sudo firewall-cmd --permanent --remove-port=${pasv_ports_to_remove}/tcp
    else
         echo "   Skipping passive port removal (state file not found or ports not set)."
    fi
    sudo firewall-cmd --reload
    echo "✅ Firewall rules removed (if they existed)."

    # 3. Remove the package
    echo "⚙️ Removing ${SERVICE_NAME} package..."
    if sudo dnf remove -y ${SERVICE_NAME}; then
         echo "✅ ${SERVICE_NAME} package removed."
    else
         echo "⚠️ Failed to remove ${SERVICE_NAME} package. Please check manually."
    fi


    # 4. Remove configuration and state files
    echo "⚙️ Removing configuration and state files..."
    sudo rm -f ${CONFIG_FILE} ${CONFIG_FILE}.bak_* # Remove config and backups
    sudo rm -f ${STATE_FILE}
    # Attempt to remove vsftpd config directory if empty
    sudo rmdir /etc/vsftpd 2>/dev/null || echo "   Note: /etc/vsftpd directory not removed (might contain other files)."


    echo "✅ ${SERVICE_NAME} removal complete."
}

# --- Main Logic ---

check_root

echo "------------------------------------"
echo " Simple vsftpd FTP Server Manager "
echo "------------------------------------"
echo " Target Service: ${SERVICE_NAME}"
echo " Config File:    ${CONFIG_FILE}"
echo " Firewall:       ${FIREWALL}"
echo "------------------------------------"

PS3="Select an option: "
options=(
    "Setup FTP Server (Install/Configure/Enable)"
    "Enable/Start FTP Server"
    "Disable/Stop FTP Server"
    "Check FTP Status"
    "Remove FTP Server Completely"
    "Quit"
)

select opt in "${options[@]}"; do
    case $REPLY in
        1) # Setup FTP Server
            echo "*** 1. Setup FTP Server ***"
            install_vsftpd

            echo ""
            read -e -p "Enter the FULL path to the directory you want to share via FTP: " ftp_dir
            # Basic validation: Check if empty
            if [[ -z "$ftp_dir" ]]; then
                echo "❌ Directory path cannot be empty. Aborting setup."
                continue # Go back to menu
            fi
             # Check if directory exists, create if user agrees
             if [[ ! -d "$ftp_dir" ]]; then
                 read -p "⚠️ Directory '$ftp_dir' does not exist. Create it? (y/N): " create_confirm
                 if [[ "${create_confirm,,}" == "y" ]]; then
                    sudo mkdir -p "$ftp_dir"
                    # Set reasonable permissions (adjust if needed)
                    # Get current user/group to own it, but allow others to read/enter
                    current_user=$(logname) || current_user=$SUDO_USER
                    if [[ -n "$current_user" ]]; then
                         sudo chown ${current_user}:${current_user} "$ftp_dir"
                         sudo chmod 755 "$ftp_dir" # Owner: rwx, Group: rx, Other: rx
                         echo "✅ Directory '$ftp_dir' created."
                    else
                         echo "⚠️ Could not determine user to own the directory. Please set permissions manually on '$ftp_dir'."
                    fi

                 else
                     echo "   Directory not created. Aborting setup."
                     continue # Go back to menu
                 fi
            fi
            echo "   You chose: ${ftp_dir}"
            echo "   This directory will be the root for ALL local users logging into FTP."
            read -p "   Confirm this path? (y/N): " path_confirm
            if [[ "${path_confirm,,}" != "y" ]]; then
                 echo "   Aborting setup."
                 continue # Go back to menu
            fi

            configure_vsftpd "$ftp_dir"
            configure_firewall
            enable_service
            echo "*** Setup Complete ***"
            check_status # Show status after setup
            echo "💡 Connect using an FTP client (like FileZilla) to:"
            echo "   Host: $(hostname -I | awk '{print $1}')"
            echo "   Port: 21"
            echo "   Username: [Your Fedora Username]"
            echo "   Password: [Your Fedora Password]"
            echo "   Make sure your client is using Passive (PASV) mode."
            ;;

        2) # Enable/Start FTP Server
             echo "*** 2. Enable/Start FTP Server ***"
             # Check if configured first
             if [[ ! -f "$CONFIG_FILE" || ! -f "$STATE_FILE" ]]; then
                 echo "⚠️ FTP server does not appear to be configured yet. Run Setup (Option 1) first."
             else
                 enable_service
                 # Ensure firewall rules are still there
                 configure_firewall # Re-applying rules is safe
             fi
            ;;

        3) # Disable/Stop FTP Server
             echo "*** 3. Disable/Stop FTP Server ***"
             disable_service
             # Note: We don't remove firewall rules on disable, only on full removal.
            ;;

        4) # Check FTP Status
            echo "*** 4. Check FTP Status ***"
            check_status
            ;;

        5) # Remove FTP Server Completely
            echo "*** 5. Remove FTP Server Completely ***"
            remove_vsftpd
            ;;

        6) # Quit
            echo "Exiting script."
            break
            ;;
        *)
            echo "Invalid option $REPLY. Please try again."
            ;;
    esac
    echo "" # Add newline before showing menu again
    # Force prompt redraw by unsetting REPLY
    REPLY=""
    # echo "Press Enter to return to the menu..."
    # read -r
done

exit 0
