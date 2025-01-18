Tables Management System

Overview

This script allows for the management of database tables through a command-line interface. It provides functionalities to create, update, delete, and query tables stored in a file-based database system.

Features

Create Table

Allows the user to define a new table with a specified name, number of columns, column names, and data types.

Supports primary key selection for a table.

List Tables

Displays all tables in the current database directory.

Drop Table

Deletes an existing table and its metadata from the database.

Insert Data

Inserts rows of data into an existing table.

Validates data types and enforces primary key constraints.

Select Data

Allows querying of table data, including:

Selecting all rows.

Selecting specific rows by primary key.

Selecting specific columns.

Delete Data

Deletes:

All rows in a table.

Specific rows based on primary key.

Specific columns, excluding primary key columns.

Update Data

Updates specific columns of a row identified by the primary key.

Requirements

Bash shell

Basic knowledge of command-line operations

Installation

Clone the repository:

git clone <repository-url>

Navigate to the project directory:

cd <repository-directory>

Set execute permissions for the script:

chmod +x <script-name>.sh

Usage

Run the script and pass the database name as an argument:

./<script-name>.sh <database-name>

Available Options

Create Table: Creates a new table in the specified database.

List Tables: Lists all tables in the database.

Drop Table: Deletes a table from the database.

Insert Data: Adds new rows to a table.

Select Data: Queries data from a table.

Delete Data: Deletes rows or columns from a table.

Update Data: Updates specific rows and columns in a table.

Directory Structure

./databases
   |-- <database-name>
       |-- <table-name>        # Data for the table
       |-- .<table-name>       # Metadata for the table

Log Messages

FAIL: Indicates an error or invalid operation (Red).

PASS: Indicates a successful operation (Green).

INFO: Provides informational messages (Yellow).

HEADER: Displays header messages (Blue).

Known Limitations

Does not support advanced querying with conditions.

Data types are limited to int and string.

Deleting specific columns cannot remove primary key columns.

Future Enhancements

Add support for advanced querying (e.g., WHERE clauses).

Introduce more data types and validations.

Implement user authentication for database access.

Improve error handling and add unit tests.

Contribution

Feel free to fork this repository and submit pull requests for new features or bug fixes. Contributions are welcome!

License

This project is licensed under the MIT License. See the LICENSE file for details.

