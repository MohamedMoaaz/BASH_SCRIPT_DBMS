#!/bin/bash

# This script provides a simple management system for creating, listing, and dropping tables
# in a simulated database. The database is stored as a collection of text files within a 
# directory structure. Each table has metadata for its columns stored in a separate file.
#
# The main functionalities of the script include:
# 1. Creating a new table: Prompts the user for a table name, the number of columns, 
#    column names, and column data types (integer or string). Also allows the user to 
#    select a primary key for the table.
# 2. Listing existing tables: Displays the list of available tables in the current database.
# 3. Dropping a table: Deletes a specified table and its metadata file from the database.

# Terminal colors for printing messages
FAIL='\033[0;31m'      # Red color for failure messages
PASS='\033[0;32m'      # Green color for success messages
INFO='\033[0;33m'      # Yellow color for informational messages
HEADER='\033[0;34m'    # Blue color for header messages
NONE='\033[0m'         # Reset color to default

# Global variable for database path
DB_PATH="./databases"  # Path where the databases are stored
DB_NAME=$1             # Database name passed as the first argument to the script

# Function to print colored log messages
# Arguments:
#   $1 - Color code (e.g., $FAIL, $PASS, $INFO, $HEADER)
#   $2 - Message to be logged
function log() {
    echo -e "${1}${2}${NONE}"
}

# Function to print a header message and clear the terminal screen
function print_header() {
    clear
    log $HEADER "======================================"
    log $HEADER "     Welcome to Tables Management     "
    log $HEADER "======================================"
}

# Function to check the data type of input
# Arguments:
#   $1 - Input value to be checked
# Returns:
#   - "int" if the input is numeric
#   - "string" if the input is alphanumeric
function check_dt() {
    local input="$1"

    if [[ "$input" =~ ^[0-9]+$ ]]; then
        echo "int"
  
    elif [[ "$input" =~ ^[a-zA-Z0-9]+$ ]]; then
        echo "string"
    else
        echo ""
    fi
}

