#!/bin/bash

# Directory and files
temp_dir="/tmp"
log_dir="/var/log"
log_file="nmap-script-ssh.log"

# Verify if the user is root
if [ "$EUID" -ne 0 ]; then
    echo "###########################################"
    echo "#                                         #"
    echo "#  ⚠️  Please, run this script as root    #"
    echo "#        using 'sudo'.                     #"
    echo "#                                         #"
    echo "###########################################"
    exit 1
fi

# Function to log messages
log_message() {
    echo "$(date): $1" >> "$log_dir/$log_file"
}

# Remove the log file if it exists
if [ -f "$log_dir/$log_file" ]; then
    rm "$log_dir/$log_file"
fi

log_message "Script Start"

# Step 1: Ask the user for the network address
read -p "Enter the network address to scan (example: 192.168.0.0/24): " red
log_message "Entered network address: $red"

# Ask for the location to save the hosts.txt fileread -p "Enter the location to save the hosts.txt file (example: /path/to/directory): " hosts_dir
hosts_file="$hosts_dir/hosts.txt"
log_message "Location of hosts.txt file: $hosts_file"

# Create or clear hosts.txt file
> "$hosts_file"

# Step 2: Perform a complete network scan to find other hosts in that network, excluding "QEMU virtual NIC"
echo "Executing a full network scan on the network $red..."
log_message "Executing a full network scan on the network $red..."
nmap -sn 192.168.1.0/24 | grep 'Nmap scan report' | awk '{print $5}' | awk -F '.' '!($4 < 4)' > "$temp_dir/temp_hosts.txt"
log_message "Network scan completed"
log_message "Network scan results:"
nmap -sn "$red" >> "$log_dir/$log_file"  # Network scan results in log

# Search for SSH port for each IP and save the information in hosts.txt
echo "Performing port scan to find the SSH port (OpenSSH)..."
log_message "Performing port scan to find the SSH port (OpenSSH)..."
total=$(wc -l < "$temp_dir/temp_hosts.txt")
completed=0

while IFS= read -r ip; do
    log_message "Scanning ports for $ip..."
    echo "Scanning ports for $ip..."
    puerto_ssh=$(nmap -sV -p- "$ip" | grep -E 'OpenSSH' | grep -oP '\d{1,5}' | head -1)
    
    if [ -n "$puerto_ssh" ]; then
        echo "$ip:$puerto_ssh" >> "$hosts_file"
        log_message "Found SSH port $puerto_ssh for $ip"
        echo "Found SSH port $puerto_ssh for $ip"
    fi

    completed=$((completed + 1))
    echo "Progress: $completed of $total"
    log_message "Progress: $completed of $total"
done < "$temp_dir/temp_hosts.txt"

rm "$temp_dir/temp_hosts.txt"  # Remove temporary file
log_message "Temporary file deleted"

log_message "End of script"
echo -e "\nThe hosts.txt file has been successfully generated at $hosts_file."



