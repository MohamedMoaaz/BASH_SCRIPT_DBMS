# 🗃️ Tables Management System

A simple bash-based command-line interface for managing database tables using a file-based storage system.

## 📌 Overview

This script provides full table management operations including creation, update, deletion, and querying. It's designed for educational or lightweight database simulation use cases.

## ✨ Features

### 📁 Create Table
- Define a new table with a name, column count, column names, and data types.
- Choose a primary key for the table.

### 📋 List Tables
- View all existing tables in the selected database.

### 🗑️ Drop Table
- Remove a table and its metadata.

### ➕ Insert Data
- Add rows to an existing table.
- Validates data types and ensures primary key uniqueness.

### 🔍 Select Data
- Select all rows.
- Select rows by primary key.
- Select specific columns.

### ❌ Delete Data
- Delete all rows from a table.
- Delete specific rows by primary key.
- Delete columns (excluding primary key columns).

### 🛠️ Update Data
- Update specific columns for a row using the primary key.

## 🧰 Requirements
- Bash Shell
- Basic command-line knowledge

## 🚀 Installation

```bash
git clone <repository-url>
cd <repository-directory>
chmod +x <script-name>.sh
```

## 🖥️ Usage

```bash
./<script-name>.sh <database-name>
```

### Menu Options
- Create Table
- List Tables
- Drop Table
- Insert Data
- Select Data
- Delete Data
- Update Data

## 📂 Directory Structure

```
./databases
  └── <database-name>
      ├── <table-name>        # Data for the table
      └── .<table-name>       # Metadata for the table
```

## 📣 Log Messages

- ✅ `PASS`: Successful operations (Green)
- ❌ `FAIL`: Errors or invalid operations (Red)
- ℹ️ `INFO`: Informational messages (Yellow)
- 📌 `HEADER`: Section headers (Blue)

## ⚠️ Known Limitations

- No support for `WHERE` clause or advanced querying
- Supports only `int` and `string` data types
- Cannot delete primary key columns

## 🔮 Future Enhancements

- Add conditional queries (e.g., WHERE support)
- Expand data type support
- Add user authentication
- Improve error handling and implement unit tests

## 🤝 Contribution

Contributions are welcome!  
Fork this repository and submit pull requests for bug fixes or new features.

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.