# Function to create a new table
# The user is prompted for table name, number of columns, column names, and data types.
# A primary key is also selected for the table.
function create_table() {
    while true; do
        read -p "Enter table name: " table_name
        if [[ "$table_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            break
        else
            log $FAIL "Invalid table name! Must start with a letter and contain only letters, numbers, or underscores"
        fi
    done
    
    if [ -f "$DB_PATH/$DB_NAME/$table_name" ]; then
        log $FAIL "Table already exists!"
        return
    fi

    # Validate number of columns
    while true; do
        read -p "Enter number of columns: " col_count
        if [[ "$col_count" =~ ^[0-9]+$ ]] && [ "$col_count" -gt 0 ]; then
            break
        else
            log $FAIL "Please enter a valid positive integer!"
        fi
    done
    
    # Collect column names and store in array
    declare -a col_names
    for ((i=1; i<=col_count; i++)); do
        while true; do
            read -p "Enter column $i name: " col_name
            
            # Validate column name format
            if ! [[ "$col_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
                log $FAIL "Invalid column name! Must start with a letter and contain only letters, numbers, or underscores"
                continue
            fi
            
            # Check for duplicate column names
            duplicate=false
            for ((j=1; j<i; j++)); do
                if [ "${col_names[$j]}" = "$col_name" ]; then
                    log $FAIL "Column name '$col_name' already exists!"
                    duplicate=true
                    break
                fi
            done
            
            # If no duplicates found, store the name and break the loop
            if ! $duplicate; then
                col_names[$i]=$col_name
                break
            fi
        done
    done
    
    # Show primary key selection menu
    clear
    echo -e "\nSelect Primary Key:"
    for ((i=1; i<=col_count; i++)); do
        echo "  $i) ${col_names[$i]}"
    done
    
    while true; do
        read -p "Enter choice [1-$col_count]: " pk_num
        if [[ "$pk_num" =~ ^[0-9]+$ ]] && [ "$pk_num" -ge 1 ] && [ "$pk_num" -le "$col_count" ]; then
            break
        else
            log $FAIL "Invalid choice!"
        fi
    done
    
    # Create table and metadata files
    touch "$DB_PATH/$DB_NAME/$table_name"
    touch "$DB_PATH/$DB_NAME/.$table_name"
    
    # Get column types and write to metadata file
    for ((i=1; i<=col_count; i++)); do
        clear
        echo -e "\nSelect type for column '${col_names[$i]}':"
        echo "  1) integer"
        echo "  2) string"
        
        while true; do
            read -p "Enter choice [1-2]: " type_choice
            case $type_choice in
                1) col_type="int"; break ;;
                2) col_type="string"; break ;;
                *) log $FAIL "Invalid choice!" ;;
            esac
        done
        
        # Write to metadata file with PK marker if applicable
        if [ "$i" -eq "$pk_num" ]; then
            echo "${col_names[$i]}:$col_type:PK" >> "$DB_PATH/$DB_NAME/.$table_name"
        else
            echo "${col_names[$i]}:$col_type:" >> "$DB_PATH/$DB_NAME/.$table_name"
        fi
    done
    
    log $PASS "Table '$table_name' created successfully!"
}

# Function to list all existing tables in the current database
function list_tables() {
    if [ -d "$DB_PATH/$DB_NAME" ] && [ "$(ls -A $DB_PATH/$DB_NAME/)" ]; then
        log $INFO "Available Tables:"
        ls $DB_PATH/$DB_NAME/
    else
        log $FAIL "No Tables found!"
    fi
}

# Function to drop a table
# The user is prompted for the table name to be dropped. If the table exists, it is deleted.
function drop_table() {
    read -p "Enter table name to drop: " tb_name
	
    if [ -f "$DB_PATH/$DB_NAME/$tb_name" ] && [ ! -z $tb_name ] ; then
        rm "$DB_PATH/$DB_NAME/$tb_name" "$DB_PATH/$DB_NAME/.$tb_name" 
        log $PASS "Table '$tb_name' dropped successfully!"
    else
        log $FAIL "Table '$tb_name' does not exist!"
    fi
}


function insert_into_table() {
    # Prompts the user to enter the table name to insert data into
    read -p "Enter table name to insert: " tb_name 

    # Checks if the table exists and is not a directory
    if [ -e "$DB_PATH/$DB_NAME/$tb_name" ] && [ ! -d "$DB_PATH/$DB_NAME/$tb_name" ] ; then
        echo "The table columns are: $(cat $DB_PATH/$DB_NAME/.$tb_name | cut -d':' -f 1 | xargs)" 
        insert_line=""
        declare -i pk_filed
        pk_filed=0
        
        # Iterates over each column in the table
        for var in $(cat $DB_PATH/$DB_NAME/.$tb_name | cut -d":" -f 1) ;
        do 
            pk_filed=pk_filed+1
            is_pk=$(grep $var $DB_PATH/$DB_NAME/.$tb_name | cut -d":" -f 3)
            data_type=$(grep $var $DB_PATH/$DB_NAME/.$tb_name | cut -d":" -f2)
            
            # Prompts the user to enter data for each column
            read -p "Enter the Column $var value  [$data_type] $is_pk :" col_data
            while true; do
                # Checks if the table is empty
                if [ -z "$(cat $DB_PATH/$DB_NAME/$tb_name)" ]; then
                    check_data_type=$(check_dt $col_data)
                    
                    # Validates the data type
                    if [ "$check_data_type" = "$data_type" ] || ([[ "$data_type" == 'string' ]] && [[ "$check_data_type" = 'int' ]]); then 
                        insert_line+=:$col_data
                        log $PASS "$var has been recorded"
                        break;
                    else	
                        log $FAIL "Invalid data type. Enter $data_type type"
                        read -p "Enter the Column $var value $is_pk :" col_data
                        continue;
                    fi
                    
                else
                    check_data_type=$(check_dt $col_data)
                    
                    # Validates the data type
                    if [ "$check_data_type" = "$data_type" ] || ([[ "$data_type" == 'string' ]] && [[ "$check_data_type" = 'int' ]]); then 
                        # Checks if the column is a primary key
                        if [ "$is_pk" = "PK" ]; then
                            declare -i counter=0
                            for val in `(cat $DB_PATH/$DB_NAME/$tb_name | cut -d":" -f $pk_filed)`; do
                                if [ "$val" = "$col_data" ] ; then
                                    counter=counter+1
                                fi
                            done
                            if [ $counter -eq 0 ]; then 
                                insert_line+=:$col_data
                                log $PASS "$var has been recorded"
                                break
                            else
                                log $FAIL "Primary key violation"
                                read -p "Enter the Column $var value $is_pk :" col_data
                                continue
                            fi
                        else
                            insert_line+=:$col_data
                            log $PASS "$var has been recorded"
                            break;
                        fi
                    else
                        log $FAIL "Invalid data type. Enter $data_type type"
                        read -p "Enter the Column $var value $is_pk :" col_data
                        continue
                    fi		
                fi
            done
        done
        echo ${insert_line:1} >> $DB_PATH/$db_name/$tb_name
    else 
        log $FAIL "Table does not exist"
    fi
}

function select_from_table() {
    # Prompts the user to enter the table name to select data from
    read -p "Enter table name to select: " tb_name 

    # Checks if the table exists and is not a directory
    if [ -e "$DB_PATH/$DB_NAME/$tb_name" ] && [ ! -d "$DB_PATH/$DB_NAME/$tb_name" ] ; then
        while true; do
            echo "  1. Select All"
            echo "  2. Select specific row"
            echo "  3. Select specific column"
            echo "  4. Exit"
            read -p "Enter your choice: " select_choice

            case $select_choice in
                1) 
                # Displays all rows in the table
                log $PASS "-------------------------------------------"
                echo "$(cat $DB_PATH/$DB_NAME/.$tb_name | cut -d':' -f 1 | xargs | sed 's/ /:/g')"
                log $PASS "-------------------------------------------"
                cat $DB_PATH/$DB_NAME/$tb_name
                log $PASS "-------------------------------------------"
                ;;
                2) 
                # Prompts the user to enter the primary key value to select a specific row
                read -p "Where PK is " pk 
                log $PASS "-------------------------------------------"
                echo "$(cat $DB_PATH/$DB_NAME/.$tb_name | cut -d':' -f 1 | xargs | sed 's/ /:/g')" 
                log $PASS "-------------------------------------------"
                if [ -z $(grep "$pk:" $DB_PATH/$DB_NAME/$tb_name) ]; then
                    log $INFO "NO DATA FOUND FOR PK $pk"
                else
                    grep "$pk:" $DB_PATH/$DB_NAME/$tb_name
                fi
                log $PASS "-------------------------------------------"
                ;;
                3)  
                # Prompts the user to enter the column name to select a specific column
                echo "$(cat $DB_PATH/$DB_NAME/.$tb_name | cut -d':' -f 1 | xargs | sed 's/ /:/g')" 
                log $PASS "-------------------------------------------"
                read -p "What column do you need: " column
                log $PASS "-------------------------------------------"
                field_num=$(grep -n "^$column" $DB_PATH/$DB_NAME/.$tb_name | cut -d':' -f1)
                if [ -z $field_num ]; then 
                    log $FAIL "Column not found"
                else 
                    cut -d':' -f"$field_num" $DB_PATH/$DB_NAME/$tb_name
                fi
                ;;
                4) 
                # Exits the selection menu
                log $PASS "Goodbye!"
                break 
                ;; 
                *) 
                # Handles invalid options
                log $FAIL "Invalid option" 
                ;;
            esac
            read -p "Press enter to continue..."
        done
    else 
        log $FAIL "Table does not exist"
    fi
}

