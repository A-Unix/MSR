#!/bin/bash

echo -e "Checking if the script is running as root!"

# Check if script is running as root user
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use 'sudo' along with the command or login as root user."
    sleep 1
    echo "Saving Preferences for next try!"
    sleep 7
    exit 1
fi

# Check if Colorama has been already installed or not
if python3 -c "import colorama" &>/dev/null; then
    echo -e "\033[95mColorama has been already installed, We have initialized it for you :)\033[0m"
    sleep 5
else
    echo -e "\033[91mColorama has not been installed. Installing it...\033[0m"
    pip install colorama
    echo -e "\033[95mDone, Colorama has been installed.\033[0m"
    sleep 3
fi


echo -e "\033[93m\nUpdating your system, wait!\n\033[0m"
sleep 0.5

# Update system
apt update

# Install pip
apt install python3-pip -y

echo -e "\033[96m\nInstalling required dependencies, wait!\n\033[0m"
sleep 0.5

# Install requirements to run the script
pip3 install stem
pip3 install selenium
apt install figlet lolcat tor -y

sleep 0.5

# Thresholds (adjust these values according to your needs)
CPU_THRESHOLD=80     # Percentage CPU usage threshold
MEM_THRESHOLD=90     # Percentage memory usage threshold
DISK_THRESHOLD=90    # Percentage disk usage threshold

# Function to send alerts
send_alert() {
    # You can customize this function to send alerts via email, SMS, etc.
    echo -e "\033[95mALERT: $1 exceeded threshold. Current value: $2\033[0m" >&2
}

# Monitor CPU usage
check_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    local comparison=$(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l)
    if (( $comparison )); then
        echo -e "\033[96mALERT: CPU usage\033[0m exceeded threshold. Current value: $cpu_usage%"
    fi
}

# Monitor memory usage
check_memory_usage() {
    local mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100}')
    if (( $(echo "$mem_usage > $MEM_THRESHOLD" | bc -l) )); then
        send_alert "Memory usage" "$mem_usage%"
    fi
}

# Monitor disk usage
check_disk_usage() {
    local disk_usage=$(df -h | grep /dev/root | awk '{print $5}' | sed 's/%//')
    if (( $(echo "$disk_usage > $DISK_THRESHOLD" | bc -l) )); then
        send_alert "Disk usage" "$disk_usage%"
    fi
}

# Main function
main() {
    check_cpu_usage
    check_memory_usage
    check_disk_usage
}

# Run the main function
main
