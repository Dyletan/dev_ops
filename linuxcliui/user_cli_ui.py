import blessed
import sys
import os
import math
from linux_user_management import *

class UserManagementCLI:
    USERS_PER_PAGE = 5
    INSTRUCTIONS = "↑/↓: Change selected User | ←/→: Change page | N: New user | Backspace: Delete | L: Lock | U: Unlock | Q: Quit"

    def __init__(self):
        # set up everything and assign default values
        self.term = blessed.Terminal()
        self.users = get_users()
        self.page = 1
        self.cur_index = 0
        self.message = ""
        self.update_pagination()

    def update_pagination(self):
        self.num_pages = math.ceil(len(self.users) / self.USERS_PER_PAGE)

    def draw(self):
        # everything realed to terminal display must be done through print()
        print(self.term.clear)
        self.draw_table_header()
        self.draw_user_list()
        self.draw_message()
        self.draw_instructions()
        self.draw_page_info()

    def draw_table_header(self):
        print(self.term.aqua + self.term.bold(f"{'#':<5}{'Username':<20}{'Full Name':<30}{'Locked':<10}") + self.term.normal)

    def draw_user_list(self):
        start_index = (self.page - 1) * self.USERS_PER_PAGE
        # to prevent going out of bounds
        end_index = min(start_index + self.USERS_PER_PAGE, len(self.users))
        users_on_this_page = self.users[start_index:end_index]
        for idx, user in enumerate(users_on_this_page):
            is_locked = 'Yes' if user['locked'] else 'No'
            line = f"{idx+1+start_index:<5}{user['username']:<20}{user['fullname']:<30}{is_locked:<10}"
            if idx + start_index == self.cur_index:
                # highlight on select
                print(self.term.black_on_white(line))
            else:
                print(line)

    def draw_message(self):
        print(self.term.move_y(self.term.height - 6) + self.message)

    def draw_instructions(self):
        print(self.term.orchid2 + self.term.move_y(self.term.height - 3) + self.INSTRUCTIONS + self.term.normal) 

    def draw_page_info(self):
        print(self.term.move_xy(self.term.width//2, self.term.height - 2) + f"Page {self.term.peru}{self.page}/{self.num_pages}{self.term.normal}")
            
    def get_input(self, prompt, hide=False):
        # clear the line and display prompt
        print(self.term.move_y(self.term.height - 6) + self.term.clear_eol + self.term.steelblue1 + prompt + self.term.normal, end='', flush=True)
        user_input = []
        while True:
            char = self.term.inkey()
            if char.name == 'KEY_ENTER':
                # move to new line
                print()
                # convert array of chars into str
                return ''.join(user_input)
            elif char.name == 'KEY_BACKSPACE':
                if user_input:
                    user_input.pop()
                    # to erase a character
                    print('\b \b', end='', flush=True)
            # append if a normal character        
            elif not char.is_sequence:
                user_input.append(char)
                print('*' if hide else char, end='', flush=True)

    def add_user(self):
        username = self.get_input("Enter username: ")
        fullname = self.get_input("Enter full name: ")
        password = self.get_input("Enter password: ", hide=True)
        
        if create_user(username, fullname, password):
            self.message = f"{self.term.forestgreen}User {username} created.{self.term.normal}"
        else:
            self.message = f"{self.term.firebrick3}Failed to create user {username}.{self.term.normal}"

    def delete_user(self):
        user = self.users[self.cur_index]
        confirm = self.get_input(f"{self.term.orange}Are you sure you want to delete {user['username']}? (y/n):{self.term.normal} ")

        if confirm.lower() == 'y':
            if delete_user(user['username']):
                self.message = f"{self.term.forestgreen}User {user['username']} deleted.{self.term.normal}"
            else:
                self.message = f"{self.term.firebrick3}Failed to delete user {user['username']}.{self.term.normal}"
        else:
            self.message = "Deletion cancelled."

    def lock_user(self):
        user = self.users[self.cur_index]
        if lock_user(user['username']):
            self.message = f"{self.term.forestgreen}User {user['username']} locked.{self.term.normal}"
        else:
            self.message = f"{self.term.firebrick3}Failed to lock user {user['username']}.{self.term.normal}"         

    def unlock_user(self):
        user = self.users[self.cur_index]
        if unlock_user(user['username']):
            self.message = f"{self.term.forestgreen}User {user['username']} unlocked.{self.term.normal}"
        else:
            self.message = f"{self.term.firebrick3}Failed to unlock user {user['username']}.{self.term.normal}"
            
    def move(self, direction):
        new_index = self.cur_index + direction
        head_of_page = (self.page - 1) * self.USERS_PER_PAGE
        bottom_of_page = self.page * self.USERS_PER_PAGE
        if new_index < head_of_page:
            self.change_page(-1)
        elif new_index >= bottom_of_page:
            self.change_page(1)
        else:
            self.cur_index = new_index

    def change_page(self, direction):
        new_page = self.page + direction
        if 1 <= new_page <= self.num_pages:
            self.page = new_page
            self.cur_index = (self.page - 1) * self.USERS_PER_PAGE
            
    def handle_input(self, key):
        if key.lower() == 'q':
            return False
        elif key.name == 'KEY_DOWN':
            self.move(1)
        elif key.name == 'KEY_UP':
            self.move(-1)
        elif key.name == 'KEY_RIGHT':
            self.change_page(1)
        elif key.name == 'KEY_LEFT':
            self.change_page(-1)
        elif key.name == 'KEY_BACKSPACE':
            self.delete_user()
        elif key.lower() == 'n':
            self.add_user()
        elif key.lower() == 'l':
            self.lock_user()
        elif key.lower() == 'u':
            self.unlock_user()
        return True
    
    def refresh_users(self):
        self.users = get_users()
        self.update_pagination()
        if self.cur_index >= len(self.users):
            self.cur_index = len(self.users) - 1
    
    def run(self):
        with self.term.fullscreen(), self.term.cbreak(), self.term.hidden_cursor():
            while True:
                self.draw()
                if not self.handle_input(self.term.inkey()):
                    break
                self.refresh_users()

def main():
    if os.geteuid() != 0:
        print("This script must be run with sudo privileges.")
        sys.exit(1)
    
    cli = UserManagementCLI()
    cli.run()

if __name__ == "__main__":
    main()