function delete_from_table() {
    # Prompts the user to enter the table name to delete data from
    read -p "Enter table name to select: " tb_name 

    # Checks if the table exists and is not a directory
    if [ -e "$DB_PATH/$DB_NAME/$tb_name" ] && [ ! -d "$DB_PATH/$DB_NAME/$tb_name" ] ; then
        while true; do
            echo "  1. Delete All"
            echo "  2. Delete specific row"
            echo "  3. Delete specific column"
            echo "  4. Exit"
            read -p "Enter your choice: " select_choice

            case $select_choice in
                1) 
                # Deletes all data in the table
                sed -i '1,$d' $DB_PATH/$DB_NAME/$tb_name
                log $PASS "All Data Deleted"
                ;;
                2) 
                # Prompts the user to enter the primary key value to delete a specific row
                read -p "Where PK is " pk 
                sed -i "/$pk:/d" $DB_PATH/$DB_NAME/$tb_name
                log $PASS "Row with primary key $pk deleted"
                ;;
                3)  
                # Prompts the user to enter the column name to delete a specific column
                echo "$(cat $DB_PATH/$DB_NAME/.$tb_name | cut -d':' -f 1 | xargs | sed 's/ /:/g')" 
                log $PASS "-------------------------------------------"
                read -p "What column do you need to delete: " column
                if [ -n "$column" ] ; then
                    field_num=$(grep -n "^$column" $DB_PATH/$DB_NAME/.$tb_name | cut -d':' -f1)
                    if [ -z "$field_num" ] ; then 
                        log $FAIL "Column not found"
                    else 
                        is_pk=$(grep -n "^$column" $DB_PATH/$DB_NAME/.$tb_name | cut -d':' -f4)
                        if [ "$is_pk" != "PK" ]; then
                            awk -F':' -v col="$field_num" '{
                                line = ""
                                for (i = 1; i <= NF; i++) {
                                    if (i != col) line = line $i ":"
                                }
                                # Remove the last colon
                                line = substr(line, 1, length(line) - 1)
                                print line
                            }' "$DB_PATH/$DB_NAME/$tb_name" > temp_file && mv temp_file "$DB_PATH/$DB_NAME/$tb_name"
                            sed -i "/^$column:/d" $DB_PATH/$DB_NAME/.$tb_name
                            log $PASS "The column $column deleted"
                        else 
                            log $FAIL "You can't drop PK Column"
                        fi
                    fi
                else
                    log $FAIL "Enter valid column name"
                fi
                ;;
                4) 
                # Exits the deletion menu
                log $PASS "Goodbye!"
                break 
                ;; 
                *) 
                # Handles invalid options
                log $FAIL "Invalid option" 
                ;;
            esac
            read -p "Press enter to continue..."
        done
    else 
        log $FAIL "Table does not exist"
    fi
}

