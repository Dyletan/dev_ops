import yaml
import sys

def generate_acl_commands(acl_file):
    with open(acl_file, 'r') as f:
        config = yaml.safe_load(f)
    
    commands = []
    for acl in config['acls']:
        topic = acl['topic']
        for user in acl['users']:
            principal = f"User:{user['name']}"
            for permission in user['permissions']:
                if permission == 'read':
                    commands.append(f'--add --allow-principal {principal} --operation READ --topic {topic}')
                elif permission == 'write':
                    commands.append(f'--add --allow-principal {principal} --operation WRITE --topic {topic}')
                elif permission == 'admin':
                    commands.append(f'--add --allow-principal {principal} --operation ALL --topic {topic}')
    
    return commands

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python generate_acl_commands.py <acl_file>")
        sys.exit(1)
    
    commands = generate_acl_commands(sys.argv[1])
    for cmd in commands:
        print(cmd)