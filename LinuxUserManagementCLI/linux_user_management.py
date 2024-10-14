import subprocess
import pwd

def is_user_locked(username):
    try:
        output = subprocess.check_output(['sudo', 'passwd', '-S', username], stderr=subprocess.DEVNULL).decode()
        return 'L' in output.split()[1]
    except subprocess.CalledProcessError:
        return False
    
def get_users():
    users = []
    for user in pwd.getpwall():
        if user.pw_uid >= 1000 and user.pw_uid < 65534: # to not display weird users
            users.append({
                'username': user.pw_name,
                'fullname': user.pw_gecos.split(',')[0],
                'locked': is_user_locked(user.pw_name)
            })
    return users

def create_user(username, fullname, password):
    if not password:
        return False
    try:
        subprocess.run(['sudo', 'useradd', '-m', '-c', fullname, '-p', password, username], check=True)
        return True
    except subprocess.CalledProcessError:
        return False

def update_user(username, command, option):
    try:
        subprocess.run(['sudo', f'{command}', f'-{option}', username], check=True)
        return True
    except subprocess.CalledProcessError as e:
        return False

def delete_user(username):
    return update_user(username, 'userdel', 'r')

def lock_user(username):
    return update_user(username, 'usermod', 'L')

def unlock_user(username):
    return update_user(username, 'usermod', 'U')