function update_table() {
    # Prompts the user to enter the table name to update data in
    read -p "Enter table name to select: " tb_name 

    # Checks if the table exists and is not a directory
    if [ -e "$DB_PATH/$DB_NAME/$tb_name" ] && [ ! -d "$DB_PATH/$DB_NAME/$tb_name" ] ; then
        # Displays the table columns
        log $PASS "---------------------------" 
        log $PASS "The table columns are: $(cat $DB_PATH/$DB_NAME/.$tb_name | cut -d':' -f 1 | xargs | sed 's/ /:/g')"
        
        # Gets the primary key column name
        pk_name=$(grep -i ":PK" $DB_PATH/$DB_NAME/.$tb_name | cut -d ':' -f 1)
        read -p "Enter [column $pk_name [PK]] value for the row you want to update: " update_row
        
        # Gets the primary key column number
        PK_column_number=$(grep -in ":PK" $DB_PATH/$DB_NAME/.$tb_name | cut -d ':' -f 1)
        
        # Gets the row number to update
        row_number=$(awk -F':' -v pk="$update_row" pk_col="$PK_column_number"' { if ( $(pk_col) == pk) print NR}' "$DB_PATH/$DB_NAME/$tb_name")

        while true; do
            if [ -n "$row_number" ] ; then
                col_name=($(awk -F':' '{print $1}' "$DB_PATH/$DB_NAME/.$tb_name"))
                break_flag="0"
                
                while true ; do
                    if [ "$break_flag" != 0 ]; then 
                        break
                    fi
                    read -p "PRESS EXIT || which column you want to update: " column
                    for col in "${col_name[@]}"; do
                        if [[ "$column" == "$col" ]] || [[ "exit" =~ $column ]]; then
                            break_flag="1"
                            break
                        else
                            continue
                        fi
                    done
                    if [ "$break_flag" = 0 ]; then 
                        log $FAIL "Invalid column name"
                    fi
                done
                
                if [[ $column = $pk_name ]]; then
                    log $FAIL "Can't update the Primary key"
                    continue
                fi
                shopt -s nocasematch
                if [[ "exit" =~ $column ]]; then
                    shopt -u nocasematch
                    break
                fi
                field_number=$(awk -F':' -v column="$column" ' { if ($1 == column) print NR}' "$DB_PATH/$DB_NAME/.$tb_name")
                
                old_val=$(sed -n "$row_number p" $DB_PATH/$DB_NAME/$tb_name | cut -d':' -f "$field_number")
                echo "The old value is: $old_val"
                data_type=$(grep -i "$column:" $DB_PATH/$DB_NAME/.$tb_name | cut -d ':' -f 2)
                
                while true; do
                    read -p "The new value is (make sure to enter [$data_type] data): " new_val
                    
                    if [ "$(check_dt $new_val)" = "$data_type" ] || ([[ "$data_type" == 'string' ]] && [[ "$(check_dt $new_val)" = 'int' ]]); then
                        awk -F':' -v R_N="$row_number" -v OV="$old_val" -v NV="$new_val" -v FN="$field_number" '{
                            if (NR == R_N) {
                                if ($FN == OV) $FN = NV  # Replace the value in the specific field
                            }
                            # Reassemble the line dynamically
                            new_line = $1
                            for (i = 2; i <= NF; i++) {
                                new_line = new_line ":" $i
                            }
                            print new_line
                        }' "$DB_PATH/$DB_NAME/$tb_name" > temp_file && mv temp_file "$DB_PATH/$DB_NAME/$tb_name"
                        break
                    else
                        log $FAIL "Wrong data type"
                    fi
                done
            else
                log $FAIL "Primary key value does not exist"
                break
            fi
        done
    else
        log $FAIL "Invalid Table"
    fi
}

function main_menu() {
    while true; do
        print_header
        echo "  1. Create Table"
        echo "  2. List Tables"
        echo "  3. Drop Table"
        echo "  4. Insert Into Table"
        echo "  5. Select From Table"
        echo "  6. Delete From Table"
        echo "  7. Update Table"
        echo "  8. Exit"
        
        read -p "Enter your choice: " choice

        case $choice in
            1) create_table $tb_name ;;
            2) list_tables ;;
            3) drop_table ;;
            4) insert_into_table ;;
            5) select_from_table ;;
            6) delete_from_table ;;
            7) update_table ;;
            8) log $PASS "Goodbye!"; break ;; 
            *) log $FAIL "Invalid option" ;;
        esac
        read -p "Press enter to continue..."
    done
}

mkdir -p $DB_PATH
main_menu