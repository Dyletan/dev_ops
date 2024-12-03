## Functions in `linux_user_management.py`:

1. `is_user_locked(username: str) -> bool`
- Purpose: Checks if a user account is locked.
- Parameters:
  - `username`: The username to check.
- Returns: `True` if the user is locked, `False` otherwise.
- Example: `is_locked = is_user_locked('bob')`

2. `get_users() -> List[Dict[str, Union[str, bool]]]`
- Purpose: Retrieves a list of all non-system users on the Linux system.
- Parameters: None
- Returns: A list of dictionaries, each containing:
  - 'username': The user's login name
  - 'fullname': The user's full name
  - 'locked': Boolean indicating if the account is locked
- Example: `users = get_users()`

3. `create_user(username: str, fullname: str, password: str) -> bool`
- Purpose: Creates a new user account.
- Parameters:
  - `username`: The login name for the new user
  - `fullname`: The full name of the new user
  - `password`: The password for the new user
- Returns: `True` if user creation was successful, `False` otherwise.
- Example: `success = create_user('bob', 'Bob', 'securepass123')`


4. `update_user(username: str, command: str, option: str) -> bool`
- Purpose: Performs various user account modifications.
- Parameters:
  - `username`: The user to modify
  - `command`: The command to run (e.g., 'usermod', 'userdel')
  - `option`: The option for the command (e.g., '-L' for lock, '-U' for unlock)
- Returns: `True` if the operation was successful, `False` otherwise.
- Note: This is a helper function not meant to be called directly.

5. `delete_user(username: str) -> bool`
- Purpose: Deletes a user account.
- Parameters:
  - `username`: The user to delete
  - Returns: `True` if deletion was successful, `False` otherwise.
- Example: `success = delete_user('bob')`

6. `lock_user(username: str) -> bool`
- Purpose: Locks a user account.
- Parameters:
  - `username`: The user to lock
- Returns: `True` if locking was successful, `False` otherwise.
- Example: `success = lock_user('bob')`

7. `unlock_user(username: str) -> bool`
- Purpose: Unlocks a user account.
- Parameters:
  - `username`: The user to unlock
- Returns: `True` if unlocking was successful, `False` otherwise.
- Example: `success = unlock_user('bob')`

## CLI Key Bindings in user_cli_ui.py:

- `↑/↓`: Change the selected user.
- `←/→`: Change page.
- `N`: Create a new user.
- `Backspace`: Delete a user.
- `L`: Lock a user.
- `U`: Unlock a user.
- `Q`: Quit the CLI.