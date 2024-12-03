import yaml
import os
import sys

def validate_acl_config(config):
    required_fields = ['topic', 'users']
    valid_permissions = {'read', 'write', 'admin'}
    seen_users = set()  # Track duplicate users within a single ACL

    for field in required_fields:
        if field not in config:
            raise ValueError(f"Missing required field: {field}")

    # Validate topic
    if not isinstance(config['topic'], str) or not config['topic'].strip():
        raise ValueError("Topic must be a non-empty string")

    # Validate users and permissions
    if not isinstance(config['users'], list) or not config['users']:
        raise ValueError("Users must be a non-empty list")

    for user in config['users']:
        if 'name' not in user or not user['name'].strip():
            raise ValueError("Each user must have a non-empty name")

        if user['name'] in seen_users:
            raise ValueError(f"Duplicate user '{user['name']}' found")
        seen_users.add(user['name'])

        if 'permissions' not in user or not isinstance(user['permissions'], list) or not user['permissions']:
            raise ValueError(f"User {user['name']} must have a non-empty permissions list")

        invalid_perms = set(user['permissions']) - valid_permissions
        if invalid_perms:
            raise ValueError(f"Invalid permissions for user {user['name']}: {invalid_perms}")

def main():
    acls_dir = 'Task4/acls'
    exit_code = 0

    # Validate each ACL configuration file
    for filename in os.listdir(acls_dir):
        if filename.endswith('.yaml'):
            file_path = os.path.join(acls_dir, filename)
            try:
                with open(file_path, 'r') as f:
                    config = yaml.safe_load(f)
                
                if not config or 'acls' not in config:
                    raise ValueError("Invalid file format: missing 'acls' key")
                
                if not isinstance(config['acls'], list) or not config['acls']:
                    raise ValueError("The 'acls' key must contain a non-empty list")
                
                for acl in config['acls']:
                    validate_acl_config(acl)
                    
                print(f"✓ {filename} is valid")

            except Exception as e:
                print(f"✗ Error in {filename}: {str(e)}", file=sys.stderr)
                exit_code = 1

    sys.exit(exit_code)

if __name__ == "__main__":
    main()