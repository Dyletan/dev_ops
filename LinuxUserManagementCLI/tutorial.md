## Tutorial: Getting Started with the User Management CLI

This tutorial will guide you through setting up and running the User Management CLI to manage Linux users.

### Step 1: Install Dependencies
Ensure you have Python3 and the `blessed` package installed. You can install it with:
```bash
pip install blessed
```

### Step 2: Download the script
1. On the main page of this repository press on green button "Code" and select "Download ZIP". 
2. After installation unzip it to any directory

### Step 3: Run the CLI
Run the user management CLI by executing:
```bash
cd $DIRECTORY
python3 linux_cli_ui.py
```
instead of $DIRECTORY provide the directory where linux_cli_ui.py is stored

### Step 4: Navigating the CLI
- Use the arrow keys `↑/↓` to scroll through the users.
- Press `←/→` to change pages.
- Press `N` to create a new user.
1. Provide the username (can't be blank and same as other usernames).
2. Provide the fullname (optional).
3. Provide password (can't be blank).
- Press `Backspace` to delete a user.
1. Press `Y` to proceed and anything else to cancel.
- Press `L` to lock a user and `U` to unlock a user.
- Press `Q` to quit.