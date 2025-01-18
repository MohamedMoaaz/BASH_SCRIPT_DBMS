#!/bin/bash

# Terminal colors
FAIL='\033[0;31m'        # Red color for errors
PASS='\033[0;32m'        # Green color for success
INFO='\033[0;33m'        # Yellow color for information
HEADER='\033[0;34m'      # Blue color for header
NONE='\033[0m'           # Reset color

# Global variable for the base path of the databases
DB_PATH="./databases"

# Function to log messages with specified color formatting
# Arguments:
#   $1: Color code for message
#   $2: Message to display
function log() {
    echo -e "${1}${2}${NONE}"
}

# Function to print the header for the menu
function print_header() {
    clear
    log $HEADER "======================================"
    log $HEADER "       Bash Shell Script DBMS         " 
    log $HEADER "======================================"
}

# Function to create a new database
# Arguments:
#   $1: The name of the database to create
function create_database() {
    db_name=$1
    if [ -z $db_name ]; then 
        log $FAIL "You must enter a name for a database"
    elif [ -d "$DB_PATH/$db_name" ]; then 
        log $FAIL "Database '$db_name' already exists!"
        return 1
    else
        mkdir -p "$DB_PATH/$db_name"
        log $PASS "Database '$db_name' created successfully!"
        return 0
    fi
}

# Function to list all available databases
function list_databases() {
    if [ -d "$DB_PATH" ] && [ "$(ls -A $DB_PATH)" ]; then
        log $INFO "Available Databases:"
        ls -d $DB_PATH/*/ | cut -d'/' -f3
    else
        log $FAIL "No databases found!"
    fi
}

# Function to drop (delete) an existing database
# Prompts for the database name to drop
function drop_database() {
    read -p "Enter database name to drop: " db_name
    
    if [ -d "$DB_PATH/$db_name" ] && [ ! -z $db_name ]; then
        rm -r "$DB_PATH/$db_name"
        log $PASS "Database '$db_name' dropped successfully!"
    else
        log $FAIL "Database '$db_name' does not exist!"
    fi
}

# Function to connect to an existing database
# Prompts for the database name to connect
function connect_database() {
    read -p "Enter database name to connect: " db_name
    
    if [ -d "$DB_PATH/$db_name" ] && [ ! -z $db_name ]; then
        source table_operations.bash $db_name
        #cd "$DB_PATH/$db_name"
        #table_menu
        #cd ../..
    else
        log $FAIL "Database '$db_name' does not exist!"
    fi
}

# Main menu function which displays options and accepts user input
function main_menu() {
    while true; do
        print_header
        echo "  1. Create Database"
        echo "  2. List Databases"
        echo "  3. Connect To Database"
        echo "  4. Drop Database"
        echo "  5. Exit"
        
        read -p "Enter your choice: " choice

        case $choice in
            1) read -p "Enter database name: " db_name; create_database $db_name ;;
            2) list_databases ;;
            3) connect_database ;;
            4) drop_database ;;
            5) log $PASS "Goodbye!"; break ;; 
            *) log $FAIL "Invalid option" ;;
        esac
        
        read -p "Press enter to continue..."
    done
}

# Create the databases directory if it doesn't exist
mkdir -p $DB_PATH

# Run the main menu in a loop to keep the program running
while true; do
    main_menu
done